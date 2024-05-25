const mongoose = require('mongoose');

const stepSchema = new mongoose.Schema({
  id_Step: { type: Number, unique: true, },
  nom_Step: { type: String, required: true },
  id_items: [
    {
      id_item: { type: Number, required: true },
    },
  ],
  is_Obligatoire:{ type: Boolean, validate: [isValidBoolean, 'is_Obligatoire: must be true or false'] },
  id_rest: { type: Number, ref: 'Restaurant' } , 
  isArchived: { type: Boolean, validate: [isValidBoolean, 'isArchived must be true or false'] },
});

function isValidBoolean(value) {
  return typeof value === 'boolean';
}
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
