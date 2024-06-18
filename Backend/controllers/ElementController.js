const Step = require('../models/ElementModel');
const mongoose = require('mongoose');

const createStep = async (req, res) => {
  try {
    const { body } = req;
    
    const { nom_Step, id_items, is_Obligatoire, id_rest } = body;

    const existingStep = await Step.findOne({ nom_Step, id_rest });

    if (existingStep) {
      return res.status(400).json({
        status: 400,
        message: 'Ce Step existe déjà',
      });
    }

    let idItemsArray = null;

    if (typeof id_items === 'string') {
      idItemsArray = id_items.split(',').map(idItem => ({ id_item: parseInt(idItem.trim(), 10) }));
    } else if (Array.isArray(id_items)) {
      idItemsArray = id_items.map(idItem => {
        if (typeof idItem === 'string' || typeof idItem === 'number') {
          return { id_item: parseInt(idItem.toString().trim(), 10) };
        } else if (typeof idItem === 'object' && idItem.id_item) {
          return { id_item: parseInt(idItem.id_item.toString().trim(), 10) };
        } else {
          throw new Error('Type de id_item invalide');
        }
      });
    } else {
      throw new Error('Type de id_items invalide');
    }

    const newStep = new Step({
      nom_Step,
      id_items: idItemsArray,
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
    const { _id } = req.query;
    const { nom_Step, id_items } = req.body;

    if (!_id) {
      return res.status(400).json({
        status: 400,
        message: "L'ID de l'élément à mettre à jour est manquant.",
      });
    }

    const step = await Step.findById(_id);
    if (!step) {
      return res.status(404).json({
        status: 404,
        message: "L'élément à mettre à jour n'a pas été trouvé.",
      });
    }

    step.nom_Step = nom_Step;
    step.id_items = id_items.map(item => {
      if (!item._id || !mongoose.Types.ObjectId.isValid(item._id)) {
        item._id = new mongoose.Types.ObjectId();
      }
      return item;
    });
    await step.save();
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
const getNomStepById = async (req, res) => {
  try {
    const { stepId } = req.params; 
    const step = await Step.findOne({ id_step: stepId }); 

    if (!step) {
      return res.status(404).json({ message: 'Step non trouvé' });
    }

    res.status(200).json({ nom_Step: step.nom_Step }); 
  } catch (error) {
    console.error('Erreur lors de la récupération de l\'étape par ID:', error);
    res.status(500).json({ message: 'Erreur interne du serveur' });
  }
};
module.exports = {
  createStep ,
  updateStep,
   ArchiverStep,
  ObligationStep,
  getStepsByRestaurantId,
  getNomStepById,
}