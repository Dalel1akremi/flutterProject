import React, { useState, useEffect } from 'react';
import router from 'next/router';

const NouveauMotDePasseAdmin = () => {
  const [newPassword, setNewPassword] = useState('');
  const [confirmNewPassword, setConfirmNewPassword] = useState('');
  const [message, setMessage] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  const [successMessage, setSuccessMessage] = useState<string | null>(null);

  useEffect(() => {
    const email = localStorage.getItem('email');
    if (!email) {
      setError('Email non trouvé dans local storage');
      setLoading(false);
    } else {
      setLoading(false);
    }
  }, []);

  const handleSubmit = async (e: { preventDefault: () => void; }) => {
    e.preventDefault();
    const email = localStorage.getItem('email');
    if (!email) {
      setMessage('Email non trouvé dans local storage');
      return;
    }

    if (newPassword !== confirmNewPassword) {
      setMessage('Les mots de passe ne correspondent pas.');
      return;
    }

    try {
      const MY_IP = process.env.MY_IP || '127.0.0.1';
      const response = await fetch(`http://${MY_IP}:3000/newPasswordAdmin?email=${email}`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ newPassword, confirmNewPassword })
      });

      const data = await response.json();

      if (data.success) {
        setSuccessMessage('Mot de passe mis à jour avec succès.');
        setTimeout(() => {
          setSuccessMessage(null);
          router.push('/connexion');
        }, 1000);
      } else {
        setMessage(data.message);
      }
    } catch (error) {
      console.error('Error:', error);
      setMessage('Une erreur s\'est produite lors de la mise à jour du mot de passe.');
    }
  };

  if (loading) {
    return <div>Loading...</div>;
  }

  if (error) {
    return <div>Error: {error}</div>;
  }

  return (
    <div className="container">
      <h1>Modifier le mot de passe restaurateur</h1>
      <form className="form" onSubmit={handleSubmit}>
        <div className="formGroup">
          <label className="input-label">Nouveau Mot de Passe:</label>
          <input className="input" type="password" value={newPassword} onChange={(e) => setNewPassword(e.target.value)} />
        </div>
        <div className="formGroup">
          <label className="input-label">Confirmer le Nouveau Mot de Passe:</label>
          <input className="input" type="password" value={confirmNewPassword} onChange={(e) => setConfirmNewPassword(e.target.value)} />
        </div>
        <button type="submit">Enregistrer</button>
      </form>
      {message && <div style={{ backgroundColor: 'lightcoral', padding: '10px', marginTop: '10px' }}>{message}</div>}
      {successMessage && <div style={{ backgroundColor: 'lightgreen', padding: '10px', marginTop: '10px' }}>{successMessage}</div>}
    </div>
  );
};

export default NouveauMotDePasseAdmin;
