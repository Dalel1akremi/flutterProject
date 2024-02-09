
const mongoose = require('mongoose');

const CompositionSchema = new mongoose.Schema({
  id_comp: { type: Number, unique: true },
  nom: {
    type: String,
    required: true,
    isVisible:true,
  },
 
  image: String,
});
CompositionSchema.pre('save', async function (next) {
  try {
    if (!this.id_comp) {
      const lastComp = await this.constructor.findOne({}, {}, { sort: { id_comp: -1 } });
      this.id_comp = lastComp ? lastComp.id_comp + 1 : 1;
    }
    next();
  } catch (error) {
    next(error);
  }
});
const Composition = mongoose.model('Composition', CompositionSchema);


module.exports = Composition;
