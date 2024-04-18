import { useEffect, useState } from 'react';
import axios from 'axios';
import AcmeLogo from "./AcmeLogo.jsx";
import styles from './Navbar.module.css';
import jwt from 'jsonwebtoken';

export default function Navbar() {
  const [restaurantName, setRestaurantName] = useState('');

  useEffect(() => {
    const fetchRestaurantName = async () => {
      try {
        // Récupérer le token du localStorage
        const token = localStorage.getItem('token');
        if (!token) {
          throw new Error('Token not found in localStorage');
        }
  
        // Décoder le token pour obtenir l'id_rest
        const decodedToken = jwt.decode(token);
        const { id_rest: decodedRestaurantId } = decodedToken;
  
        // Faire l'appel à l'API pour récupérer les restaurants
        const response = await axios.get('http://localhost:3000/getRestau');
        console.log('Response from API:', response.data); // Afficher la réponse de l'API dans la console
        const { restaurants } = response.data;
        
        // Trouver le restaurant correspondant à l'ID décodé
        const matchedRestaurant = restaurants.find(restaurant => restaurant.id_rest === decodedRestaurantId);
        if (matchedRestaurant) {
          setRestaurantName(matchedRestaurant.nom);
        } else {
          console.error('Aucun restaurant correspondant trouvé pour cet ID.');
        }
      } catch (error) {
        console.error('Erreur lors de la récupération du nom du restaurant :', error);
      }
    };
  
    fetchRestaurantName();
  }, []);
  
  
  return (
    <nav className={styles.navbar}>
      <div className={styles.left}>
        <div className={styles.logo}><AcmeLogo /></div>
        <div className={styles.logo}>{restaurantName || 'Nom du Restaurant'}</div>
      </div>
      <div className={styles.center}>
        <a href="/" className={styles.link}>Accueil</a>
        <a href="/Categories" className={styles.link}>Catégories</a>
        <a href="/produits" className={styles.link}>Produits</a>
        <a href="/commandes" className={styles.link}>Commandes</a>
        <a href="/Elements" className={styles.link}>Elements</a>
        <a href="/profil" className={styles.link}>Profil</a>
       

      </div>
      <div className={styles.right}>
        <a href="/deconnexion" className={styles.link}>Se déconnecter</a>
      </div>
    </nav>
  );
}
