import axios from 'axios';
import { useRouter } from 'next/router';
import { useState, useEffect, ChangeEvent } from 'react';

const UpdateProduits = () => {
  const router = useRouter();
  const { query } = router;
  const [formData, setFormData] = useState({
    nom: '',
    prix: '',
    description: '',
    isArchived: false,
    quantite: '',
    max_quantite: '',
    is_Menu: false,
    is_Redirect: false,
    id_cat: '',
    _id: query._id || '',
  });
  const [message, setMessage] = useState('');
  const [isSuccess, setIsSuccess] = useState(false);
  const [isError, setIsError] = useState(false);

  useEffect(() => {
    if (query._id) {
      axios.get(`http://localhost:3000/getItemById/${query._id}`) // Utiliser _id à la place de id_item
        .then(response => {
          const itemData = response.data;
          setFormData({
            nom: itemData.nom || '',
            prix: itemData.prix || '',
            description: itemData.description || '',
            isArchived: !!itemData.isArchived, // Convertir en boolean
            quantite: itemData.quantite || '',
            max_quantite: itemData.max_quantite || '',
            is_Menu: !!itemData.is_Menu, // Convertir en boolean
            is_Redirect: !!itemData.is_Redirect, // Convertir en boolean
            id_cat: itemData.id_cat || '',
            _id: query._id || '', // Utiliser _id à la place de id_item
          });
        })
        .catch(error => {
          console.error("Erreur lors de la récupération des données de l'API :", error);
        });
    }
  }, [query]);
  

  const handleInputChange = (e: ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setFormData(prevState => ({
      ...prevState,
      [name]: value,
    }));
  };

  const handleCheckboxChange = (e: ChangeEvent<HTMLInputElement>) => {
    const { name, checked } = e.target;
    setFormData(prevState => ({
      ...prevState,
      [name]: checked,
    }));
  };
  const handleTextareaChange = (e: ChangeEvent<HTMLTextAreaElement>) => {
    const { name, value } = e.target;
    setFormData(prevState => ({
      ...prevState,
      [name]: value,
    }));
  };
  const handleSubmit = async (e: { preventDefault: () => void; }) => {
    e.preventDefault();
    try {
      await axios.put(`http://localhost:3000/updateItem/${formData._id}`, formData);
      setIsSuccess(true);
      setMessage('Les données ont été mises à jour avec succès !');
      setTimeout(() => {
        setIsSuccess(false);
        setMessage('');
      }, 1000);
    } catch (error) {
      setIsSuccess(false);
      setMessage("Une erreur s'est produite lors de la mise à jour des données.");
      console.error("Erreur lors de la mise à jour des données :", error);
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
          <textarea  className="textarea" id="description" name="description" value={formData.description} onChange={handleTextareaChange}></textarea>
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
            <label className="input-label" htmlFor="isArchived"><strong>Archivé:</strong></label>
            <input
              className="checkbox"
              type="checkbox"
              id="isArchived"
              name="isArchived"
              checked={formData.isArchived}
              onChange={handleCheckboxChange}
            />
          </div>
          <div className="formGroup">
            <label className="input-label" htmlFor="is_Menu"><strong>Est un menu:</strong></label>
            <input
              className="checkbox"
              type="checkbox"
              id="is_Menu"
              name="is_Menu"
              checked={formData.is_Menu}
              onChange={handleCheckboxChange}
            />
          </div>
          <div className="formGroup">
            <label className="input-label" htmlFor="is_Redirect"><strong>Redirection:</strong></label>
            <input
              className="checkbox"
              type="checkbox"
              id="is_Redirect"
              name="is_Redirect"
              checked={formData.is_Redirect}
              onChange={handleCheckboxChange}
            />
          </div>
        <div className="formGroup">
          <label htmlFor="id_cat"><strong>ID catégorie:</strong></label>
          <input className="input" type="text" id="id_cat" name="id_cat" value={formData.id_cat} onChange={handleInputChange} />
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
