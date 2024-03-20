// pages/connexion.tsx
import { useState } from 'react';
import axios from 'axios';
import { useRouter } from 'next/router';
import Navbar from '../styles/navbar'; 

const Connexion = () => {
  const router = useRouter();
  const [formData, setFormData] = useState({
    email: '',
    password: '',
  });

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setFormData(prevState => ({
      ...prevState,
      [name]: value,
    }));
  };

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    try {
      const response = await axios.post('http://localhost:3000/login', formData);
      alert(response.data.message); 
     
      router.push('/');
    } catch (error: any) {
      alert(error.response.data.message); 
    }
  };

  return (
    <div>
      <Navbar/>
      <div className={"container"}>
        <h1>Connexion</h1>
        <form onSubmit={handleSubmit}>
          <div className={"formGroup"}>
            <label>Email:</label>
            <input type="email" name="email" value={formData.email} onChange={handleChange} required className={"input"} />
          </div>
          <div className={"formGroup"}>
            <label>Mot de passe:</label>
            <input type="password" name="password" value={formData.password} onChange={handleChange} required className={"input"} />
          </div>
          <button type="submit" className={"button"}>Se connecter</button>
        </form>
      </div>
    </div>
  );
};

export default Connexion;
