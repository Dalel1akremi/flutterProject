// controllers/itemController.js

const Items =require( '../models/itemsModel');
exports.createItem = async (req, res) => {
  try {
    const { body, file } = req;

    const {
      nom_item,
      prix,
      isObligatoire,
      description,
      isArchived,
      quantite,
      max_quantite,
      is_Menu,
      id_cat,
      id,
<<<<<<< HEAD
      id_menu,
=======
      nom,
>>>>>>> 7f07aee (feat:fix `itemController`)
    } = body;
    const imageUrl = file ? `http://localhost:3000/images/${file.filename}` : null;
    // Validate data types
    const validatedPrix = parseFloat(prix);
    const validatedIsObligatoire = Boolean(isObligatoire);
    const validatedIsArchived = Boolean(isArchived);
    const validatedQuantite = parseInt(quantite);
    const validatedMaxQuantite = parseInt(max_quantite);
    const validatedIsMenu = Boolean(is_Menu);

    // Check if validation fails
    if (isNaN(validatedPrix)) {
      console.error('Invalid prix:', prix);
    }
    if (isNaN(validatedIsObligatoire)) {
      console.error('Invalid data for obligatoire:', isObligatoire);
    }
    if (isNaN(validatedQuantite)) {
      console.error('Invalid quantite:', quantite);
    }
    if (isNaN(validatedMaxQuantite)) {
      console.error('Invalid max_quantite:', max_quantite);
    }

    if (isNaN(validatedPrix) || isNaN(validatedQuantite) || isNaN(validatedMaxQuantite)) {
      
      res.json({
        status: 400,
        message: 'Invalid data types in request body'
      });
      return;
    }

<<<<<<< HEAD
    const existingItem = await Items.findOne({nom_item });
=======
    const existingItem = await Items.findOne({ nom });
>>>>>>> 7f07aee (feat:fix `itemController`)

    if (existingItem) {
      
      res.json({
        status: 400,
        message: 'Cet Item existe déjà'
      });
      return;
    }
    console.log('New Item Data:', {
      nom_item,
      prix:validatedPrix,
      isObligatoire:validatedIsObligatoire,
      description,
      isArchived:validatedIsArchived,
      quantite: validatedQuantite,
      max_quantite: validatedMaxQuantite,
      is_Menu: validatedIsMenu,
<<<<<<< HEAD
      id_cat,
      id,
      id_menu,  // Log the id field
=======
      nom_cat,
      id,
      nom,  // Log the id field
>>>>>>> 7f07aee (feat:fix `itemController`)
    });
    const newItem = new Items({
      nom_item,
      prix:validatedPrix,
      isObligatoire:validatedIsObligatoire,
      description,
      isArchived:validatedIsArchived,
      quantite: validatedQuantite,
      max_quantite: validatedMaxQuantite,
      is_Menu: validatedIsMenu,
<<<<<<< HEAD
      id_cat,
      id,
      id_menu, 
=======
      nom_cat,
      id,
      nom, 
>>>>>>> 7f07aee (feat:fix `itemController`)
      image: imageUrl,
    });

    const savedItem = await newItem.save();
    res.json({
      status: 200,
      message: 'Item created successfully',
      data: savedItem,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      status: 500,
      message: 'Error creating menu item',
      error: error.message,
    });
<<<<<<< HEAD
  }
};

exports.getItem = async (req, res) => {
  try {
    const { id_menu } = req.query;

    // Fetch menus based on the provided type
    const Item = await Items.find({ id_menu });

    if (Item.length === 0) {
      
      res.json({
        status: 404,
        message: 'Aucun item trouvé pour ce type',
        
      });
    } else {
      
      res.json({
        status: 200,
        message: 'Items récupérés avec succès',
        data:Item
        
      });
    }
  } catch (error) {
    console.error(error);
    res.json({
      status: 500,
      message: 'Erreur lors de la récupération des items',
      error:error.message
      
    });
   
=======
>>>>>>> 7f07aee (feat:fix `itemController`)
  }
};

exports.getItem = async (req, res) => {
  try {
    const { nom } = req.query;

    // Fetch menus based on the provided type
    const Item = await Items.find({ nom });

    if (Item.length === 0) {
      
      res.json({
        status: 404,
        message: 'Aucun item trouvé pour ce type',
        
      });
    } else {
      
      res.json({
        status: 200,
        message: 'Items récupérés avec succès',
        data:Item
        
      });
    }
  } catch (error) {
    console.error(error);
    res.json({
      status: 500,
      message: 'Erreur lors de la récupération des items',
      error:error.message
      
    });
   
  }
};
