const Restaurant = require('./../models/RestaurantModel');
const createRestaurant = async (req, res) => {
  try {
    const { body, files } = req; 
    const { nom, adresse, ModeDeRetrait, ModeDePaiement, numero_telephone, email } = body;
  
    const existingRestaurant = await Restaurant.findOne({ $or: [{ nom }, { email }] });
    
    if (existingRestaurant) {
      return res.status(400).json({ success: false, status: 400, message: 'Le nom ou l\'e-mail du restaurant existe déjà' });
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
      numero_telephone,
      email
    });

    const savedRestaurant = await newRestaurant.save();
    res.json({ success: true, status: 200, message: 'Restaurant ajouté avec succès', restaurant: savedRestaurant });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, status: 500, message: 'Erreur lors de l\'ajout du restaurant' });
  }
};



const getRestau = async (req, res) => {
  try {
    // Récupérer tous les restaurants avec leurs noms et id_rest
    const restaurants = await Restaurant.find({}, 'id_rest nom email');

    if (!restaurants || restaurants.length === 0) {
      return res.status(404).json({ success: false, status: 404, message: 'Aucun restaurant trouvé' });
    }

    // Extrayez à la fois les noms et les id_rest des restaurants
    const restaurantData = restaurants.map(restaurant => ({
      id_rest: restaurant.id_rest,
      nom: restaurant.nom,
      email:restaurant.email,
    }));
    

    res.json({ success: true, status: 200, message: 'Noms des restaurants récupérés avec succès', restaurants: restaurantData });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, status: 500, message: 'Erreur lors de la récupération des noms des restaurants' });
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
  
  const getAllRestaurantNames = async (req, res) => {
    try {
        const restaurants = await Restaurant.find({}, 'nom'); 

        if (!restaurants || restaurants.length === 0) {
            return res.status(404).json({ success: false, status: 404, message: 'Aucun restaurant trouvé' });
        }

        const restaurantNames = restaurants.map(restaurant => restaurant.nom);

        res.json({ success: true, status: 200, message: 'Noms des restaurants récupérés avec succès', restaurantNames });
    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, status: 500, message: 'Erreur lors de la récupération des noms des restaurants' });
    }
};

module.exports = {
    createRestaurant,
    getRestaurant,
    getRestau,
    getAllRestaurantNames
   
};