import { useEffect, useState } from 'react';
import axios from 'axios';
import Link from 'next/link';
import AcmeLogo from "../../styles/AcmeLogo";
import styles from './../../styles/Navbar.module.css';
const Restaurant = () => {
  const [restaurants, setRestaurants] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const MY_IP = process.env.MY_IP || '127.0.0.1';
  useEffect(() => {
    const fetchRestaurants = async () => {
      try {
      
        const response = await axios.get(`http://${MY_IP}:3000/getRestaurant`);
        setRestaurants(response.data.restaurants);
        setLoading(false);
      } catch (error) {
        console.error('Erreur lors de la récupération des restaurants:', error);
        setLoading(false);
      }
    };

    fetchRestaurants();
  }, []);

  return (
    
    <div>
       <nav className={styles.navbar}>
      <div className={styles.left}>
        <div className={styles.logo}><AcmeLogo /></div>
        <a href="/admin/RestaurantAdmin" className={styles.link}>Restaurant</a>
      </div>
    </nav>
      <div className="header">
        <h1>Liste des Restaurants</h1>
        <Link href="/admin/CreerRestaurantAdmin" passHref>
          <button className="green-button">+</button>
        </Link>
      </div>

      <div className="restaurants-list">
        
        <table>
          <thead>
            <tr>
              <th>Logo</th>
              <th>ID Restaurant</th>
              <th>Nom</th>
              <th>Adresse</th>
              <th>Mode de Retrait</th>
              <th>Mode de Paiement</th>
              <th>Numéro de Téléphone</th>
              <th>Email</th>
            </tr>
          </thead>
          <tbody>
            {restaurants.map((restaurant, index) => (
              
              <tr key={index}>
                <td>
                  <img src={`http://${MY_IP}:3000/${restaurant.logo}`} alt={`Logo ${restaurant.nom}`} style={{ width: '50px', height: '50px' }} />
                </td>
                <td>{restaurant.id_rest}</td>
                <td>{restaurant.nom}</td>
                <td>{restaurant.adresse}</td>
                <td>{restaurant.ModeDeRetrait ? restaurant.ModeDeRetrait.join(', ') : 'Non spécifié'}</td>
                <td>{restaurant.ModeDePaiement ? restaurant.ModeDePaiement.join(', ') : 'Non spécifié'}</td>
                <td>{restaurant.numero_telephone}</td>
                <td>{restaurant.email}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default Restaurant;
