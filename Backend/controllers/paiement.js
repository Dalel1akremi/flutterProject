// Importez le modèle de paiement
const Payment = require('./../models/paiement');
const braintree = require('braintree');
const gateway = new braintree.BraintreeGateway({
  environment: braintree.Environment.Sandbox,
  merchantId: 'cfgs2n5nw3r5385q',
  publicKey: 'wqmpp5jmjmywjhm8',
  privateKey: '1e8816ff7d4dbc7b2374b02173217aff',
});

const porfeuille = async (req, res) => {
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
const process_payment = async (req, res) => {
  try {
    const paymentIntent = await stripe.paymentIntents.create({
      amount: req.body.amount,
      currency: req.body.currency,
      payment_method: req.body.paymentMethod,
      confirm: true, // La confirmation est automatique par défaut
      return_url: 'https://dashboard.stripe.com/test/apikeys', // Remplacez par l'URL de retour appropriée sur votre site
    });

    // Utilisez le modèle de paiement pour enregistrer les détails du paiement dans la base de données MongoDB
    const payment = new Payment({
      amount: req.body.amount,
      currency: req.body.currency,
      paymentMethod: paymentIntent.payment_method,
    });

    await payment.save();

    res.status(200).json({ success: true });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Erreur lors du traitement du paiement.' });
  }
};

module.exports = {
process_payment,
};

module.exports = {
  porfeuille,
};
