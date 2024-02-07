// controllers/userController.js
const jwt = require('jsonwebtoken'); 
const bcrypt = require('bcrypt');
const User = require('../models/userModel');
const  nodemailer = require("nodemailer");
const  crypto= require("crypto");

const registerUser = async (req, res) => {
  const { nom, prenom, telephone, email, password, confirmPassword } = req.body;

  try {
    // Check if a user with the same email already exists
    const existingUser = await User.findOne({ email });

    if (existingUser) {
      // User with the same email already exists
      return res.status(400).json({ message: 'User with this email already exists' });
    }

    // Check if passwords match
    if (password !== confirmPassword) {
      return res.status(400).json({ message: 'Passwords do not match' });
    }

    // Hash the password before saving it
    const hashedPassword = await bcrypt.hash(password, 10);

    // Create a new user with the hashed password
    const newUser = new User({
      nom,
      prenom,
      telephone,
      email,
      password: hashedPassword,
      
    });

    // Save the user to the database
    await newUser.save();

    res.status(201).json({ message: 'User registered successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Internal server error' });
  }
};
const loginUser = async (req, res) => {
  const { email, password } = req.body;

  try {
    // Recherche de l'utilisateur dans la base de données
    const user = await User.findOne({ email });

    if (!user) {
      // L'utilisateur n'existe pas
      return res.status(401).json({ message: 'Invalid email or password' });
    }

    // Vérification du mot de passe
    const passwordMatch = await bcrypt.compare(password, user.password);

    if (!passwordMatch) {
      // Mot de passe incorrect
      return res.status(401).json({ message: 'Invalid email or password' });
    }

    // Création d'un jeton JWT
    const token = jwt.sign(
      { userId: user._id, email: user.email ,nom: user.nom},
      'your-secret-key', // Remplacez par une clé secrète plus sécurisée dans un environnement de production
      { expiresIn: '1h' } // Durée de validité du jeton (1 heure dans cet exemple)
    );

    res.status(200).json({ token, userId: user._id,nom: user.nom, message: 'Login successful' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Internal server error' });
  }
};
const reset_password = async (req, res) => {
  const { email } = req.body;

  try {
    // Recherche de l'utilisateur dans la base de données
    const user = await User.findOne({ email });

    if (!user) {
      // L'utilisateur n'existe pas
      return res.status(404).json({ message: 'Utilisateur non trouvé.' });
    }

    // Générer un nouveau code de validation aléatoire à 6 chiffres
    const validationCode = Math.floor(100000 + Math.random() * 900000).toString();

    // Debugging: Log the generated validation code
    console.log('Generated Validation Code:', validationCode);

    // Update the user object with the new validation code
    user.validationCode = validationCode;
    user.validationCodeTimestamp = Date.now();

    // Save the user object with the new validation code
    await user.save();

    const transporter = nodemailer.createTransport({
      service: 'Gmail',
      auth: {
        user: 'yakinebenali5@gmail.com',
        pass: 'gqyi qqac kxxz qqrn',
      },
    });

    // Envoyer le code de validation par e-mail
    const mailOptions = {
      from: '', // Put your email address here
      to: email,
      subject: 'Code de validation',
      text: `Votre code de validation est : ${validationCode}`,
      replyTo: email,
    };

    transporter.sendMail(mailOptions, (error, info) => {
      if (error) {
        console.error(error);
        res.status(500).json({ success: false, message: 'Email not sent' });
      } else {
        console.log('Email sent successfully: ' + info.response);
        res.json({ success: true, message: 'Email sent successfully' });
      }
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, message: 'Erreur lors de la génération du code de validation.' });
  }
};


// Function to validate the code
// Function to validate the code
const validate_code = async (req, res) => {
  const { email, validationCode } = req.body;

  try {
    // Recherche de l'utilisateur dans la base de données
    const user = await User.findOne({ email });

    if (!user) {
      // L'utilisateur n'existe pas
      return res.status(404).json({ success: false, message: 'Utilisateur non trouvé.' });
    }

    // Debugging: Log the validation codes for comparison
    console.log('Stored Validation Code:', user.validationCode);
    console.log('Entered Validation Code:', validationCode);

    // Check if the validation code is correct
    if (user.validationCode !== validationCode) {
      return res.status(400).json({ success: false, message: 'Code de validation incorrect.' });
    }

    // Check if the validation code has expired (more than 1 minute old)
    const currentTime = Date.now();
    const codeExpirationTime = user.validationCodeTimestamp + 1 * 60 * 1000; // 1 minute in milliseconds

    if (currentTime > codeExpirationTime) {
      return res.status(400).json({ success: false, message: 'Code de validation expiré.' });
    }

    // Reset validation code and timestamp in the database
    user.validationCode = null;
    user.validationCodeTimestamp = null;
    await user.save();

    // Perform further actions for password reset...
    // For example, you can render a password reset form for the user to input a new password.

    res.json({ success: true, message: 'Code de validation valide.' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, message: 'Erreur lors de la validation du code.' });
  }
};
// ...

// ...

const new_password = async (req, res) => {
  const { newPassword, confirmNewPassword } = req.body;
  const userEmail = req.query.email || req.body.email;

  try {
    // Vérifier si l'utilisateur existe
    const existingUser = await User.findOne({ email: userEmail });

    if (!existingUser) {
      // User not found
      return res.status(404).json({ success: false, message: 'User not found.' });
    }

    // Validate the new password
    if (newPassword !== confirmNewPassword) {
      return res.status(400).json({ success: false, message: 'Passwords do not match.' });
    }

    // Hash the new password before saving it
    const hashedPassword = await bcrypt.hash(newPassword, 10);

    // Update the user's password with the hashed password
    existingUser.password = hashedPassword;

    // Save the updated user object
    await existingUser.save();

    res.json({ success: true, message: 'Password updated successfully.' });
  } catch (error) {
    console.error(error);

    // Handle different types of errors
    if (error.name === 'MongoError' && error.code === 11000) {
      // Duplicate key error (e.g., unique constraint violation)
      return res.status(400).json({ success: false, message: 'Duplicate key error.' });
    }

    // Handle other errors
    res.status(500).json({ success: false, message: 'Error updating password.' });
  }
};

// ...


// ...

const getUser = async (req, res) => {
  try {
    // For simplicity, assuming you have only one user in the database
    const user = await User.findOne();

    if (user) {
      // Return user data as JSON
      res.json(user);
    } else {
      // If no user is found, return a 404 status
      res.status(404).json({ message: 'User not found' });
    }
  } catch (error) {
    console.error(error);
    // Return a 500 status for server errors
    res.status(500).json({ message: 'Internal server error' });
  }
};
const updateUser = async (req, res) => {
  const {  nom, prenom, telephone } = req.body;

  const userEmail = req.query.email; // Utiliser le paramètre de requête pour l'email

  try {
    // Vérifier si l'utilisateur existe
    const existingUser = await User.findOne({ email: userEmail });

    if (!existingUser) {
      // L'utilisateur n'existe pas
      return res.status(404).json({ message: 'User not found' });
    }

    // Mettre à jour uniquement les champs spécifiés (nom, prenom, telephone)
    if (nom) {
      existingUser.nom = nom;
    }
    if (prenom) {
      existingUser.prenom = prenom;
    }
    if (telephone) {
      existingUser.telephone = telephone;
    }

    // Sauvegarder les modifications
    await existingUser.save();

    res.status(200).json({ message: 'User updated successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

module.exports = {
  registerUser,
  loginUser,
  reset_password,
  validate_code,
  new_password,
  getUser,
  updateUser,
};