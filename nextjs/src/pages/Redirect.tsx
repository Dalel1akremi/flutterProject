import { useEffect, useState } from 'react';
import axios from 'axios';
import { useRouter } from 'next/router';
import Link from 'next/link';
import Navbar from '../styles/navbar'; 


const Redirect = () => {
  const router = useRouter();
  const { id_item, id_rest } = router.query;
  const [redirectData, setRedirectData] = useState<any[]>([]);
  const [editingItemId, setEditingItemId] = useState<string | null>(null);
  const [editedItem, setEditedItem] = useState<any | null>(null);
  const [editedPrix, setEditedPrix] = useState<number | null>(null);
  const [editedDescription, setEditedDescription] = useState<string | null>(null);
  const [editedQuantite, setEditedQuantite] = useState<number | null>(null);
  const [editedMaxQuantite, setEditedMaxQuantite] = useState<number | null>(null);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const response = await axios.get(`http://localhost:3000/getRedirect?id_item=${id_item}&id_rest=${id_rest}`);
        setRedirectData(response.data.data); 
      } catch (error) {
        console.error('Erreur lors de la récupération des données redirect :', error);
      }
    };

    if (id_item && id_rest) {
      fetchData();
    }
  }, [id_item, id_rest]);

  if (!redirectData.length) {
    return <p>Chargement...</p>;
  }


const handleArchivedToggle = async (id_item: string, currentValue: boolean) => {
  try {
    console.log('ID de redirection à archiver:', id_item);
    await axios.put(`http://localhost:3000/ArchiverRedirect/${id_item}`, { isArchived: !currentValue });

    setRedirectData(prevItems =>
      prevItems.map(item =>
        item.id_item.toString() === id_item ? { ...item, isArchived: !currentValue } : item
      )
    );
    const response = await axios.get(`http://localhost:3000/getRedirect?id_item=${id_item}&id_rest=${id_rest}`);
    setRedirectData(response.data.data);

  } catch (error) {
    console.error('Erreur lors de la mise à jour du statut isArchived :', error);
  }
};

  
const handleEditRedirect = (item: any) => {
  setEditingItemId(item._id);
  setEditedItem({
    ...item,
  });
  setEditedPrix(item.prix);
  setEditedDescription(item.description);
  setEditedQuantite(item.quantite);
  setEditedMaxQuantite(item.max_quantite);
};

const handleUpdateRedirect = async () => {
  try {
    const { _id } = editedItem!;
    await axios.put(`http://localhost:3000/updateRedirect/${_id}`, {
      nom: editedItem?.nom,
      prix: editedPrix,
      description: editedDescription,
      quantite: editedQuantite,
      max_quantite: editedMaxQuantite,
    });

    const response = await axios.get(`http://localhost:3000/getRedirect?id_item=${id_item}&id_rest=${id_rest}`);
    setRedirectData(response.data.data);

   
    setEditingItemId(null);
    setEditedItem(null);

  } catch (error) {
    console.error('Erreur lors de la mise à jour de l\'élément :', error);
  }
};

  return (
    <div>
      <Navbar />
      <div className="header">
  <h1>Données Redirect</h1>
  <Link href={`/CreerRedirect?id_item=${id_item}`} passHref>
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
            <th>Archiver</th>
            <th>Modification</th>
          </tr>
        </thead>
   
        <tbody>
    {redirectData.map((item, index) => (
      <tr key={index}>
        <td>
          {editingItemId === item._id ? (
            <input 
              value={editedItem?.nom || ''}
              onChange={(e) => setEditedItem({ ...editedItem, nom: e.target.value })}
            />
          ) : (
            item.nom
          )}
        </td>
        <td>
          {editingItemId === item._id ? (
            <input 
              type="number"
              value={editedPrix || ''}
              onChange={(e) => setEditedPrix(parseFloat(e.target.value))}
            />
          ) : (
            `${item.prix}€`
          )}
        </td>
        <td>
          {editingItemId === item._id ? (
            <textarea 
              value={editedDescription || ''}
              onChange={(e) => setEditedDescription(e.target.value)}
            />
          ) : (
            item.description
          )}
        </td>
        <td>
          {editingItemId === item._id ? (
            <input 
              type="number"
              value={editedQuantite || ''}
              onChange={(e) => setEditedQuantite(parseInt(e.target.value))}
            />
          ) : (
            item.quantite
          )}
        </td>
        <td>
          {editingItemId === item._id ? (
            <input 
              type="number"
              value={editedMaxQuantite || ''}
              onChange={(e) => setEditedMaxQuantite(parseInt(e.target.value))}
            />
          ) : (
            item.max_quantite
          )}
        </td>
    <td>
      <input
        type="checkbox"
        checked={item.isArchived}
        onChange={() => handleArchivedToggle(item.id_item, item.isArchived)}
        className={item.isArchived ? 'redCheckbox' : ''}
      />
    </td>
    <td>
            {editingItemId === item._id ? (
              <button onClick={handleUpdateRedirect}>Enregistrer</button>
            ) : (
              <button onClick={() => handleEditRedirect(item)}>Modifier</button>
            )}
          </td>
  </tr>
))}
        </tbody>
      </table>
    </div>
  );
};

export default Redirect;
