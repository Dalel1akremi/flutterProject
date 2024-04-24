import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { useRouter } from 'next/router';

const ValidationMP = () => {
  const router = useRouter();
  const [email, setEmail] = useState('');
  const [message, setMessage] = useState('');
  const [code, setCode] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [resetStep, setResetStep] = useState(1);
  const [validationCode, setValidationCode] = useState('');
  const [successMessage, setSuccessMessage] = useState('');

  useEffect(() => {
                    // Récupérer l'email depuis les paramètres de requête
                    const routerEmail = router.query.email;
                
                    // Vérifier si routerEmail est défini et s'il s'agit d'une chaîne de caractères
                    if (typeof routerEmail === 'string') {
                        setEmail(routerEmail);
                    }
                }, [router.query]);
                

  const handleResetPassword = async () => {
    try {
      const response = await axios.post('http://192.168.2.65:3000/validate_codeAdmin', { email, validationCode  });
      setMessage(response.data.message);
      if (response.data.success) {
        setResetStep(3);
        router.push('/NouveauMP');
      }
    } catch (error:any) {
      setMessage(error.response.data.message || 'Une erreur est survenue');
    }
  };

  return (
    <div className="container">
      <h2>Validation du Code de Réinitialisation</h2>
      <div className="formGroup">
        <label className="input-label">Email:</label>
        <input className="input" type="email" value={email} onChange={e => setEmail(e.target.value)} />
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
