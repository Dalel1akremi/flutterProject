import AcmeLogo from "./AcmeLogo.jsx";
import styles from './Navbar.module.css';

export default function Navbar() {
  return (
    <nav className={styles.navbar}>
      <div className={styles.left}>
       <div className={styles.logo}> <AcmeLogo /></div>
        <div className={styles.logo}>MELTING POT </div>
      </div>
      <div className={styles.center}>
        <a href="/" className={styles.link}>Acceuil</a>
        <a href="/Categorie" className={styles.link}>Catégorie</a>
        <a href="/produits" className={styles.link}>Produit</a>
        <a href="/commandes" className={styles.link}>Commande</a>
      </div>
      <div className={styles.right}>
      <a href="/connexion" className={styles.link}> Se connecter</a>
        <a href="/register" className={styles.link}>S'inscrire</a>
      </div>
    </nav>
  );
}
