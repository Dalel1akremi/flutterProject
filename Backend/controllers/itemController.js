const Item = require('../models/itemModel');
const Step=require('./../models/StepModel');
exports.createItem = async (req, res) => {
  try {
    const { body, file } = req;
    const {
      nom,
      type,
      prix,
      description,
      isArchived,
      quantite,
      max_quantite,
      is_Menu,
      is_Redirect,
      id_cat,
      id_Steps,
      id,
    } = body;

    const imageUrl = file ? `http://localhost:3000/images/${file.filename}` : null;

    // Validate data types
    const validatedPrix = parseFloat(prix);
    const validatedIsArchived = isArchived === 'true';
    const validatedQuantite = parseInt(quantite);
    const validatedMaxQuantite = parseInt(max_quantite);
    const validatedIsMenu = is_Menu === 'true';
    const validatedIsRedirect = is_Redirect === 'true';

    // Check if validation fails
    if (isNaN(validatedPrix) || isNaN(validatedQuantite) || isNaN(validatedMaxQuantite)) {
      res.status(400).json({
        status: 400,
        message: 'Invalid data types in request body',
      });
      return;
    }

    const existingItem = await Item.findOne({ nom });

    if (existingItem !== null) {
      res.status(400).json({
        status: 400,
        message: 'Ce Item existe déjà',
      });
      return;
    }

    console.log('New Item Data:', {
      nom,
      type,
      prix: validatedPrix,
      description,
      isArchived: validatedIsArchived,
      quantite: validatedQuantite,
      max_quantite: validatedMaxQuantite,
      is_Menu: validatedIsMenu,
      is_Redirect: validatedIsRedirect,
      id_cat,
      id,
    });

    let newItemData = {
      nom,
      type,
      prix: validatedPrix,
      description,
      isArchived: validatedIsArchived,
      quantite: validatedQuantite,
      max_quantite: validatedMaxQuantite,
      is_Menu: validatedIsMenu,
      is_Redirect: validatedIsRedirect,
      id_cat,
      id,
      image: imageUrl,
    };

    if (validatedIsMenu) {
      const idStepsArray = id_Steps.split(',').map(idStep => ({ id_Step: parseInt(idStep) }));
      newItemData.id_Steps = idStepsArray;
    } else {
      newItemData.id_Steps = null;
    }

    const newItem = new Item(newItemData);

    const savedItem = await newItem.save();
    res.status(200).json({
      status: 200,
      message: 'Item créé avec succès',
      savedItem,
    });

  } catch (error) {
    console.error(error);
    res.status(500).json({
      status: 500,
      message: 'Erreur lors de la création de Item',
    });
  }
};
exports.getItem = async (req, res) => {
  try {
    const { id_cat } = req.query;

    // Fetch items based on the provided category and populate the id_Steps field
    const items = await Item.find({ 'id_cat': id_cat }).populate('id_Steps.id_Step');

    // Check if items array is empty
    if (items.length === 0) {
      res.status(200).json({
        status: 200,
        message: 'Aucun Item trouvé pour cette catégorie',
        formattedItems: [],  // Send an empty array instead of null
      });
    } else {
      // Existing code for formatting items
// Existing code for formatting items
const formattedItems = await Promise.all(items.map(async (item) => {
  const idStepData = await Promise.all((item.id_Steps || []).map(async (step) => {
    // Check if step.id_Step exists before trying to fetch data
    if (step.id_Step) {
      const stepData = await Step.findOne({ 'id_Step': step.id_Step }).lean();
      const idItemsData = await Promise.all((stepData ? stepData.id_items : []).map(async (idItem) => {
        const itemData = await Item.findOne({ 'id_item': idItem.id_item }).lean();
        return {
          id_item: idItem.id_item,
          nom_item: itemData ? itemData.nom : null,
         
          // Add more properties as needed
        };
      }));

      return {
        id_Step: step.id_Step,
        nom_Step: stepData ? stepData.nom_Step : null,
        id_items: idItemsData,
        is_Obligatoire: stepData ? stepData.is_Obligatoire : null, // Add is_Obligatoire field
      };
    } else {
      return null; // Handle the case where id_Step is missing or null
    }
  }));

  return {
    id_item: item.id_item,
    nom: item.nom,
    type: item.type,
    prix: item.prix,
    description: item.description,
    isArchived: item.isArchived,
    quantite: item.quantite,
    max_quantite: item.max_quantite,
    is_Menu: item.is_Menu,
    is_Redirect: item.is_Redirect,
    image: item.image,
    id_cat: item.id_cat,
    id_Steps: idStepData.filter((step) => step !== null), // Remove null entries
  
  };
}));

      res.status(200).json({
        status: 200,
        message: 'Item récupérés avec succès',
        formattedItems,
      });
    }
  } catch (error) {
    console.error(error);
    res.status(500).json({
      status: 500,
      message: 'Erreur lors de la récupération des Item',
    });
  }

};
