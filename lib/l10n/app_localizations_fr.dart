// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Use Me';

  @override
  String get settings => 'Réglages';

  @override
  String get profile => 'Profil';

  @override
  String get myProfile => 'Mon profil';

  @override
  String get personalInfo => 'Informations personnelles';

  @override
  String get application => 'Application';

  @override
  String get account => 'Compte';

  @override
  String get emailPassword => 'Email, mot de passe';

  @override
  String get about => 'À propos';

  @override
  String get versionLegal => 'Version, mentions légales';

  @override
  String get logout => 'Déconnexion';

  @override
  String get logoutConfirmTitle => 'Déconnexion';

  @override
  String get logoutConfirmMessage => 'Voulez-vous vraiment vous déconnecter ?';

  @override
  String get cancel => 'Annuler';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsEnabled => 'Activées';

  @override
  String get notificationsDisabled => 'Désactivées';

  @override
  String get notificationsMuted => 'Notifications silencieuses';

  @override
  String get enableNotificationsInSettings =>
      'Veuillez autoriser les notifications dans les réglages';

  @override
  String get rememberEmail => 'Mémoriser l\'email';

  @override
  String get rememberEmailEnabled => 'Email pré-rempli à la connexion';

  @override
  String get rememberEmailDisabled => 'Email non mémorisé';

  @override
  String get appearance => 'Apparence';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeLightSubtitle => 'Thème lumineux';

  @override
  String get themeDarkSubtitle => 'Thème sombre';

  @override
  String get themeSystemSubtitle => 'Suit les réglages de l\'appareil';

  @override
  String get language => 'Langue';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSystem => 'Système';

  @override
  String get languageSystemSubtitle => 'Suit les réglages de l\'appareil';

  @override
  String get userGuide => 'Guide d\'utilisation';

  @override
  String get tipsAndAdvice => 'Astuces et conseils';

  @override
  String get artistGuide => 'Guide artiste';

  @override
  String get engineerGuide => 'Guide ingénieur';

  @override
  String get studioGuide => 'Guide studio';

  @override
  String get messages => 'Messages';

  @override
  String get noConversations => 'Aucune conversation';

  @override
  String get startNewConversation => 'Commencez une nouvelle conversation';

  @override
  String get newMessage => 'Nouveau message';

  @override
  String get loading => 'Chargement...';

  @override
  String get error => 'Erreur';

  @override
  String get retry => 'Réessayer';

  @override
  String get conversationSettings => 'Paramètres';

  @override
  String get viewProfile => 'Voir le profil';

  @override
  String get viewParticipants => 'Voir les participants';

  @override
  String get information => 'Informations';

  @override
  String get block => 'Bloquer';

  @override
  String get blockContact => 'Bloquer ce contact';

  @override
  String get blockConfirmTitle => 'Bloquer';

  @override
  String blockConfirmMessage(String name) {
    return 'Voulez-vous bloquer $name ? Vous ne recevrez plus de messages de ce contact.';
  }

  @override
  String blocked(String name) {
    return '$name a été bloqué';
  }

  @override
  String get report => 'Signaler';

  @override
  String get reportProblem => 'Signaler un problème';

  @override
  String get reportConfirmTitle => 'Signaler';

  @override
  String get reportConfirmMessage =>
      'Pourquoi souhaitez-vous signaler cette conversation ?';

  @override
  String get reportSent => 'Signalement envoyé';

  @override
  String get leaveConversation => 'Quitter la conversation';

  @override
  String get deleteFromList => 'Supprimer de votre liste';

  @override
  String get leaveConfirmTitle => 'Quitter la conversation';

  @override
  String leaveConfirmMessage(String name) {
    return 'Voulez-vous quitter la conversation avec $name ? L\'historique sera supprimé.';
  }

  @override
  String get leave => 'Quitter';

  @override
  String get actions => 'Actions';

  @override
  String get accountSettings => 'Compte';

  @override
  String get credentials => 'Identifiants';

  @override
  String get email => 'Email';

  @override
  String get notAvailable => 'Non disponible';

  @override
  String get changePassword => 'Changer le mot de passe';

  @override
  String oauthNoPasswordReset(String provider) {
    return 'Vous êtes connecté via $provider. Gérez votre mot de passe depuis les paramètres $provider.';
  }

  @override
  String get sendResetEmail => 'Recevoir un email de réinitialisation';

  @override
  String emailSentTo(String email) {
    return 'Email envoyé à $email';
  }

  @override
  String get sendError => 'Erreur lors de l\'envoi';

  @override
  String get dangerZone => 'Zone de danger';

  @override
  String get deleteAccount => 'Supprimer mon compte';

  @override
  String get deleteAccountWarning => 'Cette action est irréversible';

  @override
  String get deleteAccountConfirmTitle => 'Supprimer le compte';

  @override
  String get deleteAccountConfirmMessage =>
      'Êtes-vous sûr de vouloir supprimer votre compte ? Toutes vos données seront perdues. Cette action est irréversible.';

  @override
  String get delete => 'Supprimer';

  @override
  String get confirmDeletion => 'Confirmer la suppression';

  @override
  String get enterPassword => 'Entrez votre mot de passe pour confirmer :';

  @override
  String get password => 'Mot de passe';

  @override
  String get confirm => 'Confirmer';

  @override
  String get deletionError => 'Erreur lors de la suppression';

  @override
  String get studio => 'Studio';

  @override
  String get studioProfile => 'Profil studio';

  @override
  String get nameAddressContact => 'Nom, adresse, contact';

  @override
  String get services => 'Services';

  @override
  String get serviceCatalog => 'Catalogue des prestations';

  @override
  String get team => 'Équipe';

  @override
  String get manageEngineers => 'Gérer les ingénieurs';

  @override
  String get paymentMethods => 'Moyens de paiement';

  @override
  String get paymentMethodsSubtitle => 'Espèces, virement, PayPal...';

  @override
  String get aiAssistant => 'Assistant IA';

  @override
  String get aiSettingsSubtitle => 'Configurer les réponses automatiques';

  @override
  String get visibility => 'Visibilité';

  @override
  String get studioVisible => 'Studio visible';

  @override
  String get artistsCanSee =>
      'Les artistes peuvent voir votre studio et vous envoyer des demandes de session.';

  @override
  String get edit => 'Modifier';

  @override
  String get becomeVisible => 'Rendez-vous visible';

  @override
  String get artistsCantFind =>
      'Les artistes ne peuvent pas encore vous trouver';

  @override
  String get claimStudio =>
      'Revendiquez votre studio pour apparaître sur la carte et recevoir des demandes de session.';

  @override
  String get calendar => 'Calendrier';

  @override
  String get availability => 'Disponibilités';

  @override
  String get manageSlots => 'Gérer mes créneaux';

  @override
  String participants(int count) {
    return '$count participants';
  }

  @override
  String get copy => 'Copier';

  @override
  String get deleteMessage => 'Supprimer';

  @override
  String version(String version) {
    return 'Use Me v$version';
  }

  @override
  String get studiosPlatform => 'La plateforme des studios';

  @override
  String versionBuild(String version, String build) {
    return 'Version $version ($build)';
  }

  @override
  String get legalInfo => 'Informations légales';

  @override
  String get termsOfService => 'Conditions d\'utilisation';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get legalNotices => 'Mentions légales';

  @override
  String get support => 'Support';

  @override
  String get helpCenter => 'Centre d\'aide';

  @override
  String get contactUs => 'Nous contacter';

  @override
  String get followUs => 'Suivez-nous';

  @override
  String copyright(String year) {
    return '© $year Use Me. Tous droits réservés.';
  }

  @override
  String get archive => 'Archiver';

  @override
  String get unarchive => 'Désarchiver';

  @override
  String get mySessions => 'Mes sessions';

  @override
  String get book => 'Réserver';

  @override
  String get noSession => 'Pas de session';

  @override
  String get enjoyYourDay => 'Profitez de votre journée !';

  @override
  String get inProgressStatus => 'En cours';

  @override
  String get upcomingStatus => 'À venir';

  @override
  String get pastStatus => 'Passées';

  @override
  String get noSessions => 'Aucune session';

  @override
  String get bookFirstSession => 'Réservez votre première session';

  @override
  String get pendingStatus => 'En attente';

  @override
  String get confirmedStatus => 'Confirmée';

  @override
  String get completedStatus => 'Terminée';

  @override
  String get cancelledStatus => 'Annulée';

  @override
  String get noShowStatus => 'Absent';

  @override
  String hoursOfSession(int hours) {
    return '${hours}h de session';
  }

  @override
  String sessionAt(String studio) {
    return 'Session chez $studio';
  }

  @override
  String get sessionRequest => 'Demande de session';

  @override
  String get noStudioSelected => 'Aucun studio sélectionné';

  @override
  String get selectStudioFirst =>
      'Sélectionnez d\'abord un studio pour voir ses disponibilités.';

  @override
  String get back => 'Retour';

  @override
  String get sessionType => 'Type de session';

  @override
  String get sessionDuration => 'Durée de la session';

  @override
  String get chooseSlot => 'Choisissez votre créneau';

  @override
  String get engineerPreference => 'Préférence d\'ingénieur';

  @override
  String get notesOptional => 'Notes (optionnel)';

  @override
  String get describeProject => 'Décrivez votre projet, vos besoins...';

  @override
  String get sendRequest => 'Envoyer la demande';

  @override
  String get summaryLabel => 'Récapitulatif';

  @override
  String get noPreference => 'Pas de préférence';

  @override
  String get engineerSelectedLabel => 'Ingénieur sélectionné';

  @override
  String get letStudioChoose => 'Laisser le studio choisir';

  @override
  String availableCount(int count) {
    return '$count dispo';
  }

  @override
  String get requestSent =>
      'Demande envoyée ! Le studio vous répondra bientôt.';

  @override
  String get slotInfoText =>
      'Les créneaux verts ont plus d\'ingénieurs disponibles. Vous pouvez aussi choisir votre ingénieur préféré.';

  @override
  String get engineer => 'Ingénieur';

  @override
  String get notSpecified => 'Non spécifié';

  @override
  String get goodMorning => 'Bonjour';

  @override
  String get goodAfternoon => 'Bon après-midi';

  @override
  String get goodEvening => 'Bonsoir';

  @override
  String get quickAccess => 'Accès rapide';

  @override
  String get sessionsLabel => 'Sessions';

  @override
  String get favoritesLabel => 'Favoris';

  @override
  String get preferencesLabel => 'Préférences';

  @override
  String get upcomingSessions => 'Sessions à venir';

  @override
  String get viewAll => 'Voir tout';

  @override
  String get noUpcomingSessions => 'Aucune session prévue';

  @override
  String get bookNextSession => 'Réserve ta prochaine session en studio';

  @override
  String get recentActivity => 'Activité récente';

  @override
  String get noHistory => 'Pas encore d\'historique';

  @override
  String get completedSessionsHere => 'Tes sessions terminées apparaîtront ici';

  @override
  String get waitingStatus => 'Attente';

  @override
  String get todaySessions => 'Sessions du jour';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get noSessionToday => 'Pas de session aujourd\'hui';

  @override
  String get noSessionsPlanned => 'Aucune session prévue';

  @override
  String get noAssignedSessions => 'Vous n\'avez pas de sessions assignées';

  @override
  String get notConnected => 'Non connecté';

  @override
  String get myAvailabilities => 'Mes disponibilités';

  @override
  String get workingHours => 'Horaires de travail';

  @override
  String get unavailabilities => 'Indispos';

  @override
  String get add => 'Ajouter';

  @override
  String get noTimeOff => 'Aucune indisponibilité';

  @override
  String get addTimeOffHint => 'Ajoutez vos vacances, congés ou absences';

  @override
  String get myStudio => 'Mon Studio';

  @override
  String get overview => 'Vue d\'ensemble';

  @override
  String get session => 'Session';

  @override
  String get artist => 'Artiste';

  @override
  String get artists => 'Artistes';

  @override
  String get artistsLabel => 'Artistes';

  @override
  String get planning => 'Planning';

  @override
  String get stats => 'Stats';

  @override
  String get thisMonth => 'Ce mois';

  @override
  String get freeDay => 'Journée libre';

  @override
  String get noSessionScheduled => 'Aucune session programmée';

  @override
  String get pendingRequests => 'Demandes en attente';

  @override
  String get recentArtists => 'Artistes récents';

  @override
  String get filterByStatus => 'Filtrer par statut';

  @override
  String get all => 'Tous';

  @override
  String get confirmed => 'Confirmées';

  @override
  String sessionCount(int count) {
    return '$count session';
  }

  @override
  String sessionsCount(int count) {
    return '$count sessions';
  }

  @override
  String get noSessionThisDay => 'Pas de session ce jour';

  @override
  String get noSessionTodayScheduled =>
      'Aucune session programmée aujourd\'hui';

  @override
  String get scheduleSession => 'Planifier une session';

  @override
  String get serviceCatalogTitle => 'Catalogue services';

  @override
  String get noService => 'Aucun service';

  @override
  String get createServiceCatalog => 'Créez votre catalogue de services';

  @override
  String get newService => 'Nouveau service';

  @override
  String get active => 'Actif';

  @override
  String get inactive => 'Inactif';

  @override
  String get rooms => 'Salles';

  @override
  String get noRooms => 'Aucune salle';

  @override
  String get createRoomsHint => 'Configurez les salles de votre studio';

  @override
  String get addRoom => 'Ajouter une salle';

  @override
  String get editRoom => 'Modifier la salle';

  @override
  String get roomName => 'Nom de la salle';

  @override
  String get roomNameHint => 'Ex: Studio A, Cabine 1...';

  @override
  String get roomDescriptionHint => 'Décrivez la salle et ses caractéristiques';

  @override
  String get accessType => 'Type d\'accès';

  @override
  String get withEngineer => 'Avec ingénieur';

  @override
  String get withEngineerDesc => 'Ingénieur son requis';

  @override
  String get selfService => 'Libre accès';

  @override
  String get selfServiceDesc => 'Sans ingénieur';

  @override
  String get equipment => 'Équipements';

  @override
  String get equipmentHint =>
      'Micro, console, enceintes... (séparés par virgule)';

  @override
  String get roomActive => 'Salle active';

  @override
  String get roomVisibleForBooking => 'Visible pour les réservations';

  @override
  String get roomHiddenForBooking => 'Masquée des réservations';

  @override
  String get deleteRoom => 'Supprimer la salle';

  @override
  String get deleteRoomConfirm =>
      'Voulez-vous vraiment supprimer cette salle ?';

  @override
  String get selectRoom => 'Choisir une salle';

  @override
  String get noRoomAvailable => 'Aucune salle disponible';

  @override
  String get restDay => 'Fermé';

  @override
  String get inProgress => 'En cours';

  @override
  String get upcoming => 'À venir';

  @override
  String get past => 'Passées';

  @override
  String get listView => 'Vue liste';

  @override
  String get calendarView => 'Vue calendrier';

  @override
  String get deleteTimeOff => 'Supprimer';

  @override
  String get deleteTimeOffConfirm => 'Supprimer cette indisponibilité ?';

  @override
  String daysCount(int count) {
    return '$count jour';
  }

  @override
  String daysCountPlural(int count) {
    return '$count jours';
  }

  @override
  String get addTimeOff => 'Ajouter une indisponibilité';

  @override
  String get fromDate => 'Du';

  @override
  String get toDate => 'Au';

  @override
  String get reasonOptional => 'Raison (optionnel)';

  @override
  String get enterCustomReason => 'Ou saisissez une raison...';

  @override
  String get errorLoadingAvailability =>
      'Erreur lors du chargement des disponibilités';

  @override
  String get available => 'Dispo';

  @override
  String get limited => 'Limité';

  @override
  String get unavailable => 'Indispo';

  @override
  String slotsForDate(String date) {
    return 'Créneaux du $date';
  }

  @override
  String get noSlotAvailable => 'Aucun créneau disponible';

  @override
  String get tryAnotherDate => 'Essayez une autre date';

  @override
  String get fullyAvailable => 'Parfaitement disponibles';

  @override
  String get partiallyAvailable => 'Partiellement disponibles';

  @override
  String get noEngineerAvailable => 'Aucun ingénieur dispo';

  @override
  String get studioUnavailable => 'Studio indisponible';

  @override
  String get noEngineerTryAnotherDate =>
      'Aucun ingénieur disponible ce jour. Essayez une autre date.';

  @override
  String get chooseEngineer => 'Choisir un ingénieur';

  @override
  String availableCountLabel(int count) {
    return '$count disponible(s)';
  }

  @override
  String get optionalEngineerInfo =>
      'Optionnel : laissez le studio assigner un ingénieur automatiquement';

  @override
  String get availableLabel => 'DISPONIBLES';

  @override
  String get unavailableLabel => 'INDISPONIBLES';

  @override
  String get studioWillAssignEngineer => 'Le studio assignera un ingénieur';

  @override
  String get bookNextSessionSubtitle => 'Réservez votre prochaine session';

  @override
  String get emailHint => 'Email';

  @override
  String get emailRequired => 'Email requis';

  @override
  String get emailInvalid => 'Email invalide';

  @override
  String get passwordHint => 'Mot de passe';

  @override
  String get passwordRequired => 'Mot de passe requis';

  @override
  String minCharacters(int count) {
    return 'Minimum $count caractères';
  }

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get signIn => 'Se connecter';

  @override
  String get or => 'ou';

  @override
  String get noAccountYet => 'Pas encore de compte ?';

  @override
  String get signUp => 'S\'inscrire';

  @override
  String get demoAccess => 'Accès démo';

  @override
  String get enterEmailFirst => 'Entrez votre email d\'abord';

  @override
  String get demoMode => 'Mode Démo';

  @override
  String get browseWithoutLogin => 'Naviguer sans connexion';

  @override
  String get studioAdmin => 'Studio (Admin)';

  @override
  String get manageSessionsArtistsServices =>
      'Gérer sessions, artistes, services';

  @override
  String get soundEngineer => 'Ingénieur son';

  @override
  String get viewAndTrackSessions => 'Voir et tracker les sessions';

  @override
  String get bookSessions => 'Réserver des sessions';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get joinCommunity => 'Rejoignez la communauté';

  @override
  String get iAm => 'Je suis...';

  @override
  String get orByEmail => 'ou par email';

  @override
  String get stageNameOrName => 'Nom de scène ou nom';

  @override
  String get fullName => 'Nom complet';

  @override
  String get nameRequired => 'Nom requis';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get confirmationRequired => 'Confirmation requise';

  @override
  String get passwordsDontMatch => 'Mots de passe différents';

  @override
  String get createMyAccount => 'Créer mon compte';

  @override
  String get alreadyHaveAccount => 'Déjà un compte ?';

  @override
  String get chooseYourProfile => 'Choisissez votre profil';

  @override
  String get actionIsPermanent => 'Cette action est définitive';

  @override
  String get howToUseApp => 'Comment souhaitez-vous utiliser l\'app ?';

  @override
  String get iOwnStudio => 'Je possède un studio';

  @override
  String get iWorkInStudio => 'Je travaille dans un studio';

  @override
  String get iWantToBookSessions => 'Je veux réserver des sessions';

  @override
  String get acceptBooking => 'Accepter la réservation';

  @override
  String get choosePaymentMethod => 'Choisissez le mode de paiement';

  @override
  String get noPaymentMethodConfigured =>
      'Aucun moyen de paiement configuré. Allez dans Réglages > Moyens de paiement.';

  @override
  String get paymentMode => 'Mode de paiement';

  @override
  String get depositRequested => 'Acompte demandé';

  @override
  String get customMessageOptional => 'Message personnalisé (optionnel)';

  @override
  String get customMessageHint => 'Ex: Merci pour ta confiance !';

  @override
  String get totalAmount => 'Montant total';

  @override
  String get depositToPay => 'Acompte à régler';

  @override
  String get paymentBy => 'Paiement par';

  @override
  String ofTotalAmount(int percent) {
    return '$percent% du montant total';
  }

  @override
  String get acceptAndSendInfo => 'Accepter et envoyer les infos';

  @override
  String get welcome => 'Bienvenue !';

  @override
  String get discoverAppFeatures =>
      'Découvrez comment tirer le meilleur de Use Me';

  @override
  String get nearbyStudios => 'Studios à proximité';

  @override
  String get discoverWhereToRecord => 'Découvre où enregistrer';

  @override
  String get noStudioFound => 'Aucun studio trouvé';

  @override
  String get enableLocationToDiscover =>
      'Active ta localisation pour découvrir les studios près de toi';

  @override
  String get partner => 'Partner';

  @override
  String get missingStudio => 'Studio manquant ?';

  @override
  String get tellUsWhichStudio => 'Dis-nous quel studio tu cherches';

  @override
  String get studioName => 'Nom du studio';

  @override
  String get studioNameExample => 'Ex: Studio XYZ';

  @override
  String get pleaseEnterStudioName => 'Veuillez entrer le nom du studio';

  @override
  String get city => 'Ville';

  @override
  String get cityExample => 'Ex: Paris, Lyon...';

  @override
  String get pleaseEnterCity => 'Veuillez entrer la ville';

  @override
  String get notesOptionalLabel => 'Notes (optionnel)';

  @override
  String get notesHint => 'Adresse, site web, infos utiles...';

  @override
  String get sending => 'Envoi en cours...';

  @override
  String get sendRequestLabel => 'Envoyer la demande';

  @override
  String get requestSubmitted => 'Demande envoyée !';

  @override
  String get weWillVerifyAndAddStudio =>
      'Nous allons vérifier et ajouter ce studio prochainement.';

  @override
  String get searchingStudios => 'Recherche de studios...';

  @override
  String get partnerLabel => 'Partenaire';

  @override
  String get newConversation => 'Nouvelle conversation';

  @override
  String get searchContact => 'Rechercher un contact...';

  @override
  String get searchNewContact =>
      'Démarrez une nouvelle conversation pour trouver ce contact';

  @override
  String get errorLoadingContacts => 'Erreur lors du chargement des contacts';

  @override
  String get user => 'Utilisateur';

  @override
  String get contact => 'Contact';

  @override
  String get noResult => 'Aucun résultat';

  @override
  String get noContactAvailable => 'Aucun contact disponible';

  @override
  String get myContacts => 'Mes contacts';

  @override
  String get searchResults => 'Résultats de recherche';

  @override
  String get tryOtherTerms => 'Essayez avec d\'autres termes';

  @override
  String get contactsWillAppearHere => 'Vos contacts apparaîtront ici';

  @override
  String get noName => 'Sans nom';

  @override
  String get searchByNameOrEmail => 'Rechercher par nom ou email...';

  @override
  String get searchArtist => 'Rechercher un artiste';

  @override
  String get typeAtLeastTwoChars =>
      'Tapez au moins 2 caractères pour rechercher parmi les artistes inscrits';

  @override
  String get noArtistFound => 'Aucun artiste trouvé';

  @override
  String get artistNotRegistered =>
      'Cet artiste n\'est pas encore inscrit. Invitez-le ou créez sa fiche manuellement.';

  @override
  String get link => 'Lier';

  @override
  String get createNewArtist => 'Créer un nouvel artiste';

  @override
  String get artistNotOnApp =>
      'L\'artiste n\'est pas sur l\'app ? Créez sa fiche et invitez-le';

  @override
  String get home => 'Accueil';

  @override
  String get favorites => 'Favoris';

  @override
  String get myFavorites => 'Mes favoris';

  @override
  String get studios => 'Studios';

  @override
  String get studiosLabel => 'Studios';

  @override
  String get engineers => 'Ingénieurs';

  @override
  String get engineersLabel => 'Ingénieurs';

  @override
  String get noFavoriteStudio => 'Aucun studio favori';

  @override
  String get noFavoriteStudios => 'Aucun studio favori';

  @override
  String get exploreStudiosAndAddFavorites =>
      'Explorez les studios et ajoutez-les à vos favoris';

  @override
  String get exploreStudiosToFavorite =>
      'Explorez les studios et ajoutez-les à vos favoris';

  @override
  String get noFavoriteEngineer => 'Aucun ingénieur favori';

  @override
  String get noFavoriteEngineers => 'Aucun ingénieur favori';

  @override
  String get discoverEngineersAndAddFavorites =>
      'Découvrez les ingénieurs et ajoutez-les à vos favoris';

  @override
  String get discoverEngineersToFavorite =>
      'Découvrez les ingénieurs et ajoutez-les à vos favoris';

  @override
  String get noFavoriteArtists => 'Aucun artiste favori';

  @override
  String get addArtistsToFavorite =>
      'Ajoutez des artistes à vos favoris depuis la liste des artistes';

  @override
  String get unnamed => 'Sans nom';

  @override
  String get claimStudioTitle => 'Mon studio';

  @override
  String get nearbyStudiosTitle => 'Studios à proximité';

  @override
  String get selectStudioToClaim =>
      'Sélectionnez votre studio pour le revendiquer';

  @override
  String get connectGoogleCalendarDesc =>
      'Connectez votre agenda Google pour synchroniser automatiquement vos disponibilités.';

  @override
  String get connectGoogleCalendar => 'Connecter Google Calendar';

  @override
  String get claimYourStudioTitle => 'Revendiquez votre studio';

  @override
  String get claimYourStudio => 'Revendiquez votre studio';

  @override
  String get claimYourStudioDesc =>
      'Rendez votre studio visible aux artistes et recevez des demandes de session.';

  @override
  String get claimStudioDescription =>
      'Rendez votre studio visible aux artistes et recevez des demandes de session.';

  @override
  String get noStudioFoundNearby => 'Aucun studio trouvé à proximité';

  @override
  String get createStudioManually =>
      'Créez votre studio manuellement ci-dessous';

  @override
  String get createStudioManuallyBelow =>
      'Créez votre studio manuellement ci-dessous';

  @override
  String get studioNotAppearing => 'Mon studio n\'apparaît pas';

  @override
  String get studioNotListed => 'Mon studio n\'apparaît pas';

  @override
  String get createStudioProfileManually =>
      'Créer manuellement mon profil studio';

  @override
  String get createManualProfile => 'Créer manuellement mon profil studio';

  @override
  String get claimThisStudio => 'Revendiquer ce studio ?';

  @override
  String get claimStudioExplanation =>
      'En revendiquant ce studio, vous le rendez visible aux artistes sur Use Me. Ils pourront voir vos disponibilités et vous envoyer des demandes de session.';

  @override
  String get claimStudioInfo =>
      'En revendiquant ce studio, vous le rendez visible aux artistes sur Use Me. Ils pourront voir vos disponibilités et vous envoyer des demandes de session.';

  @override
  String get claim => 'Revendiquer';

  @override
  String studioClaimedSuccess(String name) {
    return '$name revendiqué avec succès !';
  }

  @override
  String get studioClaims => 'Revendications studios';

  @override
  String get studioClaimsSubtitle => 'Approuver ou refuser les demandes';

  @override
  String get unclaim => 'Retirer';

  @override
  String get unclaimStudioTitle => 'Retirer le studio ?';

  @override
  String unclaimStudioMessage(String name) {
    return 'Voulez-vous vraiment retirer \"$name\" ? Votre studio ne sera plus visible par les artistes.';
  }

  @override
  String get studioUnclaimed => 'Studio retiré avec succès';

  @override
  String get configurePayments => 'Configurez vos paiements';

  @override
  String get paymentOptionsDescription =>
      'Ces options seront proposées aux artistes lors de la confirmation de réservation.';

  @override
  String get defaultDeposit => 'Acompte par défaut';

  @override
  String get depositPercentDescription =>
      'Pourcentage du montant total demandé en acompte';

  @override
  String get acceptedPaymentMethods => 'Moyens de paiement acceptés';

  @override
  String get instructionsOptional => 'Instructions (optionnel)';

  @override
  String get instructionsHint => 'Ex: Mettre le nom de l\'artiste en référence';

  @override
  String get paypalEmail => 'Email PayPal';

  @override
  String get cardInfo => 'Informations';

  @override
  String get details => 'Détails';

  @override
  String get iban => 'IBAN';

  @override
  String get createMyStudio => 'Créer mon studio';

  @override
  String get studioNameRequired => 'Nom du studio *';

  @override
  String get studioNameHint => 'Ex: Studio Harmonie';

  @override
  String get studioNameRequiredError => 'Le nom du studio est requis';

  @override
  String get studioNameIsRequired => 'Le nom du studio est requis';

  @override
  String get description => 'Description';

  @override
  String get describeStudioHint => 'Décrivez votre studio en quelques mots...';

  @override
  String get describeYourStudio => 'Décrivez votre studio en quelques mots...';

  @override
  String get location => 'Localisation';

  @override
  String get address => 'Adresse';

  @override
  String get addressHint => 'Ex: 123 rue de la Musique';

  @override
  String get postalCode => 'Code postal';

  @override
  String get cityRequired => 'Ville *';

  @override
  String get cityRequiredError => 'La ville est requise';

  @override
  String get cityIsRequired => 'La ville est requise';

  @override
  String get phone => 'Téléphone';

  @override
  String get phoneHint => '06 12 34 56 78';

  @override
  String get website => 'Site web';

  @override
  String get websiteHint => 'https://www.monstudio.com';

  @override
  String get offeredServices => 'Services proposés';

  @override
  String get servicesOffered => 'Services proposés';

  @override
  String get creating => 'Création en cours...';

  @override
  String get creatingInProgress => 'Création en cours...';

  @override
  String get studioCreatedSuccess => 'Studio créé avec succès !';

  @override
  String get manualCreation => 'Création manuelle';

  @override
  String get studioVisibleAfterCreation =>
      'Votre studio sera visible aux artistes dès sa création. Vous pourrez compléter votre profil plus tard.';

  @override
  String get manualCreationDescription =>
      'Votre studio sera visible aux artistes dès sa création. Vous pourrez compléter votre profil plus tard.';

  @override
  String get editSession => 'Modifier la session';

  @override
  String get newSession => 'Nouvelle session';

  @override
  String get dateAndTime => 'Date et heure';

  @override
  String get duration => 'Durée';

  @override
  String get save => 'Enregistrer';

  @override
  String get createSession => 'Créer la session';

  @override
  String get addArtistFirst => 'Ajouter un artiste d\'abord';

  @override
  String get selectArtist => 'Sélectionner un artiste';

  @override
  String get addAnotherArtist => 'Ajouter un autre artiste';

  @override
  String get allArtistsSelected => 'Tous les artistes sont déjà sélectionnés';

  @override
  String get selectAtLeastOneArtist => 'Sélectionnez au moins un artiste';

  @override
  String get deleteSession => 'Supprimer la session';

  @override
  String get actionIrreversible => 'Cette action est irréversible.';

  @override
  String get editService => 'Modifier le service';

  @override
  String get newServiceTitle => 'Nouveau service';

  @override
  String get serviceName => 'Nom du service';

  @override
  String get serviceNameHint => 'Ex: Mix, Mastering, Recording...';

  @override
  String get fieldRequired => 'Champ requis';

  @override
  String get serviceDescription => 'Description (optionnel)';

  @override
  String get serviceDescriptionHint => 'Description du service...';

  @override
  String get hourlyRate => 'Tarif horaire (€)';

  @override
  String get perHour => '€/h';

  @override
  String get invalidNumber => 'Nombre invalide';

  @override
  String get minimumDuration => 'Durée minimum';

  @override
  String get serviceActive => 'Service actif';

  @override
  String get availableForBooking => 'Disponible à la réservation';

  @override
  String get notAvailableForBooking => 'Non disponible';

  @override
  String get createService => 'Créer le service';

  @override
  String get deleteService => 'Supprimer le service';

  @override
  String get teamMembers => 'Membres de l\'équipe';

  @override
  String get pendingInvitations => 'Invitations en attente';

  @override
  String get noMember => 'Aucun membre';

  @override
  String get addEngineersToTeam => 'Ajoutez des ingénieurs à votre équipe';

  @override
  String get noInvitation => 'Aucune invitation';

  @override
  String get pendingInvitationsHere =>
      'Les invitations en attente apparaîtront ici';

  @override
  String get codeCopied => 'Code copié';

  @override
  String get removeFromTeam => 'Retirer de l\'équipe';

  @override
  String get removeMemberConfirm => 'Retirer ce membre ?';

  @override
  String memberNoAccessAnymore(String name) {
    return '$name ne pourra plus accéder aux sessions du studio.';
  }

  @override
  String get memberRemoved => 'Membre retiré';

  @override
  String get remove => 'Retirer';

  @override
  String get invitationCancelled => 'Invitation annulée';

  @override
  String get addMember => 'Ajouter un membre';

  @override
  String get searchByEmailOrInvite =>
      'Recherchez par email ou invitez un nouvel ingénieur';

  @override
  String get userNotRegistered => 'Utilisateur non inscrit';

  @override
  String get sendInvitationToJoin =>
      'Envoyez-lui une invitation pour rejoindre votre équipe.';

  @override
  String get sendInvitation => 'Envoyer l\'invitation';

  @override
  String get enterValidEmail => 'Entrez un email valide';

  @override
  String get invitationCreated => 'Invitation créée';

  @override
  String get shareCodeWithEngineer => 'Partagez ce code avec l\'ingénieur :';

  @override
  String get searchArtistHint => 'Rechercher un artiste...';

  @override
  String get noArtistEmpty => 'Aucun artiste';

  @override
  String get addFirstArtist => 'Ajoutez votre premier artiste';

  @override
  String get addArtist => 'Ajouter un artiste';

  @override
  String get tryAnotherSearch => 'Essayez une autre recherche';

  @override
  String get search => 'Rechercher';

  @override
  String get create => 'Créer';

  @override
  String get findExistingArtist => 'Trouvez un artiste existant';

  @override
  String get searchAmongRegistered =>
      'Recherchez parmi les artistes déjà inscrits sur Use Me pour le lier à votre studio.';

  @override
  String artistAddedToStudio(String name) {
    return '$name ajouté à votre studio !';
  }

  @override
  String get artistName => 'Nom d\'artiste';

  @override
  String get stageNameHint => 'Le nom de scène...';

  @override
  String get civilName => 'Nom civil';

  @override
  String get firstAndLastName => 'Prénom et nom...';

  @override
  String get emailHintArtist => 'Email de l\'artiste...';

  @override
  String get emailRequiredForInvitation => 'Email requis pour l\'invitation';

  @override
  String get phoneOptional => 'Téléphone (optionnel)';

  @override
  String get phoneHintGeneric => 'Téléphone...';

  @override
  String get musicalGenres => 'Genres musicaux';

  @override
  String get sendInvitationToggle => 'Envoyer une invitation';

  @override
  String get artistWillReceiveCode =>
      'L\'artiste recevra un code pour rejoindre votre studio';

  @override
  String get createAndInvite => 'Créer et inviter';

  @override
  String get createProfile => 'Créer la fiche';

  @override
  String get createArtistProfile => 'Créer une fiche artiste';

  @override
  String get createProfileAndInvite =>
      'Créez la fiche et invitez l\'artiste. Son compte sera automatiquement lié quand il s\'inscrira.';

  @override
  String get artistCreated => 'Artiste créé !';

  @override
  String get shareCodeWithArtist =>
      'Partagez ce code avec l\'artiste pour qu\'il rejoigne votre studio';

  @override
  String get share => 'Partager';

  @override
  String get done => 'Terminé';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get markAllRead => 'Tout marquer lu';

  @override
  String get markAllAsRead => 'Tout marquer lu';

  @override
  String get noNotification => 'Aucune notification';

  @override
  String get noNotifications => 'Aucune notification';

  @override
  String get notifiedForNewSessions =>
      'Vous serez notifié des nouvelles sessions';

  @override
  String get notifyNewSessions => 'Vous serez notifié des nouvelles sessions';

  @override
  String get loadingError => 'Erreur de chargement';

  @override
  String get personalInformation => 'Informations personnelles';

  @override
  String get fullNameLabel => 'Nom complet';

  @override
  String get required => 'Requis';

  @override
  String get stageName => 'Nom de scène';

  @override
  String get bio => 'Bio';

  @override
  String get tellAboutYourself => 'Parlez de vous...';

  @override
  String get accountSection => 'Compte';

  @override
  String get changePasswordAction => 'Changer le mot de passe';

  @override
  String get logoutAction => 'Se déconnecter';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get deleteMyAccount => 'Supprimer mon compte';

  @override
  String get resetEmailSent => 'Email de réinitialisation envoyé';

  @override
  String get deleteAccountTitle => 'Supprimer le compte';

  @override
  String get deleteAccountFinalWarning =>
      'Cette action est irréversible. Toutes vos données seront supprimées définitivement.';

  @override
  String get sessionTracking => 'Suivi session';

  @override
  String hoursPlanned(int hours) {
    return '${hours}h prévues';
  }

  @override
  String get checkIn => 'Pointage';

  @override
  String get checkInArrival => 'Pointer l\'arrivée';

  @override
  String get arrivalChecked => 'Arrivée pointée';

  @override
  String get checkOutDeparture => 'Pointer le départ';

  @override
  String get sessionNotes => 'Notes de session';

  @override
  String get addSessionNotes => 'Ajouter des notes sur la session...';

  @override
  String get photos => 'Photos';

  @override
  String get addPhoto => 'Ajouter une photo';

  @override
  String get arrivalCheckedSuccess => 'Arrivée pointée !';

  @override
  String get endSession => 'Terminer la session ?';

  @override
  String get endSessionConfirm =>
      'Voulez-vous pointer votre départ et terminer cette session ?';

  @override
  String get finish => 'Terminer';

  @override
  String get contactArtist => 'Contacter l\'artiste';

  @override
  String get reportProblemAction => 'Signaler un problème';

  @override
  String get editArtist => 'Modifier l\'artiste';

  @override
  String get newArtistTitle => 'Nouvel artiste';

  @override
  String get emailHintGeneric => 'Email...';

  @override
  String get cityHint => 'Ville...';

  @override
  String get bioOptional => 'Bio (optionnel)';

  @override
  String get fewWordsAboutArtist => 'Quelques mots sur l\'artiste...';

  @override
  String get createArtist => 'Créer l\'artiste';

  @override
  String get deleteArtist => 'Supprimer l\'artiste';

  @override
  String get calendarTitle => 'Calendrier';

  @override
  String get unavailabilityAdded => 'Indisponibilité ajoutée';

  @override
  String get unavailabilityDeleted => 'Indisponibilité supprimée';

  @override
  String get calendarConnected => 'Calendrier connecté';

  @override
  String get never => 'Jamais';

  @override
  String get lastSync => 'Dernier sync';

  @override
  String get synchronize => 'Synchroniser';

  @override
  String get disconnect => 'Déconnecter';

  @override
  String get disconnectCalendar => 'Déconnecter le calendrier ?';

  @override
  String get disconnectCalendarWarning =>
      'Vos indisponibilités synchronisées seront supprimées. Les indisponibilités manuelles seront conservées.';

  @override
  String get tipsSectionGettingStarted => 'Premiers pas';

  @override
  String get tipsSectionBookings => 'Réservations';

  @override
  String get tipsSectionProTips => 'Astuces pro';

  @override
  String get tipsSectionSetup => 'Configuration';

  @override
  String get tipsSectionSessions => 'Sessions';

  @override
  String get tipsSectionTips => 'Astuces';

  @override
  String get tipsSectionStudioSetup => 'Configuration du studio';

  @override
  String get tipsSectionTeamManagement => 'Gestion d\'équipe';

  @override
  String get tipsSectionVisibility => 'Visibilité';

  @override
  String get tipExploreMapTitle => 'Explorez la carte';

  @override
  String get tipExploreMapDesc =>
      'La carte vous montre tous les studios autour de vous. Les pins verts sont des studios partenaires avec des avantages exclusifs. Zoomez et déplacez-vous pour découvrir plus de studios.';

  @override
  String get tipCompleteProfileTitle => 'Complétez votre profil';

  @override
  String get tipCompleteProfileDesc =>
      'Un profil complet avec photo et genres musicaux aide les studios à mieux vous connaître. Allez dans Réglages > Mon profil pour ajouter ces infos.';

  @override
  String get tipChooseSlotTitle => 'Choisir le bon créneau';

  @override
  String get tipChooseSlotDesc =>
      'Les créneaux verts indiquent une forte disponibilité d\'ingénieurs. Les créneaux orange sont plus limités. Préférez les créneaux verts pour plus de flexibilité.';

  @override
  String get tipSelectEngineerTitle => 'Sélectionnez votre ingénieur';

  @override
  String get tipSelectEngineerDesc =>
      'Vous pouvez choisir un ingénieur spécifique ou laisser le studio assigner. Si vous avez déjà travaillé avec quelqu\'un, retrouvez-le dans la liste !';

  @override
  String get tipPrepareSessionTitle => 'Préparez votre session';

  @override
  String get tipPrepareSessionDesc =>
      'Utilisez le champ \"Notes\" pour décrire votre projet : style, références, ce que vous voulez accomplir. Ça aide l\'ingénieur à se préparer.';

  @override
  String get tipBookAdvanceTitle => 'Réservez à l\'avance';

  @override
  String get tipBookAdvanceDesc =>
      'Les meilleurs créneaux partent vite ! Réservez 2-3 jours à l\'avance pour avoir le choix des horaires et des ingénieurs.';

  @override
  String get tipManageFavoritesTitle => 'Gérez vos favoris';

  @override
  String get tipManageFavoritesDesc =>
      'Ajoutez vos studios préférés en favoris pour les retrouver rapidement. Appuyez sur le cœur sur la page du studio.';

  @override
  String get tipTrackSessionsTitle => 'Suivez vos sessions';

  @override
  String get tipTrackSessionsDesc =>
      'Dans l\'onglet Sessions, retrouvez tout votre historique. C\'est pratique pour re-réserver avec le même ingénieur ou studio.';

  @override
  String get tipSetScheduleTitle => 'Définissez vos horaires';

  @override
  String get tipSetScheduleDesc =>
      'Allez dans Réglages > Disponibilités pour configurer vos jours et heures de travail. Les artistes ne pourront réserver que sur vos créneaux actifs.';

  @override
  String get tipAddUnavailabilityTitle => 'Ajoutez vos indisponibilités';

  @override
  String get tipAddUnavailabilityDesc =>
      'Vacances, RDV, ou jour off ? Ajoutez une indisponibilité pour bloquer ces périodes. Vous pouvez ajouter une raison optionnelle.';

  @override
  String get tipViewSessionsTitle => 'Voir vos sessions';

  @override
  String get tipViewSessionsDesc =>
      'L\'onglet Sessions affiche toutes vos sessions à venir. Les sessions \"Confirmées\" sont validées, \"En attente\" doivent être confirmées par le studio.';

  @override
  String get tipStartSessionTitle => 'Démarrer une session';

  @override
  String get tipStartSessionDesc =>
      'Le jour J, appuyez sur \"Démarrer\" pour lancer le chrono. À la fin, appuyez sur \"Terminer\" et ajoutez vos notes de session.';

  @override
  String get tipSessionNotesTitle => 'Notes de session';

  @override
  String get tipSessionNotesDesc =>
      'Après chaque session, ajoutez des notes : réglages utilisés, fichiers exportés, remarques. C\'est utile pour vous et pour l\'artiste.';

  @override
  String get tipStayUpdatedTitle => 'Restez à jour';

  @override
  String get tipStayUpdatedDesc =>
      'Mettez à jour vos disponibilités régulièrement. Un planning à jour = plus de réservations pour vous !';

  @override
  String get tipProfileMattersTitle => 'Votre profil compte';

  @override
  String get tipProfileMattersDesc =>
      'Les artistes peuvent vous choisir spécifiquement. Une photo pro et une bio avec vos spécialités attirent plus de clients.';

  @override
  String get tipCompleteStudioProfileTitle => 'Complétez votre profil studio';

  @override
  String get tipCompleteStudioProfileDesc =>
      'Ajoutez photos, description, équipements et services. Un profil complet apparaît plus haut dans les résultats et attire plus d\'artistes.';

  @override
  String get tipSetStudioHoursTitle => 'Définissez vos horaires';

  @override
  String get tipSetStudioHoursDesc =>
      'Configurez les horaires d\'ouverture du studio dans Réglages. Les artistes ne pourront réserver que pendant ces heures.';

  @override
  String get tipAddServicesTitle => 'Ajoutez vos services';

  @override
  String get tipAddServicesDesc =>
      'Enregistrement, mix, mastering... Définissez vos services avec leurs tarifs. Ça aide les artistes à choisir.';

  @override
  String get tipInviteEngineersTitle => 'Invitez vos ingénieurs';

  @override
  String get tipInviteEngineersDesc =>
      'Allez dans Équipe > Inviter pour ajouter vos ingénieurs. Ils recevront un lien pour rejoindre votre studio.';

  @override
  String get tipManageAvailabilitiesTitle => 'Gérez les disponibilités';

  @override
  String get tipManageAvailabilitiesDesc =>
      'Chaque ingénieur gère ses propres disponibilités. Vous pouvez voir la vue d\'ensemble dans le planning du studio.';

  @override
  String get tipAssignSessionsTitle => 'Assignez les sessions';

  @override
  String get tipAssignSessionsDesc =>
      'Quand un artiste ne choisit pas d\'ingénieur, c\'est à vous de l\'assigner. Vérifiez les disponibilités avant d\'assigner.';

  @override
  String get tipManageRequestsTitle => 'Gérer les demandes';

  @override
  String get tipManageRequestsDesc =>
      'Les nouvelles demandes apparaissent dans \"En attente\". Validez rapidement pour fidéliser les artistes !';

  @override
  String get tipInviteArtistsTitle => 'Invitez vos artistes';

  @override
  String get tipInviteArtistsDesc =>
      'Vous avez des artistes réguliers ? Invitez-les via Clients > Inviter. Ils pourront réserver plus facilement.';

  @override
  String get tipTrackActivityTitle => 'Suivez l\'activité';

  @override
  String get tipTrackActivityDesc =>
      'Le dashboard vous montre les stats : sessions du mois, revenus, artistes actifs. Gardez un œil sur votre activité.';

  @override
  String get tipBecomePartnerTitle => 'Devenez partenaire';

  @override
  String get tipBecomePartnerDesc =>
      'Les studios partenaires apparaissent en vert sur la carte et en priorité. Contactez-nous pour en savoir plus !';

  @override
  String get tipEncourageReviewsTitle => 'Encouragez les avis';

  @override
  String get tipEncourageReviewsDesc =>
      'Après une session réussie, invitez l\'artiste à laisser un avis. Les bons avis attirent plus de clients.';

  @override
  String get tipsSectionAIAssistant => 'Assistant IA';

  @override
  String get tipAIAssistantTitle => 'Parle à ton assistant';

  @override
  String get tipAIAssistantDesc =>
      'L\'assistant IA connaît toutes tes données. Demande-lui tes sessions, stats, ou de l\'aide pour n\'importe quelle question !';

  @override
  String get tipAIActionsTitle => 'Actions par la voix';

  @override
  String get tipAIActionsStudioDesc =>
      'Tu peux demander à l\'assistant de créer des sessions, accepter des réservations, gérer tes services... Tout par le chat !';

  @override
  String get tipAIActionsEngineerDesc =>
      'Demande à l\'assistant de démarrer ou terminer tes sessions, gérer tes indisponibilités, et plus encore.';

  @override
  String get tipAIActionsArtistDesc =>
      'L\'assistant peut rechercher des studios, gérer tes favoris, créer des demandes de réservation pour toi.';

  @override
  String get tipAIContextTitle => 'Il te connaît';

  @override
  String get tipAIContextDesc =>
      'L\'assistant sait qui tu es et adapte ses réponses selon ton profil. Il peut accéder à tes vraies données en temps réel.';

  @override
  String get teamInvitations => 'Invitations d\'équipe';

  @override
  String get noEmailConfigured => 'Email non configuré';

  @override
  String get noInvitations => 'Aucune invitation';

  @override
  String get noInvitationsDescription =>
      'Vous n\'avez pas d\'invitation en attente.';

  @override
  String invitationSentOn(String date) {
    return 'Envoyée le $date';
  }

  @override
  String teamInvitationMessage(String studioName) {
    return '$studioName vous invite à rejoindre son équipe en tant qu\'ingénieur du son.';
  }

  @override
  String expiresOn(String date) {
    return 'Expire le $date';
  }

  @override
  String get decline => 'Refuser';

  @override
  String get accept => 'Accepter';

  @override
  String get invitationAccepted =>
      'Invitation acceptée ! Vous faites maintenant partie de l\'équipe.';

  @override
  String get declineInvitation => 'Refuser l\'invitation';

  @override
  String declineInvitationConfirm(String studioName) {
    return 'Êtes-vous sûr de vouloir refuser l\'invitation de $studioName ?';
  }

  @override
  String get invitationDeclined => 'Invitation refusée.';

  @override
  String get errorOccurred => 'Une erreur est survenue';

  @override
  String get sessionDetails => 'Détails de la session';

  @override
  String get toBeAssigned => 'À attribuer par le studio';

  @override
  String get acceptSession => 'Accepter la session';

  @override
  String get confirmAcceptSession =>
      'Voulez-vous accepter cette demande de session ?';

  @override
  String get sessionAccepted => 'Session acceptée !';

  @override
  String get declineSession => 'Refuser la session';

  @override
  String get confirmDeclineSession =>
      'Voulez-vous refuser cette demande de session ?';

  @override
  String get sessionDeclined => 'Session refusée';

  @override
  String get cancelSession => 'Annuler la session';

  @override
  String get confirmCancelSession =>
      'Voulez-vous annuler cette session ? Cette action est irréversible.';

  @override
  String get bic => 'BIC / SWIFT';

  @override
  String get accountHolder => 'Titulaire du compte';

  @override
  String get bankName => 'Nom de la banque';

  @override
  String get cancellationPolicy => 'Politique d\'annulation';

  @override
  String get cancellationPolicyDescription =>
      'Définissez vos conditions de remboursement en cas d\'annulation';

  @override
  String get customCancellationTerms => 'Conditions personnalisées';

  @override
  String get customCancellationHint =>
      'Décrivez vos conditions d\'annulation...';

  @override
  String get saveAsDefault => 'Enregistrer par défaut';

  @override
  String get saveAsDefaultDescription =>
      'Utiliser ce choix pour les prochaines sessions';

  @override
  String get proposeToEngineers => 'Proposer';

  @override
  String get assignLater => 'Plus tard';

  @override
  String get assignLaterDescription =>
      'Vous pourrez assigner un ingénieur depuis les détails de la session';

  @override
  String get selectAtLeastOne => 'Sélectionnez au moins 1';

  @override
  String get assignEngineer => 'Ingénieur son';

  @override
  String get noEngineersAvailable =>
      'Aucun ingénieur disponible pour ce créneau';

  @override
  String get proposedSessions => 'Sessions proposées';

  @override
  String get proposedSessionsEmpty => 'Aucune proposition en attente';

  @override
  String get acceptProposal => 'Accepter';

  @override
  String get declineProposal => 'Refuser';

  @override
  String get joinAsCoEngineer => 'Rejoindre';

  @override
  String get sessionProposedToYou => 'Session proposée';

  @override
  String get sessionTaken => 'Session prise';

  @override
  String get sessionTakenDesc =>
      'Cette session a été acceptée par un autre ingénieur. Vous pouvez demander à rejoindre.';

  @override
  String get requestToJoin => 'Demander à rejoindre';

  @override
  String get joinedAsCoEngineer => 'Vous avez rejoint la session !';

  @override
  String get proposalAccepted => 'Proposition acceptée !';

  @override
  String get proposalDeclined => 'Proposition refusée';

  @override
  String get youAreAssigned => 'Vous êtes assigné';

  @override
  String get pendingProposal => 'En attente de réponse';

  @override
  String get openingHours => 'Horaires d\'ouverture';

  @override
  String get openingHoursSubtitle => 'Définissez quand votre studio est ouvert';

  @override
  String get noOpeningHoursConfigured => 'Aucun horaire configuré';

  @override
  String get openingHoursSaved => 'Horaires enregistrés';

  @override
  String get allowNoEngineer => 'Réservation sans ingénieur';

  @override
  String get allowNoEngineerSubtitle =>
      'Permet aux artistes de réserver même si aucun ingénieur n\'est disponible';

  @override
  String get settingsSaved => 'Paramètre enregistré';

  @override
  String get selectStudio => 'Choisir un studio';

  @override
  String get selectStudioDescription =>
      'Sélectionnez le studio pour votre session';

  @override
  String get noLinkedStudios => 'Aucun studio lié';

  @override
  String get noLinkedStudiosDescription =>
      'Vous n\'êtes lié à aucun studio. Explorez les studios pour commencer.';

  @override
  String get discoverStudios => 'Découvrir les studios';

  @override
  String get exploreMapHint =>
      'Explorez la carte pour trouver des studios à proximité';

  @override
  String get exploreStudiosTitle => 'Explorez la carte';

  @override
  String get exploreStudiosDescription =>
      'Faites glisser la liste vers le bas pour voir la carte et découvrir les studios autour de vous. Cliquez sur un studio pour voir ses détails et le contacter.';

  @override
  String get understood => 'Compris';

  @override
  String get changePhoto => 'Changer la photo';

  @override
  String get takePhoto => 'Prendre une photo';

  @override
  String get useCamera => 'Utiliser l\'appareil photo';

  @override
  String get chooseFromGallery => 'Choisir depuis la galerie';

  @override
  String get selectExistingPhoto => 'Sélectionner une photo existante';

  @override
  String get photoUpdated => 'Photo mise à jour';

  @override
  String get aiGuideTitle => 'Guide de l\'assistant IA';

  @override
  String get aiGuideHeaderTitle => 'Votre assistant personnel';

  @override
  String get aiGuideHeaderSubtitle =>
      'Découvrez tout ce que l\'IA peut faire pour vous';

  @override
  String get aiGuideSecurityTitle => 'Toujours sous votre contrôle';

  @override
  String get aiGuideSecurityDesc =>
      'L\'assistant vous demandera TOUJOURS confirmation avant d\'effectuer une action. Rien ne sera fait sans votre accord explicite.';

  @override
  String get aiGuideIntroTitle => 'Comment ça marche ?';

  @override
  String get aiGuideWhatIsTitle => 'Un assistant intelligent';

  @override
  String get aiGuideWhatIsDesc =>
      'L\'assistant IA comprend vos demandes en langage naturel et peut consulter vos données ou effectuer des actions pour vous. Posez-lui des questions ou demandez-lui d\'agir !';

  @override
  String get aiGuideConfirmTitle => 'Confirmation obligatoire';

  @override
  String get aiGuideConfirmDesc =>
      'Avant chaque action (réservation, annulation, modification...), l\'assistant vous résumera ce qu\'il va faire et attendra votre confirmation. Vous gardez le contrôle total.';

  @override
  String get aiGuideReadTitle => 'Ce que l\'IA peut consulter';

  @override
  String get aiGuideActionsTitle => 'Actions possibles';

  @override
  String get aiGuideExamplesTitle => 'Exemples de demandes';

  @override
  String get aiGuideSessionsTitle => 'Vos sessions';

  @override
  String get aiGuideArtistSessionsDesc =>
      'Consultez vos réservations passées, en cours ou à venir. Filtrez par date ou statut.';

  @override
  String get aiGuideEngineerSessionsDesc =>
      'Voyez les sessions qui vous sont assignées, les propositions en attente et votre planning.';

  @override
  String get aiGuideStudioSessionsDesc =>
      'Accédez à toutes les sessions de votre studio, filtrez par statut, date ou artiste.';

  @override
  String get aiGuideAvailabilityTitle => 'Disponibilités';

  @override
  String get aiGuideAvailabilityDesc =>
      'Vérifiez les créneaux disponibles d\'un studio pour une date donnée.';

  @override
  String get aiGuideConversationsTitle => 'Conversations';

  @override
  String get aiGuideConversationsDesc =>
      'Consultez vos conversations récentes et les messages non lus.';

  @override
  String get aiGuideTimeOffTitle => 'Vos indisponibilités';

  @override
  String get aiGuideTimeOffDesc =>
      'Consultez vos périodes d\'indisponibilité planifiées (vacances, congés...).';

  @override
  String get aiGuidePendingTitle => 'Demandes en attente';

  @override
  String get aiGuidePendingDesc =>
      'Voyez toutes les demandes de réservation qui attendent votre réponse.';

  @override
  String get aiGuideStatsTitle => 'Statistiques';

  @override
  String get aiGuideStatsDesc =>
      'Obtenez un aperçu de vos sessions (complétées, en attente, annulées) sur une période.';

  @override
  String get aiGuideRevenueTitle => 'Rapport de revenus';

  @override
  String get aiGuideRevenueDesc =>
      'Générez un rapport de revenus détaillé, groupé par service, ingénieur ou jour.';

  @override
  String get aiGuideTeamTitle => 'Votre équipe';

  @override
  String get aiGuideTeamDesc =>
      'Listez les ingénieurs de votre équipe et leurs disponibilités.';

  @override
  String get aiGuideBookingTitle => 'Réserver une session';

  @override
  String get aiGuideBookingDesc =>
      'Demandez à l\'IA de créer une demande de réservation. Elle vous guidera dans le choix du studio, service, date et créneau.';

  @override
  String get aiGuideFavoritesTitle => 'Gérer les favoris';

  @override
  String get aiGuideFavoritesDesc =>
      'Ajoutez ou retirez des studios de vos favoris, ou consultez votre liste de favoris.';

  @override
  String get aiGuideSearchStudiosTitle => 'Rechercher des studios';

  @override
  String get aiGuideSearchStudiosDesc =>
      'Trouvez des studios par nom, ville ou type de service proposé.';

  @override
  String get aiGuideSendMessageTitle => 'Envoyer un message';

  @override
  String get aiGuideSendMessageDesc =>
      'Envoyez un message à un studio ou un artiste directement via l\'assistant.';

  @override
  String get aiGuideStartSessionTitle => 'Démarrer une session';

  @override
  String get aiGuideStartSessionDesc =>
      'Pointez votre arrivée en démarrant une session confirmée le jour J.';

  @override
  String get aiGuideCompleteSessionTitle => 'Terminer une session';

  @override
  String get aiGuideCompleteSessionDesc =>
      'Marquez une session comme terminée et ajoutez des notes si nécessaire.';

  @override
  String get aiGuideRespondProposalTitle => 'Répondre à une proposition';

  @override
  String get aiGuideRespondProposalDesc =>
      'Acceptez ou refusez les sessions que le studio vous propose.';

  @override
  String get aiGuideManageTimeOffTitle => 'Gérer les indisponibilités';

  @override
  String get aiGuideManageTimeOffDesc =>
      'Ajoutez ou supprimez des périodes d\'indisponibilité (vacances, rendez-vous...).';

  @override
  String get aiGuideAcceptDeclineTitle => 'Accepter/Refuser demandes';

  @override
  String get aiGuideAcceptDeclineDesc =>
      'Gérez les demandes de réservation en les acceptant ou refusant via l\'assistant.';

  @override
  String get aiGuideRescheduleTitle => 'Reprogrammer une session';

  @override
  String get aiGuideRescheduleDesc =>
      'Changez la date ou l\'heure d\'une session existante. L\'artiste sera notifié.';

  @override
  String get aiGuideAssignEngineerTitle => 'Assigner un ingénieur';

  @override
  String get aiGuideAssignEngineerDesc =>
      'Assignez un ingénieur disponible à une session confirmée.';

  @override
  String get aiGuideCreateSessionTitle => 'Créer une session';

  @override
  String get aiGuideCreateSessionDesc =>
      'Créez une session manuellement pour un artiste, même sans demande préalable.';

  @override
  String get aiGuideBlockSlotsTitle => 'Bloquer des créneaux';

  @override
  String get aiGuideBlockSlotsDesc =>
      'Marquez des périodes d\'indisponibilité pour fermeture exceptionnelle du studio.';

  @override
  String get aiGuideManageServicesTitle => 'Gérer les services';

  @override
  String get aiGuideManageServicesDesc =>
      'Créez ou modifiez vos services (nom, prix, durée, description).';

  @override
  String get aiGuideExample1ArtistTitle => 'Mes prochaines sessions';

  @override
  String get aiGuideExample1ArtistDesc =>
      '\"Quelles sont mes sessions cette semaine ?\" - L\'IA vous montrera toutes vos réservations à venir.';

  @override
  String get aiGuideExample2ArtistTitle => 'Trouver un studio';

  @override
  String get aiGuideExample2ArtistDesc =>
      '\"Je cherche un studio à Paris pour du mix\" - L\'IA recherchera les studios correspondants.';

  @override
  String get aiGuideExample3ArtistTitle => 'Réserver un créneau';

  @override
  String get aiGuideExample3ArtistDesc =>
      '\"Je veux réserver demain à 14h au Studio X\" - L\'IA vérifiera la disponibilité et vous guidera.';

  @override
  String get aiGuideExample1EngineerTitle => 'Sessions du jour';

  @override
  String get aiGuideExample1EngineerDesc =>
      '\"Qu\'est-ce que j\'ai aujourd\'hui ?\" - L\'IA vous montrera les sessions assignées pour aujourd\'hui.';

  @override
  String get aiGuideExample2EngineerTitle => 'Poser des congés';

  @override
  String get aiGuideExample2EngineerDesc =>
      '\"Je serai absent du 15 au 20 janvier\" - L\'IA créera l\'indisponibilité après confirmation.';

  @override
  String get aiGuideExample3EngineerTitle => 'Répondre à une proposition';

  @override
  String get aiGuideExample3EngineerDesc =>
      '\"Accepte la session de demain\" - L\'IA confirmera la proposition en attente.';

  @override
  String get aiGuideExample1StudioTitle => 'Demandes en attente';

  @override
  String get aiGuideExample1StudioDesc =>
      '\"Montre-moi les demandes en attente\" - L\'IA affichera toutes les réservations à traiter.';

  @override
  String get aiGuideExample2StudioTitle => 'Rapport de revenus';

  @override
  String get aiGuideExample2StudioDesc =>
      '\"Quel est mon chiffre d\'affaires ce mois-ci ?\" - L\'IA générera un rapport détaillé.';

  @override
  String get aiGuideExample3StudioTitle => 'Reprogrammer une session';

  @override
  String get aiGuideExample3StudioDesc =>
      '\"Décale la session de Lundi à Mardi 10h\" - L\'IA reprogrammera après votre confirmation.';

  @override
  String get aiGuideSettingsLink => 'Guide de l\'assistant IA';

  @override
  String get importFromGoogleCalendar => 'Importer depuis Google Calendar';

  @override
  String get importAsSession => 'Session';

  @override
  String get importAsUnavailability => 'Indispo';

  @override
  String get skipImport => 'Ignorer';

  @override
  String get selectArtistForSession => 'Sélectionner un artiste';

  @override
  String get createExternalArtist => 'Artiste externe';

  @override
  String get externalArtistName => 'Nom de l\'artiste';

  @override
  String get externalArtistHint => 'Nom de l\'artiste externe...';

  @override
  String importSummary(int sessions, int unavailabilities) {
    return '$sessions sessions, $unavailabilities indispos';
  }

  @override
  String get importButton => 'Importer';

  @override
  String get noEventsToImport => 'Aucun événement à importer';

  @override
  String eventsToReview(int count) {
    return '$count événements à traiter';
  }

  @override
  String importSuccessMessage(int sessions, int unavailabilities) {
    return 'Import réussi ! $sessions sessions et $unavailabilities indisponibilités créées.';
  }

  @override
  String get allDay => 'Toute la journée';

  @override
  String get selectAnArtist => 'Choisir un artiste';

  @override
  String get orCreateExternal => 'ou créer un artiste externe';

  @override
  String get reviewAndImport => 'Vérifier et importer';

  @override
  String get dateRange => 'Plage de dates';

  @override
  String get selectDateRange => 'Sélectionner une plage de dates';

  @override
  String get tryChangingDateRange => 'Essayez de modifier la plage de dates';

  @override
  String get changeDateRange => 'Modifier les dates';

  @override
  String get tipsSectionCalendar => 'Calendrier';

  @override
  String get tipConnectCalendarTitle => 'Connectez votre calendrier';

  @override
  String get tipConnectCalendarDesc =>
      'Liez votre Google Calendar pour synchroniser vos événements. Allez dans Réglages > Calendrier pour connecter votre compte Google.';

  @override
  String get tipImportEventsTitle => 'Importez vos événements';

  @override
  String get tipImportEventsDesc =>
      'Utilisez \"Vérifier et importer\" pour récupérer vos événements Google Calendar et les catégoriser comme sessions ou indisponibilités.';

  @override
  String get tipCategorizeEventsTitle => 'Catégorisez vos événements';

  @override
  String get tipCategorizeEventsDesc =>
      'Pour chaque événement importé, choisissez : Session (avec artiste), Indispo (bloquer le créneau), ou Ignorer. Les sessions sont créées en statut \"En attente\".';

  @override
  String get allNotificationsMarkedAsRead =>
      'Toutes les notifications ont été marquées comme lues';

  @override
  String get comingSoon => 'Prochainement';

  @override
  String get onboardingWelcomeTitle => 'Bienvenue sur Use Me';

  @override
  String get onboardingWelcomeDesc =>
      'Votre plateforme de réservation de studios d\'enregistrement';

  @override
  String get onboardingStudioSessionsTitle => 'Gérez vos réservations';

  @override
  String get onboardingStudioSessionsDesc =>
      'Planifiez vos sessions, gérez votre calendrier et suivez votre activité en temps réel';

  @override
  String get onboardingStudioTeamTitle => 'Constituez votre équipe';

  @override
  String get onboardingStudioTeamDesc =>
      'Invitez des ingénieurs du son et gérez les artistes de votre studio';

  @override
  String get onboardingEngineerSessionsTitle =>
      'Vos sessions d\'un coup d\'œil';

  @override
  String get onboardingEngineerSessionsDesc =>
      'Consultez votre planning et suivez vos sessions en cours';

  @override
  String get onboardingEngineerAvailabilityTitle => 'Gérez vos disponibilités';

  @override
  String get onboardingEngineerAvailabilityDesc =>
      'Définissez vos horaires et congés pour une meilleure organisation';

  @override
  String get onboardingArtistSearchTitle => 'Trouvez le studio parfait';

  @override
  String get onboardingArtistSearchDesc =>
      'Explorez les studios près de chez vous et comparez leurs services';

  @override
  String get onboardingArtistBookingTitle => 'Réservez facilement';

  @override
  String get onboardingArtistBookingDesc =>
      'Demandez des sessions en quelques clics et gérez vos réservations';

  @override
  String get onboardingAITitle => 'Votre assistant IA';

  @override
  String get onboardingAIDesc =>
      'Posez vos questions et obtenez de l\'aide instantanément';

  @override
  String get onboardingReadyTitle => 'Vous êtes prêt !';

  @override
  String get onboardingReadyDesc =>
      'Commencez à utiliser Use Me dès maintenant';

  @override
  String get onboardingSkip => 'Passer';

  @override
  String get onboardingNext => 'Suivant';

  @override
  String get onboardingGetStarted => 'Commencer';

  @override
  String get onboardingLocationTitle => 'Activez la localisation';

  @override
  String get onboardingLocationDescArtist =>
      'Pour trouver les studios près de chez vous';

  @override
  String get onboardingLocationDescStudio =>
      'Pour que les artistes puissent vous trouver';

  @override
  String get onboardingEnableLocation => 'Activer';

  @override
  String get onboardingLater => 'Plus tard';

  @override
  String get onboardingLocationGranted => 'Localisation activée';

  @override
  String get onboardingNotificationTitle => 'Restez informé';

  @override
  String get onboardingNotificationDesc =>
      'Recevez des alertes pour vos sessions et messages';

  @override
  String get onboardingEnableNotifications => 'Activer';

  @override
  String get onboardingNotificationGranted => 'Notifications activées';

  @override
  String get onboardingTermsTitle => 'Conditions d\'utilisation';

  @override
  String get onboardingTermsDesc =>
      'Pour utiliser Use Me, vous devez accepter nos conditions d\'utilisation et notre politique de confidentialité.';

  @override
  String get onboardingTermsAccept =>
      'J\'accepte les CGU et la Politique de confidentialité';

  @override
  String get onboardingTermsLink => 'Lire les conditions';

  @override
  String get onboardingPrivacyLink => 'Politique de confidentialité';

  @override
  String get onboardingLetsGo => 'C\'est parti !';

  @override
  String get searchAddressHint => 'Rechercher une ville, une adresse...';

  @override
  String get searchInThisZone => 'Rechercher dans cette zone';

  @override
  String get filterStudios => 'Filtrer les studios';

  @override
  String get filterDescription => 'Affinez votre recherche';

  @override
  String get filterActive => 'Actif';

  @override
  String get partnerStudiosOnly => 'Studios partenaires uniquement';

  @override
  String get partnerStudiosDescription =>
      'Afficher uniquement les studios vérifiés';

  @override
  String get serviceTypes => 'Types de services';

  @override
  String get clearFilters => 'Effacer';

  @override
  String get applyFilters => 'Appliquer';

  @override
  String get filterSessions => 'Filtrer les sessions';

  @override
  String get filterSessionsDescription => 'Affinez votre planning';

  @override
  String get statusLabel => 'Statut';

  @override
  String get studioLabel => 'Studio';

  @override
  String get addToCalendar => 'Ajouter au calendrier';

  @override
  String get addedToCalendar => 'Session ajoutée au calendrier';

  @override
  String sessionCalendarTitle(Object type) {
    return 'Session $type - Use Me';
  }

  @override
  String get studioTypePro => 'Studio Pro';

  @override
  String get studioTypeIndependent => 'Indépendant';

  @override
  String get studioTypeAmateur => 'Home Studio';

  @override
  String get studioTypeLabel => 'Type de studio';

  @override
  String get connectedDevices => 'Appareils connectés';

  @override
  String get thisDevice => 'Cet appareil';

  @override
  String get disconnectDevice => 'Déconnecter';

  @override
  String get disconnectAllOthers => 'Déconnecter tous les autres appareils';

  @override
  String get disconnectDeviceTitle => 'Déconnecter l\'appareil';

  @override
  String get disconnectDeviceConfirm =>
      'Voulez-vous déconnecter cet appareil ?';

  @override
  String get disconnectAllConfirm =>
      'Voulez-vous déconnecter tous les autres appareils ?';

  @override
  String get deviceDisconnected => 'Appareil déconnecté';

  @override
  String get allDevicesDisconnected =>
      'Tous les autres appareils ont été déconnectés';

  @override
  String get activeNow => 'Actif maintenant';

  @override
  String activeAgo(String time) {
    return 'Actif il y a $time';
  }

  @override
  String get noConnectedDevices => 'Aucun appareil connecté';

  @override
  String get securitySection => 'Sécurité';

  @override
  String get manageDevices => 'Gérer les appareils';

  @override
  String get sessionExpired => 'Votre session a expiré';

  @override
  String get disconnectedRemotely =>
      'Vous avez été déconnecté depuis un autre appareil';
}
