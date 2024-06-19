
const jwt = require('jsonwebtoken'); 
const bcrypt = require('bcrypt');
const User = require('../models/userModel');
const  nodemailer = require("nodemailer");

const GeocodedAd=require ('../models/AdresseModel');
const axios = require('axios');

const registerGoogle = async (req, res) => {
  
  const { nom, prenom, email } = req.body;

  try {
    const existingUser = await User.findOne({ email });

    if (existingUser) {
      return res.status(400).json({ message: 'Un utilisateur avec cet e-mail existe déjà' });
    }

    const newUser = new User({
      nom,
      prenom,
      email,
      telephone: '', 
      password: '', 
      validationCode: '', 
      isEmailConfirmed: true,
    });

    await newUser.save();

    return res.status(200).json({ success: true, message: 'Utilisateur enregistré avec succès.', userId: newUser._id });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ success: false, message: 'Erreur lors de l\'enregistrement de l\'utilisateur' });
  }
};



const checkUser = async (req, res) => {
  const { email } = req.query;

  try {
    const existingUser = await User.findOne({ email });

    if (existingUser) {
      res.status(200).json({ message: 'Utilisateur trouvé', userId: existingUser._id });
    } else {
      res.status(404).json({ message: 'Utilisateur non trouvé' });
    }
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Erreur lors de la recherche de l\'utilisateur' });
  }
};

