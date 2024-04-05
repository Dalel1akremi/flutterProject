import React, { useState, useEffect } from 'react';
import axios from 'axios';
import jwt from 'jsonwebtoken';
import { useRouter } from 'next/router';
import Link from 'next/link';
import Navbar from '@/styles/navbar';

interface Category {
  _id: string;
  nom_cat: string;
  id_cat: number;
  is_archived: boolean;
}

const CategoriesPage = () => {
  const router = useRouter();
  const [categories, setCategories] = useState<Category[]>([]);
  const [editingCategoryId, setEditingCategoryId] = useState<string>('');
  const [newCategoryName, setNewCategoryName] = useState<string>('');
  const [idRest, setIdRest] = useState<string>('');

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
      const response = await axios.get(`http://localhost:3000/getCategories?id_rest=${id_rest}`);
      setCategories(response.data.data);
    } catch (error) {
      console.error('Erreur lors de la récupération des catégories :', error);
    }
  };

  const handleArchiveToggle = async (id_cat: string) => {
    try {
      await axios.put(`http://localhost:3000/ArchivedCategorie/${id_cat}`, {});
      // Refresh categories after update
      getCategories(idRest);
    } catch (error) {
      console.error('Erreur lors de la mise à jour de l\'état is_archived :', error);
    }
  };

  const handleEditCategory = (id_cat: string, nom_cat: string) => {
    setEditingCategoryId(id_cat);
    setNewCategoryName(nom_cat);
  };

  const handleUpdateCategory = async (id_cat: string) => {
    try {
      await axios.put(`http://localhost:3000/updateCategory/${id_cat}`, { nom_cat: newCategoryName });
      // Refresh categories after update
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
      <div>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
          <h1>Liste des catégories</h1>
          <Link href="/creerCategorie">
            <button style={{ backgroundColor: 'green', color: 'white', border: 'none', padding: '10px 20px', borderRadius: '5px', cursor: 'pointer' }}>+</button>
          </Link>
        </div>
        <table>
          <thead>
            <tr>
              <th>Nom</th>
              <th>ID</th>
              <th>Statut</th>
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
                    checked={category.is_archived}
                    onChange={() => handleArchiveToggle(category.id_cat.toString())}
                    style={{ cursor: 'pointer' }}
                    className={category.is_archived ? 'redCheckbox' : ''}
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
    </div>
  );
};

export default CategoriesPage;
