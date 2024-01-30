const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const cors = require('cors'); // Add this line

const userController = require('./controllers/userController');
const viewController = require('./controllers/viewController');
const categoriesController = require('./controllers/categoriesController');
const CompositionDeBController=require('./controllers/CompositionDeBController');
const itemController =require( './controllers/itemController');
const menuController =require( './controllers/menuController');
const app = express();
const PORT = 3000;

// Enable CORS
app.use(cors({
}));

// Connect to MongoDB
mongoose.connect('mongodb://127.0.0.1:27017/registration')
  .then(() => console.log('Now connected to MongoDB!'))
  .catch(err => console.error('Something went wrong', err));

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Routes
app.post('/register', userController.registerUser);
app.post('/login', userController.loginUser);
app.get('/', viewController.renderIndex);
app.post('/reset_password', userController.reset_password);
app.post('/validate_code',userController.validate_code);
app.post('/new_password',userController.new_password);
app.post('/createCategorie', categoriesController.createCategorie);
app.get('/getCategories', categoriesController.getCategories);
app.post('/insererComposition',CompositionDeBController.insererComposition);
app.get('/getCompositions',CompositionDeBController.getCompositions);
app.post('/createItem', itemController.createItem);
app.get('/getItem', itemController.getItem);
app.post('/createMenu', menuController.createMenu);
app.get('/getMenu', menuController.getMenu);


app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
