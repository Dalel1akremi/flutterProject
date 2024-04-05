// models/AdminModel.js

const { number } = require('joi');
const mongoose = require('mongoose');

const AdminSchema = new mongoose.Schema({
  id_Admin: { type: Number, unique: true },
  nom: String,
  prenom: String,
  telephone:String,
  email: {type:String,unique:true},
  password: String,
  validationCode: String, 
  validationCodeTimestamp: Date,
  id_rest: { 
    type: Number,
    required: true,
  },
});
AdminSchema.pre('save', async function (next) {
  try {
    if (!this.id_Admin) {
      const lastAdmin = await this.constructor.findOne({}, {}, { sort: { id_Admin: -1 } });
      this.id_Admin = lastAdmin ? lastAdmin.id_Admin + 1 : 1;
    }
    next();
  } catch (error) {
    next(error);
  }
});
const Admin = mongoose.model('Admin', AdminSchema);

module.exports = Admin;