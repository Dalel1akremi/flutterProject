const Restaurant = require('./../models/RestaurantModel');
const createRestaurant = async (req, res) => {
  try {
    const { body, files } = req; 
    const { nom, adresse, ModeDeRetrait, ModeDePaiement, numero_telephone } = body;
  
    const existingRestaurant = await Restaurant.findOne({ nom });
    
    if (existingRestaurant) {
      return res.status(400).json({ success: false, status: 400, message: 'Le nom du restaurant existe déjà' });
    }

   
    const logoUrl = files.logo ? `http://localhost:3000/images/${files.logo[0].filename}` : null;
    const imageUrl = files.image ? `http://localhost:3000/images/${files.image[0].filename}` : null;

    const filteredModesDeRetraitArray = ModeDeRetrait.trim().split(',').filter(mode => mode.trim() !== '');
    const filteredModesDePaiementArray = ModeDePaiement.split(',').filter(mode => mode.trim() !== '');

  
    const newRestaurant = new Restaurant({
      logo: logoUrl,
      image: imageUrl,
      nom,
      adresse,
      ModeDeRetrait: filteredModesDeRetraitArray,
      ModeDePaiement: filteredModesDePaiementArray,
      numero_telephone
    });

    const savedRestaurant = await newRestaurant.save();
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