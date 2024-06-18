// ignore_for_file: file_names
import 'package:flutter/material.dart';

class TermsOfUsePage extends StatelessWidget {
  const TermsOfUsePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(222, 212, 133, 14),
        title: const Text('CGU'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '1. Objet',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            SizedBox(height: 10.0),
            Text(
              'Les présentes « conditions générales d\'utilisation » ont pour objet l\'encadrement juridique de l\'utilisation de l\'application TEST DEV et de ses services.\n Ce contrat est conclu entre :',
            ),
            SizedBox(height: 5.0),
            Text(
              '• Le gérant de l\'application, ci-après désigné « l\'Éditeur ». \n • Toute personne physique ou morale souhaitant accéder à l\'application et à ses services, ci-après appelé « l\'Utilisateur ».\n  Les conditions générales d\'utilisation doivent être acceptées par tout Utilisateur, et son accès à l\'application vaut acceptation de ces conditions.',
            ),
            SizedBox(height: 20.0),
            Text(
              '2. Accès aux services',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            SizedBox(height: 10.0),
            Text(
              'L\'Utilisateur de l\'application a accès aux services suivants :',
            ),
            SizedBox(height: 5.0),
            Text(
              '• Service de commande en ligne \n • Service de livraison\n • Suivie en temps réel de la commande \n • Paiement en ligne \n Tout Utilisateur ayant accès à internet peut accéder gratuitement et depuis n\'importe où à l\'application. Les frais supportés par l\'Utilisateur pour y accéder (connexion internet, matériel informatique, etc.) ne sont pas à la charge de l\'Éditeur. \n Les services suivants ne sont pas accessibles pour l\'Utilisateur que s\'il est membre de l\'application (c\'est-à-dire qu\'il est identifié à l\'aide de ses identifiants de connexion) :',
            ),
            SizedBox(height: 5.0),
            Text(
              '• Service de modification des données personnelles \n • Enregistrement des cartes bancaires\n • Enregistrement des adresses\n • Paiement par carte fidélité\n  L\'application et ses différents services peuvent être interrompus ou suspendus par l\'Éditeur, notamment à l\'occasion d\'une maintenance, sans obligation de préavis ou de justification.',
            ),
            SizedBox(height: 20.0),
            Text(
              '3. Responsabilité de l\'Utilisateur',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            SizedBox(height: 10.0),
            Text(
              'L\'Utilisateur est responsable des risques liés à l\'utilisation de son identifiant de connexion et de son mot de passe.\n Le mot de passe de l\'Utilisateur doit rester secret. En cas de divulgation de mot de passe, l\'Editeur décline toute responsabilité.\n L\'Utilisateur assume l\'entière responsabilité de l\'utilisation qu\'il fait des informations et contenus présents sur notre application. \n Tout usage du service par l\'Utilisateur ayant directement ou indirectement pour conséquence des dommages doit faire l\'objet d\'une indemnisation au profit de l\'application. \n Le membre s\'engage à tenir des propos respectueux des autres et de la loi et accepte que ces publications soient modérées ou refusées par l\'Éditeur, sans obligation de justification.\n En publiant sur l\'application, l\'Utilisateur cède à la société éditrice le droit non exclusif et gratuit de représenter, reproduire, adapter, modifier, diffuser et distribuer sa publication, directement ou par un tiers autorisé.\n L\'Éditeur s\'engage toutefois à citer le membre en cas d\'utilisation de sa publication.',
            ),
            SizedBox(height: 20.0),
            Text(
              '4. Responsabilité de l\'Éditeur',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            SizedBox(height: 10.0),
            Text(
              'Tout disfonctionnement du serveur ou du réseau ne peut engager la responsabilité de l\'Éditeur.\n De même, la responsabilité de l\'application ne peut être engagée en cas de force majeure ou du fait imprévisible et insurmontable d\'un tiers.\n L\'application TEST DEV s\'engage à mettre en œuvre tous les moyens nécessaires pour garantir la sécurité et la confidentialité des données.',
            ),
            SizedBox(height: 20.0),
            Text(
              '5. Propriété intellectuelle',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            SizedBox(height: 10.0),
            Text(
              'Les contenus de l\'application TEST DEV (logos, textes, éléments graphiques, vidéos, etc.) sont protégés par le droit d\'auteur, en vertu du Code de la propriété intellectuelle.\n L\'Utilisateur devra obtenir l\'autorisation de l\'éditeur de l\'application avant toute reproduction, copie ou publication de ces différents contenus. \nCes derniers peuvent être utilisés par les utilisateurs à des fins privées ; tout usage commercial est interdit.\n L\'Utilisateur est entièrement responsable de tout contenu qu\'il met en ligne et il s\'engage à ne pas porter atteinte à un tiers.\n L\'Éditeur de l\'application se réserve le droit de modérer ou de supprimer librement et à tout moment les contenus mis en ligne par les utilisateurs, et ce sans justification.',
            ),
            SizedBox(height: 20.0),
            Text(
              '6. Évolution des conditions générales d\'utilisation',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            SizedBox(height: 10.0),
            Text(
              'L\'application TEST DEV se réserve le droit de modifier les clauses de ces conditions générales d\'utilisation à tout moment et sans justification.',
            ),
            SizedBox(height: 20.0),
            Text(
              '7. Durée du contrat',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            SizedBox(height: 10.0),
            Text(
              'La durée du présent contrat est indéterminée. Le contrat produit ses effets à l\'égard de l\'Utilisateur à compter du début de l\'utilisation du service.',
            ),
            SizedBox(height: 20.0),
            Text(
              '8. Droit applicable et juridiction compétente',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            SizedBox(height: 10.0),
            Text(
              'Le présent contrat dépend de la législation française.\n En cas de litige non résolu à l\'amiable entre l\'Utilisateur et l\'Éditeur, les tribunaux dont dépend le siège de la franchise TEST DEV sont compétents pour régler le contentieux.',
            ),
          ],
        ),
      ),
    );
  }
}
