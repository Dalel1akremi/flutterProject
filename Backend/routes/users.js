

const {  registerUser,loginUser ,reset_password} = require('../controllers/userController');
const express = require('express');
const router = express.Router();

router.post('/register',registerUser); 
router.post('/login',loginUser); 

module.exports = router;
 
