const Step = require('../models/StepModel');
const Item = require('../models/itemModel');
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

    // Recherche des étapes associées à l'id_item fourni
    const steps = await Step.find({ id_item });

    // Récupération des noms des étapes
    const stepNames = steps.map(step => step.nom_Step);

    // Récupération des noms des items associés aux étapes où is_Step est vrai
    const items = await Item.aggregate([
      {
        $match: {
          id_Step: { $in: steps.map(step => step.id_Step) },
          is_Step: true
        }
      },
      {
        $project: {
          _id: 0,
          nom: 1
        }
      }
    ]);

    res.json({
      status: 200,
      message: 'Steps et Items récupérés avec succès',
      data: {
        stepNames: stepNames,
        itemNames: items.map(item => item.nom)
      }
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
