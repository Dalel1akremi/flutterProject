const mongoose = require('mongoose');

const restaurantSchema = new mongoose.Schema({
  id: { type: Number, unique: true },
  logo: String,
  nom: { type: String, unique: true },
  adresse: { type: String, required: true },
  ModeDeRetrait: [{ type: String }], 
  ModeDePaiement: [{ type: String }],
});
restaurantSchema.pre('save', async function (next) {
  try {
    if (!this.id) {
      const lastRestau = await this.constructor.findOne({}, {}, { sort: { id: -1 } });
      this.id = lastRestau ? lastRestau.id + 1 : 1;
    }
    next();
  } catch (error) {
    next(error);
  }
});
const Restaurant = mongoose.model('Restaurant', restaurantSchema);

module.exports = Restaurant;
