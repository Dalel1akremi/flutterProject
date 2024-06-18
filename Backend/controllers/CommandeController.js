const Commande = require ('./../models/CommandeModel');
const Item = require ('./../models/itemModel');
const Restaurant = require('./../models/RestaurantModel');
const  nodemailer = require("nodemailer");
const createCommande = async (req, res) => {
  try {
    const { id_items } = req.body;
    const { email, id_rest } = req.query;

    if (!id_items || !Array.isArray(id_items) || id_items.length === 0) {
      console.error('Les id_items sont manquants ou non fournis sous forme de tableau dans le corps de la requête.');
      return res.status(400).json({ error: 'Les id_items sont requis et doivent être fournis sous forme de tableau dans le corps de la requête.' });
    }

  
    if (!email) {
      console.error('id_user est manquant dans les paramètres de requête.');
      return res.status(400).json({ error: 'id_user est manquant dans les paramètres de requête.' });
    }

   
    const restaurant = await Restaurant.findOne({ id_rest });

    
    if (!restaurant) {
      console.error(`Restaurant avec l'identifiant ${id_rest} non trouvé.`);
      return res.status(404).json({ error: `Restaurant avec l'identifiant ${id_rest} non trouvé.` });
    }

    const numero_telephone = restaurant.numero_telephone;

    const itemIds = id_items.map(item => item.id_item);
    const items = await Item.find({ id_item: { $in: itemIds } });

    if (items.length !== id_items.length) {
      console.error('Un ou plusieurs éléments non trouvés.');
      return res.status(404).json({ error: 'Un ou plusieurs éléments non trouvés.' });
    }


    const formattedItems = id_items.map((itemInput) => {
      const matchingItem = items.find(item => item.id_item === itemInput.id_item);

      if (!matchingItem) {
        console.error(`Le produit avec id_item${itemInput.id_item} n'a pas été trouvé.`);
        return res.status(404).json({ error: `Le produit avec id_item${itemInput.id_item} n'a pas été trouvé.` });
      }

      return {
        id_item: matchingItem.id_item,
        nom: itemInput.nom,
        prix: itemInput.prix,
        quantite: itemInput.quantite,
        elements_choisis: itemInput.elements_choisis,
        remarque:itemInput.remarque,
      };
    });

    const temps = id_items[0].temps;
    const mode_retrait = id_items[0].mode_retrait;
    const montant_Total = id_items[0].montant_Total;
    const adresse = id_items[0].adresse;
    const newCommande = new Commande({
      id_rest: id_rest,
      id_items: formattedItems,
      email: email,
      temps: temps,
      mode_retrait: mode_retrait,
      montant_Total: montant_Total,
      numero_telephone: numero_telephone,
      adresse:adresse, 
    });

    const savedCommande = await newCommande.save();
    return res.status(201).json(savedCommande);
  } catch (error) {
    console.error('Erreur lors de creation de  Commande:', error.message);
    return res.status(500).json({ error: 'Erreur interne du serveur' });
  }
}
const getCommandesEncours = async (req, res) => {
  try {
    const email = req.query.email;
    if (!email) {
      console.error('L\'email est manquant dans les paramètres de requête.');
      return res.status(400).json({ error: 'L\'email est manquant dans les paramètres de requête.' });
    }

  
    const etats = ['Encours', 'Validée', 'En Préparation', 'Prête'];

    const commandes = await Commande.find({email, etat: { $in: etats } });

    if (!commandes || commandes.length === 0) {
      console.error('Aucune commande trouvée avec les états spécifiés.');
      return res.status(404).json({ error: 'Aucune commande trouvée avec les états spécifiés.' });
    }
    const commandesAvecRestaurants = [];
    for (let commande of commandes) {
      try {
        const id_rest = commande.id_rest;
        const restaurant = await Restaurant.findOne({ id_rest });
        
        if (restaurant) {
          const commandeAvecRestaurant = {
            ...commande.toObject(),
            nom_restaurant: restaurant.nom
          };
          
          commandesAvecRestaurants.push(commandeAvecRestaurant);
          
    
        } else {
          console.log('Restaurant introuvable pour id_rest:', id_rest);
        }
      } catch (error) {
        console.error('Erreur lors de la récupération du nom du restaurant :', error.message);
       console.error('Erreur lors de la récupération du nom du restaurant pour la commande:', commande._id);
      }
    }

    return res.status(200).json(commandesAvecRestaurants);
  } catch (error) {
    console.error('Erreur lors de la récupération des commandes avec les états spécifiés :', error.message);
    return res.status(500).json({ error: 'Internal Server Error' });
  }
};




const getCommandes = async (req, res) => {
  const { id_rest } = req.query; 

  try {
    const allowedStates = ['Validée', 'En Préparation', 'Encours', 'Prête', 'Passée'];
      
    const commandes = await Commande.find({ etat: { $in: allowedStates }, id_rest });

    if (!commandes || commandes.length === 0) {
      console.error('No commandes found for restaurant:', id_rest);
      return res.status(404).json({ error: `No commandes found for restaurant ${id_rest}` });
    }

  
   

    return res.status(200).json(commandes);
  } catch (error) {
    console.error('Error getting commandes for restaurant:', id_rest, error.message);
    return res.status(500).json({ error: 'Erreur interne du serveur' });
  }
};



