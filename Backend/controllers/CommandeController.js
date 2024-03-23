const Commande = require ('./../models/CommandeModel');
const Item = require ('./../models/itemModel');
const  User = require('./../models/userModel');
const  nodemailer = require("nodemailer");
const createCommande = async (req, res) => {
  try {
    const { id_items } = req.body;
    const {id_user , _id} = req.query;

    if (!id_items || !Array.isArray(id_items) || id_items.length === 0) {
      console.error('id_items are missing or not provided as an array in the request body.');
      return res.status(400).json({ error: 'id_items are required and should be provided as an array in the request body.' });
    }

    if (!id_user) {
      console.error('id_user is missing in the request query parameters.');
      return res.status(400).json({ error: 'id_user is required in the request query parameters.' });
    }

    const itemIds = id_items.map(item => item.id_item);
    const items = await Item.find({ id_item: { $in: itemIds } });

    if (items.length !== id_items.length) {
      console.error('One or more items not found.');
      return res.status(404).json({ error: 'One or more items not found.' });
    }

    const formattedItems = id_items.map((itemInput) => {
      const matchingItem = items.find(item => item.id_item === itemInput.id_item);

      if (!matchingItem) {
        console.error(`Item with id_item ${itemInput.id_item} not found.`);
        return res.status(404).json({ error: `Item with id_item ${itemInput.id_item} not found.` });
      }

      return {
        id_item: matchingItem.id_item,
        nom: matchingItem.nom,
        prix: matchingItem.prix,
        quantite: itemInput.quantite,
      };
    });

    const temps = id_items[0].temps; 
    const mode_retrait = id_items[0].mode_retrait; 
    const montant_Total = id_items[0].montant_Total; 


    const newCommande = new Commande({
      _id: _id,
      id_items: formattedItems,
      id_user: id_user,
      temps: temps,
      mode_retrait: mode_retrait,
      montant_Total: montant_Total,
    });

    const savedCommande = await newCommande.save();
    console.log('Commande created successfully:', savedCommande);
    return res.status(201).json(savedCommande);
  } catch (error) {
    console.error('Error creating Commande:', error.message);
    return res.status(500).json({ error: 'Internal Server Error' });
  }
}

  
const getCommandesEncours = async (req, res) => {
  try {
    const id_user = req.query.id_user;
    if (!id_user) {
      console.error('id_user is missing in the request query parameters.');
      return res.status(400).json({ error: 'id_user is required in the request query parameters.' });
    }
      const commandes = await Commande.find({ etat: 'encours' });
      if (!commandes || commandes.length === 0) {
        console.error('No commandes with etat "encours" found.');
        return res.status(404).json({ error: 'No commandes with etat "encours" found.' });
      }
  
      return res.status(200).json(commandes);
    } catch (error) {
      console.error('Error getting commandes with etat "encours":', error.message);
      return res.status(500).json({ error: 'Internal Server Error' });
    }
  };
  const getCommandes = async (req, res) => {
    try {
        // Récupérer les commandes en cours
        const commandes = await Commande.find({ etat: 'encours' });
        if (!commandes || commandes.length === 0) {
            console.error('No commandes with etat "encours" found.');
            return res.status(404).json({ error: 'No commandes with etat "encours" found.' });
        }
        
        // Récupérer les IDs des utilisateurs associés aux commandes
        const userIds = commandes.map(commande => commande.id_user);
        
        // Récupérer les utilisateurs correspondants à ces IDs
        const users = await User.find({ _id: { $in: userIds } });
        
        // Créer un objet pour faire correspondre les IDs d'utilisateur avec leurs emails
        const userIdToEmailMap = {};
        users.forEach(user => {
            userIdToEmailMap[user._id] = user.email;
        });
        
        // Ajouter l'email de chaque utilisateur à sa commande correspondante
        const commandesWithEmails = commandes.map(commande => {
            return {
                ...commande.toObject(), // Convertir la commande en un objet JavaScript pour éviter toute modification accidentelle
                userEmail: userIdToEmailMap[commande.id_user]
            };
        });
        
        return res.status(200).json(commandesWithEmails);
    } catch (error) {
        console.error('Error getting commandes with etat "encours":', error.message);
        return res.status(500).json({ error: 'Internal Server Error' });
    }
};

  const updateCommandeState = async (req, res) => {
    try {
      const { commandeId } = req.query;
      if (!commandeId) {
        console.error('Commande ID is missing in the request parameters.');
        return res.status(400).json({ error: 'Commande ID is required in the request parameters.' });
      }
      const commande = await Commande.findById(commandeId);
      if (!commande) {
        console.error(`Commande with ID ${commandeId} not found.`);
        return res.status(404).json({ error: `Commande with ID ${commandeId} not found.` });
      }
      if (commande.etat === 'passé') {
        console.log(`Commande with ID ${commandeId} is already in the "passe" state.`);
        return res.status(200).json({ message: `Commande with ID ${commandeId} is already in the "passe" state.` });
      }
      commande.etat = 'passé';
      await commande.save();
      console.log(`Commande with ID ${commandeId} updated successfully to "passe".`);
      return res.status(200).json({ message: `Commande with ID ${commandeId} updated successfully to "passe".` });
    } catch (error) {
      console.error('Error updating commande state:', error.message);
      return res.status(500).json({ error: 'Internal Server Error' });
    }
  };
  const getCommandesPassé = async (req, res) => {
    try {
      const id_user = req.query.id_user;

      if (!id_user) {
        console.error('id_user is missing in the request query parameters.');
        return res.status(400).json({ error: 'id_user is required in the request query parameters.' });
      }

      const commandes = await Commande.find({ id_user, etat: 'passé' });

      if (!commandes || commandes.length === 0) {
        console.error(`No past commandes found for id_user ${id_user}.`);
        return res.status(404).json({ error: `No past commandes found for id_user ${id_user}.` });
      }

      return res.status(200).json(commandes);
    } catch (error) {
      console.error('Error getting past commandes:', error.message);
      return res.status(500).json({ error: 'Internal Server Error' });
    }
};
const transporter = nodemailer.createTransport({
  service: 'Gmail',
  auth: {
    user: 'meltingpot449@gmail.com',
    pass: 'zcvy livf qkty thhr',
  },
});
const sendNotification  = async (req, res) => {
  const { userEmail } = req.body;

  // Configuration de l'e-mail
  const mailOptions = {
    from: 'meltingpot449@gmail.com',
    to: userEmail,
    subject: 'Votre commande est prête',
    text: 'Votre commande est prête. Venez la récupérer dès que possible.',
  };

  try {
    // Envoi de l'e-mail
    await transporter.sendMail(mailOptions);
    console.log('E-mail sent successfully');
    res.status(200).json({ message: 'E-mail sent successfully' });
  } catch (error) {
    console.error('Error sending e-mail:', error.message);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};

module.exports = {
  createCommande,
  getCommandesEncours,
  updateCommandeState,
  getCommandesPassé,
  getCommandes,
  sendNotification,
};
