
const jwt = require('jsonwebtoken'); 
const bcrypt = require('bcrypt');
const User = require('../models/userModel');
const  nodemailer = require("nodemailer");

const GeocodedAd=require ('../models/AdresseModel');
const axios = require('axios');
const registerUser = async (req, res) => {
  const { nom, prenom, telephone, email, password, confirmPassword } = req.body;

  try {
 
    const existingUser = await User.findOne({ email });

    if (existingUser) {
  
      return res.status(400).json({ message: 'User with this email already exists' });
    }

    if (password !== confirmPassword) {
      return res.status(400).json({ message: 'Passwords do not match' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const newUser = new User({
      nom,
      prenom,
      telephone,
      email,
      password: hashedPassword,
      
    });

    await newUser.save();

    res.status(201).json({ message: 'User registered successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Internal server error' });
  }
};
const loginUser = async (req, res) => {
  const { email, password } = req.body;

  try {
  
    const user = await User.findOne({ email });

    if (!user) {
      
      return res.status(401).json({ message: 'Invalid email or password' });
    }

    const passwordMatch = await bcrypt.compare(password, user.password);

    if (!passwordMatch) {
   
      return res.status(401).json({ message: 'Invalid email or password' });
    }


    const token = jwt.sign(
      { userId: user._id, email: user.email ,nom: user.nom,telephone:user.telephone},
      'your-secret-key',
      { expiresIn: '7d' } 
    );

    res.status(200).json({ token, userId: user._id,nom: user.nom,telephone:user.telephone, message: 'Login successful' });
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
        console.log('Email sent successfully: ' + info.response);
        res.json({ success: true, message: 'Email sent successfully' });
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

   
    console.log('Stored Validation Code:', user.validationCode);
    console.log('Entered Validation Code:', validationCode);


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
    
      return res.status(404).json({ success: false, message: 'User not found.' });
    }


    if (newPassword !== confirmNewPassword) {
      return res.status(400).json({ success: false, message: 'Passwords do not match.' });
    }

    
    const hashedPassword = await bcrypt.hash(newPassword, 10);

    existingUser.password = hashedPassword;

    await existingUser.save();

    res.json({ success: true, message: 'Password updated successfully.' });
  } catch (error) {
    console.error(error);

   
    if (error.name === 'MongoError' && error.code === 11000) {
    
      return res.status(400).json({ success: false, message: 'Duplicate key error.' });
    }

   
    res.status(500).json({ success: false, message: 'Error updating password.' });
  }
};

const getUser= async (req, res) => {
  const { email } = req.query;
 
  try {
    const user = await User.findOne({ email: email });

    if (user) {
      res.json(user);
    } else {
      res.status(404).json({ message: 'User not found' });
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
 
      return res.status(404).json({ message: 'User not found' });
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

    res.status(200).json({ message: 'User updated successfully' });
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
      
        console.log("Street Number not available. Proceeding without validation.");
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
  loginUser,
  reset_password,
  validate_code,
  new_password,
  getUser,
  updateUser,
  searchAddress,
  getGeocodedDetails,
  updateGeocodedDetails,
};