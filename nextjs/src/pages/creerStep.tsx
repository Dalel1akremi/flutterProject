import React, { useState } from 'react';
import axios from 'axios';
import Navbar from '@/styles/navbar';

const CreateStep = () => {
  const [nomStep, setNomStep] = useState('');
  const [idItems, setIdItems] = useState('');
  const [isObligatoire, setIsObligatoire] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState('');

  const handleSubmit = async (e: { preventDefault: () => void; }) => {
    e.preventDefault();
    setIsLoading(true);
    try {
      const response = await axios.post('http://localhost:3000/createStep', {
        nom_Step: nomStep,
        id_items: idItems,
        is_Obligatoire: isObligatoire,
      });
      console.log(response.data);
      setIsLoading(false);
      // Réinitialiser les champs après la soumission réussie
      setNomStep('');
      setIdItems('');
      setIsObligatoire(false);
      setErrorMessage('');
    } catch (error) {
      setIsLoading(false);
      if (axios.isAxiosError(error)) {
        if (error.response) {
          setErrorMessage(error.response.data.message);
        } else {
          setErrorMessage('Une erreur s\'est produite lors de la création du Step');
        }
      } else {
        setErrorMessage('Une erreur s\'est produite lors de la création du Step');
      }
    }
  };

  return (
                    <div>
      <Navbar />
    <div className="container">
      <h1>Créer un Step</h1>
      <form onSubmit={handleSubmit}>
        <div className="formGroup">
          <label className="input-label">Nom du Step :</label>
          <input
          className="input"
            type="text"
            value={nomStep}
            onChange={(e) => setNomStep(e.target.value)}
            required
          />
        </div>
        <div className="formGroup">
          <label className="input-label">ID Items :</label>
          <input
          className="input" 
            type="text"
            value={idItems}
            onChange={(e) => setIdItems(e.target.value)}
            required
          />
        </div>
        <div className="formGroup">
          <label className="checkbox-label">Est Obligatoire :</label>
          <input
          className="checkbox"
            type="checkbox"
            checked={isObligatoire}
            onChange={(e) => setIsObligatoire(e.target.checked)}
          />
        </div>
        {errorMessage && <p style={{ color: 'red' }}>{errorMessage}</p>}
        <button type="submit" disabled={isLoading}>
          {isLoading ? 'En cours...' : 'Créer Step'}
        </button>
      </form>
    </div>
    </div>
  );
};

export default CreateStep;
