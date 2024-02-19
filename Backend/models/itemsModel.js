// models/itemsModel.js

const { boolean } = require('joi');
const  { Schema, model } =require( 'mongoose');

const itemsSchema = new Schema({

  id_item: { type:Number, ref: 'menus' },
  nom: { type: String, unique: true },
  type: String,
  prix: Number,
  description: String,
  isArchived:{ type: Boolean, validate: [isValidBoolean, 'isArchived must be true or false'] },
  image: String,
  quantite: Number,
  max_quantite: Number,
  is_Menu:  { type: Boolean, default: false},
  is_Redirect: { type: Boolean, default: false},
  id: { type: Schema.Types.ObjectId, ref: 'CompositionDeBase' },
  id_cat: { type:Number, ref: 'Categories' },
});
function isValidBoolean(value) {
  return typeof value === 'boolean';
}
 
const Items = model('Items', itemsSchema);

module.exports = Items;
