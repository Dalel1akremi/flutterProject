// controllers/itemController.js

const Redirect =require( '../models/RedirectModel');
const createRedirect  = async (req, res) => {
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
      id_rest,
    } = body;
    const imageUrl = file ? `images/${file.filename}` : null;
    const validatedPrix = parseFloat(prix);
    const validatedIsArchived = Boolean(isArchived);
    const validatedQuantite = parseInt(quantite);
    const validatedMaxQuantite = parseInt(max_quantite);
    const validatedIsMenu = Boolean(is_Menu);
    if (isNaN(validatedPrix)) {
      console.error(' Prix invalide:', prix);
    }
  
    if (isNaN(validatedQuantite)) {
      console.error('Quantite invalide:', quantite);
    }
    if (isNaN(validatedMaxQuantite)) {
      console.error('Max_quantite invalide:', max_quantite);
    }

    if (isNaN(validatedPrix) || isNaN(validatedQuantite) || isNaN(validatedMaxQuantite)) {
      
      res.json({
        status: 400,
        message: 'Types de données invalides dans le corps de la requête'
      });
      return;
    }

    const existingRedirect = await Redirect.findOne({nom,id_rest });

    if (existingRedirect) {
      
      res.json({
        status: 400,
        message: 'Cet Redirect existe déjà'
      });
      return;
    }
    console.log('Nouvelles données de redirect:', {
      id_item,
      nom,
      prix:validatedPrix,
      description,
      isArchived:validatedIsArchived,
      quantite: validatedQuantite,
      max_quantite: validatedMaxQuantite,
      is_Menu: validatedIsMenu,
      id_rest,
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
      image: imageUrl,
      id_rest
    });

    const savedRedirect = await newRedirect.save();
    res.json({
      status: 200,
      message: 'Redirect crée avec succée ',
      data: savedRedirect,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      status: 500,
      message: 'Erreur lors de création de  Redirect',
      error: error.message,
    });
  }
};

const getRedirect= async (req, res) => {
  try {
    const { id_item,id_rest} = req.query;

    const Redirects = await Redirect.find({ id_item ,id_rest,'isArchived': false });


    if (Redirect.length === 0) {
      
      res.json({
        status: 404,
        message: 'Aucun Redirect trouvé pour ce type',
        
      });
    } else {
      
      res.json({
        status: 200,
        message: 'Redirect récupérés avec succès',
        data:Redirects
        
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
const getRedirectAd= async (req, res) => {
  try {
    const { id_item,id_rest} = req.query;

    const Redirects = await Redirect.find({ id_item ,id_rest});


    if (Redirect.length === 0) {
      
      res.json({
        status: 404,
        message: 'Aucun Redirect trouvé pour ce type',
        
      });
    } else {
      
      res.json({
        status: 200,
        message: 'Redirect récupérés avec succès',
        data:Redirects
        
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
const ArchiverRedirect = async (req, res) => {
  try {
    const { _id} = req.params;
    const { isArchived } = req.body;
   

    if (!_id) {
      return res.status(400).json({
        status: 400,
        message: "L'ID de l'élément à mettre à jour est manquant.",
      });
    }

    await Redirect.findOneAndUpdate({ _id: _id }, { isArchived });

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

const updateRedirect = async (req, res) => {
  try {
    const { _id } = req.params;
    const { nom, prix, description, quantite, max_quantite } = req.body;


    if (!_id) {
      return res.status(400).json({
        status: 400,
        message: "L'ID de l'élément à mettre à jour est manquant.",
      });
    }

    await Redirect.findOneAndUpdate({ _id:_id}, {
      nom,
      prix,
      description,
      quantite,
      max_quantite,
    });

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
  createRedirect ,
   getRedirect,
  ArchiverRedirect,
  updateRedirect,
  getRedirectAd,
}