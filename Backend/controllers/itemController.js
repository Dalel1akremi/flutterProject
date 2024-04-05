const Item = require('../models/itemModel');
const Step=require('./../models/StepModel');
exports.createItem = async (req, res) => {
  try {
    const { body, file } = req;
    const {
      nom,
      prix,
      description,
      quantite,
      max_quantite,
      is_Menu,
      is_Redirect,
      id_cat,
      id_Steps,
      id_rest,
    } = body;

    const imageUrl = file ? `http://localhost:3000/images/${file.filename}` : null;

    const validatedPrix = parseFloat(prix);
    const validatedQuantite = parseInt(quantite);
    const validatedMaxQuantite = parseInt(max_quantite);
    const validatedIsMenu = is_Menu === 'true';
    const validatedIsRedirect = is_Redirect === 'true';

    if (isNaN(validatedPrix) || isNaN(validatedQuantite) || isNaN(validatedMaxQuantite)) {
      res.status(400).json({
        status: 400,
        message: 'Types de données invalides dans le corps de la requête',
      });
      return;
    }

    // Vérifier si un item avec le même nom existe déjà pour ce restaurant
    const existingItem = await Item.findOne({ nom, id_rest });

    if (existingItem !== null) {
      res.status(400).json({
        status: 400,
        message: 'Cet Item existe déjà pour ce restaurant',
      });
      return;
    }

    const idStepsArray = validatedIsMenu ? id_Steps.split(',').map(idStep => ({ id_Step: parseInt(idStep) })) : null;

    const newItemData = {
      nom,
      prix: validatedPrix,
      description,
      isArchived: false,
      quantite: validatedQuantite,
      max_quantite: validatedMaxQuantite,
      is_Menu: validatedIsMenu,
      is_Redirect: validatedIsRedirect,
      id_cat,
      image: imageUrl,
      id_rest,
      id_Steps: idStepsArray,
    };

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
      message: 'Erreur lors de la création de l\'Item',
    });
  }
};


exports.getItem = async (req, res) => {
  try {
    const { id_cat, id_rest } = req.query;
    const items = await Item.find({ 'id_cat': id_cat, 'id_rest': id_rest, 'isArchived': false }).populate('id_Steps.id_Step');

    if (items.length === 0) {
      res.status(200).json({
        status: 200,
        message: 'Aucun Item trouvé pour cette catégorie et ce restaurant',
        formattedItems: [],  
      });
    } else {
      const formattedItems = await Promise.all(items.map(async (item) => {
        const idStepData = await Promise.all((item.id_Steps || []).map(async (step) => {
          if (step.id_Step) {
            const stepData = await Step.findOne({ 'id_Step': step.id_Step }).lean();
            const idItemsData = await Promise.all((stepData ? stepData.id_items : []).map(async (idItem) => {
              const itemData = await Item.findOne({ 'id_item': idItem.id_item }).lean();
              return {
                id_item: idItem.id_item,
                nom_item: itemData ? itemData.nom : null,
              };
            }));

            return {
              id_Step: step.id_Step,
              nom_Step: stepData ? stepData.nom_Step : null,
              id_items: idItemsData,
              is_Obligatoire: stepData ? stepData.is_Obligatoire : null, 
            };
          } else {
            return null;
          }
        }));

        return {
          id_item: item.id_item,
          nom: item.nom,
          prix: item.prix,
          description: item.description,
          isArchived: item.isArchived,
          quantite: item.quantite,
          max_quantite: item.max_quantite,
          is_Menu: item.is_Menu,
          is_Redirect: item.is_Redirect,
          image: item.image,
          id_cat: item.id_cat,
          id_Steps: idStepData.filter((step) => step !== null), 
          id_rest: item.id_rest,
        };
      }));

      res.status(200).json({
        status: 200,
        message: 'Items récupérés avec succès',
        formattedItems,
      });
    }
  } catch (error) {
    console.error(error);
    res.status(500).json({
      status: 500,
      message: 'Erreur lors de la récupération des Items',
    });
  }
};


exports.getItems = async (req, res) => {
  try {
    const items = await Item.find();
    res.status(200).json({
      status: 200,
      message: 'Items récupérés avec succès',
      items,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      status: 500,
      message: 'Erreur lors de la récupération des items',
    });
  }
};
exports.updateItem = async (req, res) => {
  try {
    const { itemId } = req.params;
    const { isArchived } = req.body; 


    if (!itemId) {
      return res.status(400).json({
        status: 400,
        message: "L'ID de l'élément à mettre à jour est manquant.",
      });
    }

    await Item.findByIdAndUpdate(itemId, { isArchived });

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
exports.getItemsByRestaurantId = async (req, res) => {
  try {
    const id_restaurant = req.query.id_rest; // Récupère l'ID du restaurant à partir des paramètres de la requête

    // Supposons que votre modèle Item soit importé et correctement défini
    const items = await Item.find({ id_rest: id_restaurant }); // Requête pour récupérer les éléments du restaurant spécifié par son ID

    res.status(200).json({
      status: 200,
      message: 'Items récupérés avec succès pour le restaurant correspondant',
      items,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      status: 500,
      message: 'Erreur lors de la récupération des items pour le restaurant correspondant',
    });
  }
};
