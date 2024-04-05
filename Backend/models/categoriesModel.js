// models/categoriesModel.js


const { boolean } = require('joi');
const mongoose = require('mongoose');

const categoriesSchema = new mongoose.Schema({
  id_cat: { type: Number, unique: true },
  nom_cat: { type: String, unique: true },
  id_rest: { type: Number, ref: 'Restaurant' },
  isArchived: { type: Boolean, validate: [isValidBoolean, 'isArchived must be true or false'] },
 
});
function isValidBoolean(value) {
  return typeof value === 'boolean';
}

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