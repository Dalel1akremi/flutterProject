import Link from 'next/link';
import axios from 'axios';
import { useEffect, useState } from 'react';

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
  const [items, setItems] = useState<Item[]>([]);

  useEffect(() => {
    const fetchItems = async () => {
      try {
        const response = await axios.get('http://localhost:3000/getItems');
        setItems(response.data.items);
      } catch (error) {
        console.error('Erreur lors de la récupération des items :', error);
      }
    };

    fetchItems();
  }, []);

  const handleArchivedToggle = async (itemId: string, currentValue: boolean) => {
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
              <td>{item.id_Steps ? item.id_Steps.map(step => step.id_Step).join(', ') : ''}</td>
              <td>{item.id_item}</td>
              {/* Ajoutez d'autres colonnes au besoin */}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};

export default Produits;
