// Importez le modèle de paiement
const Payment = require('./../models/paiement');
const braintree = require('braintree');
const gateway = new braintree.BraintreeGateway({
  environment: braintree.Environment.Sandbox,
  merchantId: 'cfgs2n5nw3r5385q',
  publicKey: 'wqmpp5jmjmywjhm8',
  privateKey: '1e8816ff7d4dbc7b2374b02173217aff',
});

const process_payment = async (req, res) => {
  const { cardNumber, expirationDate, cvv } = req.body;

  try {
    // Ajout de la carte à MongoDB
    const nouvelleCarte = new Payment({
      cardNumber,
      expirationDate,
      cvv,
    });

    await nouvelleCarte.save();

    // Création d'un token Braintree pour la carte
    const carteBraintree = await gateway.paymentMethod.create({
      customerId: 'ID_DU_CLIENT', // Remplacez par l'ID de votre client dans Braintree
      paymentMethodNonce: 'fake-valid-nonce', // Utilisez un nonce valide pour l'environnement de test
    });

    res.json({ success: true, message: 'Carte ajoutée avec succès', token: carteBraintree.token });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, message: 'Erreur lors de l\'ajout de la carte' });
  }
};

module.exports = {
    process_payment,
};
