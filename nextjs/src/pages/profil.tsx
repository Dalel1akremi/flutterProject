import { useState, useEffect } from 'react';
import axios from 'axios';
import jwt from 'jsonwebtoken';
import { useRouter } from 'next/router';
import Navbar from '@/styles/navbar';

interface AdminData {
  nom: string;
  prenom: string;
  telephone: number;
  email: string;
  id_rest: string;
}

const Profile = () => {
  const [adminData, setAdminData] = useState<AdminData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [editedNom, setEditedNom] = useState('');
  const [editedPrenom, setEditedPrenom] = useState('');
  const [editedTelephone, setEditedTelephone] = useState('');
  const [editedEmail, setEditedEmail] = useState('');
  const [successMessage, setSuccessMessage] = useState<string | null>(null);
  const router = useRouter();

  useEffect(() => {
    const fetchAdmin = async () => {
      try {
        const token = localStorage.getItem('token');
        if (!token) {
          throw new Error('Token non trouvé');
        }

        const decodedToken = jwt.decode(token) as { [key: string]: any };
        const { email } = decodedToken;
        const MY_IP = process.env.MY_IP || '127.0.0.1';
        const response = await axios.get(`http://${MY_IP}:3000/getAdminByEmail?email=${email}`);
        setAdminData(response.data);
        setLoading(false);
      } catch (error) {
        console.error('Erreur lors de la récupération des données :', error);
        setError('Une erreur est survenue lors de la récupération des données.');
        setLoading(false);
      }
    };

    fetchAdmin();
  }, []);

  const handleNomChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    setEditedNom(event.target.value);
  };

  const handlePrenomChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    setEditedPrenom(event.target.value);
  };

  const handleTelephoneChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    setEditedTelephone(event.target.value);
  };


  const handleSubmit = async () => {
    try {
      if (!adminData) {
        throw new Error('Aucune donnée d\'administrateur trouvée');
      }
      const MY_IP = process.env.MY_IP || '127.0.0.1';
      const response = await axios.post(`http://${MY_IP}:3000/updateAdmin?email=${adminData.email}`, {
        nom: editedNom,
        prenom: editedPrenom,
        telephone: editedTelephone,
        email: editedEmail,
      });
      console.log(response.data); 
      setSuccessMessage('Modifications enregistrées avec succès');
      setTimeout(() => {
        setSuccessMessage(null);
        router.push('/profil'); 
      }, 1000);
    } catch (error) {
      console.error('Erreur lors de la mise à jour de l\'administrateur :', error);
    }
  };
                  
  const renderForm = () => {
    if (loading) {
      return <div>Loading...</div>;
    }
  
    if (error) {
      return <div>Erreur: {error}</div>;
    }
  
    if (!adminData) {
      return <div>Aucune donnée d'administrateur trouvée.</div>;
    }
  
    return (
      <div>
        <Navbar />
        <div className="container">
          <h1>Profil de Restaurateur</h1>
          <form className="form">
            <div className="formGroup">
              <label className="input-label">Nom:</label>
              <input className="input" type="text" value={editedNom || adminData.nom} onChange={handleNomChange} />
            </div>
            <div className="formGroup">
              <label className="input-label">Prénom:</label>
              <input className="input" type="text" value={editedPrenom || adminData.prenom} onChange={handlePrenomChange} />
            </div>
            <div className="formGroup">
              <label className="input-label">Téléphone:</label>
              <input className="input" type="text" value={editedTelephone || adminData.telephone} onChange={handleTelephoneChange} />
            </div>
            <div className="formGroup">
              <label className="input-label">Email:</label>
              <input className="input" type="email" value={ adminData.email}readOnly  />
            </div>
            <div className="formGroup">
              <label className="input-label">ID Restaurant:</label>
              <input className="input" type="text" value={adminData.id_rest} readOnly />
            </div>
            <button type="button" onClick={handleSubmit}>Enregistrer les modifications</button>
            {successMessage && <div style={{ backgroundColor: 'lightgreen', padding: '10px', marginTop: '10px' }}>{successMessage}</div>}
          </form>
        </div>
      </div>
    );
  };
                  
  return (
    <div>
      {renderForm()}
    </div>
  );
};

export default Profile;
