// Importez le modèle de paiement
const Payment = require('./../models/paiement');
const stripe = require('stripe')('sk_test_51Oewv4EGPVAvixp1l4CpqbvNKStpP7xMOTWEFlx0yzMQZBAVYWP1jmqSiVQBkdPkEptqiSTozRl6eX0048fPKmYP00cx9SSnpI');

// Fonction pour le traitement du paiement
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
