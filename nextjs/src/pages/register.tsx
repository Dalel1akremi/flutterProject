// pages/register.tsx
import { useState } from 'react';
import axios from 'axios';
import Navbar from '../styles/navbar';
const Register = () => {
  const [formData, setFormData] = useState({
    nom: '',
    prenom: '',
    email: '',
    telephone: '',
    password: '',
    confirmPassword: '',
  });

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setFormData(prevState => ({
      ...prevState,
      [name]: value,
    }));
  };

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    try {
      const response = await axios.post('/api/register', formData);
      alert(response.data.message); // Afficher le message de succès
      // Réinitialiser le formulaire après l'inscription réussie
      setFormData({
        nom: '',
        prenom: '',
        email: '',
        telephone: '',
        password: '',
        confirmPassword: '',
      });
    } catch (error: any) {
      alert(error.response.data.message); // Afficher le message d'erreur
    }
  };

  return (
    <div >
      <Navbar /> 
      <div className={"container"}>
      <h1 style={{ textAlign: 'center' }}>Créer un compte</h1>
      <form onSubmit={handleSubmit} className={"form"}>
        <div className={"formGroup"}>
          <label>Nom:</label>
          <input type="text" name="nom" value={formData.nom} onChange={handleChange} required className={"input"} />
        </div>
        <div className={"formGroup"}>
          <label>Prénom:</label>
          <input type="text" name="prenom" value={formData.prenom} onChange={handleChange} required className={"input"} />
        </div>
        <div className={"formGroup"}>
          <label>Email:</label>
          <input type="email" name="email" value={formData.email} onChange={handleChange} required className={"input"} />
        </div>
        <div className={"formGroup"}>
          <label>Téléphone:</label>
          <input type="text" name="telephone" value={formData.telephone} onChange={handleChange} required className={"input"} />
        </div>
        <div className={"formGroup"}>
          <label>Mot de passe:</label>
          <input type="password" name="password" value={formData.password} onChange={handleChange} required className={"input"} />
        </div>
        <div className={"formGroup"}>
          <label>Confirmer le mot de passe:</label>
          <input type="password" name="confirmPassword" value={formData.confirmPassword} onChange={handleChange} required className={"input"}/>
        </div>
        <button type="submit" className={"button"}>S'inscrire</button>
      </form>
      </div>
    </div>
  );
};

export default Register;
