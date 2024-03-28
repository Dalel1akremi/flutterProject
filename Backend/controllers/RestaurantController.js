const Restaurant = require('./../models/RestaurantModel');
const createRestaurant = async (req, res) => {
  try {
      const { body, files } = req; // Utilisez `files` au lieu de `file` pour récupérer plusieurs fichiers
      const { nom, adresse, ModeDeRetrait, ModeDePaiement } = body;
    
      const existingRestaurant = await Restaurant.findOne({ nom });
      
      if (existingRestaurant) {
          return res.status(400).json({ success: false, status: 400, message: 'Le nom du restaurant existe déjà' });
      }

      // Récupérez les URLs des fichiers uploadés
      const logoUrl = files.logo ? `http://localhost:3000/images/${files.logo[0].filename}` : null;
      const imageUrl = files.image ? `http://localhost:3000/images/${files.image[0].filename}` : null;

      // Filtrer et diviser les modes de retrait et de paiement
      const filteredModesDeRetraitArray = ModeDeRetrait.trim().split(',').filter(mode => mode.trim() !== '');
      const filteredmodesDePaiementArray = ModeDePaiement.split(',').filter(mode => mode.trim() !== '');

      // Créer un nouvel objet Restaurant avec les données récupérées
      const newRestaurant = new Restaurant({
          logo: logoUrl,
          image: imageUrl,
          nom,
          adresse,
          ModeDeRetrait: filteredModesDeRetraitArray,
          ModeDePaiement: filteredmodesDePaiementArray,
      });

      // Enregistrer le nouveau restaurant dans la base de données
      const savedRestaurant = await newRestaurant.save();

      // Répondre avec les détails du restaurant ajouté
      res.json({ success: true, status: 200, message: 'Restaurant ajouté avec succès', restaurant: savedRestaurant });
  } catch (error) {
      console.error(error);
      res.status(500).json({ success: false, status: 500, message: 'Erreur lors de l\'ajout du restaurant' });
  }
};



const getRestaurant = async (req, res) => {
    try {
      const restaurants = await Restaurant.find();
  
      if (!restaurants || restaurants.length === 0) {
        return res.status(404).json({ success: false, status: 404, message: 'Aucun restaurant trouvé' });
      }

      res.json({ success: true, status: 200, message: 'Restaurants récupérés avec succès', restaurants });
    } catch (error) {
      console.error(error);
      res.status(500).json({ success: false, status: 500, message: 'Erreur lors de la récupération des restaurants' });
    }
  };
  
 
module.exports = {
    createRestaurant,
    getRestaurant,
   
};