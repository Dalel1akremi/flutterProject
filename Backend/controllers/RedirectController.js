// controllers/itemController.js

const Redirect =require( '../models/RedirectModel');
exports.createRedirect = async (req, res) => {
  try {
    const { body, file } = req;

    const {
      id_item,
      nom,
      prix,
      description,
      isArchived,
      quantite,
      max_quantite,
      is_Menu,
      id_cat,
      id,
    } = body;
    const imageUrl = file ? `http://localhost:3000/images/${file.filename}` : null;
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

    const existingRedirect = await Redirect.findOne({nom });

    if (existingRedirect) {
      
      res.json({
        status: 400,
        message: 'Cet Redirect existe déjà'
      });
      return;
    }
    console.log('New Redirect Data:', {
      id_item,
      nom,
      prix:validatedPrix,
      description,
      isArchived:validatedIsArchived,
      quantite: validatedQuantite,
      max_quantite: validatedMaxQuantite,
      is_Menu: validatedIsMenu,
      id_cat,
      id,
       // Log the id field
    });
    const newRedirect = new Redirect({
      id_item,
      nom,
      prix:validatedPrix,
      description,
      isArchived:validatedIsArchived,
      quantite: validatedQuantite,
      max_quantite: validatedMaxQuantite,
      is_Menu: validatedIsMenu,
      id_cat,
      id,
      image: imageUrl,
    });

    const savedRedirect = await newRedirect.save();
    res.json({
      status: 200,
      message: 'Redirect created successfully',
      data: savedRedirect,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      status: 500,
      message: 'Error creating Redirect',
      error: error.message,
    });
  }
};

exports.getRedirect= async (req, res) => {
  try {
    const { id_item} = req.query;

    // Fetch menus based on the provided type
    const Redirect = await Redirect.find({ id_item });

    if (Redirect.length === 0) {
      
      res.json({
        status: 404,
        message: 'Aucun Redirect trouvé pour ce type',
        
      });
    } else {
      
      res.json({
        status: 200,
        message: 'Redirect récupérés avec succès',
        data:Item
        
      });
    }
  } catch (error) {
    console.error(error);
    res.json({
      status: 500,
      message: 'Erreur lors de la récupération des Redirects',
      error:error.message
      
    });
   
  }
};