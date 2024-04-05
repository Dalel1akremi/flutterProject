// updateProduits.tsx

import axios from 'axios';
import { useRouter } from 'next/router';
import { useState, useEffect } from 'react';

const UpdateProduits = () => {
  const router = useRouter();
  const { query } = router;
  const [formData, setFormData] = useState({
    nom: '',
    prix: '',
    description: '',
    isArchived: '',
    quantite: '',
    max_quantite: '',
    is_Menu: '',
    is_Redirect: '',
    id_cat: '',
    id_item: '',
  });
  const [message, setMessage] = useState('');
  const [isSuccess, setIsSuccess] = useState(false);
  const [isError, setIsError] = useState(false);
  useEffect(() => {
    setFormData({
      nom: Array.isArray(query.nom) ? query.nom[0] : query.nom || '',
      prix: Array.isArray(query.prix) ? query.prix[0] : query.prix || '',
      description: Array.isArray(query.description) ? query.description[0] : query.description || '',
      isArchived: Array.isArray(query.isArchived) ? query.isArchived[0] : query.isArchived || '',
      quantite: Array.isArray(query.quantite) ? query.quantite[0] : query.quantite || '',
      max_quantite: Array.isArray(query.max_quantite) ? query.max_quantite[0] : query.max_quantite || '',
      is_Menu: Array.isArray(query.is_Menu) ? query.is_Menu[0] : query.is_Menu || '',
      is_Redirect: Array.isArray(query.is_Redirect) ? query.is_Redirect[0] : query.is_Redirect || '',
      id_cat: Array.isArray(query.id_cat) ? query.id_cat[0] : query.id_cat || '',
      id_item: Array.isArray(query.id_item) ? query.id_item[0] : query.id_item || '',
    });
  }, [query]);

  const handleInputChange = (e: { target: { name: any; value: any; }; }) => {
    const { name, value } = e.target;
    setFormData(prevState => ({
      ...prevState,
      [name]: value,
    }));
  };

  const handleSubmit = async (e: { preventDefault: () => void; }) => {
                    e.preventDefault();
                    try {
                      await axios.put(`http://localhost:3000/updateItem/${formData.id_item}`, formData);
                      setIsSuccess(true);
                      setMessage('Les données ont été mises à jour avec succès !');
                   setTimeout(() => {
        setIsSuccess(false);
        setMessage('');
      }, 1000);
                    } catch (error) {
                      setIsSuccess(false);
                      setMessage('Une erreur s\'est produite lors de la mise à jour des données.');
                      console.error('Erreur lors de la mise à jour des données :', error);
                    }
                  };

  return (
    <div>
      <h1>Modifier Produits</h1>
      <div className="container">
      <form onSubmit={handleSubmit}>
      <div className="formGroup">
          <label className="input-label" htmlFor="nom"><strong>Nom:</strong></label>
          <input className="input" type="text" id="nom" name="nom" value={formData.nom} onChange={handleInputChange} />
        </div>
        <div className="formGroup">
          <label className="input-label" htmlFor="prix"><strong>Prix:</strong></label>
          <input className="input" type="text" id="prix" name="prix" value={formData.prix} onChange={handleInputChange} />
        </div>
        <div className="formGroup">
          <label className="input-label" htmlFor="description"><strong>Description:</strong></label>
          <textarea  className="textarea" id="description" name="description" value={formData.description} onChange={handleInputChange}></textarea>
        </div>
        <div className="formGroup">
          <label className="input-label" htmlFor="isArchived"><strong>Archivé:</strong></label>
          <input className="input" type="text" id="isArchived" name="isArchived" value={formData.isArchived} onChange={handleInputChange} />
        </div>
        <div className="formGroup">
          <label className="input-label" htmlFor="quantite"><strong>Quantité:</strong></label>
          <input className="input" type="text" id="quantite" name="quantite" value={formData.quantite} onChange={handleInputChange} />
        </div>
        <div className="formGroup">
          <label className="input-label" htmlFor="max_quantite"><strong>Quantité maximale:</strong></label>
          <input className="input" type="text" id="max_quantite" name="max_quantite" value={formData.max_quantite} onChange={handleInputChange} />
        </div>
        <div className="formGroup">
          <label className="input-label" htmlFor="is_Menu"><strong>Est un menu:</strong></label>
          <input className="input" type="text" id="is_Menu" name="is_Menu" value={formData.is_Menu} onChange={handleInputChange} />
        </div>
        <div className="formGroup">
          <label className="input-label" htmlFor="is_Redirect"><strong>Redirection:</strong></label>
          <input className="input" type="text" id="is_Redirect" name="is_Redirect" value={formData.is_Redirect} onChange={handleInputChange} />
        </div>
        <div className="formGroup">
          <label htmlFor="id_cat"><strong>ID catégorie:</strong></label>
          <input className="input" type="text" id="id_cat" name="id_cat" value={formData.id_cat} onChange={handleInputChange} />
        </div>
        <div className="formGroup">
          <label className="input-label" htmlFor="id_item"><strong>ID item:</strong></label>
          <input className="input" type="text" id="id_item" name="id_item" value={formData.id_item} onChange={handleInputChange} />
        </div>
        <button className="submit-button" type="submit">Enregistrer</button>
      </form>
    
    {message && (
  <div 
    className={isError ? "error-message" : "success-message"}
    style={{
      textAlign: 'center',
      backgroundColor: isError ? 'red' : 'green',
      padding: '10px',
      marginBottom:'25px',
      margin: '20px auto',
      borderRadius: '5px',
      width: 'fit-content',
    }}
  >
    {message}
  </div>
  
)}
</div>
</div>
 );
 };
export default UpdateProduits;
