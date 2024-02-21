// controllers/userController.js
const jwt = require('jsonwebtoken'); 
const bcrypt = require('bcrypt');
const User = require('../models/userModel');
const  nodemailer = require("nodemailer");

const  crypto= require("crypto");
const GeocodedAd=require ('../models/AdresseModel');
const axios = require('axios');
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
      { expiresIn: '7d' } // Durée de validité du jeton (1 heure dans cet exemple)
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




const validate_code = async (req, res) => {
  const { email, validationCode } = req.body;

  try {
  
    const user = await User.findOne({ email });

    if (!user) {
   
      return res.status(404).json({ success: false, message: 'Utilisateur non trouvé.' });
    }

   
    console.log('Stored Validation Code:', user.validationCode);
    console.log('Entered Validation Code:', validationCode);


    if (user.validationCode !== validationCode) {
      return res.status(400).json({ success: false, message: 'Code de validation incorrect.' });
    }

   
    const currentTime = Date.now();
    const codeExpirationTime = user.validationCodeTimestamp + 1 * 60 * 1000; 

    if (currentTime > codeExpirationTime) {
      return res.status(400).json({ success: false, message: 'Code de validation expiré.' });
    }

    user.validationCode = null;
    user.validationCodeTimestamp = null;
    await user.save();

    res.json({ success: true, message: 'Code de validation valide.' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, message: 'Erreur lors de la validation du code.' });
  }
};

const new_password = async (req, res) => {
  const { newPassword, confirmNewPassword } = req.body;
  const userEmail = req.query.email || req.body.email;

  try {

    const existingUser = await User.findOne({ email: userEmail });

    if (!existingUser) {
    
      return res.status(404).json({ success: false, message: 'User not found.' });
    }


    if (newPassword !== confirmNewPassword) {
      return res.status(400).json({ success: false, message: 'Passwords do not match.' });
    }

    
    const hashedPassword = await bcrypt.hash(newPassword, 10);

    existingUser.password = hashedPassword;

    await existingUser.save();

    res.json({ success: true, message: 'Password updated successfully.' });
  } catch (error) {
    console.error(error);

   
    if (error.name === 'MongoError' && error.code === 11000) {
    
      return res.status(400).json({ success: false, message: 'Duplicate key error.' });
    }

   
    res.status(500).json({ success: false, message: 'Error updating password.' });
  }
};


const getUser = async (req, res) => {
 
  try{
 
  const user = await User.findOne();

  if (user) {
    res.json(user);
  } else {
    res.status(404).json({ message: 'User not found' });
  }
} catch (error) {
  console.error(error);
  res.status(500).json({ message: 'Internal server error' });
}
};
const updateUser = async (req, res) => {
  const {  nom, prenom, telephone } = req.body;

  const userEmail = req.query.email;
  try {
 
    const existingUser = await User.findOne({ email: userEmail });

    if (!existingUser) {
 
      return res.status(404).json({ message: 'User not found' });
    }

    
    if (nom) {
      existingUser.nom = nom;
    }
    if (prenom) {
      existingUser.prenom = prenom;
    }
    if (telephone)
 {
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


const searchAddress = async (req, res) => {
  const { country, city, street, streetNumber } = req.body;
  const { _id } = req.query; // Assurez-vous que votre ID utilisateur est dans les en-têtes

  if (!_id) {
    return res.status(400).json({ message: 'L\'ID utilisateur est manquant dans les en-têtes.' });
  }

  const searchQuery = `${streetNumber} ${street}, ${city}, ${country}`;

  try {
    // Effectuez une requête à Nominatim
    const response = await axios.get('https://nominatim.openstreetmap.org/search', {
      params: {
        q: searchQuery,
        format: 'json',
      },
    });

    if (response.data.length > 0) {
      // Enregistrez les résultats de géocodage dans la base de données
      const firstGeocodedResult = response.data[0];
      const geocodedAddress = new GeocodedAd({
        _id: _id,  // Utilisez l'ID automatique de MongoDB tel quel
        country,
        city,
        street,
        streetNumber,
        geocodedResults: firstGeocodedResult,
      });

      await geocodedAddress.save();

      res.json({ message: 'Résultats de géocodage enregistrés ', results:firstGeocodedResult});
    } else {
      res.json({ message: 'Aucun résultat de géocodage trouvé.' });
    }
  } catch (error) {
    console.error(error);
    res.status(500).send('Erreur lors du géocodage de l\'adresse.');
  }
};
const getGeocodedDetails = async (req, res) => {
  const { _id } = req.query; // User ID

  try {
    // Find the geocoded address in the database based on user ID
    const geocodedAddress = await GeocodedAd.findOne({ _id });

    if (!geocodedAddress) {
      return res.status(404).json({ message: 'Aucun résultat de géocodage trouvé pour cet utilisateur.' });
    }

    
    const { country, city, street, streetNumber } = geocodedAddress;

    res.json({status: 200,
      message: 'Détails de géocodage récupérés :',
      geocodedDetails: { country, city, street, streetNumber },
    });
  } catch (error) {
    console.error(error);
    res.status(500).send('Erreur lors de la récupération des détails de géocodage.');
  }
};
const updateGeocodedDetails = async (req, res) => {
  const { _id } = req.query; // User ID
  const { country, city, street, streetNumber } = req.body; // Updated geocoded details

  try {
    // Find the geocoded address in the database based on user ID
    const geocodedAddress = await GeocodedAd.findOne({ _id });

    if (!geocodedAddress) {
      return res.status(404).json({ message: 'Aucun résultat de géocodage trouvé pour cet utilisateur.' });
    }

    // Update the geocoded details
    geocodedAddress.country = country;
    geocodedAddress.city = city;
    geocodedAddress.street = street;
    geocodedAddress.streetNumber = streetNumber;

    // Save the updated geocoded details
    await geocodedAddress.save();

    res.json({
      status: 200,
      message: 'Détails de géocodage mis à jour avec succès.',
      geocodedDetails: { country, city, street, streetNumber },
    });
  } catch (error) {
    console.error(error);
    res.status(500).send('Erreur lors de la mise à jour des détails de géocodage.');
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
  searchAddress,
  getGeocodedDetails,
  updateGeocodedDetails,
};