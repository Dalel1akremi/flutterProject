const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const cors = require('cors');
const multer = require('multer');
const path = require('path');

const userController = require('./controllers/userController');
const viewController = require('./controllers/viewController');
<<<<<<< HEAD
const CompositionDeBController=require('./controllers/CompositionDeBController');
const itemController =require( './controllers/itemController');=======
const categoriesController = require('./controllers/categoriesController');
const CompositionDeBController=require('./controllers/CompositionDeBController');
const itemController =require( './controllers/itemController');
const menuController =require( './controllers/menuController');
const paiement =require( './controllers/paiement');
const app = express();
const PORT = 3000;

// Enable CORS
app.use(cors());

// Serve static files from the 'public' folder
app.use(express.static('public'));

// Configure Multer for file uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, './public/images');
  },
  filename: (req, file, cb) => {
    cb(null,  file.originalname);
  },
});

const upload = multer({ storage: storage });

// Connect to MongoDB
mongoose
  .connect('mongodb://127.0.0.1:27017/registration', {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  })
  .then(() => console.log('Now connected to MongoDB!'))
  .catch((err) => console.error('Something went wrong', err));

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Routes
app.post('/register', userController.registerUser);
app.post('/login', userController.loginUser);
app.get('/', viewController.renderIndex);
app.get('/getUser', userController.getUser);
app.put('/updateUser', userController.updateUser);
app.get('/searchAddress', userController.searchAddress);

app.post('/reset_password', userController.reset_password);
app.post('/validate_code',userController.validate_code);
app.post('/new_password',userController.new_password);
<<<<<<< HEAD
app.post('/insererComposition',CompositionDeBController.insererComposition);
=======
app.post('/createCategorie', categoriesController.createCategorie);
app.get('/getCategories', categoriesController.getCategories);
app.post('/insererComposition', CompositionDeBController.insererComposition);
app.get('/getCompositions', CompositionDeBController.getCompositions);
app.post('/createItem', upload.single('image'),itemController.createItem);
app.get('/getItem', itemController.getItem);

// Corrected createMenu route
app.post('/createMenu', upload.single('image'), menuController.createMenu);
app.get('/getMenu', menuController.getMenu);
app.post('/porfeuille', paiement.porfeuille);


>>>>>>> d06e0d2 (feat: add `creatCategorie` api)
app.get('/getCompositions',CompositionDeBController.getCompositions);
app.post('/createItem', itemController.createItem);
app.get('/getItem', itemController.getItem);
app.post('/createMenu', menuController.createMenu);


app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
