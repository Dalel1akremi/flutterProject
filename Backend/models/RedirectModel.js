

const { boolean } = require('joi');
const  { Schema, model } =require( 'mongoose');

const RedirectSchema = new Schema({

  id_item: { type:Number, ref: 'item' },
  nom: { type: String, unique: true },
  prix: Number,
  description: String,
  isArchived:{ type: Boolean, validate: [isValidBoolean, 'isArchived must be true or false'] },
  image: String,
  quantite: Number,
  max_quantite: Number,
  is_Menu:  { type: Boolean, default: false},
  is_Redirect: { type: Boolean, default: false},
  id_rest: { type: Number, ref: 'Restaurant' }, 
});
function isValidBoolean(value) {
  return typeof value === 'boolean';
}
 
const Redirect = model('Redirect', RedirectSchema);

module.exports = Redirect;
