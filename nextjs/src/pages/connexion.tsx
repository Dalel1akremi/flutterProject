// pages/connexion.tsx
import { useState } from 'react';
import axios from 'axios';
import { useRouter } from 'next/router';
import Navbar from '../styles/navbar'; 

const Connexion = () => {
  const router = useRouter();
  const [formData, setFormData] = useState({
    email: '',
    password: '',
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
      const response = await axios.post('/api/login', formData);
      alert(response.data.message); // Afficher le message de succès
      // Rediriger vers une page différente après la connexion réussie
      router.push('/dashboard');
    } catch (error: any) {
      alert(error.response.data.message); // Afficher le message d'erreur
    }
  };

  return (
    <div>
      <Navbar/>
      <div className={"container"}>
        <h1>Connexion</h1>
        <form onSubmit={handleSubmit}>
          <div>
            <label>Email:</label>
            <input type="email" name="email" value={formData.email} onChange={handleChange} required />
          </div>
          <div>
            <label>Mot de passe:</label>
            <input type="password" name="password" value={formData.password} onChange={handleChange} required />
          </div>
          <button type="submit">Se connecter</button>
        </form>
      </div>
    </div>
  );
};

export default Connexion;
