const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const cors = require('cors');
const busboy = require('express-busboy');
const Menu = require('../models/menuModel');
const path = require('path');
const fs = require('fs');
const { v4: uuidv4 } = require('uuid');

const sendResponse = (res, status, message, data = null, error = null) => {
  res.status(status).json({ status, message, data, error });
};

const uploadImage = async (filename, buffer) => {
  const uniqueFilename = `${uuidv4()}_${filename}`;
  const imagePath = path.join(__dirname, '../public/images/', uniqueFilename);

  // Use asynchronous file writing to avoid blocking the event loop
  await fs.promises.writeFile(imagePath, buffer);

  // Create a URL based on the image path
  const imageUrl = `/public/images/${uniqueFilename}`;
  return imageUrl;
};
const app = express();
// Set up express-busboy middleware
busboy.extend(app, {
  upload: true,
  path: './public/images',
  allowedPath: /./,
});

exports.createMenu = async (req, res) => {
  try {
    const {
      nom,
      type,
      prix,
      description,
      isArchived,
      image: imageUrl,
      quantite,
      max_quantite,
      is_Menu,
      nom_cat,
      id,
    } = req.body;

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
      sendResponse(res, 400, 'Invalid data types in request body', null);
      return;
    }

    const existingMenu = await Menu.findOne({ nom });

    if (existingMenu) {
      sendResponse(res, 400, 'Ce menu existe déjà', null);
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
    });

    const data = await newMenu.save();
    console.log("data: ", data);
    sendResponse(res, 201, 'Menu créé avec succès', newMenu);
  } catch (error) {
    console.error(error);
    sendResponse(res, 500, 'Erreur lors de la création du menu', null, error.message);
  }
};



exports.getMenu = async (req, res) => {
  try {
    const { nom_cat } = req.query;

    // Fetch menus based on the provided type
    const menus = await Menu.find({ nom_cat });

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
