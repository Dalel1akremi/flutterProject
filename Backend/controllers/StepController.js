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

