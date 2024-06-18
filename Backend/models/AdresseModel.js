// models/geocodedAdModel.js
const mongoose = require('mongoose');

const geocodedSchema = new mongoose.Schema({
   _id: { type: mongoose.Schema.Types.ObjectId, ref: 'User' }, 
  country: String,
  city: String,
  street: String,
  streetNumber: String,
  geocodedResults: { type: mongoose.Schema.Types.Mixed, required: true },
});

const GeocodedAd = mongoose.model('GeocodedAd', geocodedSchema);

module.exports = GeocodedAd;
