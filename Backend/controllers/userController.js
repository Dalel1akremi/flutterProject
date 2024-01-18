// controllers/userController.js

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

module.exports = {
  registerUser,
};
