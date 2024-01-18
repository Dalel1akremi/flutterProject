// app.js

const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');

const userController = require('./controllers/userController');
const viewController = require('./controllers/viewController');

const app = express();
const PORT = 3000;

// Connect to MongoDB
mongoose.connect('mongodb://127.0.0.1:27017/registration')
.then(() => console.log('Now connected to MongoDB!'))
    .catch(err => console.error('Something went wrong', err));;

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Routes
app.post('/register', userController.registerUser);
app.post('/login', userController.loginUser);
app.get('/', viewController.renderIndex);

app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
