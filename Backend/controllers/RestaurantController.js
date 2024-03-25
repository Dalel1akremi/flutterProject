const Restaurant = require('./../models/RestaurantModel');
const createRestaurant = async (req, res) => {
    try {
        const { body, file } = req;
        const { nom, adresse, ModeDeRetrait , ModeDePaiement} = body;
        const existingRestaurant = await Restaurant.findOne({ nom });
        if (existingRestaurant) {
            return res.status(400).json({ success: false, status: 400, message: 'Le nom du restaurant existe déjà' });
        }
        const imageUrl = file ? `http://localhost:3000/images/${file.filename}` : null;

       
        const modesDeRetraitArray = ModeDeRetrait.trim().split(',');
        const filteredModesDeRetraitArray = modesDeRetraitArray.filter(mode => mode.trim() !== '');
        
        const modesDePaiementArray = ModeDePaiement.split(',');
        const filteredmodesDePaiementArray = modesDePaiementArray.filter(mode => mode.trim() !== '');
        const newRestaurant = new Restaurant({
            logo: imageUrl,
            nom,
            adresse,
            ModeDeRetrait: filteredModesDeRetraitArray,
            ModeDePaiement:filteredmodesDePaiementArray,
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