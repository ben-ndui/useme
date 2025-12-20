import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/tip_item.dart';

/// Tips and guides data for each user role
class TipsData {
  TipsData._();

  // ============ ARTISTE ============
  static List<TipSection> get artistTips => [
    TipSection(
      title: 'Premiers pas',
      icon: FontAwesomeIcons.rocket,
      color: Colors.blue,
      tips: [
        TipItem(
          title: 'Explorez la carte',
          description: 'La carte vous montre tous les studios autour de vous. Les pins verts sont des studios partenaires avec des avantages exclusifs. Zoomez et deplacez-vous pour decouvrir plus de studios.',
          icon: FontAwesomeIcons.mapLocationDot,
        ),
        TipItem(
          title: 'Completez votre profil',
          description: 'Un profil complet avec photo et genres musicaux aide les studios a mieux vous connaitre. Allez dans Reglages > Mon profil pour ajouter ces infos.',
          icon: FontAwesomeIcons.userPen,
        ),
      ],
    ),
    TipSection(
      title: 'Reservations',
      icon: FontAwesomeIcons.calendarCheck,
      color: Colors.green,
      tips: [
        TipItem(
          title: 'Choisir le bon creneau',
          description: 'Les creneaux verts indiquent une forte disponibilite d\'ingenieurs. Les creneaux orange sont plus limites. Preferez les creneaux verts pour plus de flexibilite.',
          icon: FontAwesomeIcons.clock,
        ),
        TipItem(
          title: 'Selectionnez votre ingenieur',
          description: 'Vous pouvez choisir un ingenieur specifique ou laisser le studio assigner. Si vous avez deja travaille avec quelqu\'un, retrouvez-le dans la liste !',
          icon: FontAwesomeIcons.userGear,
        ),
        TipItem(
          title: 'Preparez votre session',
          description: 'Utilisez le champ "Notes" pour decrire votre projet : style, references, ce que vous voulez accomplir. Ca aide l\'ingenieur a se preparer.',
          icon: FontAwesomeIcons.clipboard,
        ),
      ],
    ),
    TipSection(
      title: 'Astuces pro',
      icon: FontAwesomeIcons.wandMagicSparkles,
      color: Colors.purple,
      tips: [
        TipItem(
          title: 'Reservez a l\'avance',
          description: 'Les meilleurs creneaux partent vite ! Reservez 2-3 jours a l\'avance pour avoir le choix des horaires et des ingenieurs.',
          icon: FontAwesomeIcons.calendarPlus,
          iconColor: Colors.orange,
        ),
        TipItem(
          title: 'Gerez vos favoris',
          description: 'Ajoutez vos studios preferes en favoris pour les retrouver rapidement. Appuyez sur le coeur sur la page du studio.',
          icon: FontAwesomeIcons.heart,
          iconColor: Colors.red,
        ),
        TipItem(
          title: 'Suivez vos sessions',
          description: 'Dans l\'onglet Sessions, retrouvez tout votre historique. C\'est pratique pour re-reserver avec le meme ingenieur ou studio.',
          icon: FontAwesomeIcons.clockRotateLeft,
        ),
      ],
    ),
  ];

  // ============ INGENIEUR ============
  static List<TipSection> get engineerTips => [
    TipSection(
      title: 'Configuration',
      icon: FontAwesomeIcons.gear,
      color: Colors.blue,
      tips: [
        TipItem(
          title: 'Definissez vos horaires',
          description: 'Allez dans Reglages > Disponibilites pour configurer vos jours et heures de travail. Les artistes ne pourront reserver que sur vos creneaux actifs.',
          icon: FontAwesomeIcons.calendarDays,
        ),
        TipItem(
          title: 'Ajoutez vos indisponibilites',
          description: 'Vacances, RDV, ou jour off ? Ajoutez une indisponibilite pour bloquer ces periodes. Vous pouvez ajouter une raison optionnelle.',
          icon: FontAwesomeIcons.calendarXmark,
        ),
      ],
    ),
    TipSection(
      title: 'Sessions',
      icon: FontAwesomeIcons.microphone,
      color: Colors.green,
      tips: [
        TipItem(
          title: 'Voir vos sessions',
          description: 'L\'onglet Sessions affiche toutes vos sessions a venir. Les sessions "Confirmees" sont validees, "En attente" doivent etre confirmees par le studio.',
          icon: FontAwesomeIcons.listCheck,
        ),
        TipItem(
          title: 'Demarrer une session',
          description: 'Le jour J, appuyez sur "Demarrer" pour lancer le chrono. A la fin, appuyez sur "Terminer" et ajoutez vos notes de session.',
          icon: FontAwesomeIcons.play,
        ),
        TipItem(
          title: 'Notes de session',
          description: 'Apres chaque session, ajoutez des notes : reglages utilises, fichiers exportes, remarques. C\'est utile pour vous et pour l\'artiste.',
          icon: FontAwesomeIcons.penToSquare,
        ),
      ],
    ),
    TipSection(
      title: 'Astuces',
      icon: FontAwesomeIcons.lightbulb,
      color: Colors.orange,
      tips: [
        TipItem(
          title: 'Restez a jour',
          description: 'Mettez a jour vos disponibilites regulierement. Un planning a jour = plus de reservations pour vous !',
          icon: FontAwesomeIcons.rotate,
        ),
        TipItem(
          title: 'Votre profil compte',
          description: 'Les artistes peuvent vous choisir specifiquement. Une photo pro et une bio avec vos specialites attirent plus de clients.',
          icon: FontAwesomeIcons.idCard,
        ),
      ],
    ),
  ];

