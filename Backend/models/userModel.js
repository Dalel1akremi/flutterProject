// models/userModel.js

const { number } = require('joi');
const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  nom: String,
  prenom: String,
  telephone:String,
  email: String,
  password: String,
});

const User = mongoose.model('User', userSchema);

module.exports = User;