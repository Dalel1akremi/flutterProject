import React, { useEffect, useState } from 'react';
import axios from 'axios';
import { useRouter } from 'next/router';
import Navbar from '../styles/navbar';
import Link from 'next/link';
import jwt from 'jsonwebtoken'; // Importer jwt pour décoder le token
 
interface Item {
  _id: string;
  nom: string;
  prix: number;
  description: string;
  isArchived: boolean;
  quantite: number;
  max_quantite: number;
  is_Menu: boolean;
  is_Redirect: boolean;
  id_cat: string;
  id_Steps: { id_Step: string; nom_Step: string; id_items: { id_item: string; nom_item: string }[] }[];
  image: string | null;
  id: string;
  id_item: string;
}

// Votre composant Produits
const Produits = () => {
  const router = useRouter();
  const [items, setItems] = useState<Item[]>([]);

  useEffect(() => {
    const fetchItems = async () => {
      const token = localStorage.getItem('token'); // Récupérer le jeton du stockage local
      if (!token) {
        router.push('/connexion'); // Rediriger vers la page de connexion si le jeton n'existe pas
        return;
      }

      try {
        const decodedToken = jwt.decode(token) as { [key: string]: any };
      const { id_rest } = decodedToken;// Extraire l'identifiant du restaurant
        const response = await axios.get(`http://localhost:3000/getItemsByRestaurantId?id_rest=${id_rest}`);
        setItems(response.data.items); // Mettre à jour les produits avec ceux du restaurant
      } catch (error) {
        console.error('Erreur lors de la récupération des items :', error);
      }
    };

    fetchItems();
  }, []);

  const handleArchivedToggle = async (itemId: any, currentValue: any) => {
    try {
      await axios.put(`http://localhost:3000/updateItem/${itemId}`, { isArchived: !currentValue });
      setItems(prevItems =>
        prevItems.map(item =>
          item._id === itemId ? { ...item, isArchived: !currentValue } : item
        )
      );
    } catch (error) {
      console.error('Erreur lors de la mise à jour du statut isArchived :', error);
    }
  };

  return (
    <div>
      <Navbar />
      <div className="header">
        <h1>Liste des produits disponibles</h1>
        <Link href="/CreerProduits" passHref>
          <button className="green-button">+</button>
        </Link>
      </div>
      <table>
        <thead>
          <tr>
            <th>Nom</th>
            <th>Prix</th>
            <th>Description</th>
            <th>Quantité</th>
            <th>Quantité maximale</th>
            <th>isMenu</th>
            <th>Redirection</th>
            <th>isArchived</th>
            <th>id</th>
            <th>id_cat</th>
            <th>id_Steps</th>
            <th>id_item</th>
            {/* Ajoutez d'autres colonnes au besoin */}
          </tr>
        </thead>
        <tbody>
          {items.map((item) => (
            <tr key={item._id}>
              <td>{item.nom}</td>
              <td>{item.prix}</td>
              <td>{item.description}</td>
              <td>{item.quantite}</td>
              <td>{item.max_quantite}</td>
              <td>{item.is_Menu ? 'Oui' : 'Non'}</td>
              <td>{item.is_Redirect ? 'Oui' : 'Non'}</td>
              <td>
                <input
                  type="checkbox"
                  checked={item.isArchived}
                  onChange={() => handleArchivedToggle(item._id, item.isArchived)}
                  className={item.isArchived ? 'redCheckbox' : ''}
                />
              </td>
              <td>{item.id}</td>
              <td>{item.id_cat}</td>
              <td>{item.id_Steps ? item.id_Steps.map((step: { id_Step: any; }) => step.id_Step).join(', ') : ''}</td>
              <td>{item.id_item}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};

export default Produits;
