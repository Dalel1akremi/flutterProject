import { useEffect, useState } from 'react';
import { useRouter } from 'next/router';
import Navbar from '@/styles/navbar';

const Deconnexion = () => {
  const router = useRouter();
  const [confirmLogout, setConfirmLogout] = useState(false);

  useEffect(() => {
    const token = localStorage.getItem('token');
    if (!token) {
      router.push('/connexion');
      return;
    }
    setConfirmLogout(true);
  }, []);

  const handleLogout = () => {
    localStorage.removeItem('token');
    router.push('/connexion');
  };

  const handleCancel = () => {
    router.push('/');
  };

  return (
    <div>
      <Navbar />
      <div className="container">
      {confirmLogout && (
        <div className="modal">
          <div className="modal-content">
            <p>Voulez-vous vraiment vous déconnecter ?</p>
            <div className="buttons">
            <button className="logout-button" onClick={handleLogout}>Oui</button>
            <button className="cancel-button" onClick={handleCancel}>Non</button>
            </div>
          </div>
        </div>
      )}
    </div>
    </div>
  );
};

export default Deconnexion;
