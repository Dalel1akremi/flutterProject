const mongoose = require('mongoose');

const paiementSchema = new mongoose.Schema({
  cardNumber: String,
  expirationDate: String,
  cvv: String,
  email: { type: String, ref: 'User' },
});

const Paiement = mongoose.model('Paiement', paiementSchema);

module.exports = Paiement;
