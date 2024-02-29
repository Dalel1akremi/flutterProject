const Step = require('../models/StepModel');
const Item = require('../models/itemModel');
exports.createStep = async (req, res) => {
  try {
    const { body } = req;
    const { nom_Step, id_item ,is_Obligatoire} = body;

    // Check if the Step already exists
    const existingStep = await Step.findOne({ nom_Step });

    if (existingStep) {
      res.json({
        status: 400,
        message: 'Ce Step existe déjà'
      });
      return;
    }

    // Create a new Step with id_item included
    const newStep = new Step({
      nom_Step,
      id_item,
      is_Obligatoire,
    });

    // Save the new Step to the database
    const savedStep = await newStep.save();

    res.json({
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
}

exports.getStep = async (req, res) => {
  try {
    const { id_item } = req.query;

    // Recherche des étapes associées à l'id_item fourni
    const steps = await Step.find({ id_item });

    // Création d'un tableau pour stocker les données des étapes avec leurs éléments associés
    const stepsWithItems = [];

    // Boucle sur les étapes
    for (const step of steps) {
      // Récupération des noms des éléments associés à cette étape
      const items = await Item.find({ id_Step: step.id_Step, is_Step: true }, { _id: 0, nom: 1 });
      
      // Stockage des données de l'étape et de ses éléments associés dans le tableau
      stepsWithItems.push({
        stepName: step.nom_Step,
        itemNames: items.map(item => item.nom),
        stepObligation:step.is_Obligatoire,
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
