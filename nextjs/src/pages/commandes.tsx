import { useEffect, useState } from 'react';
import axios from 'axios';
import Navbar from '../styles/navbar';
import { useRouter } from 'next/router';
import jwt from 'jsonwebtoken'; // Importer le package jsonwebtoken

interface Commande {
  _id: string;
  userEmail: string;
  numero_commande: string;
  etat: string;
  id_items: Item[];
}

interface Item {
  id_item: number;
  nom: string;
  prix: number;
  quantite?: number;
}

const CommandesPage = () => {
  const router = useRouter();
  const [commandes, setCommandes] = useState<Commande[]>([]);
  const [idRest, setIdRest] = useState<string | null>(null);

  useEffect(() => {
    const token = localStorage.getItem('token');
    if (token) {
      const decodedToken = jwt.decode(token) as { [key: string]: any };
      const { id_rest } = decodedToken;
      setIdRest(id_rest);
      fetchCommandes(id_rest);
    } else {
      router.push('/connexion');
    }
  }, []);


  const fetchCommandes = async (id_rest: any) => {
    try {
      const response = await axios.get<Commande[]>(`http://localhost:3000/getCommandes?id_rest=${id_rest}`);
      setCommandes(response.data);
    } catch (error) {
      console.error('Erreur lors de la récupération des commandes :', error);
    }
  };

  const handleClick = async (id: string) => {
    try {
      // Mettre à jour l'état de la commande dans le backend
      await axios.put(`http://localhost:3000/commandes?commandeId=${id}`, { etat: 'passé' });

      // Appeler l'API sendNotification
      await axios.post('http://localhost:3000/sendNotification', { userEmail: commandes.find(commande => commande._id === id)?.userEmail });

      // Mettre à jour l'état de la commande dans le state local
      setCommandes(prevCommandes =>
        prevCommandes.map(commande => {
          if (commande._id === id) {
            return { ...commande, etat: 'passé' };
          }
          return commande;
        })
      );
    } catch (error: any) {
      console.error('Error updating commande:', error.message);
    }
  };

  return (
    <div>
      <Navbar />
      <h1>Liste des commandes en cours :</h1>
      <table>
        <thead>
          <tr>
            <th>ID de la commande</th>
            <th>Email de l'utilisateur</th>
            <th>Numéro de commande</th>
            <th>État de la commande</th>
            <th>Articles commandés</th>
          </tr>
        </thead>
        <tbody>
          {commandes.map((commande, index) => (
            <tr key={index}>
              <td>{commande._id}</td>
              <td>{commande.userEmail}</td>
              <td>{commande.numero_commande}</td>
              <td onClick={() => handleClick(commande._id)} style={{ cursor: 'pointer', textDecoration: 'underline' }}>
                {commande.etat}
              </td>
              <td>
                <ul>
                  {commande.id_items.map((item, itemIndex) => (
                    <li key={itemIndex}>
                      <p>Nom : {item.nom}</p>
                      <p>Prix : {item.prix}</p>
                      {item.quantite && <p>Quantité : {item.quantite}</p>}
                    </li>
                  ))}
                </ul>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};

export default CommandesPage;
