import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { useRouter } from 'next/router';
import Navbar from '../styles/navbar';
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
  const [editedIdSteps, setEditedIdSteps] = useState<string | null>('');
  const [editedIsMenu, setEditedIsMenu] = useState<boolean | null>(null); 
  const [editedIsRedirect, setEditedIsRedirect] = useState<boolean | null>(null); 
  const [message, setMessage] = useState('');
  const [isSuccess, setIsSuccess] = useState(false);
  const [isLoading, setIsLoading] = useState<boolean>(false);
  const [selectedStepId, setSelectedStepId] = useState<number | null>(null);
  const [StepName, setStepName] = useState<string>('');

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
        const MY_IP = process.env.MY_IP || '127.0.0.1';
        const response = await axios.get(`http://${MY_IP}:3000/getItemsByRestaurantId?id_rest=${id_rest}`);
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
      setItems(prevItems =>
        prevItems.map(item =>
          item._id === itemId ? { ...item, isArchived: !currentValue } : item
        )
      );
      const MY_IP = process.env.MY_IP || '127.0.0.1';
      await axios.put(`http://${MY_IP}:3000/ArchiverItem/${itemId}`, { isArchived: !currentValue });
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
    setEditedIdSteps(item.id_Steps ? item.id_Steps.map(step => step.id_Step).join(', ') : '');
    setEditedIsMenu(item.is_Menu); 
    setEditedIsRedirect(item.is_Redirect);
  };

  const getNomStepById = async (id_Step: number) => {
    try {
      console.log('Appel de getNomItemById avec id_item :', id_Step);
      const MY_IP = process.env.MY_IP || '127.0.0.1';
      const response = await axios.get(`http://${MY_IP}:3000/getNomStepById/${id_Step}`);
      console.log('Réponse de getNomItemById :', response.data);
      setStepName(response.data.nom_Step);
      setSelectedStepId(id_Step);
    } catch (error) {
      console.error('Erreur lors de la récupération de l\'item :', error);
    }
  };

  const handleEditItem = async () => {
    try {
      if (editedIsMenu && editedIsRedirect) {
        setIsLoading(false);
        setIsSuccess(false);
        alert("Erreur: le bouton de redirection ne peut pas être qu'un produit simple.");
        return;
      }
      const { _id } = editedItem!;
      setIsLoading(true);
      const MY_IP = process.env.MY_IP || '127.0.0.1';
      await axios.put(`http://${MY_IP}:3000/updateItem?itemId=${_id}`, {
        nom: editedItem?.nom,
        prix: editedPrix,
        description: editedDescription,
        quantite: editedQuantite,
        max_quantite: editedMaxQuantite,
        is_Menu: editedIsMenu, 
        is_Redirect: editedIsRedirect,
        id_Steps: editedIdSteps 
      });
      const response = await axios.get(`http://${MY_IP}:3000/getItemById?itemId=${_id}`);
      setEditedItem(response.data.data);
      setEditingItemId(null);
      setEditedPrix(null);
      setEditedDescription(null);
      setEditedQuantite(null);
      setEditedMaxQuantite(null);
      setIsSuccess(true);
      setMessage('Les données ont été mises à jour avec succès !');
      setItems(prevItems =>
        prevItems.map(item =>
          item._id === _id ? { 
            ...item, 
            nom: editedItem?.nom || '', 
            prix: editedPrix || 0, 
            description: editedDescription || '', 
            quantite: editedQuantite || 0, 
            max_quantite: editedMaxQuantite || 0, 
            is_Menu: editedIsMenu || false, 
            is_Redirect: editedIsRedirect || false, 
            id_Steps: editedIdSteps ? editedIdSteps.split(',').map(id => ({ id_Step: id, nom_Step: '', id_items: [] })) : [], 
            id_rest: item.id_rest 
          } : item
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
  const handleCreerProduitClick = () => {
    router.push('/CreerProduits'); 
  };

  const handleRedirectClick = (item: Item) => {
    if (item.is_Redirect) {
      const redirectUrl = `/Redirects?id_item=${item.id_item}&id_rest=${item.id_rest}`;
      router.push(redirectUrl);
    }
  };

  return (
    <div>
      <Navbar />
      <h1>Liste des produits disponibles</h1>
      <div className="header">
        
          <button  onClick={handleCreerProduitClick} style={{ backgroundColor: 'green', color: 'white', border: 'none', padding: '10px 20px', marginBottom: '10px', marginLeft: '1230px', borderRadius: '5px', cursor: 'pointer' }}>+</button>
       
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
                          if (!prevItem) return null; 
                      
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
                    {item.is_Redirect ? (
                      <span></span> 
                    ) : (
                      <input
                        type="number"
                        value={editedPrix || ''}
                        onChange={(e) => setEditedPrix(Number(e.target.value))}
                      />
                    )}
                  </td>
                  <td>
                    <input
                      type="text"
                      value={editedDescription || ''}
                      onChange={(e) => setEditedDescription(e.target.value)}
                    />
                  </td>
                  <td>
                    {item.is_Redirect ? (
                      <span></span> 
                    ) : (
                      <input
                        type="number"
                        value={editedQuantite || ''}
                        onChange={(e) => setEditedQuantite(Number(e.target.value))}
                      />
                    )}
                  </td>
                  <td>
                    {item.is_Redirect ? (
                      <span></span> 
                    ) : (
                      <input
                        type="number"
                        value={editedMaxQuantite || ''}
                        onChange={(e) => setEditedMaxQuantite(Number(e.target.value))}
                      />
                    )}
                  </td>
                </>
              ) : (
                <>
                  <td>
                    {item.is_Redirect ? (
                      <button 
                        onClick={() => handleRedirectClick(item)} 
                        className="redirectButton"
                      >
                        {item.nom}
                      </button>
                    ) : (
                      item.nom
                    )}
                  </td>
                  <td>
                    {item.is_Redirect ? (
                      <span></span> 
                    ) : (
                      <span>{item.prix}€</span>
                    )}
                  </td>
                  <td>{item.description}</td>
                  <td>
                    {item.is_Redirect ? (
                      <span></span> 
                    ) : (
                      <span>{item.quantite}</span>
                    )}
                  </td>
                  <td>
                    {item.is_Redirect ? (
                      <span></span> 
                    ) : (
                      <span>{item.max_quantite}</span>
                    )}
                  </td>
                </>
              )}
              <td>
                {editingItemId === item._id ? (
                  <select
                    value={editedIsMenu ? "Oui" : "Non"}
                    onChange={(e) => setEditedIsMenu(e.target.value === "Oui")}
                  >
                    <option value="Oui">Oui</option>
                    <option value="Non">Non</option>
                  </select>
                ) : (
                  item.is_Menu ? 'Oui' : 'Non'
                )}
              </td>
              <td>
                {editingItemId === item._id ? (
                  <select
                    value={editedIsRedirect ? "Oui" : "Non"}
                    onChange={(e) => setEditedIsRedirect(e.target.value === "Oui")}
                  >
                    <option value="Oui">Oui</option>
                    <option value="Non">Non</option>
                  </select>
                ) : (
                  item.is_Redirect ? 'Oui' : 'Non'
                )}
              </td>
              <td>
                <input
                  type="checkbox"
                  checked={item.isArchived}
                  onChange={() => handleArchivedToggle(item._id, item.isArchived)}
                  className={item.isArchived ? 'redCheckbox' : ''}
                />
              </td>
              <td>{item.id_cat}</td>
              <td>
                {editingItemId === item._id ? (
                  <input
                    type="text"
                    value={editedIdSteps || ''}
                    onChange={(e) => setEditedIdSteps(e.target.value)}
                  />
                ) : (
                  item.id_Steps ? (
                    item.id_Steps.map((step: { id_Step: any; nom_Step: string }) => (
                      <div key={step.id_Step}>
                        <span
                          onClick={() => getNomStepById(step.id_Step)}
                          style={{ cursor: 'pointer', textDecoration: 'underline', marginRight: '5px' }}
                        >
                          {selectedStepId === step.id_Step ? (
                            <>
                              {step.id_Step} - <strong>{StepName}</strong>
                            </>
                          ) : (
                            <>
                              {step.id_Step}  {step.nom_Step}
                            </>
                          )}
                        </span>
                        <span></span>
                      </div>
                    ))
                  ) : null
                )}
              </td>
              <td>{item.id_item}</td>
              <td>
                {editingItemId === item._id ? (
                  <button 
                    onClick={handleEditItem} 
                    disabled={!editedItem?.nom}
                    style={{
                      backgroundColor: editedItem?.nom ? 'blue' : 'gray',
                      color: 'white',
                      border: 'none',
                      padding: '5px 10px',
                      borderRadius: '5px',
                      cursor: editedItem?.nom ? 'pointer' : 'not-allowed'
                    }}
                  >
                    Enregistrer
                  </button>
                ) : (
                  <button 
                    onClick={() => startEditingItem(item)}
                    style={{
                      backgroundColor: 'blue',
                      color: 'white',
                      border: 'none',
                      padding: '5px 10px',
                      borderRadius: '5px',
                      cursor: 'pointer'
                    }}
                  >
                    Modifier
                  </button>
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
