import { useState, useEffect } from 'react';
import axios from 'axios';
import { useRouter } from 'next/router';
import Navbar from '../styles/navbar';
import jwt from 'jsonwebtoken'; // Importer la bibliothèque jwt pour décoder le token
import React from 'react';

const CreateCategoriePage = () => {
  const router = useRouter();
  const [nomCat, setNomCat] = useState('');
  const [message, setMessage] = useState('');
  const [isError, setIsError] = useState(false);

  useEffect(() => {
    const token = localStorage.getItem('token');
    if (!token) {
      router.push('/connexion');
    }
  }, []);

  const handleCreateCategorie = async () => {
    try {
      const token = localStorage.getItem('token');
      if (token) {
        const decodedToken = jwt.decode(token) as { [key: string]: any };
        const { id_rest } = decodedToken; 
  
        const nomCatNormalized = nomCat.charAt(0).toUpperCase() + nomCat.slice(1).toLowerCase();
  
        const response = await axios.post('http://localhost:3000/createCategorie', {
          nom_cat: nomCatNormalized,
          id_rest: id_rest, 
        });
  
        if (response.data.status === 200) {
          setMessage('Catégorie créée avec succès');
          router.push('/Categorie');
          setIsError(false); 
        } else {
          setMessage(response.data.message);
          setIsError(true); 
        }
      } 
    } catch (error: any) {
      setIsError(true); 
      if (error.response && error.response.data.status === 400 && error.response.data.message === 'Cette catégorie existe déjà') {
        setMessage('erreur,Cette catégorie existe déjà');
      } else {
        setMessage('Une erreur est survenue lors de la création de la catégorie');
      }
    }
  };

  return (
    <div>
      <Navbar />
      <div style={{ maxWidth: '400px', margin: 'auto', textAlign: 'center' }}>
        <h1 style={{ marginBottom: '20px' }}>Créer une nouvelle catégorie</h1>
        <input
          type="text"
          placeholder="Nom de la catégorie"
          value={nomCat}
          onChange={e => setNomCat(e.target.value)}
          style={{ marginBottom: '10px', padding: '8px', borderRadius: '5px', border: '1px solid #ccc', width: '100%' }}
        />

        <button onClick={handleCreateCategorie} style={{ padding: '10px 20px', borderRadius: '5px', background: '#007bff', color: '#fff', border: 'none', cursor: 'pointer' }}>Créer</button>
        
        {/* Utilisation d'une classe CSS dynamique en fonction de isError */}
        <div style={{ marginTop: '20px', backgroundColor: message.includes('succès') ? 'green' : message.includes('erreur') ? 'red' : 'white', padding: '10px', borderRadius: '5px', color: 'white' }}>
  {message}
</div>


      </div>
    </div>
  );
};


export default CreateCategoriePage;
