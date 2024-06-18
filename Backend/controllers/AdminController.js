// controllers/AdminController.js
const jwt = require('jsonwebtoken'); 
const bcrypt = require('bcrypt');
const Admin = require('../models/adminModel');
const  nodemailer = require("nodemailer");

const registerAdmin = async (req, res) => {
  const { nom, prenom, telephone, email, password, confirmPassword,id_rest } = req.body;

  try {
    const existingAdmin = await Admin.findOne({ email });

    if (existingAdmin) {
      return res.status(400).json({ message: 'email déja existe' });
    }

    if (password !== confirmPassword) {
      return res.status(400).json({ message: 'mot de passe incompatible' });
    }


    const hashedPassword = await bcrypt.hash(password, 10);

    const newAdmin = new Admin({
      nom,
      prenom,
      telephone,
      email,
      password: hashedPassword,
      id_rest,
    });

    await newAdmin.save();

    res.status(201).json({ message: 'inscrit avec succée' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Erreur interne du serveur' });
  }
};
const loginAdmin = async (req, res) => {
  const { email, password } = req.body;

  try {

    const admin = await Admin.findOne({ email });

    if (!admin) {
        return res.status(401).json({ message: 'email invalide' });
    }


    const passwordMatch = await bcrypt.compare(password, admin.password);

    if (!passwordMatch) {
      return res.status(401).json({ message: 'Mot de passe invalide' });
    }

    const tokenData = {
      adminId: admin._id,
      email: admin.email,
      nom: admin.nom,
      telephone: admin.telephone,
      id_rest: admin.id_rest, 
    };

    const token = jwt.sign(
      tokenData,
      'your-secret-key', 
      { expiresIn: '7d' } 
    );

  

    res.status(200).json({ token, adminId: admin._id, nom: admin.nom, telephone: admin.telephone, message: 'connexion avec succée' });
    console.log(token);} catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Erreur du serveur' });
  }
};


const reset_passwordAdmin = async (req, res) => {
  const { email } = req.body;

  try {

    const admin = await Admin.findOne({ email });

    if (!admin) {
  
      return res.status(404).json({ message: 'restaurateur non trouvé.' });
    }

    const validationCode = Math.floor(100000 + Math.random() * 900000).toString();

    console.log('Code de validation généré:', validationCode);

    admin.validationCode = validationCode;
    admin.validationCodeTimestamp = Date.now();

    await admin.save();

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
      subject: 'Code de validation',
      text: `Votre code de validation est : ${validationCode}`,
      replyTo: 'meltingpot449@gmail.com',
    };

    transporter.sendMail(mailOptions, (error, info) => {
      if (error) {
        console.error(error);
        res.status(500).json({ success: false, message: 'Email non envoyée' });
      } else {
        console.log('Email envoyée avec succée: ' + info.response);
        res.json({ success: true, message: 'Email envoyée avec succée' });
      }
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, message: 'Erreur lors de la génération du code de validation.' });
  }
};
const validate_codeAdmin = async (req, res) => {
  const { email, validationCode } = req.body;

  try {
  
    const admin = await Admin.findOne({ email });

    if (!admin) {
   
      return res.status(404).json({ success: false, message: 'Utilisateur non trouvé.' });
    }

   
    console.log('Code de validation enregistré:', admin.validationCode);
    console.log('Code de validation saisi:', validationCode);


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
const new_passwordAdmin = async (req, res) => {
  const { newPassword, confirmNewPassword } = req.body;
  const adminEmail = req.query.email || req.body.email;

  try {

    const existingAdmin = await Admin.findOne({ email: adminEmail });

    if (!existingAdmin) {
    
      return res.status(404).json({ success: false, message: 'Admin non trouvé.' });
    }


    if (newPassword !== confirmNewPassword) {
      return res.status(400).json({ success: false, message: 'Mot de passe incompatible.' });
    }

    
    const hashedPassword = await bcrypt.hash(newPassword, 10);

    existingAdmin.password = hashedPassword;

    await existingAdmin.save();

    res.json({ success: true, message: 'mot de passe changée avec succée.' });
  } catch (error) {
    console.error(error);

   
    if (error.name === 'MongoError' && error.code === 11000) {
    
      return res.status(400).json({ success: false, message: 'Erreur de clé dupliquée.' });
    }

   
    res.status(500).json({ success: false, message: 'Erreur lors de la mise à jour du mot de passe.' });
  }
};



const getAdminByEmail = async (req, res) => {
  const { email } = req.query; 
  try {

    const admin = await Admin.findOne({ email });
    
    if (admin) {
      res.json(admin);
    } else {
      res.status(404).json({ message: 'restaurateur introuvable' });
    }
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'erreur de serveur' });
  }
};


const updateAdmin = async (req, res) => {
  const { nom, prenom, telephone, email } = req.body;

  try {

    const existingAdmin = await Admin.findOne({ email: req.query.email });

    if (!existingAdmin) {
      return res.status(404).json({ message: 'restaurateur introuvable' });
    }

    existingAdmin.nom = nom || existingAdmin.nom;
    existingAdmin.prenom = prenom || existingAdmin.prenom;
    existingAdmin.telephone = telephone || existingAdmin.telephone;
   
    if (email && email !== existingAdmin.email) {

      const emailExists = await Admin.exists({ email });
      if (emailExists) {
        return res.status(400).json({ message: 'Lemail est déjà utilisée' });
      }
      existingAdmin.email = email;
    }

    await existingAdmin.save();

    res.status(200).json({ message: 'restaurateur été modifié avec succée' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Erreur interne du serveur' });
  }
};

module.exports = {
  registerAdmin,
  loginAdmin,
  reset_passwordAdmin,
  validate_codeAdmin,
  new_passwordAdmin,
  getAdminByEmail,
  updateAdmin,
  
};