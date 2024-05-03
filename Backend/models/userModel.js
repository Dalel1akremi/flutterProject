// models/userModel.js

const { number } = require('joi');
const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  id_user: { type: Number, unique: true },
  nom: String,
  prenom: String,
  telephone:String,
  email: {type:String,unique:true},
  password: String,
  validationCode: String, 
  validationCodeTimestamp: Date,
  isEmailConfirmed: { type: Boolean, default: false },
});
userSchema.pre('save', async function (next) {
  try {
    if (!this.id_user) {
      const lastUser = await this.constructor.findOne({}, {}, { sort: { id_user: -1 } });
      this.id_user = lastUser ? lastUser.id_user + 1 : 1;
    }
    next();
  } catch (error) {
    next(error);
  }
});
const User = mongoose.model('User', userSchema);

module.exports = User;