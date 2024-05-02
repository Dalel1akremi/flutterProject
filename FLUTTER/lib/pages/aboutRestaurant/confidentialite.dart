import 'package:flutter/material.dart';
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
         backgroundColor: const Color.fromARGB(222, 212, 133, 14),
        title: const Text('Politique de confidentialité'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Préambule',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
            const SizedBox(height: 10.0),
            const Text(
              'La présente politique de protection de confidentialité s\'applique aux traitements de données à caractère personnel réalisés par la franchise TEST DEV via son application TEST DEV (téléchargeable via le Play Store). Nous prenons un engagement de responsabilité et de transparence concernant les informations que vous nous communiquez.',
            ),
            const SizedBox(height: 20.0),
            const Text(
              '1. Mode de collecte de vos données',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 10.0),
            const Text(
              'Nous recueillons vos données directement auprès de vous au moment de la creation d\'un compte utilisateur sur l\'application TEST DEV, lors de l\'identification pour valider votre commande ou en nous appelons.',
            ),
            const SizedBox(height: 20.0),
            const Text(
              '2. Types de données que nous collectons',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 10.0),
            const Text(
              'Nous demandons les informations ci-dessous vous concernent lors de création du compte :',
            ),
            const SizedBox(height: 10.0),
            RichText(
              text: const TextSpan(
                text: '• Votre nom, Prénom, numéro de téléphone\n',
                style: TextStyle(color: Colors.black),
                children: [
                  TextSpan(
                    text: '• Votre adresse mail: a laquelle nous vous envoyons une confirmation de commande ainsi que la validation de la commande en ligne.\n',
                  ),
                  TextSpan(
                    text: '• Votre adresse de livraison: indispensable pour la livraison de votre commande\n',
                  ),
                  TextSpan(
                    text: '• Mot de passe\n',
                  ),
                  TextSpan(
                    text: '• Votre carte bancaire : en cas de payement en ligne\n',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            const Text(
              'En cas d\'identification via Facebook, nous recueillons l\'information suivante :',
            ),
            const SizedBox(height: 10.0),
            const Text(
              '• Adresse mail',
            ),
            const SizedBox(height: 20.0),
            const Text(
              'En cas d\'identification via Google, nous recueillons l\'information suivante :',
            ),
            const SizedBox(height: 10.0),
            const Text(
              '• Adresse mail',
            ),
            const SizedBox(height: 20.0),
            const Text(
              '2.1 - Inscription',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 10.0),
            const Text(
              '• Finalité/activité',
            ),
            const SizedBox(height: 5.0),
            const Text(
              'Pour gérer votre inscription et votre compte, y compris pour vous permettre d\'accéder à notre application et de l\'utiliser.',
            ),
            const SizedBox(height: 5.0),
            const Text(
              '• Données personnelles',
            ),
            const SizedBox(height: 5.0),
            const Text(
              '- Nom, Prenom\n- Adresse e mail\n- Numéro de téléphone portable\n- Mot de passe\n- Données de l\'appareil.',
            ),
            const Text(
              '• Fondement jungique'
            ),
            const Text ('Necessité pourlexecution d\'un contrat conclu avec vous.'),
           const Text(
              '2.2 - Avis',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 10.0),
            const Text(
              '- Finalité/activité\nPour prendre vos avis, notes, messages et autres contenus.',
            ),
            const SizedBox(height: 5.0),
            const Text(
              '• Données personnelles\n- Nom, Prénom\n- Adresse e-mail\n- Contenu fourni par vos soins',
            ),
            const SizedBox(height: 5.0),
            const Text(
              '• Fondement juridique\nNécessité pour l\'exécution d\'un contrat conclu avec vous. Nos intérêts légitimes (recueillir les suggestions des utilisateurs sur leur expérience au restaurant).',
            ),
            const SizedBox(height: 20.0),
            const Text(
              '2.3 - Programme de fidélité',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 10.0),
            const Text(
              '• Finalité/activité\nPour exécuter et gérer le programme de fidélisation',
            ),
            const SizedBox(height: 5.0),
            const Text(
              '• Données personnelles\n- Nom, Prénom\n- Adresse e-mail\n- Numéro de téléphone portable\n- Numéro carte fidélité\n- Données de l\'appareil',
            ),
            const SizedBox(height: 5.0),
            const Text(
              '• Fondement juridique\nNécessité pour l\'exécution d\'un contrat conclu avec vous. Nos intérêts légitimes (tenir nos dossiers à jour, gérer efficacement le programme de fidélisation, prévenir la fraude).',
            ),
            const SizedBox(height: 20.0),
            const Text(
              '2.4 - Promotions',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 10.0),
            const Text(
              '• Finalité/activité\nPour vous informer des promotions et offres spéciales, ainsi que des services que nous proposons et qui peuvent vous intéresser.',
            ),
            const SizedBox(height: 5.0),
            const Text(
              '• Données personnelles\n- Nom\n- Adresse e-mail\n• Activité en ligne sur notre site\n- Identifiant\n- Données de localisation\n- Numéro de téléphone portable\n- Données de l\'appareil',
            ),
            const SizedBox(height: 5.0),
            const Text(
              '• Fondement juridique\nVotre consentement à recevoir des communications marketing par e-mails, notifications push ou messages texte.',
            ),
            const SizedBox(height: 20.0),
            const Text(
              '2.5 - Sécurité',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 10.0),
            const Text(
              '• Finalité/activité\nPour administrer et protéger notre activité, pour résoudre les problèmes et pour prévenir des activités potentiellement interdites ou illégales.',
            ),
            const SizedBox(height: 5.0),
            const Text(
              '• Données personnelles\n- Nom\n- Adresse postale\n- Adresse e-mail\n- Numéro de téléphone\n- Identifiant\n- Adresse IP\n- Code IMEI',
            ),
           const Text(
              '• Fondement juridique'
            ),
            const SizedBox(height: 10.0),
            const Text(
              'Notre intérêt légitime (pour la gestion de notre entreprise, pour prévenir la fraude et les autres activités interdites ou illégales). \n Nous collectons aussi des informations techniques sur votre utilisation de nos services par l\'intermédiaire d\'un appareil mobile, des données de localisation et de performances telles que les modes de paiement mobile, les codes QR ou l\'utilisation des tickets restaurants mobiles.',
            ),
            const SizedBox(height: 20.0),
            const Text(
              '3. Traitement et utilisation de vos données',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 10.0),
            const Text(
              'Ces données sont indispensables pour fournir les services que vous demandez ou pour l\'exécution d\'un contrat dans lequel vous représentez une partie et après avoir eu votre consentement.\n Nous utilisons vos informations pour vous fournir l\'accès aux parties pertinentes de l\'application, vous fournir les services que vous avez demandés, pour recueillir vos paiements et vous contacter, en cas de besoin, à propos de nos services.\n Nous traitons aussi vos données afin de :',
            ),
            const SizedBox(height: 10.0),
          const Text(
                    '• Améliorer la qualité et l\'efficacité de nos services en analysant votre activité sur notre application.',
                  ),
                  const Text(
                    '• Faire respecter le contrat pour pouvoir nous défendre et protéger les droits de la franchise TEST DEV, des restaurants partenaires et des coursiers.',
                  ),
                const Text('Lorsque nous sommes tenus par une obligation légale de le faire, nous pouvons utiliser vos informations pour :'),
                 const Text('• Créer un historique de vos commandes'),
                 const Text('• Respecter toute obligation légale ou exigence réglementaire auxquelles nous pouvons etre soumis.'),
                 
            const SizedBox(height: 20.0),
            const Text(
              '4. Durée de conservation de vos données',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 10.0),
            const Text(
              'Les données vous concernant nécessaires à la gestion de nos relations clients sont conservées pour la période pendant laquelle vous utilisez nos services, et supprimées au plus tard trois ans à compter de notre dernier contact, sauf anonymisation ou obligation légale de conserver certaines données pour une durée plus longue ou dans le cas où vous y auriez expressément consenti.',
            ),
            const SizedBox(height: 20.0),
                        const SizedBox(height: 20.0),
            const Text(
              '5. Vos droits sur vos données',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 10.0),
            const Text(
              'En vertu de la loi sur la protection des données, vous pouvez avoir un certain nombre de droits concernant les données que nous détenons à votre sujet. Vous avez la possibilité de :',
            ),
            const SizedBox(height: 5.0),
            const Text(
              '• Demander l\'accès à vos données : Vous avez le droit d\'obtenir l\'accès à vos informations.',
            ),
            const SizedBox(height: 5.0),
            const Text(
              '• Demander la rectification de vos données : Vous êtes en droit d\'obtenir la correction de vos informations si elles sont inexactes ou incomplètes.',
            ),
            const SizedBox(height: 5.0),
            const Text(
              '• Demander l\'effacement de vos données : Il est également connu sous le nom de « droit à l\'oubli » et, en termes simples, ce droit vous permet de demander la suppression ou le retrait des informations que nous détenons.',
            ),
            const SizedBox(height: 5.0),
            const Text(
              '• Demander à limiter le traitement de vos données : Vous avez des droits de « blocage » ou de « suppression » de toute utilisation ultérieure de vos informations.',
            ),
            const SizedBox(height: 5.0),
            const Text(
              '• Vous opposer au traitement de vos données : Vous avez le droit de vous opposer à certains types de traitement.',
            ),
            const SizedBox(height: 5.0),
            const Text(
              '• Demander la portabilité des données : Vous avez le droit d\'obtenir vos informations personnelles dans un format accessible et transférable afin de pouvoir les réutiliser à vos propres fins auprès de différents prestataires de services.',
            ),
            const SizedBox(height: 10.0),
            const Text(
              'Si vous souhaitez exercer ces droits, vous pouvez faire la demande par mail à Dre@sottavera.ir, adresse du Délégué de protection des données de la société.\n Si la franchise TEST DEV a des doutes raisonnables sur votre identité, elle se réserve la possibilité de vous demander des preuves d\'identité. Une fois votre identité suffisamment établie, nous vous adresserons une réponse sous un mois à compter de la réception de votre demande.\n Selon la complexité ou le nombre de demandes, ce délai est susceptible d\'être prolongé de deux mois, ce dont vous serez naturellement avisé. \nSi vous estimez que vos données ne sont pas traitées conformément à la Règlementation applicable, vous pouvez déposer une plainte auprès de la Commission Nationale de l\'Informatique et des Libertés (CNIL). Il s\'agit de l\'autorité de contrôle chargée des questions liées au traitement des données personnelles. La CNIL peut être contactée au 3, Place de Fontenoy = TSA 80715 \n- 75334 PARIS CEDEX 07, par téléphone au 01 53 73 22 22, et sur son site internet : www.cnil.fr.',
            ),
            const SizedBox(height: 20.0),
            const Text(
              '6. Cookies',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 10.0),
            const Text(
              'L\'application TEST DEV n\'utilise pas de cookies.',
            ),
            const SizedBox(height: 20.0),
            const Text(
              '7. Divulgation de vos données',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 10.0),
            const Text(
              'Les informations que nous recueillons à votre sujet seront transférées et stockées sur nos serveurs situés dans l\'UE. Nous sommes très prudents et transparents en ce qui concerne ceux avec qui vos informations sont partagées.',
            ),
            const SizedBox(height: 5.0),
            const Text(
              '• En interne',
            ),
            const Text(
              '- Nous partageons vos informations avec d\'autres sociétés lorsque cela est nécessaire aux fins légales.',
            ),
            const Text(
              '• Avec des tiers :',
            ),
            const Text(
              'Nous partageons vos informations avec des prestataires de services tiers tels que :',
            ),
            const Text(
              '- Les prestataires de services de paiement (prestataires de services de paiement en ligne et prestataires de services de détection de fraude) : pour nous fournir leurs services.',
            ),
            const Text(
              '- Les prestataires de services informatiques (prestataires de services cloud) : à des fins de stockage et d\'analyse des données.',
            ),
            const Text(
              '- Les coursiers : afin qu\'ils puissent vous livrer votre commande.',
            ),
            const Text(
              '- Les partenaires d\'assistance à la clientèle : ils nous aideront à régler tout problème que vous pourriez avoir concernant nos services.',
            ),
            const Text(
              '- Les partenaires marketing et publicitaires : ils feront en sorte que vous visualisiez des annonces plus adaptées à vos besoins et vous enverront des courriels marketing en notre nom.',
            ),
            const SizedBox(height: 20.0),
            const Text(
              '8. Modification de politique de confidentialité',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 10.0),
            const Text(
              'La franchise TEST DEV se réserve le droit de modifier à tout moment ses politiques de confidentialité sans justification. \n Dernière mise à jour de cette politique de confidentialité : 17/10/2019.',
            ),
         

         ], 
        ), 
      ),
    );
  }
}