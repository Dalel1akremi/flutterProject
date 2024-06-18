import React, { useState, useEffect } from 'react';
import axios from 'axios';
import jwt from 'jsonwebtoken';
import { useRouter } from 'next/router';
import Navbar from '@/styles/navbar';

interface Category {
  _id: string;
  nom_cat: string;
  id_cat: number;
  isArchived: boolean;
}

const CategoriesPage = () => {
  const router = useRouter();
  const [categories, setCategories] = useState<Category[]>([]);
  const [editingCategoryId, setEditingCategoryId] = useState<string>('');
  const [newCategoryName, setNewCategoryName] = useState<string>('');
  const [idRest, setIdRest] = useState<string>('');
  const [isLoading, setIsLoading] = useState<boolean>(false);

  useEffect(() => {
    const token = localStorage.getItem('token');
    if (token) {
      const decodedToken = jwt.decode(token) as { [key: string]: any };
      const { id_rest } = decodedToken;
      setIdRest(id_rest);
      getCategories(id_rest);
    } else {
      router.push('/connexion');
    }
  }, []);

  const getCategories = async (id_rest: string) => {
    try {
      const MY_IP = process.env.MY_IP || '127.0.0.1';
      const response = await axios.get(`http://${MY_IP}:3000/getCategoriesAd?id_rest=${id_rest}`);
      setCategories(response.data.data);
    } catch (error) {
      console.error('Erreur lors de la récupération des catégories :', error);
    }
  };

  const handleArchivedToggle = async (_id: string, isArchived: boolean) => {
    try {
      const MY_IP = process.env.MY_IP || '127.0.0.1';
      setIsLoading(true);
      const newIsArchived = !isArchived; 
      const response = await axios.put(`http://${MY_IP}:3000/ArchivedCategorie/${_id}`, { isArchived: newIsArchived });
      console.log('Réponse de l\'API pour ArchiverStep:', response.data);
      setCategories(prevCategories =>
        prevCategories.map(category =>
          category._id === _id ? { ...category, isArchived: newIsArchived } : category
        )
      );
      
      setIsLoading(false);
    } catch (error) {
      console.error('Erreur lors de la mise à jour de l\'archivage de catégorie :', error);
      setIsLoading(false);
    }
  };
  

  const handleEditCategory = (id_cat: string, nom_cat: string) => {
    setEditingCategoryId(id_cat);
    setNewCategoryName(nom_cat);
  };
  const handleCreerCategorieClick = () => {
    router.push('/creerCategorie'); 
  };
  const handleUpdateCategory = async (id_cat: string) => {
    try {
      const MY_IP = process.env.MY_IP || '127.0.0.1';
      await axios.put(`http://${MY_IP}:3000/updateCategory/${id_cat}`, { nom_cat: newCategoryName });
      getCategories(idRest);
      setEditingCategoryId('');
      setNewCategoryName('');
    } catch (error) {
      console.error('Erreur lors de la mise à jour de la catégorie :', error);
    }
  };

  return (
    <div>
      <Navbar />
      <h1>Liste des catégories disponibles</h1>
      <div>         
          
            <button  onClick={handleCreerCategorieClick} style={{ backgroundColor: 'green', color: 'white', border: 'none', padding: '10px 20px', marginBottom: '30px', marginLeft: '1250px', borderRadius: '5px', cursor: 'pointer' }}>+</button>
  
        </div>
        <table>
          <thead>
            <tr>
              <th>Nom</th>
              <th>ID</th>
              <th>Archiver</th>
              <th>Modification</th>
            </tr>
          </thead>
          <tbody>
            {categories.map(category => (
              <tr key={category.id_cat.toString()}>
                <td>
                    {editingCategoryId === category._id  ? (
                      <input 
                        type="text" 
                        value={newCategoryName} 
                        onChange={e => setNewCategoryName(e.target.value)} 
                      />
                    ) : (
                      category.nom_cat
                    )}
                  </td>

                <td>{category.id_cat.toString()}</td>
                <td>
                <input
                    type="checkbox"
                    checked={category.isArchived}
                    onChange={() => handleArchivedToggle(category._id, category.isArchived)}
                    disabled={isLoading}
                  />
                </td>
                <td>
                  {editingCategoryId === category._id ? (
                    <button onClick={() => handleUpdateCategory(category.id_cat.toString())} style={{ backgroundColor: 'green', color: 'white', border: 'none', padding: '5px 10px', borderRadius: '5px', cursor: 'pointer' }}>Enregistrer</button>
                  ) : (
                    <button onClick={() => handleEditCategory(category._id, category.nom_cat)} style={{ backgroundColor: 'blue', color: 'white', border: 'none', padding: '5px 10px', borderRadius: '5px', cursor: 'pointer' }}>Modifier</button>
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
   
  );
};

export default CategoriesPage;
