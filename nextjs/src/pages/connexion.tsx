import { useState, useEffect } from 'react';
import axios from 'axios';
import { useRouter } from 'next/router';

const Connexion = () => {
  const router = useRouter();
  const [formData, setFormData] = useState({
    email: '',
    password: '',
  });

  useEffect(() => {
    const token = localStorage.getItem('token');
    if (token) {
      router.push('/produits');
    }
  }, []);

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
      const response = await axios.post('http://localhost:3000/loginAdmin', formData);
      localStorage.setItem('token', response.data.token); // Stockage du token
      alert(response.data.message);
      router.push('/produits');
    } catch (error: any) {
      alert(error.response.data.message);
    }
  };

  const handleLogout = () => {
    localStorage.removeItem('token'); // Suppression du token lors de la déconnexion
    router.push('/connexion');
  };

  const handleRegisterClick = () => {
    router.push('/register');
  };

  return (
    <div className="container">
      <div className="login-form">
        <h1>Connexion</h1>
        <form onSubmit={handleSubmit}>
          <div className="formGroup">
            <label>Email:</label>
            <input type="email" name="email" value={formData.email} onChange={handleChange} required className="input" />
          </div>
          <div className="formGroup">
            <label>Mot de passe:</label>
            <input type="password" name="password" value={formData.password} onChange={handleChange} required className="input" />
          </div>
          <button type="submit" className="button">Se connecter</button>
        </form>
      </div>
      <div className="register-section">
        <p>Si vous êtes nouveaux, merci de vous inscrire en cliquant ici</p>
        <button onClick={handleRegisterClick} className="button">S'inscrire</button>
      </div>
    </div>
  );
};

export default Connexion;
