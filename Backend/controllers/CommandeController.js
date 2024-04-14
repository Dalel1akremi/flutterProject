const Commande = require ('./../models/CommandeModel');
const Item = require ('./../models/itemModel');
const  User = require('./../models/userModel');
const Restaurant = require('./../models/RestaurantModel');
const  nodemailer = require("nodemailer");
const createCommande = async (req, res) => {
  try {
    const { id_items } = req.body;
    const { id_user, id_rest } = req.query;

    if (!id_items || !Array.isArray(id_items) || id_items.length === 0) {
      console.error('id_items are missing or not provided as an array in the request body.');
      return res.status(400).json({ error: 'id_items are required and should be provided as an array in the request body.' });
    }

  
    if (!id_user) {
      console.error('id_user is missing in the request query parameters.');
      return res.status(400).json({ error: 'id_user is required in the request query parameters.' });
    }

   
    const restaurant = await Restaurant.findOne({ id_rest });

    
    if (!restaurant) {
      console.error(`Restaurant with id_rest ${id_rest} not found.`);
      return res.status(404).json({ error: `Restaurant with id_rest ${id_rest} not found.` });
    }

    const numero_telephone = restaurant.numero_telephone;

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
      id_user: id_user,
      temps: temps,
      mode_retrait: mode_retrait,
      montant_Total: montant_Total,
      numero_telephone: numero_telephone,
      adresse:adresse, 
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

  
    const etats = ['Encours', 'Validée', 'En Préparation', 'Prête','Non validée'];

    const commandes = await Commande.find({ id_user, etat: { $in: etats } });

    if (!commandes || commandes.length === 0) {
      console.error('No commandes found with the specified etats.');
      return res.status(404).json({ error: 'No commandes found with the specified etats.' });
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
        console.error('Error retrieving restaurant name:', error.message);
       console.error('Erreur lors de la récupération du nom du restaurant pour la commande:', commande._id);
      }
    }

    return res.status(200).json(commandesAvecRestaurants);
  } catch (error) {
    console.error('Error getting commandes with specified etats:', error.message);
    return res.status(500).json({ error: 'Internal Server Error' });
  }
};




const getCommandes = async (req, res) => {
  const { id_rest } = req.query; 

  try {
    const allowedStates = ['Validée', 'En Préparation', 'En cours', 'Prête', 'Passée'];
      
    const commandes = await Commande.find({ etat: { $in: allowedStates }, id_rest });

    if (!commandes || commandes.length === 0) {
      console.error('No commandes found for restaurant:', id_rest);
      return res.status(404).json({ error: `No commandes found for restaurant ${id_rest}` });
    }

    const userIds = commandes.map(commande => commande.id_user);

    const users = await User.find({ _id: { $in: userIds } });

    const userIdToEmailMap = {};
    users.forEach(user => {
      userIdToEmailMap[user._id] = user.email;
    });

    const commandesWithEmails = commandes.map(commande => {
      return {
        ...commande.toObject(),
        userEmail: userIdToEmailMap[commande.id_user]
      };
    });

    return res.status(200).json(commandesWithEmails);
  } catch (error) {
    console.error('Error getting commandes for restaurant:', id_rest, error.message);
    return res.status(500).json({ error: 'Internal Server Error' });
  }
};



