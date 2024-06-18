
import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { useRouter } from 'next/router';

const ValidationMP = () => {
  const router = useRouter();
  const [email, setEmail] = useState('');
  const [message, setMessage] = useState('');
  const [resetStep, setResetStep] = useState(1);
  const [validationCode, setValidationCode] = useState('');
  const [successMessage, setSuccessMessage] = useState('');

  useEffect(() => {
    const routerEmail = router.query.email;

    if (typeof routerEmail === 'string') {
      setEmail(routerEmail);
      localStorage.setItem('email', routerEmail);
      console.log("Email défini à partir de la requête du routeur.", routerEmail);
    } else {
      const storedEmail = localStorage.getItem('email');
      if (storedEmail) {
        setEmail(storedEmail);
        console.log('Email récupéré depuis le stockage local :', storedEmail);
      }
    }
  }, [router.query]);

  const handleEmailChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const newEmail = e.target.value;
    setEmail(newEmail);
    localStorage.setItem('email', newEmail);
  };

  const handleResetPassword = async () => {
    try {
      const MY_IP = process.env.MY_IP || '127.0.0.1';
      const response = await axios.post(`http://${MY_IP}:3000/validate_codeAdmin`, { email, validationCode });
      setMessage(response.data.message);
      if (response.data.success) {
        setResetStep(3);
        router.push('/NouveauMP');
      }
    } catch (error: any) {
      setMessage(error.response?.data?.message || 'Une erreur est survenue');
    }
  };

  return (
    <div className="container">
      <h2>Validation du Code de Réinitialisation</h2>
      <div className="formGroup">
        <label className="input-label">Email:</label>
        <input className="input" type="email" value={email} onChange={handleEmailChange} />
      </div>
      <div className="formGroup">
        <label className="input-label">Code de Validation:</label>
        <input className="input" type="text" value={validationCode} onChange={e => setValidationCode(e.target.value)} />
      </div>
      <button onClick={handleResetPassword}>Valider</button>
      {message && (
        <div style={{ backgroundColor: 'red', textAlign: 'center', marginTop: '20px', padding: '10px' }}>{message}</div>
      )}
      {successMessage && (
        <div style={{ backgroundColor: 'green', textAlign: 'center', marginTop: '20px', padding: '10px' }}>{successMessage}</div>
      )}
    </div>
  );
};

export default ValidationMP;
