import { useState, ChangeEvent, FormEvent, useEffect } from 'react';
import axios from 'axios';
import Navbar from '../styles/navbar';
import jwt from 'jsonwebtoken';
import { useRouter } from 'next/router';

interface FormData {
  nom_cat: string;
  id_rest: string;
  image: File | null;
  [key: string]: string | File | null;
}

export default function AddCategorie() {
  const [formData, setFormData] = useState<FormData>({
    nom_cat: '',
    id_rest: '',
    image: null,
  });

  const [message, setMessage] = useState<string>('');
  const [isError, setIsError] = useState<boolean>(false);
  const router = useRouter();

  useEffect(() => {
    const token = localStorage.getItem('token');
    if (token) {
      const decodedToken = jwt.decode(token) as { [key: string]: any };
      const { id_rest } = decodedToken;
      setFormData(prevState => ({
        ...prevState,
        id_rest: decodedToken.id_rest,
      }));
    }
  }, []);

  const handleImageChange = (e: ChangeEvent<HTMLInputElement>) => {
    const files = e.target.files ?? [];
    if (files.length > 0) {
      setFormData(prevState => ({
        ...prevState,
        image: files[0],
      }));
    }
  };

  const handleChange = (e: ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setFormData(prevState => ({
      ...prevState,
      [name]: value,
    }));
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
      const MY_IP = process.env.MY_IP || '127.0.0.1';
      const response = await axios.post(`http://${MY_IP}:3000/createCategorie`, formDataToSend);
      setMessage(response.data.message);
      setIsError(false);
      setFormData({
        nom_cat: '',
        id_rest: '', 
        image: null,
      });
      router.push('/Categories'); 
    } catch (error: any) {
      setMessage(error.response.data.message);
      setIsError(true);
      console.error('Erreur lors de l\'ajout de la categorie:', error);
    }
  };

  return (
    <div>
      <Navbar />
      <div className="container">
        <h1>Ajouter une nouvelle catégorie</h1>
        <form onSubmit={handleSubmit} className="form">
  
          <div className="formGroup">
            <label className="input-label">Nom:</label>
            <input type="text" className="input" name="nom_cat" placeholder="Nom" value={formData.nom_cat} onChange={handleChange} required />
          </div>
          
          <div className="formGroup">
            <label className="input-label">Image:</label>
            <input type="file" className="file-input" accept="image/*" onChange={handleImageChange} />
          </div>
          <button type="submit" className="submit-button">Ajouter</button>
        </form>
      </div>
      {message && (
        <div 
          className={isError ? "message d'erreur" : "message de réussite"}
          style={{
            textAlign: 'center',
            backgroundColor: isError ? 'red' : 'green',
            padding: '10px',
            margin: '20px auto',
            borderRadius: '5px',
            width: 'fit-content',
          }}
        >
          {message}
        </div>
      )}
    </div>
  );
}