const updateCommandeState = async (req, res) => {
  try {
    const { commandeId, newState } = req.query;

    if (!commandeId || !newState) {
      console.error('Commande ID or new state is missing in the request parameters.');
      return res.status(400).json({ error: 'Commande ID and new state are required in the request parameters.' });
    }
    
    // Nettoyer le nouvel état en supprimant les espaces blancs inutiles
    const newStateCleaned = newState.trim();

    const allowedStates = ['Validée', 'En Préparation', 'Prête', 'Non validée','Passée'];
    if (!allowedStates.includes(newStateCleaned)) {
      console.error(`Invalid state "${newStateCleaned}" specified.`);
      return res.status(400).json({ error: `Invalid state "${newStateCleaned}" specified. Allowed states are: ${allowedStates.join(', ')}` });
    }

    const commande = await Commande.findById(commandeId);
    if (!commande) {
      console.error(`Commande with ID ${commandeId} not found.`);
      return res.status(404).json({ error: `Commande with ID ${commandeId} not found.` });
    }

     // Vérifier l'ordre des états
if (newStateCleaned === 'Validée' || newStateCleaned === 'Non validée') {
  if (commande.etat !== 'En cours') {
    console.error(`Cannot update to state "${newStateCleaned}" directly from "${commande.etat}". Must be updated from "En cours".`);
    return res.status(400).json({ error: `Cannot update to state "${newStateCleaned}" directly from "${commande.etat}". Must be updated from "En cours".` });
  }
} else if (newStateCleaned === 'En Préparation') {
  if (commande.etat !== 'Validée') {
    console.error(`Cannot update to state "${newStateCleaned}" directly from "${commande.etat}". Must be updated from "Validée".`);
    return res.status(400).json({ error: `Cannot update to state "${newStateCleaned}" directly from "${commande.etat}". Must be updated from "Validée".` });
  }
} else if (newStateCleaned === 'Prête') {
  if (commande.etat !== 'En Préparation') {
    console.error(`Cannot update to state "${newStateCleaned}" directly from "${commande.etat}". Must be updated from "En Préparation".`);
    return res.status(400).json({ error: `Cannot update to state "${newStateCleaned}" directly from "${commande.etat}". Must be updated from "En Préparation".` });
  }
} else if (newStateCleaned === 'Passée') {
  if (commande.etat !== 'Prête') {
    console.error(`Cannot update to state "${newStateCleaned}" directly from "${commande.etat}". Must be updated from "Prête".`);
    return res.status(400).json({ error: `Cannot update to state "${newStateCleaned}" directly from "${commande.etat}". Must be updated from "Prête".` });
  }
}

  

    // Mettre à jour l'état de la commande
    commande.etat = newStateCleaned;
    await commande.save();
    console.log(`Commande with ID ${commandeId} updated successfully to "${newStateCleaned}".`);
    return res.status(200).json({ message: `Commande with ID ${commandeId} updated successfully to "${newStateCleaned}".` });
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
      const etats = ['Passée', 'Annuler'];

      const commandes = await Commande.find({ id_user, etat: { $in: etats } });
  
      if (!commandes || commandes.length === 0) {
        console.error(`No past commandes found for id_user ${id_user}.`);
        return res.status(404).json({ error: `No past commandes found for id_user ${id_user}.` });
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
          console.error('Error retrieving restaurant name:', error.message);
          console.error('Erreur lors de la récupération du nom du restaurant pour la commande:', commande._id);
        }
      }
      return res.status(200).json(commandesAvecRestaurants);
    } catch (error) {
      console.error('Error getting past commandes:', error.message);
      return res.status(500).json({ error: 'Internal Server Error' });
    }
};

const sendNotification = async (req, res) => {
  const { id_rest } = req.query;
  
  try {
    // Recherchez le restaurant correspondant dans la base de données en utilisant son identifiant
    const restaurant = await Restaurant.findOne({ id_rest });
    const utilisateur = await Commande.findOne({ id_rest });

    if (!restaurant) {
      return res.status(404).json({ error: 'Restaurant not found' });
    }

    // Récupérez l'adresse e-mail et le nom du restaurant
    const userEmail = restaurant.email;
    const restaurantName = restaurant.nom;
    // Vérifiez si un utilisateur est trouvé
    if (!utilisateur) {
      return res.status(404).json({ error: 'Utilisateur not found' });
    }
    // Récupérez l'ID de l'utilisateur
    const userId = utilisateur.id_user;

    // Recherchez l'utilisateur dans la base de données en utilisant son ID
    const user = await User.findById(userId);

    // Vérifiez si l'utilisateur est trouvé
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Récupérez l'e-mail de l'utilisateur
    const userEmailAddress = user.email;

    const mailOptions = {
      from: `"Assistant de restaurant" <${userEmail}>`,
      to: userEmailAddress,
      subject: `Votre commande est prête `,
      text: `Bonjour,\nVotre commande est prête au restaurant ${restaurantName}. Venez la récupérer dès que possible.\nCordialement, Assistant de restaurant`,
    };

    const transporter = nodemailer.createTransport({
      service: 'Gmail',
      auth: {
        user: userEmail,
        pass: 'zcvy livf qkty thhr',
      },
    });

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
