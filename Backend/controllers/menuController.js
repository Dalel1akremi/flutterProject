// controllers/menuController.js

const Menu =require( '../models/menuModel');

const sendResponse = (res, status, message, data = null, error = null) => {
  res.status(status).json({ status, message, data, error });
};

exports.createMenu = async (req, res) => {
                    try {
                      const {
                        nom,
                        type,
                        prix,
                        description,
                        isArchived,
                        image,
                        quantite,
                        max_quantite,
                        is_Menu,
                        nom_cat,
                        id,
                      } = req.body;
                  
                      // Check if a menu with the same name already exists
                      const existingMenu = await Menu.findOne({ nom });
                      if (existingMenu) {
                        sendResponse(res, 400, 'Ce menu existe déjà', null);
                        return;
                      }
                  
                      const newMenu = new Menu({
                        nom,
                        type,
                        prix,
                        description,
                        isArchived,
                        image,
                        quantite,
                        max_quantite,
                        is_Menu,
                        nom_cat,
                        id,
                      });
                  
                      await newMenu.save();
                      sendResponse(res, 201, 'Menu créé avec succès', newMenu);
                    } catch (error) {
                      console.error(error);
                      sendResponse(res, 500, 'Erreur lors de la création du menu', null, error.message);
                    }
                  };
                  exports.getMenu = async (req, res) => {
                    try {
                      const { type } = req.query;
                  
                      // Fetch menus based on the provided type
                      const menus = await Menu.find({ type });
                  
                      if (menus.length === 0) {
                        sendResponse(res, 404, 'Aucun menu trouvé pour ce type', null);
                      } else {
                        sendResponse(res, 200, 'Menus récupérés avec succès', menus);
                      }
                    } catch (error) {
                      console.error(error);
                      sendResponse(res, 500, 'Erreur lors de la récupération des menus', null, error.message);
                    }
                  };