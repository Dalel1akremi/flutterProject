// controllers/AdminController.js
const jwt = require('jsonwebtoken'); 
const bcrypt = require('bcrypt');
const Admin = require('../models/adminModel');
const  nodemailer = require("nodemailer");

const  crypto= require("crypto");
const GeocodedAd=require ('../models/AdresseModel');
const axios = require('axios');
const registerAdmin = async (req, res) => {
  const { nom, prenom, telephone, email, password, confirmPassword } = req.body;

  try {
    // Check if a Admin with the same email already exists
    const existingAdmin = await Admin.findOne({ email });

    if (existingAdmin) {
      // Admin with the same email already exists
      return res.status(400).json({ message: 'Admin with this email already exists' });
    }

    // Check if passwords match
    if (password !== confirmPassword) {
      return res.status(400).json({ message: 'Passwords do not match' });
    }

    // Hash the password before saving it
    const hashedPassword = await bcrypt.hash(password, 10);

    // Create a new Admin with the hashed password
    const newAdmin = new Admin({
      nom,
      prenom,
      telephone,
      email,
      password: hashedPassword,
      
    });

    // Save the Admin to the database
    await newAdmin.save();

    res.status(201).json({ message: 'Admin registered successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Internal server error' });
  }
};
const loginAdmin = async (req, res) => {
                    const { email, password } = req.body;
                  
                    try {
                      // Recherche de l'utilisateur dans la base de données
                      const admin = await Admin.findOne({ email });
                  
                      if (!admin) {
                        // L'utilisateur n'existe pas
                        return res.status(401).json({ message: 'Invalid email or password' });
                      }
                  
                      // Vérification du mot de passe
                      const passwordMatch = await bcrypt.compare(password, admin.password);
                  
                      if (!passwordMatch) {
                        // Mot de passe incorrect
                        return res.status(401).json({ message: 'Invalid email or password' });
                      }
                  
                      // Création d'un jeton JWT
                      const token = jwt.sign(
                        { adminId: admin._id, email: admin.email ,nom: admin.nom,telephone:admin.telephone},
                        'your-secret-key', // Remplacez par une clé secrète plus sécurisée dans un environnement de production
                        { expiresIn: '7d' } // Durée de validité du jeton (1 heure dans cet exemple)
                      );
                  
                      res.status(200).json({ token, adminId: admin._id,nom: admin.nom,telephone:admin.telephone, message: 'Login successful' });
                    } catch (error) {
                      console.error(error);
                      res.status(500).json({ message: 'Internal server error' });
                    }
                  };
