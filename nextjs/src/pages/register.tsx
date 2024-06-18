import { useState } from 'react';
import axios from 'axios';
import router from 'next/router';


const Register = () => {
  const [formData, setFormData] = useState({
    nom: '',
    prenom: '',
    email: '',
    telephone: '',
    password: '',
    confirmPassword: '',
    id_rest:'',
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

    // Validations
    const phoneRegex = /^0033\d{9}$/;
    const passwordRegex = /^(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*])[a-zA-Z\d!@#$%^&*]{6,}$/;

    if (!phoneRegex.test(formData.telephone)) {
      alert("Le numéro de téléphone doit commencer par '0033' et ne doit pas dépasser 14 chiffres.");
      return;
    }

    if (!passwordRegex.test(formData.password)) {
      alert("Le mot de passe doit contenir au moins 6 caractères avec une lettre majuscule, un chiffre, et un symbole.");
      return;
    }

    if (formData.password !== formData.confirmPassword) {
      alert("Les mots de passe ne correspondent pas.");
      return;
    }

    try {
      const MY_IP = process.env.MY_IP || '127.0.0.1';
      const response = await axios.post(`http://${MY_IP}:3000/registerAdmin`, formData);
      alert(response.data.message); 
      router.push('/connexion');
      setFormData({
        nom: '',
        prenom: '',
        email: '',
        telephone: '',
        password: '',
        confirmPassword: '',
        id_rest:'',
      });
    } catch (error: any) {
      alert(error.response.data.message); 
    }
  };

  return (
    <div>
      <div className={"container"}>
        <h1 style={{ textAlign: 'center' }}>Créer un compte</h1>
        <form onSubmit={handleSubmit} className={"form"}>
          <div className={"formGroup"}>
            <label>Nom:</label>
            <input type="text" name="nom" value={formData.nom} onChange={handleChange} required className={"input"} />
          </div>
          <div className={"formGroup"}>
            <label>Prénom:</label>
            <input type="text" name="prenom" value={formData.prenom} onChange={handleChange} required className={"input"} />
          </div>
          <div className={"formGroup"}>
            <label>Email:</label>
            <input type="email" name="email" value={formData.email} onChange={handleChange} required className={"input"} />
          </div>
          <div className={"formGroup"}>
            <label>Téléphone:</label>
            <input type="text" name="telephone" value={formData.telephone} onChange={handleChange} required className={"input"} />
          </div>
          <div className={"formGroup"}>
            <label>Mot de passe:</label>
            <input type="password" name="password" value={formData.password} onChange={handleChange} required className={"input"} />
          </div>
          <div className={"formGroup"}>
            <label>Confirmer le mot de passe:</label>
            <input type="password" name="confirmPassword" value={formData.confirmPassword} onChange={handleChange} required className={"input"} />
          </div>
          <div className={"formGroup"}>
        <label>ID du restaurant:</label>
        <input type="text" name="id_rest" value={formData.id_rest} onChange={handleChange} required className={"input"} />
      </div>
          <button type="submit" className={"button"}>S'inscrire</button>
        </form>
      </div>
    </div>
  );
};

export default Register;
