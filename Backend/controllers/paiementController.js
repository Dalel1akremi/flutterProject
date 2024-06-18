
const Payment = require('../models/PaiementModel');
const bcrypt = require('bcrypt');
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

    const existingCard = await Payment.findOne({ cardNumber });
    
    if (existingCard) {
      return res.status(400).json({ success: false, message: 'ce numéro de carte exite déjà ' });
    }

    const saltRounds = 6; 
    const hashedCVV = await bcrypt.hash(cvv, saltRounds);

    const nouvelleCarte = new Payment({
      cardNumber,
      expirationDate,
      cvv: hashedCVV,
      email
    });

    await nouvelleCarte.save();
    
    const carteBraintree = await gateway.paymentMethod.create({
      customerId: '87802661003', 
      paymentMethodNonce: 'fake-valid-nonce', 
    });

    res.json({ success: true, message: 'Carte ajoutée avec succès', token: carteBraintree.token });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, message: 'Erreur lors de l\'ajout de la carte' });
  }
};

const recupererCarteParId = async (req, res) => {
  const email = req.query.email;
  const cardId = req.query.cardId; 

  try {
   
    const existingCard = await Payment.findOne({ email: email, _id: cardId });

    if (!existingCard) {
      return res.status(404).json({ success: false, message: 'Carte non trouvée' });
    }
    const montantAPayer = req.body.montant;

    if (!montantAPayer) {
      return res.status(400).json({ success: false, message: 'Montant à payer manquant dans la requête' });
    }

    
    const transactionResult = await effectuerPaiement(existingCard, montantAPayer);

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
   const userCards = await Payment.find({ email: email });

    if (!userCards || userCards.length === 0) {
   
      return res.status(404).json({ success: false, message: 'Aucune carte trouvée pour cet utilisateur' });
    }

    res.json({ success: true, cards: userCards });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, message: 'Erreur lors de la récupération des cartes utilisateur' });
  }
};

const effectuerPaiement = async (carte, montant) => {
  try {
    
    const result = await gateway.transaction.sale({
      amount: montant,
      paymentMethodNonce: 'fake-valid-nonce', 
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