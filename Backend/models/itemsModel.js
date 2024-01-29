// models/itemsModel.js

const  { Schema, model } =require( 'mongoose');

const itemsSchema = new Schema({
  nom: String,
  type: String,
  prix: Number,
  description: String,
  isArchived: Boolean,
  image: String,
  quantite: Number,
  max_quantite: Number,
  is_Menu: Boolean,
  nom_cat: { type: String, ref: 'Categories' },
  id: { type: Schema.Types.ObjectId, ref: 'CompositionDeBase' },
});

const Items = model('Items', itemsSchema);

module.exports = Items;
