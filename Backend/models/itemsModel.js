// models/itemsModel.js

const { boolean } = require('joi');
const  { Schema, model } =require( 'mongoose');

const itemsSchema = new Schema({

  id_item: { type: Number, unique: true },
  nom_item: { type: String, unique: true },
  prix: Number,
  isObligatoire:Boolean,
  description: String,
  isArchived: Boolean,
  image: String,
  quantite: Number,
  max_quantite: Number,
  is_Menu: Boolean,
  id_cat: { type: Number, ref: 'Categories' },
  id: { type: Schema.Types.ObjectId, ref: 'CompositionDeBase' },
  id_menu: { type: Number, ref: 'menus' },

});
itemsSchema.pre('save', async function (next) {
  try {
    if (!this.id_item) {
      const lastItem = await this.constructor.findOne({}, {}, { sort: { id_item: -1 } });
      this.id_item = lastItem ? lastItem.id_item + 1 : 1;
     }} catch (error) {
    next(error);
  }
});
const Items = model('Items', itemsSchema);

module.exports = Items;
