const Composition = require('../models/CompositionModel');

const insererComposition = async (req, res) => {
    const { nom, image } = req.body;
  
    try {
        const compositionExistante = await Composition.findOne({ nom });

        if (compositionExistante) {

          return res.status(400).json({ error: 'Le nom de composition existe déjà' });
        }
    
      const nouvelleComposition = new Composition({
        nom,
        image,
      });
  
      const compositionEnregistree = await nouvelleComposition.save();
  
      console.log('Composition enregistrée avec succès:', compositionEnregistree);
  
      res.status(200).json({ message: 'Composition enregistrée avec succès', data: compositionEnregistree ,Statut:res.statusCode});
    } catch (erreur) {
      console.error('Erreur lors de l\'enregistrement de la composition:', erreur.message);
  
      res.status(500).json({ error: 'Erreur lors de l\'enregistrement de la composition' });
    }
  };
  const getCompositions = async (req, res) => {
    try {
   
      const compositions = await Composition.find();
  
      res.status(200).json({ message: 'Compositions récupérées avec succès', data: compositions, Statut: res.statusCode });
    } catch (erreur) {
      console.error('Erreur lors de la récupération des compositions:', erreur.message);

      res.status(500).json({ error: 'Erreur lors de la récupération des compositions' });
    }
  };
  module.exports = 
  {
    insererComposition,
    getCompositions,
 };
  