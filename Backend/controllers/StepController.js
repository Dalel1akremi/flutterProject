const Step = require('../models/StepModel');

exports.createStep = async (req, res) => {
  try {
    const { body } = req;
    
    const { nom_Step, id_items, is_Obligatoire ,id_rest} = body;

    const existingStep = await Step.findOne({ nom_Step ,id_rest});

    if (existingStep) {
      return res.status(400).json({
        status: 400,
        message: 'Ce Step existe déjà',
      });
    }

    const newStep = new Step({
      nom_Step,
      id_items,
      is_Obligatoire,
      id_rest,
    
    });

    const savedStep = await newStep.save();

    return res.status(200).json({
      status: 200,
      message: 'Step créé avec succès',
      data: savedStep,
    });
  } catch (error) {
    console.error(error);
    return res.status(500).json({
      status: 500,
      message: 'Erreur lors de la création de Step',
      error: error.message,
    });
  }
};


exports.getStepsByRestaurantId = async (req, res) => {
  try {
    const id_restaurant = req.query.id_rest; // Récupère l'ID du restaurant à partir des paramètres de la requête

    // Supposons que votre modèle Item soit importé et correctement défini
    const steps = await Step.find({ id_rest: id_restaurant }); // Requête pour récupérer les éléments du restaurant spécifié par son ID

    res.status(200).json({
      status: 200,
      message: 'Steps récupérés avec succès pour le restaurant correspondant',
      steps,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      status: 500,
      message: 'Erreur lors de la récupération des items pour le restaurant correspondant',
    });
  }
};
exports.ObligationStep = async (req, res) => {
  try {
    const { stepId } = req.params;
    const { is_Obligatoire } = req.body;

    if (!stepId) {
      return res.status(400).json({
        status: 400,
        message: "L'ID du Step est requis",
      });
    }

    if (is_Obligatoire === undefined || is_Obligatoire === null) {
      return res.status(400).json({
        status: 400,
        message: "Le statut is_Obligatoire est requis",
      });
    }

    const step = await Step.findById(stepId);
    if (!step) {
      return res.status(404).json({
        status: 404,
        message: 'Step non trouvé',
      });
    }

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

    if (!stepId) {
      return res.status(400).json({
        status: 400,
        message: "L'ID du Step est requis",
      });
    }

    let step = await Step.findById(stepId);
    if (!step) {
      return res.status(404).json({
        status: 404,
        message: 'Step non trouvé',
      });
    }

    if (nom_Step) {
      step.nom_Step = nom_Step;
    }
    if (id_items) {
      step.id_items = id_items;
    }
    if (is_Obligatoire !== undefined && is_Obligatoire !== null) {
      step.is_Obligatoire = is_Obligatoire;
    }

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

