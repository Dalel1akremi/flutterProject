const mongoose = require('mongoose');

const paiementSchema = new mongoose.Schema({
  cardNumber: String,
  expirationDate: String,
  cvv: String,
});

const Paiement = mongoose.model('Paiement', paiementSchema);

module.exports = Paiement;
