// models/categoriesModel.js


const { boolean } = require('joi');
const mongoose = require('mongoose');

const categoriesSchema = new mongoose.Schema({
  id_cat: { type: Number, unique: true },
  nom_cat: { type: String, unique: true },
<<<<<<< HEAD
  id_cat: { type: Number, unique: true },
  nom_cat: { type: String, unique: true },
=======
>>>>>>> 585e03ad591721c2ad1d0b5a55a8239c17d878b2
  type_cat:String,
});
categoriesSchema.pre('save', async function (next) {
  try {
    if (!this.id_cat) {
      const lastcat = await this.constructor.findOne({}, {}, { sort: { id_cat: -1 } });
      this.id_cat = lastcat ? lastcat.id_cat + 1 : 1;
    }
    next();
  } catch (error) {
    next(error);
  }
});
const Categories = mongoose.model('Categories', categoriesSchema);

module.exports = Categories;