const Step = require('../models/StepModel');
const Item = require('../models/itemModel');
exports.createStep = async (req, res) => {
  try {
    const { body } = req;
    const { nom_Step, id_items } = body;

    // Check if the Step already exists
    const existingStep = await Step.findOne({ nom_Step });

    if (existingStep) {
      res.status(400).json({
        status: 400,
        message: 'Ce Step existe déjà',
      });
      return;
    }

    // Create a new Step with id_items included
    const newStep = new Step({
      nom_Step,
      id_items,
    });

    // Save the new Step to the database
    const savedStep = await newStep.save();

    res.status(200).json({
      status: 200,
      message: 'Step créé avec succès',
      data: savedStep,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      status: 500,
      message: 'Erreur lors de la création de Step',
      error: error.message,
    });
  }
};
exports.getStep = async (req, res) => {
  try {
    const { id_items } = req.query;

    // Convertir les id_items en tableau s'ils sont fournis sous forme de chaîne séparée par des virgules
    const idItemsArray = Array.isArray(id_items) ? id_items : id_items.split(',');

    // Convertir chaque élément du tableau en nombre
    const idItemsNumeric = idItemsArray.map(item => Number(item));

    // Recherche des étapes associées aux id_items fournis
    const steps = await Step.find({ 'id_items.id_item': { $in: idItemsNumeric } }).lean();

    // Création d'un tableau pour stocker les données des étapes avec leurs éléments associés
    const stepsWithItems = [];

    // Boucle sur les étapes
    for (const step of steps) {
      // Récupération des noms des éléments associés à cette étape
      const items = await Item.find({ 'id_Step': step.id_Step, 'is_Step': true }, { '_id': 0, 'nom': 1 });

      // Stockage des données de l'étape et de ses éléments associés dans le tableau
      stepsWithItems.push({
        stepName: step.nom_Step,
        itemNames: items.map(item => item.nom)
      });
    }

    res.json({
      status: 200,
      message: 'Steps et Items récupérés avec succès',
      data: stepsWithItems
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      status: 500,
      message: 'Erreur lors de la récupération des Steps et Items',
      error: error.message
    });
  }
}
