import { useEffect, useState } from 'react';
import { useRouter } from 'next/router';

const Deconnexion = () => {
  const router = useRouter();
  const [confirmLogout, setConfirmLogout] = useState(false);

  useEffect(() => {
    const token = localStorage.getItem('token');
    if (!token) {
      // Si le jeton n'existe pas, rediriger vers la page de connexion
      router.push('/connexion');
      return;
    }

    // Afficher la boîte de dialogue de confirmation lorsque la page est chargée
    setConfirmLogout(true);
  }, []);

  const handleLogout = () => {
    // Supprimer le jeton du stockage local
    localStorage.removeItem('token');
    // Rediriger vers la page de connexion
    router.push('/connexion');
  };

  const handleCancel = () => {
    // Rediriger vers la page d'accueil si l'utilisateur annule la déconnexion
    router.push('/');
  };

  return (
    <div>
      {confirmLogout && (
        <div className="modal">
          <div className="modal-content">
            <p>Voulez-vous vraiment vous déconnecter ?</p>
            <div className="buttons">
              <button onClick={handleLogout}>Oui</button>
              <button onClick={handleCancel}>Non</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default Deconnexion;
