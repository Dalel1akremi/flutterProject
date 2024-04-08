// pages/index.tsx
import React, { useEffect } from 'react';
import Navbar from '@/styles/navbar';
import Connexion from './connexion';
import Commandes from './commandes';

const IndexPage = () => {
  useEffect(() => {
    // Vérifier si un token est présent dans le stockage
    const token = localStorage.getItem('token');
    if (token) {
      // Rediriger vers la page des commandes si un token est trouvé
      window.location.href = '/commandes';
    }
  }, []);

  return (
    <div>
      <Navbar />
      <h1>Bonjour mes chers restaurateurs</h1>
      <Connexion />
    </div>
  );
};

export default IndexPage;
