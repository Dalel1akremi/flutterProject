// pages/index.tsx
import Navbar from '@/styles/navbar';
import Connexion from './connexion'
const IndexPage = () => {
  return (
    <div>
      <Navbar/>
      <h1>Bonjour mes chers restaurateurs</h1>
         <Connexion/>
     
    </div>
  );
};

export default IndexPage;
