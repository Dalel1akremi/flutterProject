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
  id_rest: number;
}

const Produits = () => {
  const router = useRouter();
  const [items, setItems] = useState<Item[]>([]);
  const [editingItemId, setEditingItemId] = useState<string | null>(null);
  const [editedItem, setEditedItem] = useState<Item | null>(null);
  const [editedPrix, setEditedPrix] = useState<number | null>(null);
  const [editedDescription, setEditedDescription] = useState<string | null>(null);
  const [editedQuantite, setEditedQuantite] = useState<number | null>(null);
  const [editedMaxQuantite, setEditedMaxQuantite] = useState<number | null>(null);
  const [message, setMessage] = useState('');
  const [isSuccess, setIsSuccess] = useState(false);
  const [isLoading, setIsLoading] = useState<boolean>(false);
  const [isRMenu, setIsMenu] = useState<boolean>(false);
  const [isRedirect, setIsRedirect] = useState<boolean>(false);
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
        setIsLoading(true);
        const response = await axios.get(`http://localhost:3000/getItemsByRestaurantId?id_rest=${id_rest}`);
        setItems(response.data.items);
        setIsLoading(false);
      } catch (error) {
        console.error('Erreur lors de la récupération des items :', error);
        setIsLoading(false);
      }
    };

    fetchItems();
  }, []);

  const handleArchivedToggle = async (itemId: string, currentValue: boolean) => {
    try {
      // Mettre à jour immédiatement l'état local du checkbox
      setItems(prevItems =>
        prevItems.map(item =>
          item._id === itemId ? { ...item, isArchived: !currentValue } : item
        )
      );
  
      // Envoyer une requête à l'API pour mettre à jour l'état dans la base de données
      await axios.put(`http://localhost:3000/ArchiverItem/${itemId}`, { isArchived: !currentValue });
    } catch (error) {
      console.error('Erreur lors de la mise à jour du statut isArchived :', error);
    }
  };
  

  

  const startEditingItem = (item: Item) => {
    setEditingItemId(item._id);
    if (item._id) {
      setEditedItem({ ...item });
    }
    setEditedPrix(item.prix);
    setEditedDescription(item.description);
    setEditedQuantite(item.quantite);
    setEditedMaxQuantite(item.max_quantite);
  };
  

  const handleEditItem = async () => {
    try {
      const { _id } = editedItem!;
      setIsLoading(true);
      await axios.put(`http://localhost:3000/updateItem?itemId=${_id}`, {
        nom: editedItem?.nom,
        prix: editedPrix,
        description: editedDescription,
        quantite: editedQuantite,
        max_quantite: editedMaxQuantite,
      });
  
      const response = await axios.get(`http://localhost:3000/getItemById?itemId=${_id}`);
      setEditedItem(response.data.data);
  
      setEditingItemId(null);
      setEditedPrix(null);
      setEditedDescription(null);
      setEditedQuantite(null);
      setEditedMaxQuantite(null);
      setIsSuccess(true);
      setMessage('Les données ont été mises à jour avec succès !');
  
      // Mettre à jour items avec les modifications
      setItems(prevItems =>
        prevItems.map(item =>
          item._id === _id ? { ...item, nom: editedItem?.nom || '', prix: editedPrix || 0, description: editedDescription || '', quantite: editedQuantite || 0, max_quantite: editedMaxQuantite || 0 } : item
        )
      );
  
      setTimeout(() => {
        setIsSuccess(false);
        setMessage('');
      }, 1000);
      setIsLoading(false);
    } catch (error) {
      setIsSuccess(false);
      setMessage("Une erreur s'est produite lors de la mise à jour des données.");
      console.error("Erreur lors de la mise à jour des données :", error);
      setIsLoading(false);
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
            <th>id_cat</th>
            <th>id_Steps</th>
            <th>id_item</th>
            <th>Modification</th>
          </tr>
        </thead>
        <tbody>
          {items.map((item) => (
            <tr key={item._id}>
              {editingItemId === item._id ? (
                <>
                  <td>
                    <input
                      type="text"
                      value={editedItem?.nom || ''}
                      onChange={(e) => {
                        setEditedItem(prevItem => {
                          if (!prevItem) return null; // Return null if prevItem is null
                      
                          const updatedItem: Item = { ...prevItem, nom: e.target.value };
                          if (typeof prevItem._id !== 'undefined') {
                            updatedItem._id = prevItem._id;
                          }
                          return updatedItem;
                        });
                      }}
                      
                      
                    />
                  </td>
                  <td>
                    <input
                      type="number"
                      value={editedPrix || ''}
                      onChange={(e) => setEditedPrix(Number(e.target.value))}
                    />
                  </td>
                  <td>
                    <input
                      type="text"
                      value={editedDescription || ''}
                      onChange={(e) => setEditedDescription(e.target.value)}
                    />
                  </td>
                  <td>
                    <input
                      type="number"
                      value={editedQuantite || ''}
                      onChange={(e) => setEditedQuantite(Number(e.target.value))}
                    />
                  </td>
                  <td>
                    <input
                      type="number"
                      value={editedMaxQuantite || ''}
                      onChange={(e) => setEditedMaxQuantite(Number(e.target.value))}
                    />
                  </td>
                </>
              ) : (
                <>
                  <td>{item.nom}</td>
                  <td>{item.prix}€</td>
                  <td>{item.description}</td>
                  <td>{item.quantite}</td>
                  <td>{item.max_quantite}</td>
                </>
              )}
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
              <td>{item.id_cat}</td>
              <td>{item.id_Steps ? item.id_Steps.map((step: { id_Step: any; }) => step.id_Step).join(', ') : ''}</td>
              <td>{item.id_item}</td>
              <td>
                {editingItemId === item._id ? (
                  <button onClick={handleEditItem}>Enregistrer</button>
                ) : (
                  <button onClick={() => startEditingItem(item)}>Modifier</button>
                )}
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};

export default Produits;
