
import React, { useEffect } from 'react';
import Navbar from '@/styles/navbar';
import router from 'next/router';


const IndexPage = () => {
  useEffect(() => {

    const token = localStorage.getItem('token');
    if (token) {
    }
    else {
      router.push('/connexion');
    }
 
  }, []);

  return (
    <div>
      <Navbar />
      <h1>Bonjour mes chers restaurateurs</h1>
    
    </div>
  );
};

export default IndexPage;
