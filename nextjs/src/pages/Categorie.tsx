import { useState } from 'react';
import axios from 'axios';
import Link from 'next/link';
import Navbar from '../styles/navbar';

const CreateCategoriePage = () => {
  const [nomCat, setNomCat] = useState('');
  const [typeCat, setTypeCat] = useState('');
  const [message, setMessage] = useState('');

  const handleCreateCategorie = async () => {
    try {
      const nomCatNormalized = nomCat.charAt(0).toUpperCase() + nomCat.slice(1).toLowerCase();
  
      const response = await axios.post('http://localhost:3000/createCategorie', {
        nom_cat: nomCatNormalized,
        type_cat: typeCat
      });
      
      if (response.data.status === 200) {
        setMessage('Catégorie créée avec succès');
      } else {
        setMessage(response.data.message);
      }
    } catch (error: any) { 
      if (error.response && error.response.data.status === 400 && error.response.data.message === 'Cette catégorie existe déjà') {
        setMessage('Cette catégorie existe déjà');
      } else {
        setMessage('Une erreur est survenue lors de la création de la catégorie');
      }
    }
  };

  return (
    <div>
    
    <Navbar/>
    <div style={{ maxWidth: '400px', margin: 'auto', textAlign: 'center' }}>
      <h1 style={{ marginBottom: '20px' }}>Créer une nouvelle catégorie</h1>
      <input 
        type="text" 
        placeholder="Nom de la catégorie"
        value={nomCat}
        onChange={e => setNomCat(e.target.value)}
        style={{ marginBottom: '10px', padding: '8px', borderRadius: '5px', border: '1px solid #ccc', width: '100%' }}
      />
      <input 
        type="text" 
        placeholder="Type de la catégorie"
        value={typeCat}
        onChange={e => setTypeCat(e.target.value)}
        style={{ marginBottom: '10px', padding: '8px', borderRadius: '5px', border: '1px solid #ccc', width: '100%' }}
      />
      <button onClick={handleCreateCategorie} style={{ padding: '10px 20px', borderRadius: '5px', background: '#007bff', color: '#fff', border: 'none', cursor: 'pointer' }}>Créer</button>
      {message && <p style={{ marginTop: '20px', color: 'red' }}>{message}</p>}
    </div>
    </div>
  );
};

export default CreateCategoriePage;
