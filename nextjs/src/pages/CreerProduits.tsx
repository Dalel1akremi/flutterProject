import { useState, ChangeEvent, FormEvent } from 'react';
import axios from 'axios';
import Navbar from '../styles/navbar';

interface FormData {
  nom: string;
  type: string;
  prix: number;
  description: string;
  quantite: number;
  max_quantite: number;
  is_Menu: boolean;
  is_Redirect: boolean;
  id_cat: string;
  id_Steps: string;
  id: string;
  image: File | null;

  [key: string]: string | number | boolean | File | null;
}

export default function AddItem() {
  const [formData, setFormData] = useState<FormData>({
    nom: '',
    type: '',
    prix: 0,
    description: '',
    quantite: 0,
    max_quantite: 0,
    is_Menu: false,
    is_Redirect: false,
    id_cat: '',
    id_Steps: '',
    id: '',
    image: null,
  });

  const handleChange = (e: ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    const { name, value } = e.target;
    setFormData(prevState => ({
      ...prevState,
      [name]: name === 'prix' || name === 'quantite' || name === 'max_quantite' ? parseFloat(value) : value,
    }));
  };

  const handleImageChange = (e: ChangeEvent<HTMLInputElement>) => {
    const files = e.target.files ?? [];
    if (files.length > 0) {
      setFormData(prevState => ({
        ...prevState,
        image: files[0],
      }));
    }
  };

  const handleSubmit = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    try {
      const formDataToSend = new FormData();
      for (const key in formData) {
        const value = formData[key];
        if (value !== null) {
          if (key === 'image') {
            formDataToSend.append(key, value as File);
          } else {
            formDataToSend.append(key, value.toString());
          }
        }
      }
      const response = await axios.post('http://localhost:3000/createItem', formDataToSend);
      alert(response.data.message);
      setFormData({
        nom: '',
        type: '',
        prix: 0,
        description: '',
        quantite: 0,
        max_quantite: 0,
        is_Menu: false,
        is_Redirect: false,
        id_cat: '',
        id_Steps: '',
        id: '',
        image: null,
      });
    } catch (error: any) {
      alert(error.response.data.message);
      console.error('Error adding item:', error);
    }
  };

  return (
    <div >
      <Navbar />
      <div className="container">
      <h1>Ajouter un nouvel item</h1>
      <form onSubmit={handleSubmit} className="form">
        <div className="formGroup">
          <label className="input-label">Nom:</label>
          <input type="text" className="input" name="nom" placeholder="Nom" value={formData.nom} onChange={handleChange} required />
        </div>
        <div className="formGroup">
          <label className="input-label">Type:</label>
          <input type="text" className="input" name="type" placeholder="Type" value={formData.type} onChange={handleChange} required />
        </div>
        <div className="formGroup">
          <label className="input-label">Prix:</label>
          <input type="number" className="input" name="prix" placeholder="Prix" value={formData.prix} onChange={handleChange} required />
        </div>
        <div className="formGroup">
          <label className="input-label">Description:</label>
          <textarea className="textarea" name="description" placeholder="Description" value={formData.description} onChange={handleChange}></textarea>
        </div>
        <div className="formGroup">
          <label className="input-label">Quantité:</label>
          <input type="number" className="input" name="quantite" placeholder="Quantité" value={formData.quantite} onChange={handleChange} />
        </div>
        <div className="formGroup">
          <label className="input-label">Quantité maximale:</label>
          <input type="number" className="input" name="max_quantite" placeholder="Quantité maximale" value={formData.max_quantite} onChange={handleChange} />
        </div>
        <div className="formGroup">
          <input type="checkbox" className="checkbox" name="is_Menu" checked={formData.is_Menu} onChange={() => setFormData(prevState => ({ ...prevState, is_Menu: !prevState.is_Menu }))} />
          <label htmlFor="is_Menu" className="checkbox-label">Menu</label>
        </div>
        <div className="formGroup">
          <input type="checkbox" className="checkbox" name="is_Redirect" checked={formData.is_Redirect} onChange={() => setFormData(prevState => ({ ...prevState, is_Redirect: !prevState.is_Redirect }))} />
          <label htmlFor="is_Redirect" className="checkbox-label">Redirection</label>
        </div>
        <div className="formGroup">
          <label className="input-label">ID de la catégorie:</label>
          <input type="text" className="input" name="id_cat" placeholder="ID de la catégorie" value={formData.id_cat} onChange={handleChange} />
        </div>
        <div className="formGroup">
          <label className="input-label">ID des étapes (séparés par des virgules):</label>
          <input type="text" className="input" name="id_Steps" placeholder="ID des étapes" value={formData.id_Steps} onChange={handleChange} />
        </div>
        <div className="formGroup">
          <label className="input-label">ID:</label>
          <input type="text" className="input" name="id" placeholder="ID" value={formData.id} onChange={handleChange} />
        </div>
        <div className="formGroup">
          <label className="input-label">Image:</label>
          <input type="file" className="file-input" accept="image/*" onChange={handleImageChange} />
        </div>
        <button type="submit" className="submit-button">Ajouter</button>
      </form>
    </div>
    </div>
  );
}
