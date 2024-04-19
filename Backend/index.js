const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const cors = require('cors');
const multer = require('multer');


const userController = require('./controllers/userController');
const AdminController = require('./controllers/AdminController');
const viewController = require('./controllers/viewController');
const categoriesController = require('./controllers/categoriesController');
const RedirectController =require( './controllers/RedirectController');
const itemController =require( './controllers/itemController');
const StepController =require( './controllers/StepController');
const paiement =require( './controllers/paiementController');
const Commande=require("./controllers/CommandeController");
const Restaurant=require('./controllers/RestaurantController');
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
app.post('/registerAdmin', AdminController.registerAdmin);
app.post('/login', userController.loginUser);
app.post('/loginAdmin', AdminController.loginAdmin);
app.post('/reset_passwordAdmin', AdminController.reset_passwordAdmin)
app.post('/validate_codeAdmin', AdminController.validate_codeAdmin);
app.post('/newPasswordAdmin', AdminController.new_passwordAdmin);
app.get('/getAdminByEmail', AdminController.getAdminByEmail);
app.post('/updateAdmin', AdminController.updateAdmin);
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
app.get('/getCategoriesAd', categoriesController.getCategoriesAd);
app.put('/ArchivedCategorie/:_id', categoriesController.ArchivedCategorie);
app.put('/updateCategory/:id_cat', categoriesController.updateCategory);
app.post('/createRedirect', upload.single('image'),RedirectController.createRedirect);
app.get('/getRedirect', RedirectController.getRedirect);
app.get('/getRedirectAd', RedirectController.getRedirectAd);
app.put('/ArchiverRedirect/:_id', RedirectController.ArchiverRedirect);
app.put('/updateRedirect/:_id', RedirectController.updateRedirect);
app.post('/createStep', StepController.createStep);
app.get('/getStepsByRestaurantId', StepController.getStepsByRestaurantId);
app.put('/ObligationStep/:stepId', StepController.ObligationStep);
app.put('/updateStep/:_id', StepController.updateStep);
app.put('/ArchiverStep/:_id', StepController.ArchiverStep);
app.post('/createItem',upload.single('image'), itemController.createItem);
app.get('/getItem', itemController.getItem);
app.get('/getItems', itemController.getItems);
app.get('/getItemsByRestaurantId', itemController.getItemsByRestaurantId);
app.put('/ArchiverItem/:itemId', itemController.ArchiverItem);
app.put('/updateItem', itemController.updateItem);
app.get('/getItemById', itemController.getItemById);
app.get('/getItemRest', itemController.getItemRest);
app.get('/getNomItemById/:itemId', itemController.getNomItemById);
app.post('/porfeuille', paiement.porfeuille);
app.post('/recupererCarteParId', paiement.recupererCarteParId);
app.get('/recupererCartesUtilisateur', paiement.recupererCartesUtilisateur);
app.post('/createCommande', Commande.createCommande);
app.get('/getCommandesEncours', Commande.getCommandesEncours);
app.put('/commandes', Commande.updateCommandeState);
app.get('/getCommandesPasse', Commande.getCommandesPassé);
app.get('/getCommandes', Commande.getCommandes);
app.post('/sendNotification', Commande.sendNotification);
app.post('/createRestaurant',upload.fields([{ name: 'logo', maxCount: 1 }, { name: 'image', maxCount: 1 }]), Restaurant.createRestaurant);
app.get('/getRestau',Restaurant.getRestau);
app.get('/getRestaurant',Restaurant.getRestaurant);
app.get('/getAllRestaurantNames',Restaurant.getAllRestaurantNames);
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});