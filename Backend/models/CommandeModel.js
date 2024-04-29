const mongoose = require('mongoose');

const commandeSchema = new mongoose.Schema({
  numero_commande: {
    type: String,
    unique: true,
  },
  etat: {
    type: String,
    enum: ['Encours','Validée', 'En Préparation','Prête','Non validée','Passée'],
    default: 'Encours',
  },
  id_items: [
    {
      id_item: { type: Number, ref: 'Item', required: true },
      nom: String,
      prix: Number,
      quantite:Number,
      elements_choisis: [String],
      remarque:String,
      
    },
  ],
  email: {type : String ,ref:'User'},
  temps: { type: String  }, 
  mode_retrait: { type: String },
  montant_Total:{ type: Number  }, 
  id_rest: { type: Number, ref: 'Restaurant' } ,
  numero_telephone :{type: String},
  adresse:{ type: String },
});

commandeSchema.pre('save', async function (next) {
  try {
    if (!this.numero_commande) {
      const lastComp = await this.constructor.findOne({}, {}, { sort: { numero_commande: -1 } });
      const lastNumber = lastComp ? parseInt(lastComp.numero_commande.slice(1)) : 0;
      const nextNumber = lastNumber + 1;
      this.numero_commande = `C${nextNumber.toString().padStart(3, '0')}`;
    }
    next();
  } catch (error) {
    next(error);
  }
});


const Commande = mongoose.model('Commande', commandeSchema);

module.exports = Commande;
