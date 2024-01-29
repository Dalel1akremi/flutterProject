
const mongoose = require('mongoose');

const CompositionSchema = new mongoose.Schema({
  nom: {
    type: String,
    required: true,
    isVisible:true,
  },
 
  image: String,
});

const Composition = mongoose.model('Composition', CompositionSchema);


module.exports = Composition;
