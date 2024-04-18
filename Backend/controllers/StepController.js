const Step = require('../models/StepModel');

const createStep = async (req, res) => {
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
      isArchived: false, 
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


const getStepsByRestaurantId = async (req, res) => {
  try {
    const id_restaurant = req.query.id_rest; 
    const steps = await Step.find({ id_rest: id_restaurant }); 
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
const ObligationStep = async (req, res) => {
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
const updateStep = async (req, res) => {
  try {
    const { _id } = req.params;
    const { nom_Step, id_items } = req.body;

    if (!_id) { 
      return res.status(400).json({
        status: 400,
        message: "L'ID de l'élément est manquant.",
      });
    }

    let updateData = {};

    if (nom_Step) {
      updateData.nom_Step = nom_Step;
    }

    if (id_items) {
      const id_itemsArray = id_items.split(',').map(idItem => ({ id_item: parseInt(idItem.trim()) }));
      updateData.id_items = id_itemsArray;
    }

    await Step.findByIdAndUpdate(_id, updateData);

    res.status(200).json({
      status: 200,
      message: "L'élément a été mis à jour avec succès.",
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      status: 500,
      message: 'Erreur lors de la mise à jour de l\'élément.',
    });
  }
};




const ArchiverStep = async (req, res) => {
  try {
    const { _id} = req.params;
    const { isArchived } = req.body;
   

    if (!_id) {
      return res.status(400).json({
        status: 400,
        message: "L'ID de l'élément à mettre à jour est manquant.",
      });
    }

    await Step.findOneAndUpdate({ _id: _id }, { isArchived });

    res.status(200).json({
      status: 200,
      message: "L'élément a été mis à jour avec succès.",
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      status: 500,
      message: 'Erreur lors de la mise à jour de l\'élément.',
    });
  }
};

module.exports = {
  createStep ,
  updateStep,
   ArchiverStep,
  ObligationStep,
  getStepsByRestaurantId,

}