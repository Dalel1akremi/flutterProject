// controllers/userController.js
const jwt = require('jsonwebtoken'); 
const bcrypt = require('bcrypt');
const User = require('../models/userModel');

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
      { userId: user._id, email: user.email },
      'your-secret-key', // Remplacez par une clé secrète plus sécurisée dans un environnement de production
      { expiresIn: '1h' } // Durée de validité du jeton (1 heure dans cet exemple)
    );

    res.status(200).json({ token, userId: user._id, message: 'Login successful' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

module.exports = {
  registerUser,
  loginUser,
};