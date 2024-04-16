const mongoose = require('mongoose');

const restaurantSchema = new mongoose.Schema({
  id_rest: { type: Number, unique: true },
  logo: String,
  nom: { type: String, unique: true },
  adresse: { type: String, required: true },
  image: String,
  ModeDeRetrait: [{
    type: String,
    enum: ['A Emporter', 'Sur place', 'En Livraison'] 
  }] 
, 
  ModeDePaiement: [{ type: String,
    enum: ['Carte bancaire','Espèces','Tickets Restaurant'] 
   }],
   numero_telephone: {
    type: String,
    validate: {
      validator: function(value) {
        return /^(\+|00)33[1-9]([-. ]?[0-9]{2}){4}$/g.test(value);
      },
      
      message: 'Le numéro de téléphone doit être un numéro français valide.'
    }
  },
  email: {
    type: String, unique: true,
    validate: {
      validator: function(value) {
        return /^[a-zA-Z0-9._%+-]+@gmail\.com$/i.test(value);
      },
      message: 'L\'adresse e-mail doit être un compte Gmail valide.'
    }
  }
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
