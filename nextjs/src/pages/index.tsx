// pages/index.tsx
import React, { useEffect } from 'react';
import Navbar from '@/styles/navbar';


const IndexPage = () => {
  useEffect(() => {
    // Vérifier si un token est présent dans le stockage
    const token = localStorage.getItem('token');
 
  }, []);

  return (
    <div>
      <Navbar />
      <h1>Bonjour me chers restaurateur</h1>
    
    </div>
  );
};

export default IndexPage;
