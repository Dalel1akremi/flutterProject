import React, { useState, useEffect } from 'react';
import axios from 'axios';
import Navbar from '@/styles/navbar';
import jwt from 'jsonwebtoken'; 
import router from 'next/router';

const CreateStep = () => {
  const [nomStep, setNomStep] = useState('');
  const [idItems, setIdItems] = useState('');
  const [isObligatoire, setIsObligatoire] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState('');
  const [restaurantId, setRestaurantId] = useState(null);

  useEffect(() => {
    const token = localStorage.getItem('token');
  
    if (token) {
      const decodedToken = jwt.decode(token) as { [key: string]: any };
      const { id_rest } = decodedToken;
      setRestaurantId(id_rest); 
    }
  }, []);
  
  const handleSubmit = async (e: { preventDefault: () => void; }) => {
    e.preventDefault();
    setIsLoading(true);
    try {
      const idItemsArray = idItems.split(',').map(id => ({ id_item: id.trim() }));
      const MY_IP = process.env.MY_IP || '127.0.0.1';
      const response = await axios.post(`http://${MY_IP}:3000/createStep`, {
        nom_Step: nomStep,
        id_items: idItemsArray,
        is_Obligatoire: isObligatoire,
        id_rest: restaurantId, 
      });
      console.log(response.data);
      setIsLoading(false);
      setNomStep('');
      setIdItems('');
      setIsObligatoire(false);
      setErrorMessage('');
      router.push('/Elements');
    } catch (error) {
      setIsLoading(false);
      if (axios.isAxiosError(error)) {
        if (error.response) {
          setErrorMessage(error.response.data.message);
        } else {
          setErrorMessage('Une erreur s\'est produite lors de la création de l\élement');
        }
      } else {
        setErrorMessage('Une erreur s\'est produite lors de la création de l\élement');
      }
    }
  };
  

  
  return (
    <div>
      <Navbar />
      <div className="container">
        <h1>Créer un élement du produit</h1>
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
