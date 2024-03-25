const mongoose = require('mongoose');

const restaurantSchema = new mongoose.Schema({
  id_rest: { type: Number, unique: true },
  logo: String,
  nom: { type: String, unique: true },
  adresse: { type: String, required: true },
  ModeDeRetrait: [{
    type: String,
    enum: ['En Emporter', 'Sur place', 'En Livraison'] 
  }] 
, 
  ModeDePaiement: [{ type: String,
    enum: ['carte bancaire','espece','carnet des cheques'] 
   }],
});
restaurantSchema.pre('save', async function (next) {
  try {
    if (!this.id_rest) {
      const lastRestau = await this.constructor.findOne({}, {}, { sort: { id_rest: -1 } });
      this.id_rest = lastRestau ? lastRestau.id_rest + 1 : 1;
    }
    next();
  } catch (error) {
    next(error);
  }
});
const Restaurant = mongoose.model('Restaurant', restaurantSchema);

module.exports = Restaurant;
