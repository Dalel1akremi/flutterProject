import { useEffect, useState } from 'react';
import axios from 'axios';
import AcmeLogo from "./AcmeLogo.jsx";
import styles from './Navbar.module.css';
import jwt from 'jsonwebtoken';
import { useRouter } from 'next/router'; 

export default function Navbar() {
  const [restaurantName, setRestaurantName] = useState('');
  const router = useRouter();

  useEffect(() => {
    const fetchRestaurantName = async () => {
      try {
        const token = localStorage.getItem('token');
        if (!token) {
          throw new Error('Token not found in localStorage');
        }
        const decodedToken = jwt.decode(token);
        const { id_rest: decodedRestaurantId } = decodedToken;
        const response = await axios.get('http://localhost:3000/getRestau');
        const { restaurants } = response.data;
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

  const shouldDisplayRestaurantLink = router.pathname === 'admin/RestaurantAdmin';

  return (
    <nav className={styles.navbar}>
      <div className={styles.left}>
        <div className={styles.logo}><AcmeLogo /></div>
        <div className={styles.logo}>{restaurantName || 'Nom du Restaurant'}</div>
      </div>
      <div className={styles.center}>
        <a href="/Categories" className={styles.link}>Catégories</a>
        <a href="/produits" className={styles.link}>Produits</a>
        <a href="/commandes" className={styles.link}>Commandes</a>
        <a href="/Elements" className={styles.link}>Elements</a>
        <a href="/profil" className={styles.link}>Profil</a>
        

        {shouldDisplayRestaurantLink && (
          <a href="/RestaurantAdmin" className={styles.link}>Restaurant</a>
        )}
      </div>
      <div className={styles.right}>
        <a href="/deconnexion" className={styles.link}>Se déconnecter</a>
      </div>
    </nav>
  );
}
