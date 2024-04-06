import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { useRouter } from 'next/router';
import Navbar from '../styles/navbar';
import Link from 'next/link';
import jwt from 'jsonwebtoken';

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

const Produits = () => {
  const router = useRouter();
  const [items, setItems] = useState<Item[]>([]);
  const [selectedItem, setSelectedItem] = useState<Item | null>(null);
  const [formData, setFormData] = useState<Item>({
    _id: '',
    nom: '',
    prix: 0,
    description: '',
    isArchived: false,
    quantite: 0,
    max_quantite: 0,
    is_Menu: false,
    is_Redirect: false,
    id_cat: '',
    id_Steps: [],
    image: null,
    id: '',
    id_item: '',
  });

  useEffect(() => {
    const fetchItems = async () => {
      const token = localStorage.getItem('token');
      if (!token) {
        router.push('/connexion');
        return;
      }

      try {
        const decodedToken = jwt.decode(token) as { [key: string]: any };
        const { id_rest } = decodedToken;
        const response = await axios.get(`http://localhost:3000/getItemsByRestaurantId?id_rest=${id_rest}`);
        setItems(response.data.items);
      } catch (error) {
        console.error('Erreur lors de la récupération des items :', error);
      }
    };

    fetchItems();
  }, []);

  const handleArchivedToggle = async (itemId: string, currentValue: boolean) => {
    try {
      await axios.put(`http://localhost:3000/ArchiverItem/${itemId}`, { isArchived: !currentValue });
      setItems(prevItems =>
        prevItems.map(item =>
          item._id === itemId ? { ...item, isArchived: !currentValue } : item
        )
      );
    } catch (error) {
      console.error('Erreur lors de la mise à jour du statut isArchived :', error);
    }
  };

  const handleEdit = (item: Item) => {
    setSelectedItem(item);
    console.log('ID de l\'élément sélectionné :', item._id);
    // Encodez les anciennes valeurs dans l'URL et naviguez vers la page updateProduits
    const oldValuesUrl = `/updateProduits?&nom=${encodeURIComponent(item.nom)}&prix=${encodeURIComponent(item.prix)}&description=${encodeURIComponent(item.description)}&isArchived=${encodeURIComponent(item.isArchived.toString())}&quantite=${encodeURIComponent(item.quantite.toString())}&max_quantite=${encodeURIComponent(item.max_quantite.toString())}&is_Menu=${encodeURIComponent(item.is_Menu.toString())}&is_Redirect=${encodeURIComponent(item.is_Redirect.toString())}&id_cat=${encodeURIComponent(item.id_cat)}&_id=${encodeURIComponent(item._id)}`;
    router.push(oldValuesUrl);
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
            <th>Modification</th>
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
              <td>
                <button onClick={() => handleEdit(item)}>Modifier</button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};

export default Produits;
