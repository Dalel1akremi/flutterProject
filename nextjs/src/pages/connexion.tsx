import React, { useState } from 'react';
import axios from 'axios';
import { useRouter } from 'next/router';

const Connexion = () => {
  const router = useRouter();
  const [formData, setFormData] = useState({
    email: '',
    password: '',
  });

  const [errorMessage, setErrorMessage] = useState('');
  const [successMessage, setSuccessMessage] = useState('');

  const handleChange = (e: { target: { name: any; value: any; }; }) => {
    const { name, value } = e.target;
    setFormData(prevState => ({
      ...prevState,
      [name]: value,
    }));
  };

  const handleSubmit = async (e: { preventDefault: () => void; }) => {
    e.preventDefault();
    try {
      const MY_IP = process.env.MY_IP || '127.0.0.1';
      const response = await axios.post(`http://${MY_IP}:3000/loginAdmin`, formData);
      localStorage.setItem('token', response.data.token);
      setSuccessMessage(response.data.message);
      setErrorMessage('');
      router.push('/');
    } catch (error) {
      if (axios.isAxiosError(error)) {
        setErrorMessage(error.response?.data.message || 'Une erreur s\'est produite');
      } else {
        setErrorMessage('Une erreur s\'est produite');
      }
      setSuccessMessage('');
    }
  };
  
  
  const handleRegisterClick = () => {
    router.push('/register');
  };

  const handleForgotPasswordClick = () => {
    router.push('/oublieMP');
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
        <div>
          <button onClick={handleForgotPasswordClick} className="forgot-password-button">Mot de passe oublié ?</button>
        </div>
      </div>
      {errorMessage && (
        <div style={{ backgroundColor: 'red', textAlign: 'center', marginTop: '20px', padding: '10px' }}>{errorMessage}</div>
      )}
      {successMessage && (
        <div style={{ backgroundColor: 'green', textAlign: 'center', marginTop: '20px', padding: '10px' }}>{successMessage}</div>
      )}
      <div className="register-section">
        <p>Si vous êtes nouveaux, merci de vous inscrire en cliquant ici</p>
        <button onClick={handleRegisterClick} className="button">S'inscrire</button>
      </div>
    </div>
  );
};

export default Connexion;
