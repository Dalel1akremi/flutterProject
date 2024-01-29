

const {  registerUser,loginUser ,reset_password} = require('../controllers/userController');
const { createCategorie}=require('../controllers/categoriesController')
const express = require('express');
const router = express.Router();

router.post('/register',registerUser); 
router.post('/login',loginUser); 
router.post('/createCat',createCategorie);

module.exports = router;
 
