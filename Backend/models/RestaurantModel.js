const mongoose = require('mongoose');

const restaurantSchema = new mongoose.Schema({
  logo: String,
  nom: { type: String, unique: true },
  adresse: { type: String, required: true },
  ModeDeRetrait: [{
    type: String,
    enum: ['Emporter', 'Sur place', 'En Livraison'] 
  }] 
});

const Restaurant = mongoose.model('Restaurant', restaurantSchema);

module.exports = Restaurant;
