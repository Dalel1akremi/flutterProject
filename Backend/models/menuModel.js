// models/itemsModel.js

const  { Schema, model } =require( 'mongoose');

const menuSchema = new Schema({
id_menu: { type: Number, unique: true },
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
