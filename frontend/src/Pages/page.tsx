import { useState } from 'react';
import axios from 'axios';

interface FormData {
  nom: string;
  prenom: string;
  telephone: string;
  email: string;
  password: string;
  confirmPassword: string;
}

export default function RegisterPage() {
  const [formData, setFormData] = useState<FormData>({
    nom: '',
    prenom: '',
    telephone: '',
    email: '',
    password: '',
    confirmPassword: ''
  });
  const [errorMessage, setErrorMessage] = useState<string>('');

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setFormData({
      ...formData,
      [name]: value
    });
  };

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();

    try {
      const response = await axios.post('http://localhost:3100/register', formData);
      console.log(response.data);
      // Rediriger l'utilisateur vers une autre page après l'enregistrement réussi
    } catch (error: any) {
      console.error(error.response?.data);
      setErrorMessage(error.response?.data.message);
    }
  };

  return (
    <div>
      <h1>Créer un compte</h1>
      {errorMessage && <p>{errorMessage}</p>}
      <form onSubmit={handleSubmit}>
        <input type="text" name="nom" placeholder="Nom" value={formData.nom} onChange={handleChange} required />
        <input type="text" name="prenom" placeholder="Prénom" value={formData.prenom} onChange={handleChange} required />
        <input type="tel" name="telephone" placeholder="Téléphone" value={formData.telephone} onChange={handleChange} required />
        <input type="email" name="email" placeholder="Email" value={formData.email} onChange={handleChange} required />
        <input type="password" name="password" placeholder="Mot de passe" value={formData.password} onChange={handleChange} required />
        <input type="password" name="confirmPassword" placeholder="Confirmer le mot de passe" value={formData.confirmPassword} onChange={handleChange} required />
        <button type="submit">S'inscrire</button>
      </form>
    </div>
  );
}
