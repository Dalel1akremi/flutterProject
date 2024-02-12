// models/itemsModel.js

const  { Schema, model } =require( 'mongoose');

const menuSchema = new Schema({
id_menu: { type: Number, unique: true },
nom: { type: String, unique: true },
  type: String,
  prix: Number,
  description: String,
<<<<<<< HEAD
  isArchived: Boolean,
=======
  isArchived:{ type: Boolean, validate: [isValidBoolean, 'isArchived must be true or false'] },
>>>>>>> 585e03ad591721c2ad1d0b5a55a8239c17d878b2
  image: String,
  quantite: Number,
  max_quantite: Number,
  is_Menu:  { type: Boolean, validate: [isValidBoolean, 'is_Menu must be true or false'] },
  is_Redirect: { type: Boolean, validate: [isValidBoolean, 'is_Redirect must be true or false'] },
  id_cat: { type:Number, ref: 'Categories' },
  id: { type: Schema.Types.ObjectId, ref: 'CompositionDeBase' },
});
function isValidBoolean(value) {
  return typeof value === 'boolean';
}
menuSchema.pre('save', async function (next) {
                    try {
                      if (!this.id_menu) {
                        const lastMenu = await this.constructor.findOne({}, {}, { sort: { id_menu: -1 } });
                        this.id_menu = lastMenu ? lastMenu.id_menu + 1 : 1;
                      }
                      next();
                    } catch (error) {
                      next(error);
                    }
                  });
const Menu = model('Menu', menuSchema);

module.exports = Menu;
