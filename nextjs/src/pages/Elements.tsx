import React, { useState, useEffect } from 'react';
import axios from 'axios';
import Navbar from '../styles/navbar';
import Link from 'next/link';
import router from 'next/router';
import jwt from 'jsonwebtoken';
interface Step {
  _id: string;
  id_Step: string; 
  nom_Step: string;
  id_items: { id_item: number; nom: string; _id: string }[];
  is_Obligatoire: boolean;
  isArchived: boolean;
}

const Steps = () => {
  const [steps, setSteps] = useState<Step[]>([]);
  const [selectedItemId, setSelectedItemId] = useState<number | null>(null);
  const [itemName, setItemName] = useState<string>('');
  const [isLoading, setIsLoading] = useState<boolean>(false);
  const [editedItem, setEditedItem] = useState<any | null>(null);
  const [editingItemId, setEditingItemId] = useState<string | null>(null);
  const [editedIdItems, setEditedIdItems] = useState<string | null>('');

  useEffect(() => {
    const fetchSteps = async () => {
      const token = localStorage.getItem('token');
      if (!token) {
        router.push('/connexion');
        return;
      }

      try {
        const decodedToken = jwt.decode(token) as { [key: string]: any };
        const { id_rest } = decodedToken;
        const response = await axios.get(`http://localhost:3000/getStepsByRestaurantId?id_rest=${id_rest}`);
        setSteps(response.data.steps);
      } catch (error) {
        console.error('Erreur lors de la récupération des steps :', error);
      }
    };

    fetchSteps();
  }, []);

  const getNomItemById = async (id_item: number) => {
    try {
      console.log('Appel de getNomItemById avec id_item :', id_item);
      const response = await axios.get(`http://localhost:3000/getNomItemById/${id_item}`);
      console.log('Réponse de getNomItemById :', response.data);
      setItemName(response.data.nom);
      setSelectedItemId(id_item);
    } catch (error) {
      console.error('Erreur lors de la récupération de l\'item :', error);
    }
  };

  const handleObligationToggle = async (stepId: string, currentValue: boolean) => {
    try {
      setIsLoading(true);
      await axios.put(`http://localhost:3000/ObligationStep/${stepId}`, { is_Obligatoire: !currentValue });
      setSteps(prevSteps =>
        prevSteps.map(step =>
          step._id === stepId ? { ...step, is_Obligatoire: !currentValue } : step
        )
      );
      setIsLoading(false);
    } catch (error) {
      console.error('Erreur lors de la mise à jour de l\'obligation de l\'étape :', error);
      setIsLoading(false);
    }
  };

  const handleEdit = (step: Step) => {
    setEditingItemId(step._id);
    setEditedItem({ 
      ...step,
    });
    setEditedIdItems(step.id_items ? step.id_items.map(item => item.id_item).join(',') : ''); // Mise à jour de la valeur de editedIdItems
  };
  
  const handleSave = async (_id: string) => {
    try {
      if (!editedItem) {
        console.error('Étape non trouvée ou élément non modifié');
        return;
      }
  
      const modifiedStepIndex = steps.findIndex(step => step._id === _id);
      if (modifiedStepIndex === -1) {
        console.error('Étape non trouvée');
        return;
      }
  
      const updatedSteps = [...steps];
      const updatedIdItems = editedIdItems ? editedIdItems.split(',').map((id: string) => ({
        id_item: parseInt(id),
        nom: '', // Vous devez fournir la valeur appropriée pour cette propriété
        _id: ''   // Vous devez fournir la valeur appropriée pour cette propriété
      })) : [];
  
      updatedSteps[modifiedStepIndex] = {
        ...updatedSteps[modifiedStepIndex],
        nom_Step: editedItem.nom_Step,
        id_items: updatedIdItems,
      };
  
      setSteps(updatedSteps);
  
      await axios.put(`http://localhost:3000/updateStep?_id=${_id}`, {
        nom_Step: editedItem.nom_Step,
        id_items: updatedIdItems,
      });
  
      setEditingItemId(null);
      setEditedItem(null);
      setEditedIdItems('');
    } catch (error) {
      console.error('Erreur lors de la mise à jour du nom du Step :', error);
    }
  };

  const handleArchivedToggle = async (_id: string, isArchived: boolean) => {
    try {
      setIsLoading(true);
      const response = await axios.put(`http://localhost:3000/ArchiverStep/${_id}`, { isArchived: !isArchived });
      console.log('Réponse de l\'API pour ArchiverStep:', response.data); 
      setSteps(prevSteps =>
        prevSteps.map(step =>
          step._id === _id ? { ...step, isArchived: !isArchived } : step
        )
      );
      setIsLoading(false);
    } catch (error) {
      console.error('Erreur lors de la mise à jour de l\'archivage de l\'étape :', error);
      setIsLoading(false);
    }
  };
  
  
  return (
    <div>
      <Navbar />
      <div className="header">
        <h1>Liste des étapes disponibles</h1>
        <Link href="/creerElement" passHref>
          <button className="green-button">+</button>
        </Link>
      </div>
      <table>
        <thead>
          <tr>
          <th>ID de l'étape</th>
            <th>Nom de l'étape</th>
            <th>Items associés</th>
            <th>Est obligatoire</th>
            <th>Archiver</th>
            <th>Modification</th>
          </tr>
        </thead>
        <tbody>
        {steps && steps.map((step, index) => (
          <tr key={index}>
            <td>{step.id_Step}</td>
            <td>
              {editingItemId === step._id ? (
                <input 
                  value={editedItem?.nom_Step || ''}
                  onChange={(e) => setEditedItem({ ...editedItem, nom_Step: e.target.value })}
                />
              ) : (
                step.nom_Step
              )}
            </td>          
            <td>
  {editingItemId === step._id ? (
    <input
      type="text"
      value={editedIdItems || ''}
      onChange={(e) => setEditedIdItems(e.target.value)}
    />
  ) : (
    step.id_items ? step.id_items.map((item, index) => (
      <div key={index}>
        <li key={item._id} onClick={() => getNomItemById(item.id_item)} style={{ cursor: 'pointer' }}>
                      {selectedItemId === item.id_item && (
                        <>
                          {item.id_item} - <strong>{itemName}</strong>
                        </>
                      )}
                      {selectedItemId !== item.id_item && (
                        <>
                          {item.id_item} - {item.nom}
                        </>
                      )}
                    </li>

      </div>
    )) : ''
  )}
</td>

              <td>
                <input
                  type="checkbox"
                  checked={step.is_Obligatoire}
                  onChange={() => handleObligationToggle(step._id, step.is_Obligatoire)}
                  disabled={isLoading}
                />
              </td>
              <td>
                  <input
                    type="checkbox"
                    checked={step.isArchived}
                    onChange={() => handleArchivedToggle(step._id, step.isArchived)}
                    disabled={isLoading}
                  />
                </td>
                <td>
              {editingItemId === step._id ? (
                <button onClick={() => handleSave(step._id)}>Enregistrer</button>
              ) : (
                <button onClick={() => handleEdit(step)}>Modifier</button>
              )}
            </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
  
};

export default Steps;
