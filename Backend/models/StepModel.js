const mongoose = require('mongoose');

const stepSchema = new mongoose.Schema({
  id_Step: { type: Number, unique: true, },
  nom_Step: { type: String, required: true },
  id_items: [
    {
      id_item: { type: Number, ref: 'item', required: true },
    },
  ], 
});

stepSchema.pre('save', async function (next) {
  const currentStep = this;
  if (!currentStep.isNew) {
    return next();
  }
  try {
    const lastStep = await Step.findOne().sort({ id_Step: -1 }).exec();
    currentStep.id_Step = lastStep ? lastStep.id_Step + 1 : 1;
    next();
  } catch (error) {
    next(error);
  }
});

const Step = mongoose.model('Step', stepSchema);

module.exports = Step;