const registerUser = async (req, res) => {
  const { nom, prenom, telephone, email, password, confirmPassword } = req.body;

  try {
    const existingUser = await User.findOne({ email });

    if (existingUser) {
      if (existingUser.isEmailConfirmed) {
        return res.status(400).json({ message: 'Un utilisateur avec cet e-mail existe déjà' });
      } else {
        const validationCode = Math.floor(100000 + Math.random() * 900000).toString();

        existingUser.validationCode = validationCode;
        await existingUser.save();

        sendConfirmationEmail(email, validationCode);

        return res.status(400).json({ message: 'Vous avez déjà un compte avec cet e-mail. Veuillez confirmer votre e-mail.' });
      }
    }

    if (password !== confirmPassword) {
      return res.status(400).json({ message: 'Les mots de passe ne correspondent pas' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const validationCode = Math.floor(100000 + Math.random() * 900000).toString();

    const newUser = new User({
      nom,
      prenom,
      telephone,
      email,
      password: hashedPassword,
      validationCode,
    });
    await newUser.save();

    sendConfirmationEmail(email, validationCode);

    return res.status(200).json({ success: true, message: 'Veuillez vérifier votre email pour activer votre compte.' });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ success: false, message: 'Erreur lors de l\'enregistrement de l\'utilisateur' });
  }
};


const confirmEmail = async (req, res) => {
  const {email, code } = req.body;

  try {
      const user = await User.findOne({ email });
      console.log(user);
      if (!user) {
          return res.status(404).json({ message: 'Utilisateur non trouvé' });
      }

      if (user.validationCode !== code) {
          return res.status(400).json({ message: 'Code de confirmation incorrect' });
      }

      user.isEmailConfirmed = true;
      await user.save();

      return res.status(200).json({ message: 'Email confirmé avec succè' });
  } catch (error) {
      console.error(error);
      return res.status(500).json({ message: 'Erreur lors de la confirmation de l\'email' });
  }
};

const sendConfirmationEmail = (email, validationCode) => {
  const transporter = nodemailer.createTransport({
      service: 'Gmail',
      auth: {
          user: 'meltingpot449@gmail.com',
          pass: 'zcvy livf qkty thhr',
      },
  });

  const mailOptions = {
      from: '"Assistant de restaurant" <meltingpot449@gmail.com>',
      to: email,
      subject: 'Confirmation de votre compte',
      text: `Votre code de confirmation est : ${validationCode}`
  };

  transporter.sendMail(mailOptions, (error, info) => {
      if (error) {
          console.error(error);
      } else {
          console.log('Email envoyé avec succée: ' + info.response);
      }
  });
};


const loginUser = async (req, res) => {
  const { email, password } = req.body;

  try {
    const user = await User.findOne({ email });

    if (!user) {
      return res.status(401).json({ message: ' Email invalide ' });
    }

    if (!user.isEmailConfirmed) {
      return res.status(401).json({ message: 'Email non confirmé' });
    }

    const passwordMatch = await bcrypt.compare(password, user.password);

    if (!passwordMatch) {
      return res.status(401).json({ message: 'Mot de passe invalide' });
    }

    const token = jwt.sign(
      { userId: user._id, email: user.email, nom: user.nom, telephone: user.telephone },
      'your-secret-key',
      { expiresIn: '7d' }
    );

    res.status(200).json({ token, userId: user._id, nom: user.nom, telephone: user.telephone, message: 'Connexion réussie' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

const reset_password = async (req, res) => {
  const { email } = req.body;

  try {
  
    const user = await User.findOne({ email });

    if (!user) {

      return res.status(404).json({ message: 'Utilisateur non trouvé.' });
    }

    const validationCode = Math.floor(100000 + Math.random() * 900000).toString();

    console.log('Generated Validation Code:', validationCode);

 
    user.validationCode = validationCode;
    user.validationCodeTimestamp = Date.now();

    await user.save();

    const transporter = nodemailer.createTransport({
      service: 'Gmail',
      auth: {
        user: 'meltingpot449@gmail.com',
        pass: 'zcvy livf qkty thhr',
      },
    });


    const mailOptions = {
      from:'"Assistant de restaurant" <meltingpot449@gmail.com>',
      to: email,
      subject: 'Code de validation',
      text: `Votre code de validation est : ${validationCode}`,
      replyTo: email,
    };

    transporter.sendMail(mailOptions, (error, info) => {
      if (error) {
        console.error(error);
        res.status(500).json({ success: false, message: 'Email not sent' });
      } else {
        console.log('Email envoyé avec succès: ' + info.response);
        res.json({ success: true, message: 'Email envoyé avec succès' });
      }
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, message: 'Erreur lors de la génération du code de validation.' });
  }
};




const validate_code = async (req, res) => {
  const { email, validationCode } = req.body;

  try {
  
    const user = await User.findOne({ email });

    if (!user) {
   
      return res.status(404).json({ success: false, message: 'Utilisateur non trouvé.' });
    }

   
    console.log('SCode de validation enregistré:', user.validationCode);
    console.log('Code de validation saisi:', validationCode);


    if (user.validationCode !== validationCode) {
      return res.status(400).json({ success: false, message: 'Code de validation incorrect.' });
    }

   
    const currentTime = Date.now();
    const codeExpirationTime = user.validationCodeTimestamp + 1 * 60 * 1000; 

    if (currentTime > codeExpirationTime) {
      return res.status(400).json({ success: false, message: 'Code de validation expiré.' });
    }

    user.validationCode = null;
    user.validationCodeTimestamp = null;
    await user.save();

    res.json({ success: true, message: 'Code de validation valide.' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, message: 'Erreur lors de la validation du code.' });
  }
};

const new_password = async (req, res) => {
  const { newPassword, confirmNewPassword } = req.body;
  const userEmail = req.query.email || req.body.email;

  try {

    const existingUser = await User.findOne({ email: userEmail });

    if (!existingUser) {
    
      return res.status(404).json({ success: false, message: 'Utilisateur non trouvé.' });
    }


    if (newPassword !== confirmNewPassword) {
      return res.status(400).json({ success: false, message: 'Les mots de passe ne correspondent pas.' });
    }

    
    const hashedPassword = await bcrypt.hash(newPassword, 10);

    existingUser.password = hashedPassword;

    await existingUser.save();

    res.json({ success: true, message: 'Mot de passe mis à jour avec succès.' });
  } catch (error) {
    console.error(error);

   
    if (error.name === 'MongoError' && error.code === 11000) {
    
      return res.status(400).json({ success: false, message: 'Erreur de clé dupliquée.' });
    }

   
    res.status(500).json({ success: false, message: 'Erreur lors de la mise à jour du mot de passe."' });
  }
};

const getUser= async (req, res) => {
  const { email } = req.query;
 
  try {
    const user = await User.findOne({ email: email });

    if (user) {
      res.json(user);
    } else {
      res.status(404).json({ message: 'Utilisateur non trouvé.' });
    }
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

const updateUser = async (req, res) => {
  const {  nom, prenom, telephone } = req.body;

  const userEmail = req.query.email;
  try {
 
    const existingUser = await User.findOne({ email: userEmail });

    if (!existingUser) {
 
      return res.status(404).json({ message: 'Utilisateur non trouvé.' });
    }

    
    if (nom) {
      existingUser.nom = nom;
    }
    if (prenom) {
      existingUser.prenom = prenom;
    }
    if (telephone)
 {
      existingUser.telephone = telephone;
    }

    await existingUser.save();

    res.status(200).json({ message: 'Utilisateur mis à jour avec succès.' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Internal server error' });
  }
};
const searchAddress = async (req, res) => {
  const { country, city, street, streetNumber } = req.body;
  const { _id } = req.query;

  if (!_id) {
    return res.status(400).json({ message: 'L\'ID utilisateur est manquant dans les en-têtes.' });
  }

  if (!country || !city || !street || !streetNumber) {
    return res.status(400).json({ message: 'Veuillez fournir des valeurs valides pour tous les champs.' });
  }

  const searchQuery = `${streetNumber} ${street}, ${city}, ${country}`;

  try {
    
    const existingGeocodedAddress = await GeocodedAd.findOne({
      _id,
    });

    if (existingGeocodedAddress) {
      return res.status(400).json({ message: 'L\'adresse géocodée pour ce utilisateur existe déjà dans la base de données.' });
    }

    const response = await axios.get('https://nominatim.openstreetmap.org/search', {
      params: {
        q: searchQuery,
        format: 'json',
      },
    });

    if (response.data.length > 0) {
      const firstGeocodedResult = response.data[0];

      if (!firstGeocodedResult.address || !firstGeocodedResult.address.house_number) {
      
        console.log("Numéro de rue non disponible. Procédure sans validation.");
      }

      const geocodedAddress = new GeocodedAd({
        _id,
        country,
        city,
        street,
        streetNumber,
        geocodedResults: firstGeocodedResult,
      });

      await geocodedAddress.save();

      return res.json({ message: 'Résultats de géocodage enregistrés ', results: firstGeocodedResult });
    } else {
      return res.json({ message: 'Aucun résultat de géocodage trouvé.' });
    }
  } catch (error) {
    console.error(error);
    return res.status(500).send('Erreur lors du géocodage de l\'adresse.');
  }
};



const getGeocodedDetails = async (req, res) => {
  const { _id } = req.query;

  try {
   
    const geocodedAddress = await GeocodedAd.findOne({ _id });

    if (!geocodedAddress) {
      return res.status(404).json({ message: 'Aucun résultat de géocodage trouvé pour cet utilisateur.' });
    }

    
    const { country, city, street, streetNumber } = geocodedAddress;

    res.json({status: 200,
      message: 'Détails de géocodage récupérés :',
      geocodedDetails: { country, city, street, streetNumber },
    });
  } catch (error) {
    console.error(error);
    res.status(500).send('Erreur lors de la récupération des détails de géocodage.');
  }
};
const updateGeocodedDetails = async (req, res) => {
  const { _id } = req.query;
  const { country, city, street, streetNumber } = req.body; 

  try {

    const geocodedAddress = await GeocodedAd.findOne({ _id });

    if (!geocodedAddress) {
      return res.status(404).json({ message: 'Aucun résultat de géocodage trouvé pour cet utilisateur.' });
    }

    if (!country || !city || !street || !streetNumber) {
      return res.status(400).json({ message: 'Veuillez fournir des valeurs valides pour tous les champs lors de la mise à jour.' });
    }

    const currentGeocodedResults = geocodedAddress.geocodedResults;

    geocodedAddress.country = country;
    geocodedAddress.city = city;
    geocodedAddress.street = street;
    geocodedAddress.streetNumber = streetNumber;

    await geocodedAddress.save();

  
    const updatedResponse = await axios.get('https://nominatim.openstreetmap.org/search', {
      params: {
        q: `${streetNumber} ${street}, ${city}, ${country}`,
        format: 'json',
      },
    });

  
    if (updatedResponse.data.length > 0) {
      geocodedAddress.geocodedResults = updatedResponse.data[0];
      await geocodedAddress.save();
    } else {
  
      geocodedAddress.geocodedResults = currentGeocodedResults;
      await geocodedAddress.save();
    }

    res.json({
      status: 200,
      message: 'Détails de géocodage mis à jour avec succès.',
      geocodedDetails: { country, city, street, streetNumber },
    });
  } catch (error) {
    console.error(error);
    res.status(500).send('Erreur lors de la mise à jour des détails de géocodage.');
  }
};

module.exports = {
  registerUser,
  confirmEmail,
  loginUser,
  reset_password,
  validate_code,
  new_password,
  getUser,
  updateUser,
  searchAddress,
  getGeocodedDetails,
  updateGeocodedDetails,
  registerGoogle,
  checkUser,
};