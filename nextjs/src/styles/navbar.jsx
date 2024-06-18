import { useEffect, useState } from 'react';
import axios from 'axios';
import styles from './Navbar.module.css';
import jwt from 'jsonwebtoken';
import { useRouter } from 'next/router'; 

export default function Navbar() {
  const [restaurantName, setRestaurantName] = useState('');
  const [restaurantLogo, setRestaurantLogo] = useState('');
  const router = useRouter();

  useEffect(() => {
    const fetchRestaurantData = async () => {
      try {
        const token = localStorage.getItem('token');
        if (!token) {
          throw new Error('Token non trouvé dans localStorage');
        }
        const decodedToken = jwt.decode(token);
        const { id_rest: decodedRestaurantId } = decodedToken;
        const MY_IP = process.env.MY_IP || '127.0.0.1';
        const response = await axios.get(`http://${MY_IP}:3000/getRestau`);
        const { restaurants } = response.data;
        const matchedRestaurant = restaurants.find(restaurant => restaurant.id_rest === decodedRestaurantId);
        if (matchedRestaurant) {
          setRestaurantName(matchedRestaurant.nom);
          setRestaurantLogo(`http://${MY_IP}:3000/${matchedRestaurant.logo}`);
        } else {
          console.error('Aucun restaurant correspondant trouvé pour cet ID.');
        }
      } catch (error) {
        console.error('Erreur lors de la récupération du nom du restaurant :', error);
      }
    };
  
    fetchRestaurantData();
  }, []);

  const shouldDisplayRestaurantLink = router.pathname === '/admin/RestaurantAdmin';
 
  return (
    <nav className={styles.navbar}>
      <div className={styles.left}>
        <div className={styles.logo}>
          <img src={restaurantLogo } alt="" style={{ width: '70px', height: '50px' }}/>
        </div>
        <div className={styles.restaurantName}>{restaurantName || 'Nom du Restaurant'}</div>
      </div>

      <div className={styles.center}>
      <a href="/" className={styles.link}>Acceuil</a>
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
 