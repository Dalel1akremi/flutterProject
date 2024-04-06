const { Schema, model } = require('mongoose');

const itemSchema = new Schema({
  id_item: { type: Number, unique: true },
  nom: String,
  prix: Number,
  description: String,
  isArchived: { type: Boolean, validate: [isValidBoolean, 'isArchived must be true or false'] },
  image: String,
  quantite: Number,
  max_quantite: Number,
  is_Menu: { type: Boolean, validate: [isValidBoolean, 'is_Menu must be true or false'] },
  is_Redirect: { type: Boolean, validate: [isValidBoolean, 'is_Redirect must be true or false'] },
  id_cat: { type: Number, ref: 'Categories' },
  id_Steps: [
    {
      id_Step: { type: Number, required: true },
    },
  ],
  id_rest: { type: Number, ref: 'Restaurant' }, 
});

function isValidBoolean(value) {
  return typeof value === 'boolean';
}

itemSchema.pre('save', async function (next) {
  try {
    if (!this.id_item) {
      const lastMenu = await this.constructor.findOne({}, {}, { sort: { id_item: -1 } });
      this.id_item = lastMenu ? lastMenu.id_item + 1 : 1;
    }
    next();
  } catch (error) {
    next(error);
  }
});

// Création d'un index unique personnalisé
itemSchema.index({ nom: 1, id_rest: 1 }, { unique: true });
const Item = model('Item', itemSchema);

module.exports = Item;