  // ============ STUDIO ============
  static List<TipSection> get studioTips => [
    TipSection(
      title: 'Configuration du studio',
      icon: FontAwesomeIcons.buildingUser,
      color: Colors.blue,
      tips: [
        TipItem(
          title: 'Completez votre profil studio',
          description: 'Ajoutez photos, description, equipements et services. Un profil complet apparait plus haut dans les resultats et attire plus d\'artistes.',
          icon: FontAwesomeIcons.images,
        ),
        TipItem(
          title: 'Definissez vos horaires',
          description: 'Configurez les horaires d\'ouverture du studio dans Reglages. Les artistes ne pourront reserver que pendant ces heures.',
          icon: FontAwesomeIcons.clock,
        ),
        TipItem(
          title: 'Ajoutez vos services',
          description: 'Enregistrement, mix, mastering... Definissez vos services avec leurs tarifs. Ca aide les artistes a choisir.',
          icon: FontAwesomeIcons.tags,
        ),
      ],
    ),
    TipSection(
      title: 'Gestion d\'equipe',
      icon: FontAwesomeIcons.users,
      color: Colors.green,
      tips: [
        TipItem(
          title: 'Invitez vos ingenieurs',
          description: 'Allez dans Equipe > Inviter pour ajouter vos ingenieurs. Ils recevront un lien pour rejoindre votre studio.',
          icon: FontAwesomeIcons.userPlus,
        ),
        TipItem(
          title: 'Gerez les disponibilites',
          description: 'Chaque ingenieur gere ses propres disponibilites. Vous pouvez voir la vue d\'ensemble dans le planning du studio.',
          icon: FontAwesomeIcons.calendarCheck,
        ),
        TipItem(
          title: 'Assignez les sessions',
          description: 'Quand un artiste ne choisit pas d\'ingenieur, c\'est a vous de l\'assigner. Verifiez les disponibilites avant d\'assigner.',
          icon: FontAwesomeIcons.userGear,
        ),
      ],
    ),
    TipSection(
      title: 'Reservations',
      icon: FontAwesomeIcons.calendarDays,
      color: Colors.purple,
      tips: [
        TipItem(
          title: 'Gerer les demandes',
          description: 'Les nouvelles demandes apparaissent dans "En attente". Validez rapidement pour fideliser les artistes !',
          icon: FontAwesomeIcons.bell,
          iconColor: Colors.orange,
        ),
        TipItem(
          title: 'Invitez vos artistes',
          description: 'Vous avez des artistes reguliers ? Invitez-les via Clients > Inviter. Ils pourront reserver plus facilement.',
          icon: FontAwesomeIcons.envelopeOpenText,
        ),
        TipItem(
          title: 'Suivez l\'activite',
          description: 'Le dashboard vous montre les stats : sessions du mois, revenus, artistes actifs. Gardez un oeil sur votre activite.',
          icon: FontAwesomeIcons.chartLine,
        ),
      ],
    ),
    TipSection(
      title: 'Visibilite',
      icon: FontAwesomeIcons.eye,
      color: Colors.orange,
      tips: [
        TipItem(
          title: 'Devenez partenaire',
          description: 'Les studios partenaires apparaissent en vert sur la carte et en priorite. Contactez-nous pour en savoir plus !',
          icon: FontAwesomeIcons.handshake,
          iconColor: Colors.green,
        ),
        TipItem(
          title: 'Encouragez les avis',
          description: 'Apres une session reussie, invitez l\'artiste a laisser un avis. Les bons avis attirent plus de clients.',
          icon: FontAwesomeIcons.star,
          iconColor: Colors.amber,
        ),
      ],
    ),
  ];
}
