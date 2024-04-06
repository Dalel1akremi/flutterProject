const Step = require('../models/StepModel');
const Item = require('../models/itemModel');
exports.createStep = async (req, res) => {
  try {
    const { body } = req;
    
    const { nom_Step, id_items ,is_Obligatoire} = body;

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
      is_Obligatoire,

     

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

}
exports.getSteps = async (req, res) => {
  try {
    // Récupérer tous les Steps dans la base de données
    const steps = await Step.find().populate('id_items', 'nom_item prix description'); // Vous pouvez utiliser la méthode populate pour récupérer les informations des items associés
    
    // Si aucun Step n'est trouvé, retourner une réponse 404
    if (!steps || steps.length === 0) {
      return res.status(404).json({
        status: 404,
        message: 'Aucun Step trouvé',
      });
    }

    // Si des Steps sont trouvés, retourner la liste des Steps
    res.status(200).json({
      status: 200,
      message: 'Steps récupérés avec succès',
      data: steps,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      status: 500,
      message: 'Erreur lors de la récupération des Steps',
      error: error.message,
    });
  }
}
exports.ObligationStep = async (req, res) => {
  try {
    const { stepId } = req.params;
    const { is_Obligatoire } = req.body;

    // Vérifier si l'ID du Step est fourni
    if (!stepId) {
      return res.status(400).json({
        status: 400,
        message: "L'ID du Step est requis",
      });
    }

    // Vérifier si le statut is_Obligatoire est fourni
    if (is_Obligatoire === undefined || is_Obligatoire === null) {
      return res.status(400).json({
        status: 400,
        message: "Le statut is_Obligatoire est requis",
      });
    }

    // Vérifier si le Step existe
    const step = await Step.findById(stepId);
    if (!step) {
      return res.status(404).json({
        status: 404,
        message: 'Step non trouvé',
      });
    }

    // Mettre à jour le statut is_Obligatoire du Step
    step.is_Obligatoire = is_Obligatoire;
    await step.save();

    res.status(200).json({
      status: 200,
      message: 'Statut is_Obligatoire du Step mis à jour avec succès',
      data: step,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      status: 500,
      message: "Erreur lors de la mise à jour du statut is_Obligatoire du Step",
      error: error.message,
    });
  }
};
exports.updateStep = async (req, res) => {
  try {
    const { stepId } = req.params;
    const { nom_Step, id_items, is_Obligatoire } = req.body;

    // Vérifier si l'ID du Step est fourni
    if (!stepId) {
      return res.status(400).json({
        status: 400,
        message: "L'ID du Step est requis",
      });
    }

    // Vérifier si le Step existe
    let step = await Step.findById(stepId);
    if (!step) {
      return res.status(404).json({
        status: 404,
        message: 'Step non trouvé',
      });
    }

    // Mettre à jour les champs du Step
    if (nom_Step) {
      step.nom_Step = nom_Step;
    }
    if (id_items) {
      step.id_items = id_items;
    }
    if (is_Obligatoire !== undefined && is_Obligatoire !== null) {
      step.is_Obligatoire = is_Obligatoire;
    }

    // Enregistrer les modifications dans la base de données
    step = await step.save();

    res.status(200).json({
      status: 200,
      message: 'Step mis à jour avec succès',
      data: step,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      status: 500,
      message: 'Erreur lors de la mise à jour du Step',
      error: error.message,
    });
  }
};

