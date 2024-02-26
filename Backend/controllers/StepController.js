const Step = require('../models/StepModel');

exports.createStep = async (req, res) => {
  try {
    const { body } = req;
    const { nom_Step, id_item } = body;

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
                      const steps = await Step.find({ id_item });

                      // Récupérer uniquement les noms des steps
                      const stepNames = steps.map(Step => Step.nom_Step);
                      res.json({
                                        status: 200,
                                        message: 'Steps récupérés avec succès',
                                        data: stepNames,
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