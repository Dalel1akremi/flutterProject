import { useState, ChangeEvent, FormEvent, useEffect } from 'react';
import axios from 'axios';
import Navbar from '../styles/navbar';
import jwt from 'jsonwebtoken';
import { useRouter } from 'next/router'; 

interface RedirectFormData {
  nom: string;
  prix: number;
  description: string;
  quantite: number;
  max_quantite: number;
  id_rest: number;
  id_item: number;
  image: File | null;
}

export default function AddRedirect() {
  const [message, setMessage] = useState<string>('');
  const [isError, setIsError] = useState<boolean>(false);
  const router = useRouter();
  const { id_item } = router.query; 
  const [id_rest, setIdRest] = useState<number>(0); 
  const [formData, setFormData] = useState<RedirectFormData>({
    nom: '',
    prix: 0,
    description: '',
    quantite: 0,
    max_quantite: 0,
    id_rest: 0,
    id_item: id_item ? parseInt(id_item as string, 10) : 0,
    image: null,
  });


  
  useEffect(() => {
    const token = localStorage.getItem('token');
    if (token) {
      const decodedToken = jwt.decode(token) as { [key: string]: any };
      const { id_rest } = decodedToken;
      setIdRest(id_rest);
      setFormData(prevState => ({
        ...prevState,
        id_rest: id_rest,

      }));
    }
  
    if (id_item) {
      setFormData(prevState => ({
        ...prevState,
        id_item: parseInt(id_item as string, 10),
      }));
    }
  }, [id_item]);
  const handleSubmit = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    try {
      const formDataToSend = new FormData();
      for (const key in formData) {
        if (formData.hasOwnProperty(key)) {
          const value = formData[key as keyof RedirectFormData];
          if (value !== null) {
            if (key === 'image') {
              formDataToSend.append(key, value as File);
            } else {
              formDataToSend.append(key, value.toString());
            }
          }
        }
      }
      
      const MY_IP = process.env.MY_IP || '127.0.0.1';
      const response = await axios.post(`http://${MY_IP}:3000/createRedirect`, formDataToSend);
      setMessage(response.data.message);
      setIsError(false);
      setFormData({
        nom: '',
        prix: 0,
        description: '',
        quantite: 0,
        max_quantite: 0,
        id_rest: id_rest,
        image: null,
        id_item: 0,
        
      });
      const redirectUrl = `/Redirects?id_item=${id_item}&id_rest=${id_rest}`;
      router.push(redirectUrl);
    } catch (error: any) {
      setMessage(error.response.data.message);
      setIsError(true);
      console.error('Erreur lors de l\'ajout de la redirect', error);
    }
  };

  const handleChange = (e: ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    const { name, value } = e.target;
    setFormData(prevState => ({
      ...prevState,
      [name]: name === 'prix' || name === 'quantite' || name === 'max_quantite' ? parseFloat(value) : name === 'id_cat' || name === 'id_rest' ? parseInt(value) : value,
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

 

  return (
    <div>
      <Navbar />
      <div className="container">
        <h1>Ajouter une nouvelle redirection</h1>
        <form onSubmit={handleSubmit} className="form">
          {/* Form inputs */}
       
          <div className="formGroup">
            
            <label className="input-label">Nom:</label>
            <input type="text" className="input" name="nom" placeholder="Nom" value={formData.nom} onChange={handleChange} required />
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
            <label className="input-label">Image:</label>
            <input type="file" className="file-input" accept="image/*" onChange={handleImageChange} />
          </div>
          <button type="submit" className="submit-button">Ajouter</button>
        </form>
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
    </div>
  );
}
