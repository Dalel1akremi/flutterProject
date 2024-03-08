const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const cors = require('cors');
const multer = require('multer');


const userController = require('./controllers/userController');
const viewController = require('./controllers/viewController');
const categoriesController = require('./controllers/categoriesController');
const CompositionDeBController=require('./controllers/CompositionDeBController');
const RedirectController =require( './controllers/RedirectController');
const itemController =require( './controllers/itemController');
const StepController =require( './controllers/StepController');
const paiement =require( './controllers/paiement');
const Commande=require("./controllers/CommandeController");
const app = express();
const PORT = 3000;

app.use(cors());

app.use(express.static('public'));

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, './public/images');
  },
  filename: (req, file, cb) => {
    cb(null,  file.originalname);
  },
});

const upload = multer({ storage: storage });

mongoose
  .connect('mongodb://127.0.0.1:27017/registration', {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  })
  .then(() => console.log('Now connected to MongoDB!'))
  .catch((err) => console.error('Something went wrong', err));

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

app.post('/register', userController.registerUser);
app.post('/login', userController.loginUser);
app.get('/', viewController.renderIndex);
app.get('/getUser', userController.getUser);
app.put('/updateUser', userController.updateUser);
app.post('/searchAddress', userController.searchAddress);
app.get('/getGeocodedDetails', userController.getGeocodedDetails);
app.put('/updateGeocodedDetails', userController.updateGeocodedDetails);
app.post('/reset_password', userController.reset_password);
app.post('/validate_code', userController.validate_code);
app.put('/new_password', userController.new_password);
app.post('/createCategorie', categoriesController.createCategorie);
app.get('/getCategories', categoriesController.getCategories);
app.post('/insererComposition', CompositionDeBController.insererComposition);
app.get('/getCompositions', CompositionDeBController.getCompositions);
app.post('/createRedirect', upload.single('image'),RedirectController.createRedirect);
app.get('/getRedirect', RedirectController.getRedirect);
app.post('/createStep', StepController.createStep);
app.post('/createItem',upload.single('image'), itemController.createItem);
app.get('/getItem', itemController.getItem);
app.post('/porfeuille', paiement.porfeuille);
app.post('/recupererCarteParId', paiement.recupererCarteParId);
app.get('/recupererCartesUtilisateur', paiement.recupererCartesUtilisateur);
app.post('/createCommande', Commande.createCommande);
app.get('/getCommandesEncours', Commande.getCommandesEncours);
app.put('/commandes', Commande.updateCommandeState);
app.get('/getCommandesPasse', Commande.getCommandesPassé);
app.get('/getCommandes', Commande.getCommandes);
app.post('/sendNotification', Commande.sendNotification);

app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});