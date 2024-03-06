// Importez le modèle de paiement
const Payment = require('./../models/paiement');
const braintree = require('braintree');
const gateway = new braintree.BraintreeGateway({
  environment: braintree.Environment.Sandbox,
  merchantId: 'njxddktr78b76t3z',
  publicKey: 'rqyt73bwxp7wsv9y',
  privateKey: '36aab07db19d6ca6b8f74c0fa75867be',
});

const porfeuille = async (req, res) => {
  const { cardNumber, expirationDate, cvv } = req.body;
  const email = req.query.email;
  try {
    // Ajout de la carte à MongoDB
    const nouvelleCarte = new Payment({
      cardNumber,
      expirationDate,
      cvv,
      email
    });

    await nouvelleCarte.save();

    // Création d'un token Braintree pour la carte
    const carteBraintree = await gateway.paymentMethod.create({
      customerId: '87802661003', // Remplacez par l'ID de votre client dans Braintree
      paymentMethodNonce: 'fake-valid-nonce', // Utilisez un nonce valide pour l'environnement de test
    });

    res.json({ success: true, message: 'Carte ajoutée avec succès', token: carteBraintree.token });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, message: 'Erreur lors de l\'ajout de la carte' });
  }
};
const recupererCarteParId = async (req, res) => {
  const email = req.query.email;
  const cardId = req.query.cardId; // Ajoutez cette ligne pour récupérer l'identifiant de la carte

  try {
    // Vérifier si la carte existe pour cet utilisateur
    const existingCard = await Payment.findOne({ email: email, _id: cardId });

    if (!existingCard) {
      // La carte n'existe pas pour cet utilisateur
      return res.status(404).json({ success: false, message: 'Card not found' });
    }

    // Récupérer le montant à partir du corps de la requête
    const montantAPayer = req.body.montant;

    if (!montantAPayer) {
      return res.status(400).json({ success: false, message: 'Montant à payer manquant dans la requête' });
    }

    // Création d'une transaction avec la carte récupérée et le montant du panier
    const transactionResult = await effectuerPaiement(existingCard, montantAPayer);

    // Créer un objet de réponse minimisé
    const minimalResponse = {
      success: true,
      message: 'Paiement effectué avec succès',
      transactionId: transactionResult.transaction.id,
      amount: transactionResult.transaction.amount,
      currency: transactionResult.transaction.currencyIsoCode,
      status: transactionResult.transaction.status,
      createdAt: transactionResult.transaction.createdAt
    };

    res.json(minimalResponse);
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, message: 'Erreur lors du paiement' });
  }
};

const recupererCartesUtilisateur = async (req, res) => {
  const email = req.query.email;

  try {
    // Récupérer toutes les cartes associées à l'utilisateur avec l'e-mail donné
    const userCards = await Payment.find({ email: email });

    if (!userCards || userCards.length === 0) {
      // Aucune carte trouvée pour cet utilisateur
      return res.status(404).json({ success: false, message: 'Aucune carte trouvée pour cet utilisateur' });
    }

    // Si des cartes sont trouvées, les renvoyer dans la réponse
    res.json({ success: true, cards: userCards });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, message: 'Erreur lors de la récupération des cartes utilisateur' });
  }
};


// Fonction pour effectuer le paiement avec une carte et un montant
const effectuerPaiement = async (carte, montant) => {
  try {
    
    const result = await gateway.transaction.sale({
      amount: montant, // Montant du paiement provenant du panier
      paymentMethodNonce: 'fake-valid-nonce', // Utilisez un nonce valide pour l'environnement de test
      options: {
        submitForSettlement: true,
      },
    });

    return result;
  } catch (error) {
    throw error;
  }
};


module.exports = {
  porfeuille,
  recupererCarteParId,
  recupererCartesUtilisateur,
};