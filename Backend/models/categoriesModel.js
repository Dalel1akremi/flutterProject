// models/categoriesModel.js


const { boolean } = require('joi');
const mongoose = require('mongoose');

const categoriesSchema = new mongoose.Schema({
  nom_cat: String,
  type_cat:String,
});

const Categories = mongoose.model('Categories', categoriesSchema);

module.exports = Categories;