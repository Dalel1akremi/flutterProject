// pages/index.tsx

import Link from 'next/link';

const IndexPage = () => {
  return (
    <div>
      <h1>Accueil</h1>
      <div>
        <Link href="/commandes">
          <button>Commandes</button>
        </Link>
        <Link href="/Produits">
          <button>Produits</button>
        </Link>
      </div>
    </div>
  );
};

export default IndexPage;
