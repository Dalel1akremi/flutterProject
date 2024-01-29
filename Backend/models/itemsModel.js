// models/itemsModel.js

const  { Schema, model } =require( 'mongoose');

const itemsSchema = new Schema({

  id_item: { type: Number, unique: true },
nom: { type: String, unique: true },
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
itemsSchema.pre('save', async function (next) {
  try {
    if (!this.id_item) {
      const lastItem = await this.constructor.findOne({}, {}, { sort: { id_item: -1 } });
      this.id_item = lastItem ? lastItem.id_item + 1 : 1;
    }
    next();
  } catch (error) {
    next(error);
  }
});
const Items = model('Items', itemsSchema);

module.exports = Items;
