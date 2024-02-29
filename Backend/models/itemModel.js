// models/itemsModel.js

const  { Schema, model } =require( 'mongoose');

const itemSchema = new Schema({
  id_item: { type: Number, unique: true },
 nom: { type: String, unique: true },
  type: String,
  prix: Number,
  description: String,
  isArchived:{ type: Boolean, validate: [isValidBoolean, 'isArchived must be true or false'] },
  image: String,
  quantite: Number,
  max_quantite: Number,
  is_Menu:  { type: Boolean, validate: [isValidBoolean, 'is_Menu must be true or false'] },
  is_Redirect: { type: Boolean, validate: [isValidBoolean, 'is_Redirect must be true or false'] },
  id: { type: Schema.Types.ObjectId, ref: 'CompositionDeBase' },
  id_cat: { type:Number, ref: 'Categories' },
  id_Steps: [
    {
      id_Step: {type: Number, required: true },
    },
  ],
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
                
const item = model('Item', itemSchema);

module.exports = item;
