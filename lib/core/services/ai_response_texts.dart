/// Role-based AI response texts for local fallback.
///
/// Each method returns a response string based on user role
/// (studio, engineer, or artist/default).
class AIResponseTexts {
  final bool isStudio;
  final bool isEngineer;

  const AIResponseTexts({
    required this.isStudio,
    required this.isEngineer,
  });

  String getWelcomeMessage() {
    if (isStudio) {
      return '''Salut ! 👋 Je suis ton assistant UZME.

Je peux t'aider à :
• 📊 Gérer tes réservations et demandes
• 💬 Rédiger des réponses aux artistes
• 📅 Optimiser tes disponibilités
• 💡 Améliorer ta visibilité
• ❓ Répondre à toutes tes questions

Comment puis-je t'aider aujourd'hui ?''';
    } else if (isEngineer) {
      return '''Salut ! 👋 Je suis ton assistant UZME.

Je peux t'aider à :
• 📅 Gérer tes disponibilités
• 🎚️ Préparer tes sessions
• 💬 Communiquer avec les artistes
• 📊 Suivre ton activité
• ❓ Répondre à toutes tes questions

Qu'est-ce que je peux faire pour toi ?''';
    }

    return '''Salut ! 👋 Je suis ton assistant UZME.

Je peux t'aider à :
• 🎵 Trouver le studio parfait pour ton projet
• 💰 Comparer les prix et services
• 📅 Vérifier les disponibilités
• 🎤 Recommander des ingénieurs son
• ❓ Répondre à toutes tes questions

Qu'est-ce que tu cherches aujourd'hui ?''';
  }

  List<String> getInitialSuggestions() {
    if (isStudio) {
      return [
        'Comment répondre à une demande ?',
        'Améliorer ma visibilité',
        'Configurer mes services',
      ];
    } else if (isEngineer) {
      return [
        'Gérer mes disponibilités',
        'Préparer une session',
        'Contacter un artiste',
      ];
    }

    return [
      'Trouve-moi un studio de rap',
      'Quels sont les studios près de moi ?',
      'Combien coûte une session de mix ?',
    ];
  }

  String getPricingResponse() {
    if (isStudio) {
      return '''Pour définir tes tarifs, voici quelques conseils :

💡 **Analyse la concurrence** : Regarde les prix des studios similaires
📊 **Calcule tes coûts** : Loyer, équipement, charges...
🎯 **Positionne-toi** : Premium, milieu de gamme, ou accessible

Tu peux configurer tes services et tarifs dans Réglages > Services.

Tu veux des conseils pour optimiser tes prix ?''';
    }

    return '''Les tarifs varient selon les studios, mais voici une idée générale :

💰 **Enregistrement** : 25-50€/h
🎚️ **Mix** : 40-80€/h
🎧 **Mastering** : 50-100€/titre

Les studios Pro sur UZME offrent souvent des packs avantageux pour les projets complets (EP, Album).

Tu veux que je te montre les studios dans ton budget ?''';
  }

  String getAvailabilityResponse() {
    if (isStudio) {
      return '''Pour gérer tes disponibilités :

1. 📅 Va dans Réglages > Calendrier
2. ⏰ Définis tes horaires d'ouverture
3. 🔴 Bloque les créneaux indisponibles

Tu peux aussi connecter ton Google Calendar pour synchroniser automatiquement !

Tu veux que je t'explique comment optimiser ton planning ?''';
    } else if (isEngineer) {
      return '''Pour gérer tes disponibilités :

1. 📅 Va dans Réglages > Disponibilités
2. ⏰ Configure tes horaires de travail
3. 🏖️ Ajoute tes indisponibilités (vacances, etc.)

Le studio pourra ainsi t'assigner des sessions sur tes créneaux actifs !''';
    }

    return '''Pour voir les disponibilités, tu peux :

1. 📍 Explorer les studios sur la carte
2. 🔍 Filtrer par date et créneau
3. 📅 Consulter le calendrier de chaque studio

La plupart des studios ont des créneaux disponibles en semaine. Les week-ends sont souvent plus demandés !

Tu cherches pour quelle date ?''';
  }

  String getBookingResponse() {
    if (isStudio) {
      return '''Pour gérer les demandes de réservation :

1. 📬 Les nouvelles demandes arrivent en "En attente"
2. ✅ Accepte et assigne un ingénieur
3. 💬 Un message est envoyé automatiquement à l'artiste

Conseil : Réponds rapidement pour fidéliser les artistes !

Tu as des demandes en attente ?''';
    }

    return '''Pour réserver une session, c'est simple :

1. Choisis un studio qui te plaît
2. Sélectionne un service et un créneau
3. Envoie ta demande de réservation
4. Le studio confirme et tu reçois les détails !

Tu veux que je t'aide à trouver un studio adapté à ton projet ?''';
  }

  String getEquipmentResponse() {
    if (isStudio) {
      return '''Pour mettre en avant ton équipement :

1. 📝 Liste tout dans ton profil studio
2. 📸 Ajoute des photos de qualité
3. 🏷️ Mentionne les marques (Neumann, SSL, etc.)

Un profil bien rempli attire plus d'artistes !

Tu veux que je t'aide à optimiser ton profil ?''';
    }

    return '''Chaque studio a son propre équipement. Sur UZME, tu peux voir :

🎤 **Micros** : Neumann, Shure, AKG...
🎚️ **Consoles** : SSL, Neve, API...
🖥️ **DAW** : Pro Tools, Logic, Ableton...
🔊 **Monitoring** : Genelec, Adam, Focal...

Dis-moi quel type de son tu recherches et je peux te recommander des studios avec l'équipement adapté !''';
  }

  String getGreetingResponse() {
    if (isStudio) {
      final greetings = [
        'Hey ! 👋 Comment va ton studio aujourd\'hui ?',
        'Salut ! 📊 Besoin d\'aide pour gérer ton activité ?',
        'Hello ! 🎵 Comment puis-je t\'aider ?',
      ];
      return greetings[DateTime.now().second % greetings.length];
    } else if (isEngineer) {
      final greetings = [
        'Hey ! 👋 Prêt pour tes sessions ?',
        'Salut ! 🎚️ Comment ça va côté studio ?',
        'Hello ! 🎧 Besoin d\'aide ?',
      ];
      return greetings[DateTime.now().second % greetings.length];
    }

    final greetings = [
      'Hey ! 👋 Comment je peux t\'aider aujourd\'hui ?',
      'Salut ! 🎵 Qu\'est-ce que tu cherches ?',
      'Hello ! 🎤 Prêt à booker une session ?',
    ];
    return greetings[DateTime.now().second % greetings.length];
  }

  String getDefaultResponse(String message) {
    if (isStudio) {
      return '''Je comprends que tu cherches des infos sur "$message".

Pour mieux t'aider, tu peux me demander :
• Comment gérer les réservations
• Des conseils pour améliorer ta visibilité
• Comment configurer tes services
• Des astuces pour ton studio

Qu'est-ce qui t'intéresse ?''';
    } else if (isEngineer) {
      return '''Je comprends que tu cherches des infos sur "$message".

Pour mieux t'aider, tu peux me demander :
• Comment gérer tes disponibilités
• Des conseils pour tes sessions
• Comment communiquer avec les artistes

Qu'est-ce que je peux faire pour toi ?''';
    }

    return '''Je comprends que tu cherches des infos sur "$message".

Pour mieux t'aider, tu peux me demander :
• Des recommandations de studios
• Des infos sur les prix
• Des disponibilités
• Des conseils pour ton projet

Qu'est-ce qui t'intéresse le plus ?''';
  }
}
