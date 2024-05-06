import { useEffect, useState } from 'react';
import axios from 'axios';
import Navbar from '../styles/navbar';
import { useRouter } from 'next/router';
import jwt from 'jsonwebtoken'; 

interface Commande {
  _id: string;
  userEmail: string;
  numero_commande: string;
  etat: string;
  id_items: Item[];
  id_rest:number;
  email:string;
}

interface Item {
  id_item: number;
  nom: string;
  prix: number;
  quantite?: number;
  remarque?: string;
  elements_choisis: string[];
  
}

const CommandesPage = () => {
  const router = useRouter();
  const [commandes, setCommandes] = useState<Commande[]>([]);
  const [idRest, setIdRest] = useState<string | null>(null);
  const [errorMessage, setErrorMessage] = useState<string>("");

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

  useEffect(() => {
    if (errorMessage) {
      window.alert(errorMessage);
    }
  }, [errorMessage]);

  const fetchCommandes = async (id_rest: any) => {
    try {
      const MY_IP = process.env.MY_IP || '127.0.0.1';
      const response = await axios.get<Commande[]>(`http://${MY_IP}:3000/getCommandes?id_rest=${id_rest}`);
      setCommandes(response.data);
    } catch (error) {
      console.error('Erreur lors de la récupération des commandes :', error);
    }
  };

  const handleStateChange = async (id: string, newState: string) => {
    try {
      const MY_IP = process.env.MY_IP || '127.0.0.1';
      const response = await axios.put(`http://${MY_IP}:3000/commandes?commandeId=${id}&newState=${newState}`);
  
      setCommandes(prevCommandes =>
        prevCommandes.map(commande => {
          if (commande._id === id) {
            return { ...commande, etat: newState };
          }
          return commande;
        })
      );
  
      if (newState === "Prête") {
        await sendNotification(commandes.find(commande => commande._id === id)?.id_rest || 0, commandes.find(commande => commande._id === id)?.email || ''); // Utilisez id_rest et email de la commande
      }
    } catch (error: any) {
      console.error('Error updating commande:', error.message);
      if (error.response && error.response.data && error.response.data.message) {
        setErrorMessage(error.response.data.message);
      } else {
        setErrorMessage('Une erreur est survenue lors de la mise à jour de l\'état de la commande.');
      }
    }
};

  

  const sendNotification = async (id_rest: number ,email:string) => {
    try {
      const MY_IP = process.env.MY_IP || '127.0.0.1';
      const response = await axios.post(`http://${MY_IP}:3000/sendNotification?id_rest=${id_rest}&email=${email}`);
      console.log('Notification sent successfully:', response.data);
    } catch (error: any) {
      console.error('Error sending notification:', error.message);
    }
  };

  return (
    <div>
      <Navbar />
      <h1>Liste des commandes en cours :</h1>
      <table>
        <thead>
          <tr>
            <th>Numéro de commande</th>
            <th>Email de l'utilisateur</th>
            <th>État de la commande</th>
            <th>Articles commandés</th>
            <th>Remarques</th>
          </tr>
        </thead>
        <tbody>
          {commandes.map((commande, index) => (
            <tr key={index}>
              <td>{commande.numero_commande}</td>
              <td>{commande.email}</td>
              <td>
                <select
                  value={commande.etat}
                  onChange={e => handleStateChange(commande._id, e.target.value)}
                >
                  <option value="En cours">En cours</option>
                  <option value="Validée">Validée</option>
                  <option value="En Préparation">En Préparation</option>
                  <option value="Prête">Prête</option>
                  <option value="Non validée">Non validée</option>
                  <option value="Passée">Passée</option>
                </select>
              </td>
              <td>
                <ul>
                  {commande.id_items.map((item, itemIndex) => (
                    <li key={itemIndex}>
                      <p> <span style={{ color: 'purple', fontWeight: 'bold' }}>Nom :</span>{item.nom}</p>
                      <p> <span style={{ color: 'green', fontWeight: 'bold' }}>{item.elements_choisis.join(', ')}</span></p>
                      <p><span style={{ color: 'purple', fontWeight: 'bold' }}>Prix :</span> {item.prix}€</p>
                      {item.quantite && <p><span style={{ color: 'purple', fontWeight: 'bold' }}>Quantité :</span> {item.quantite}</p>}
                    </li>
                  ))}
                </ul>
              </td>
              <td> <ul>
                  {commande.id_items.map((item, itemIndex) => (
                    <li key={itemIndex}>
                      <span style={{ color: 'black', fontWeight: 'bold' }}>{item.nom}</span>: <span style={{ color: 'red' }}>{item.remarque}</span>
                    </li>
                  ))}
                </ul></td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};

export default CommandesPage;
