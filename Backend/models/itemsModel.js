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
  nom_cat: { type: String, ref: 'Categories' },
  id: { type: Schema.Types.ObjectId, ref: 'CompositionDeBase' },
  nom: { type: String, ref: 'menus' },
});
itemsSchema.pre('save', async function (next) {
  try {
    console.log('Pre-save hook called');
    console.log('Document:', this);
    console.log('id_item:', this.id_item);
    
    if (!this.id_item) {
      const lastItem = await this.constructor.findOne({}, {}, { sort: { id_item: -1 } });
      console.log('Last Item:', lastItem);
      this.id_item = lastItem ? lastItem.id_item + 1 : 1;
      console.log
     }} catch (error) {
    next(error);
  }
});
const Items = model('Items', itemsSchema);

module.exports = Items;
