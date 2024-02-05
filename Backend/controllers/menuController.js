
const Menu = require('../models/menuModel');

exports.createMenu = async (req, res) => {
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
      nom_cat,
      id,
    } = body;
    const imageUrl = file ? `localhost:3000/images/${file.filename}` : null;

    // Validate data types
    const validatedPrix = parseFloat(prix);
    const validatedIsArchived = Boolean(isArchived);
    const validatedQuantite = parseInt(quantite);
    const validatedMaxQuantite = parseInt(max_quantite);
    const validatedIsMenu = Boolean(is_Menu);

    // Check if validation fails
    if (isNaN(validatedPrix)) {
      console.error('Invalid prix:', prix);
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

    const existingMenu = await Menu.findOne({ nom });

    if (existingMenu) {
      
      res.json({
        status: 400,
        message: 'Ce menu existe déjà'
      });
      return;
    }
    console.log('New Menu Data:', {
      nom,
      type,
      prix: validatedPrix,
      description,
      isArchived: validatedIsArchived,
      quantite: validatedQuantite,
      max_quantite: validatedMaxQuantite,
      is_Menu: validatedIsMenu,
      nom_cat,
      id,  // Log the id field
    });
    const newMenu = new Menu({
      nom,
      type,
      prix: validatedPrix,
      description,
      isArchived: validatedIsArchived,
      quantite: validatedQuantite,
      max_quantite: validatedMaxQuantite,
      is_Menu: validatedIsMenu,
      nom_cat,
      id,
      image: imageUrl,
    });

    const savedMenu = await newMenu.save();
    res.json({
      status: 200,
      message: 'Menu item created successfully',
      data: savedMenu,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      status: 500,
      message: 'Error creating menu item',
      error: error.message,
    });
  }
};



exports.getMenu = async (req, res) => {
  try {
    const { nom_cat } = req.query;

    // Fetch menus based on the provided type
    const menus = await Menu.find({ nom_cat });

    if (menus.length === 0) {
      
      res.json({
        status: 404,
        message: 'Aucun menu trouvé pour ce type',
        
      });
    } else {
      
      res.json({
        status: 200,
        message: 'Menus récupérés avec succès',
        data:menus
        
      });
    }
  } catch (error) {
    console.error(error);
    sendResponse(res, 500, 'Erreur lors de la récupération des menus', null, error.message);
  }
};
