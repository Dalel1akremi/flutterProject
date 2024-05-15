import { useState, useEffect, ChangeEvent, FormEvent } from 'react';
import axios from 'axios';
import { useRouter } from 'next/router';
import jwt from 'jsonwebtoken';
import AcmeLogo from "../../styles/AcmeLogo";
import styles from './../../styles/Navbar.module.css';

interface RestaurantFormData {
  nom: string;
  adresse: string;
  ModeDeRetrait: string;
  ModeDePaiement: string;
  numero_telephone: string;
  email: string;
  id_rest: number;
  logo: File | null;
  image: File | null;
}

const CreateRestaurantPage = () => {
  const router = useRouter();
  const [formData, setFormData] = useState<RestaurantFormData>({
    nom: '',
    adresse: '',
    ModeDeRetrait: '',
    ModeDePaiement: '',
    numero_telephone: '',
    email: '',
    id_rest: 0,
    logo: null,
    image: null,
  });
  const [message, setMessage] = useState('');
  const [isError, setIsError] = useState(false);
  const [errors, setErrors] = useState<Partial<RestaurantFormData>>({});

  useEffect(() => {
    const token = localStorage.getItem('token');
    if (token) {
      const decodedToken = jwt.decode(token) as { [key: string]: any };
      const { id_rest } = decodedToken;
      setFormData(prevState => ({ ...prevState, id_rest }));
    }
  }, []);

  const handleImageChange = (e: ChangeEvent<HTMLInputElement>, key: keyof RestaurantFormData) => {
    const files = e.target.files ?? [];
    if (files.length > 0) {
      setFormData(prevState => ({ ...prevState, [key]: files[0] }));
    }
  };

  const handleChange = (e: ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    const { name, value } = e.target;
    if (name === 'numero_telephone') {
      if (!/^\d{13}$/.test(value)) {
      setErrors(prevErrors => ({
        ...prevErrors,
        numero_telephone: 'Le numéro de téléphone doit contenir 13 chiffres.',
      }));
    } else {
    
      setErrors(prevErrors => ({
        ...prevErrors,
        numero_telephone: '',
      }));
    }
  }
    setFormData(prevState => ({
      ...prevState,
      [name]: name === 'id_rest' ? parseInt(value) : value,
    }));
  };

  const handleCreateRestaurant = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    try {
      const validationErrors: Partial<RestaurantFormData> = {};

      if (!/^0033\d{9}$/.test(formData.numero_telephone)) {
        validationErrors.numero_telephone = 'Numéro de téléphone invalide';
      }

      const validModesDeRetrait = ['A Emporter', 'Sur place', 'En Livraison'];
      const isValidModeDeRetrait = formData.ModeDeRetrait.split(',').every(mode => validModesDeRetrait.includes(mode.trim()));
      
      if (!isValidModeDeRetrait) {
        validationErrors.ModeDeRetrait = 'Mode de retrait invalide';
      }

      const validModesDePaiement = ['Carte bancaire', 'Espèces', 'Tickets Restaurant'];
      const isValidModeDePaiement = formData.ModeDePaiement.split(',').every(mode => validModesDePaiement.includes(mode.trim()));
  
      if (!isValidModeDePaiement) {
        validationErrors.ModeDePaiement = 'Mode de paiement invalide';
      }
  
      if (Object.keys(validationErrors).length > 0) {
        setErrors(validationErrors);
        return;
      }

      if (formData.logo === null ) {
        setMessage('Veuillez ajouter un logo');
        setIsError(true);
        return;
      }
      if (formData.image === null) {
        setMessage('Veuillez ajouter une image');
        setIsError(true);
        return;
      }
  
      const formDataToSend = new FormData();

      for (const key in formData) {
        if (formData.hasOwnProperty(key)) {
          const value = formData[key as keyof RestaurantFormData];
          if (value !== null) {
            if (key === 'logo' || key === 'image') {
              formDataToSend.append(key, value as File);
            } else {
              formDataToSend.append(key, value.toString());
            }
          }
        }
      }
      const MY_IP = process.env.MY_IP || '127.0.0.1';
      const response = await axios.post(`http://${MY_IP}:3000/createRestaurant`, formDataToSend, {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      });

      if (response.data.success) {
        setMessage('Restaurant créé avec succès');
        setFormData({
          nom: '',
          adresse: '',
          ModeDeRetrait: '',
          ModeDePaiement: '',
          numero_telephone: '',
          email: '',
          id_rest: 0,
          logo: null,
          image: null,
        });
        setIsError(false);
        router.push("/admin/RestaurantAdmin");
      } else {
        setMessage(response.data.message || 'Une erreur est survenue lors de la création du restaurant');
        setIsError(true);
      }

    } catch (error: any) {
      setMessage(error.response?.data?.message || 'Une erreur est survenue lors de la création du restaurant');
      setIsError(true);
      console.error('Error creating restaurant:', error);
    }
  };

 

  return (
    <div>
    <nav className={styles.navbar}>
      <div className={styles.left}>
        <div className={styles.logo}><AcmeLogo /></div>
        <a href="/admin/RestaurantAdmin" className={styles.link}>Restaurant</a>
      </div>
    
    </nav>
    <div className="container">
        <h1>Créer un nouveau restaurant</h1>
        <form onSubmit={handleCreateRestaurant} className="form">
          <div className="formGroup">
            <label className="input-label">Nom:</label>
            <input 
              type="text" 
              className="input" 
              name="nom" 
              placeholder="Nom" 
              value={formData.nom} 
              onChange={handleChange} 
              required 
            />
            {errors.nom && <p className="error-message">{errors.nom}</p>}
          </div>

          <div className="formGroup">
            <label className="input-label">Adresse e-mail:</label>
            <input 
              type="email" 
              className="input" 
              name="email" 
              placeholder="Adresse e-mail" 
              value={formData.email} 
              onChange={handleChange} 
              required 
            />
            {errors.email && <p className="error-message">{errors.email}</p>}
          </div>

          <div className="formGroup">
            <label className="input-label">Numéro de téléphone:</label>
            <input 
              type="text" 
              className="input" 
              name="numero_telephone" 
              placeholder="Numéro de téléphone" 
              value={formData.numero_telephone} 
              onChange={handleChange} 
              maxLength={13} 
              pattern="\d*"
              required 
            />

            {errors.numero_telephone && <p className="error-message">{errors.numero_telephone}</p>}
          </div>

          <div className="formGroup">
            <label className="input-label">Adresse:</label>
            <input 
              type="text" 
              className="input" 
              name="adresse" 
              placeholder="Adresse" 
              value={formData.adresse} 
              onChange={handleChange} 
              required 
            />
            {errors.adresse && <p className="error-message">{errors.adresse}</p>}
          </div>

          <div className="formGroup">
            <label className="input-label">Modes de retrait:</label>
            <input 
              type="text" 
              className="input" 
              name="ModeDeRetrait" 
              placeholder="Modes de retrait (séparés par des virgules)" 
              value={formData.ModeDeRetrait} 
              onChange={handleChange} 
              required 
            />
            {errors.ModeDeRetrait && <p className="error-message">{errors.ModeDeRetrait}</p>}
          </div>

          <div className="formGroup">
            <label className="input-label">Modes de paiement:</label>
            <input 
              type="text" 
              className="input" 
              name="ModeDePaiement" 
              placeholder="Modes de paiement (séparés par des virgules)" 
              value={formData.ModeDePaiement} 
              onChange={handleChange} 
              required 
            />
            {errors.ModeDePaiement && <p className="error-message">{errors.ModeDePaiement}</p>}
          </div>
          <div className="formGroup">
            <label className="input-label">Logo:</label>
            <input 
              type="file" 
              className="file-input" 
              accept="image/*" 
              onChange={(e) => handleImageChange(e, 'logo')} 
            />
          </div>

          <div className="formGroup">
            <label className="input-label">Image:</label>
            <input 
              type="file" 
              className="file-input" 
              accept="image/*" 
              onChange={(e) => handleImageChange(e, 'image')} 
            />
          </div>

          <button type="submit" className="submit-button">Créer</button>
        </form>
        
        {message && (
          <div 
            className={isError ? "error-message" : "success-message"}
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
};

export default CreateRestaurantPage;