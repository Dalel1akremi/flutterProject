const Restaurant = require('./../models/RestaurantModel');
const createRestaurant = async (req, res) => {
    try {
        const { body, file } = req;
        const { nom, adresse, ModeDeRetrait } = body;

        // Vérifier si le nom du restaurant existe déjà
        const existingRestaurant = await Restaurant.findOne({ nom });
        if (existingRestaurant) {
            return res.status(400).json({ success: false, status: 400, message: 'Le nom du restaurant existe déjà' });
        }

        // Construire l'URL de l'image du logo si un fichier est envoyé dans la requête
        const imageUrl = file ? `http://localhost:3000/images/${file.filename}` : null;

        // Diviser la chaîne de modes de retrait par virgules et stocker chaque mode dans un tableau
        const modesDeRetraitArray = ModeDeRetrait.split(',');

        // Créer un nouveau restaurant avec les modes de retrait individuels
        const newRestaurant = new Restaurant({
            logo: imageUrl,
            nom,
            adresse,
            ModeDeRetrait: modesDeRetraitArray
        });

        // Sauvegarder le nouveau restaurant dans la base de données
        const savedRestaurant = await newRestaurant.save();

        // Retourner la réponse avec le restaurant ajouté
        res.json({ success: true, status: 200, message: 'Restaurant ajouté avec succès', restaurant: savedRestaurant });
    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, status: 500, message: 'Erreur lors de l\'ajout du restaurant' });
    }
};


const getRestaurant = async (req, res) => {
    try {
      // Récupérer tous les restaurants
      const restaurants = await Restaurant.find();
  
      if (!restaurants || restaurants.length === 0) {
        return res.status(404).json({ success: false, status: 404, message: 'Aucun restaurant trouvé' });
      }
  
      // Renvoyer la liste des restaurants récupérés
      res.json({ success: true, status: 200, message: 'Restaurants récupérés avec succès', restaurants });
    } catch (error) {
      console.error(error);
      res.status(500).json({ success: false, status: 500, message: 'Erreur lors de la récupération des restaurants' });
    }
  };
  
  
  
  module.exports = 
  {
    createRestaurant,
    getRestaurant,
  };
  