const reset_password = async (req, res) => {
  const { email } = req.body;

  try {
    // Recherche de l'utilisateur dans la base de données
    const admin = await Admin.findOne({ email });

    if (!admin) {
      // L'utilisateur n'existe pas
      return res.status(404).json({ message: 'Utilisateur non trouvé.' });
    }

    // Générer un nouveau code de validation aléatoire à 6 chiffres
    const validationCode = Math.floor(100000 + Math.random() * 900000).toString();

    // Debugging: Log the generated validation code
    console.log('Generated Validation Code:', validationCode);

    // Update the admin object with the new validation code
    admin.validationCode = validationCode;
    admin.validationCodeTimestamp = Date.now();

    // Save the admin object with the new validation code
    await admin.save();

    const transporter = nodemailer.createTransport({
      service: 'Gmail',
      auth: {
                    admin: 'meltingpot449@gmail.com',
        pass: 'zcvy livf qkty thhr',
      },
    });

    // Envoyer le code de validation par e-mail
    const mailOptions = {
      from: '', // Put your email address here
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
  
    const admin = await admin.findOne({ email });

    if (!admin) {
   
      return res.status(404).json({ success: false, message: 'Utilisateur non trouvé.' });
    }

   
    console.log('Stored Validation Code:', admin.validationCode);
    console.log('Entered Validation Code:', validationCode);


    if (admin.validationCode !== validationCode) {
      return res.status(400).json({ success: false, message: 'Code de validation incorrect.' });
    }

   
    const currentTime = Date.now();
    const codeExpirationTime = admin.validationCodeTimestamp + 1 * 60 * 1000; 

    if (currentTime > codeExpirationTime) {
      return res.status(400).json({ success: false, message: 'Code de validation expiré.' });
    }

    admin.validationCode = null;
    admin.validationCodeTimestamp = null;
    await admin.save();

    res.json({ success: true, message: 'Code de validation valide.' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, message: 'Erreur lors de la validation du code.' });
  }
};

const new_password = async (req, res) => {
  const { newPassword, confirmNewPassword } = req.body;
  const adminEmail = req.query.email || req.body.email;

  try {

    const existingAdmin = await Admin.findOne({ email: adminEmail });

    if (!existingAdmin) {
    
      return res.status(404).json({ success: false, message: 'Admin not found.' });
    }


    if (newPassword !== confirmNewPassword) {
      return res.status(400).json({ success: false, message: 'Passwords do not match.' });
    }

    
    const hashedPassword = await bcrypt.hash(newPassword, 10);

    existingAdmin.password = hashedPassword;

    await existingAdmin.save();

    res.json({ success: true, message: 'Password updated successfully.' });
  } catch (error) {
    console.error(error);

   
    if (error.name === 'MongoError' && error.code === 11000) {
    
      return res.status(400).json({ success: false, message: 'Duplicate key error.' });
    }

   
    res.status(500).json({ success: false, message: 'Error updating password.' });
  }
};


const getAdmin = async (req, res) => {
 
  try{
 
  const admin = await Admin.findOne();

  if (admin) {
    res.json(admin);
  } else {
    res.status(404).json({ message: 'Admin not found' });
  }
} catch (error) {
  console.error(error);
  res.status(500).json({ message: 'Internal server error' });
}
};
const updateAdmin = async (req, res) => {
  const {  nom, prenom, telephone } = req.body;

  const adminEmail = req.query.email;
  try {
 
    const existingAdmin = await Admin.findOne({ email: adminEmail });

    if (!existingAdmin) {
 
      return res.status(404).json({ message: 'Admin not found' });
    }

    
    if (nom) {
      existingAdmin.nom = nom;
    }
    if (prenom) {
      existingAdmin.prenom = prenom;
    }
    if (telephone)
 {
      existingAdmin.telephone = telephone;
    }

    // Sauvegarder les modifications
    await existingAdmin.save();

    res.status(200).json({ message: 'Admin updated successfully' });
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

  // Validate that all four fields are provided
  if (!country || !city || !street || !streetNumber) {
    return res.status(400).json({ message: 'Veuillez fournir des valeurs valides pour tous les champs.' });
  }

  const searchQuery = `${streetNumber} ${street}, ${city}, ${country}`;

  try {
    // Check if the geocoded address already exists in the database for the given admin (_id)
    const existingGeocodedAddress = await GeocodedAd.findOne({
      _id,
    });

    if (existingGeocodedAddress) {
      return res.status(400).json({ message: 'L\'adresse géocodée pour ce utilisateur existe déjà dans la base de données.' });
    }

    // If not, proceed with the geocoding process
    const response = await axios.get('https://nominatim.openstreetmap.org/search', {
      params: {
        q: searchQuery,
        format: 'json',
      },
    });

    if (response.data.length > 0) {
      const firstGeocodedResult = response.data[0];

      // Check if the geocoding result has a street number
      if (!firstGeocodedResult.address || !firstGeocodedResult.address.house_number) {
        // Allow the geocoding without a house_number for certain places
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
  const { _id } = req.query; // admin ID

  try {
    // Find the geocoded address in the database based on admin ID
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
  const { _id } = req.query; // admin ID
  const { country, city, street, streetNumber } = req.body; // Updated geocoded details

  try {
    // Find the geocoded address in the database based on admin ID
    const geocodedAddress = await GeocodedAd.findOne({ _id });

    if (!geocodedAddress) {
      return res.status(404).json({ message: 'Aucun résultat de géocodage trouvé pour cet utilisateur.' });
    }

    // Validate that all four fields are provided for the update
    if (!country || !city || !street || !streetNumber) {
      return res.status(400).json({ message: 'Veuillez fournir des valeurs valides pour tous les champs lors de la mise à jour.' });
    }

    // Save the current geocoded results
    const currentGeocodedResults = geocodedAddress.geocodedResults;

    // Update the geocoded details
    geocodedAddress.country = country;
    geocodedAddress.city = city;
    geocodedAddress.street = street;
    geocodedAddress.streetNumber = streetNumber;

    // Save the updated geocoded details
    await geocodedAddress.save();

    // Re-geocode the updated address
    const updatedResponse = await axios.get('https://nominatim.openstreetmap.org/search', {
      params: {
        q: `${streetNumber} ${street}, ${city}, ${country}`,
        format: 'json',
      },
    });

    // Check if there are results and update geocodedResults
    if (updatedResponse.data.length > 0) {
      geocodedAddress.geocodedResults = updatedResponse.data[0];
      await geocodedAddress.save();
    } else {
      // If no results, revert to the previous geocoded results
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
  registerAdmin,
  loginAdmin,
  reset_password,
  validate_code,
  new_password,
  getAdmin,
  updateAdmin,
  searchAddress,
  getGeocodedDetails,
  updateGeocodedDetails,
};