const updateCommandeState = async (req, res) => {
  try {
    const { commandeId, newState } = req.query;

    if (!commandeId || !newState) {
      console.error('la commande ID ou le nouvel état est manquant dans les paramètres de la requête.');
      return res.status(400).json({ error: 'la commande ID ou le nouvel état est manquant dans les paramètres de la requête.' });
    }

    const newStateCleaned = newState.trim();

    const allowedStates = ['Validée', 'En Préparation', 'Prête', 'Non validée', 'Passée'];
    if (!allowedStates.includes(newStateCleaned)) {
      console.error(`État invalide spécifié ${newStateCleaned}.`);
      return res.status(400).json({ error: `État spécifié invalide ${newStateCleaned} Les états autorisés sont : ${allowedStates.join(', ')}` });
    }

    const commande = await Commande.findById(commandeId);
    if (!commande) {
      console.error(`Commande avec ID ${commandeId} non trouvé.`);
      return res.status(404).json({ error: `Commande avec ID ${commandeId} non trouvé.` });
    }

    let errorMessage;

    if (newStateCleaned === 'Validée' || newStateCleaned === 'Non validée') {
      if (commande.etat !== 'Encours') {
        errorMessage = `Erreur de modification! Vous ne pouvez pas changer de l'état "${commande.etat}" à l'état "${newStateCleaned}" directement. Veuillez la modifier depuis "Encours"`;
      }
    } else if (newStateCleaned === 'En Préparation') {
      if (commande.etat !== 'Validée') {
        errorMessage = `Erreur de modification! Vous ne pouvez pas changer de l'état "${commande.etat}" à l'état "${newStateCleaned}" directement. Veuillez la modifier depuis "Validée"`;
      }
    } else if (newStateCleaned === 'Prête') {
      if (commande.etat !== 'En Préparation') {
        errorMessage = `Erreur de modification! Vous ne pouvez pas changer de l'état "${commande.etat}" à l'état "${newStateCleaned}" directement. Veuillez la modifier depuis "En Préparation"`;
      }
    } else if (newStateCleaned === 'Passée') {
      if (commande.etat !== 'Prête') {
        errorMessage = `Erreur de modification! Vous ne pouvez pas changer de l'état "${commande.etat}" à l'état "${newStateCleaned}" directement. Veuillez la modifier depuis "Prête"`;
      }
    }

    if (errorMessage) {
      return res.status(400).json({ message: errorMessage });
    }

    commande.etat = newStateCleaned;
    await commande.save();
    return res.status(200).json({ message: `Commande avec l'ID ${commandeId} modifié avec succée à "${newStateCleaned}".` });
  } catch (error) {
    console.error('erreur lors de modification de l\'etat  de commande :', error.message);
     return res.status(500).json({ error: 'Une erreur est survenue lors de la mise à jour de l\'état de la commande.' });
  }
};


  const getCommandesPassé = async (req, res) => {
    try {
      const email = req.query.email;
  
      if (!email) {
        console.error('L`\'email est manquante dans les paramètres de la requête.');
        return res.status(400).json({ error: 'email est requise dans les paramètres de la requête' });
      }
      const etats = ['Passée', 'Non validée'];

      const commandes = await Commande.find({email, etat: { $in: etats } });
  
      if (!commandes || commandes.length === 0) {
        
        return res.status(404).json({ error: `Aucune commande passée n'a été trouvée pour cet e-mail ${email}.` });
      }
      const commandesAvecRestaurants = [];
      for (let commande of commandes) {
        try {
          const id_rest = commande.id_rest;
          const restaurant = await Restaurant.findOne({ id_rest });
          
          if (restaurant) {
            const commandeAvecRestaurant = {
              ...commande.toObject(),
              nom_restaurant: restaurant.nom
            };
            
            commandesAvecRestaurants.push(commandeAvecRestaurant);
      
          } else {
            console.log('Restaurant introuvable pour id_rest:', id_rest);
          }
        } catch (error) {
          console.error('Erreur lors de la récupération du nom du restaurant :', error.message);
          console.error('Erreur lors de la récupération du nom du restaurant pour la commande:', commande._id);
        }
      }
      return res.status(200).json(commandesAvecRestaurants);
    } catch (error) {
      console.error('Erreur lors de la récupération des commandes passées :', error.message);
      return res.status(500).json({ error: 'Erreur interne du serveur' });
    }
};

const sendNotification = async (req, res) => {
  const { id_rest, email } = req.query;
  
  try {
    const restaurant = await Restaurant.findOne({ id_rest });
    const utilisateur = await Commande.findOne({ email });

    if (!restaurant) {
      return res.status(404).json({ error: 'Restaurant non trouvé' });
    }
    if (!utilisateur) {
      return res.status(404).json({ error: 'Utilisateur non trouvé' });
    }

    const restEmail = restaurant.email;
    const restaurantName = restaurant.nom;
    let transporter;

    if (restEmail === 'meltingpot449@gmail.com') {
      transporter = nodemailer.createTransport({
        service: 'Gmail',
        auth: {
          user: restEmail,
          pass: 'zcvy livf qkty thhr', 
        },
      });
    } else if (restEmail === 'yakinebenali5@gmail.com') {
      transporter = nodemailer.createTransport({
        service: 'Gmail',
        auth: {
          user: restEmail,
          pass: 'ynwl lomd mvak lnsv', 
        },
      });
    }

    const mailOptions = {
      from: `"Assistant de restaurant" <${restEmail}>`,
      to: utilisateur.email,
      subject: `Votre commande est prête `,
      text: `Bonjour,\nVotre commande est prête au restaurant ${restaurantName}. Venez la récupérer dès que possible.\nCordialement, Assistant de restaurant`,
    };

    await transporter.sendMail(mailOptions);
    console.log('Email envoyé avec succès');
    res.status(200).json({ message: 'Email envoyé avec succès' });
  } catch (error) {
    console.error('Erreur lors de  l\'envoie de l\€email:', error.message);
    res.status(500).json({ error: 'Erreur interne du serveur' });
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
