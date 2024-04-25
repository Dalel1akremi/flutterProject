import React, { useState } from 'react';
import axios from 'axios';
import { useRouter } from 'next/router';

const OublieMP = () => {
  const router = useRouter();
  const [email, setEmail] = useState('');
  const [message, setMessage] = useState('');
  const [errorMessage, setErrorMessage] = useState('');
  const [successMessage, setSuccessMessage] = useState('');

  const handleRequestValidationCode = async () => {
                    try {
                      const response = await axios.post('http://192.168.2.61:3000/reset_passwordAdmin', { email });
                      setMessage(response.data.message);
                      // Rediriger vers la page "ValidationMP" avec l'e-mail et le code de validation dans les paramètres de l'URL
                      router.push({
                        pathname: '/ValidationMP',
                        query: { email: email, validationCode: response.data.validationCode }
                      });
                    } catch (error:any) {
                      setMessage(error.response.data.message || 'Une erreur est survenue');
                    }
                  };
                  
  return (
    <div>
        <div className="container">
          <h2>Entrez votre email pour réinitialiser votre mot de passe</h2>
          <div className="formGroup">
            <label className="input-label">Email:</label>
            <input className="input" type="email" value={email} onChange={e => setEmail(e.target.value)} />
          </div>
          <button onClick={handleRequestValidationCode}>Envoyer le code de validation</button>
          {errorMessage && (
            <div style={{ backgroundColor: 'red', textAlign: 'center', marginTop: '20px', padding: '10px' }}>{errorMessage}</div>
          )}
          {successMessage && (
            <div style={{ backgroundColor: 'green', textAlign: 'center', marginTop: '20px', padding: '10px' }}>{successMessage}</div>
          )}
        </div>
      </div>
  );
};

export default OublieMP;
