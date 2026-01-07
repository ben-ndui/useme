import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appName.
  ///
  /// In fr, this message translates to:
  /// **'Use Me'**
  String get appName;

  /// No description provided for @settings.
  ///
  /// In fr, this message translates to:
  /// **'Réglages'**
  String get settings;

  /// No description provided for @profile.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get profile;

  /// No description provided for @myProfile.
  ///
  /// In fr, this message translates to:
  /// **'Mon profil'**
  String get myProfile;

  /// No description provided for @personalInfo.
  ///
  /// In fr, this message translates to:
  /// **'Informations personnelles'**
  String get personalInfo;

  /// No description provided for @application.
  ///
  /// In fr, this message translates to:
  /// **'Application'**
  String get application;

  /// No description provided for @account.
  ///
  /// In fr, this message translates to:
  /// **'Compte'**
  String get account;

  /// No description provided for @emailPassword.
  ///
  /// In fr, this message translates to:
  /// **'Email, mot de passe'**
  String get emailPassword;

  /// No description provided for @about.
  ///
  /// In fr, this message translates to:
  /// **'À propos'**
  String get about;

  /// No description provided for @versionLegal.
  ///
  /// In fr, this message translates to:
  /// **'Version, mentions légales'**
  String get versionLegal;

  /// No description provided for @logout.
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion'**
  String get logout;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous vraiment vous déconnecter ?'**
  String get logoutConfirmMessage;

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @notifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notificationsEnabled.
  ///
  /// In fr, this message translates to:
  /// **'Activées'**
  String get notificationsEnabled;

  /// No description provided for @notificationsDisabled.
  ///
  /// In fr, this message translates to:
  /// **'Désactivées'**
  String get notificationsDisabled;

  /// No description provided for @notificationsMuted.
  ///
  /// In fr, this message translates to:
  /// **'Notifications silencieuses'**
  String get notificationsMuted;

  /// No description provided for @enableNotificationsInSettings.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez autoriser les notifications dans les réglages'**
  String get enableNotificationsInSettings;

  /// No description provided for @rememberEmail.
  ///
  /// In fr, this message translates to:
  /// **'Mémoriser l\'email'**
  String get rememberEmail;

  /// No description provided for @rememberEmailEnabled.
  ///
  /// In fr, this message translates to:
  /// **'Email pré-rempli à la connexion'**
  String get rememberEmailEnabled;

  /// No description provided for @rememberEmailDisabled.
  ///
  /// In fr, this message translates to:
  /// **'Email non mémorisé'**
  String get rememberEmailDisabled;

  /// No description provided for @appearance.
  ///
  /// In fr, this message translates to:
  /// **'Apparence'**
  String get appearance;

  /// No description provided for @themeLight.
  ///
  /// In fr, this message translates to:
  /// **'Clair'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In fr, this message translates to:
  /// **'Sombre'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In fr, this message translates to:
  /// **'Système'**
  String get themeSystem;

  /// No description provided for @themeLightSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Thème lumineux'**
  String get themeLightSubtitle;

  /// No description provided for @themeDarkSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Thème sombre'**
  String get themeDarkSubtitle;

  /// No description provided for @themeSystemSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Suit les réglages de l\'appareil'**
  String get themeSystemSubtitle;

  /// No description provided for @language.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get language;

  /// No description provided for @languageFrench.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @languageEnglish.
  ///
  /// In fr, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSystem.
  ///
  /// In fr, this message translates to:
  /// **'Système'**
  String get languageSystem;

  /// No description provided for @languageSystemSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Suit les réglages de l\'appareil'**
  String get languageSystemSubtitle;

  /// No description provided for @userGuide.
  ///
  /// In fr, this message translates to:
  /// **'Guide d\'utilisation'**
  String get userGuide;

  /// No description provided for @tipsAndAdvice.
  ///
  /// In fr, this message translates to:
  /// **'Astuces et conseils'**
  String get tipsAndAdvice;

  /// No description provided for @artistGuide.
  ///
  /// In fr, this message translates to:
  /// **'Guide artiste'**
  String get artistGuide;

  /// No description provided for @engineerGuide.
  ///
  /// In fr, this message translates to:
  /// **'Guide ingénieur'**
  String get engineerGuide;

  /// No description provided for @studioGuide.
  ///
  /// In fr, this message translates to:
  /// **'Guide studio'**
  String get studioGuide;

  /// No description provided for @messages.
  ///
  /// In fr, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @noConversations.
  ///
  /// In fr, this message translates to:
  /// **'Aucune conversation'**
  String get noConversations;

  /// No description provided for @startNewConversation.
  ///
  /// In fr, this message translates to:
  /// **'Commencez une nouvelle conversation'**
  String get startNewConversation;

  /// No description provided for @newMessage.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau message'**
  String get newMessage;

  /// No description provided for @loading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In fr, this message translates to:
  /// **'Erreur'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get retry;

  /// No description provided for @conversationSettings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get conversationSettings;

  /// No description provided for @viewProfile.
  ///
  /// In fr, this message translates to:
  /// **'Voir le profil'**
  String get viewProfile;

  /// No description provided for @viewParticipants.
  ///
  /// In fr, this message translates to:
  /// **'Voir les participants'**
  String get viewParticipants;

  /// No description provided for @information.
  ///
  /// In fr, this message translates to:
  /// **'Informations'**
  String get information;

  /// No description provided for @block.
  ///
  /// In fr, this message translates to:
  /// **'Bloquer'**
  String get block;

  /// No description provided for @blockContact.
  ///
  /// In fr, this message translates to:
  /// **'Bloquer ce contact'**
  String get blockContact;

  /// No description provided for @blockConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Bloquer'**
  String get blockConfirmTitle;

  /// No description provided for @blockConfirmMessage.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous bloquer {name} ? Vous ne recevrez plus de messages de ce contact.'**
  String blockConfirmMessage(String name);

  /// No description provided for @blocked.
  ///
  /// In fr, this message translates to:
  /// **'{name} a été bloqué'**
  String blocked(String name);

  /// No description provided for @report.
  ///
  /// In fr, this message translates to:
  /// **'Signaler'**
  String get report;

  /// No description provided for @reportProblem.
  ///
  /// In fr, this message translates to:
  /// **'Signaler un problème'**
  String get reportProblem;

  /// No description provided for @reportConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Signaler'**
  String get reportConfirmTitle;

  /// No description provided for @reportConfirmMessage.
  ///
  /// In fr, this message translates to:
  /// **'Pourquoi souhaitez-vous signaler cette conversation ?'**
  String get reportConfirmMessage;

  /// No description provided for @reportSent.
  ///
  /// In fr, this message translates to:
  /// **'Signalement envoyé'**
  String get reportSent;

  /// No description provided for @leaveConversation.
  ///
  /// In fr, this message translates to:
  /// **'Quitter la conversation'**
  String get leaveConversation;

  /// No description provided for @deleteFromList.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer de votre liste'**
  String get deleteFromList;

  /// No description provided for @leaveConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Quitter la conversation'**
  String get leaveConfirmTitle;

  /// No description provided for @leaveConfirmMessage.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous quitter la conversation avec {name} ? L\'historique sera supprimé.'**
  String leaveConfirmMessage(String name);

  /// No description provided for @leave.
  ///
  /// In fr, this message translates to:
  /// **'Quitter'**
  String get leave;

  /// No description provided for @actions.
  ///
  /// In fr, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @accountSettings.
  ///
  /// In fr, this message translates to:
  /// **'Compte'**
  String get accountSettings;

  /// No description provided for @credentials.
  ///
  /// In fr, this message translates to:
  /// **'Identifiants'**
  String get credentials;

  /// No description provided for @email.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @notAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Non disponible'**
  String get notAvailable;

  /// No description provided for @changePassword.
  ///
  /// In fr, this message translates to:
  /// **'Changer le mot de passe'**
  String get changePassword;

  /// No description provided for @sendResetEmail.
  ///
  /// In fr, this message translates to:
  /// **'Recevoir un email de réinitialisation'**
  String get sendResetEmail;

  /// No description provided for @emailSentTo.
  ///
  /// In fr, this message translates to:
  /// **'Email envoyé à {email}'**
  String emailSentTo(String email);

  /// No description provided for @sendError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de l\'envoi'**
  String get sendError;

  /// No description provided for @dangerZone.
  ///
  /// In fr, this message translates to:
  /// **'Zone de danger'**
  String get dangerZone;

  /// No description provided for @deleteAccount.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer mon compte'**
  String get deleteAccount;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In fr, this message translates to:
  /// **'Cette action est irréversible'**
  String get deleteAccountWarning;

  /// No description provided for @deleteAccountConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le compte'**
  String get deleteAccountConfirmTitle;

  /// No description provided for @deleteAccountConfirmMessage.
  ///
  /// In fr, this message translates to:
  /// **'Êtes-vous sûr de vouloir supprimer votre compte ? Toutes vos données seront perdues. Cette action est irréversible.'**
  String get deleteAccountConfirmMessage;

  /// No description provided for @delete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get delete;

  /// No description provided for @confirmDeletion.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer la suppression'**
  String get confirmDeletion;

  /// No description provided for @enterPassword.
  ///
  /// In fr, this message translates to:
  /// **'Entrez votre mot de passe pour confirmer :'**
  String get enterPassword;

  /// No description provided for @password.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get password;

  /// No description provided for @confirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get confirm;

  /// No description provided for @deletionError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la suppression'**
  String get deletionError;

  /// No description provided for @studio.
  ///
  /// In fr, this message translates to:
  /// **'Studio'**
  String get studio;

  /// No description provided for @studioProfile.
  ///
  /// In fr, this message translates to:
  /// **'Profil studio'**
  String get studioProfile;

  /// No description provided for @nameAddressContact.
  ///
  /// In fr, this message translates to:
  /// **'Nom, adresse, contact'**
  String get nameAddressContact;

  /// No description provided for @services.
  ///
  /// In fr, this message translates to:
  /// **'Services'**
  String get services;

  /// No description provided for @serviceCatalog.
  ///
  /// In fr, this message translates to:
  /// **'Catalogue des prestations'**
  String get serviceCatalog;

  /// No description provided for @team.
  ///
  /// In fr, this message translates to:
  /// **'Équipe'**
  String get team;

  /// No description provided for @manageEngineers.
  ///
  /// In fr, this message translates to:
  /// **'Gérer les ingénieurs'**
  String get manageEngineers;

  /// No description provided for @paymentMethods.
  ///
  /// In fr, this message translates to:
  /// **'Moyens de paiement'**
  String get paymentMethods;

  /// No description provided for @paymentMethodsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Espèces, virement, PayPal...'**
  String get paymentMethodsSubtitle;

  /// No description provided for @aiAssistant.
  ///
  /// In fr, this message translates to:
  /// **'Assistant IA'**
  String get aiAssistant;

  /// No description provided for @aiSettingsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Configurer les réponses automatiques'**
  String get aiSettingsSubtitle;

  /// No description provided for @visibility.
  ///
  /// In fr, this message translates to:
  /// **'Visibilité'**
  String get visibility;

  /// No description provided for @studioVisible.
  ///
  /// In fr, this message translates to:
  /// **'Studio visible'**
  String get studioVisible;

  /// No description provided for @artistsCanSee.
  ///
  /// In fr, this message translates to:
  /// **'Les artistes peuvent voir votre studio et vous envoyer des demandes de session.'**
  String get artistsCanSee;

  /// No description provided for @edit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get edit;

  /// No description provided for @becomeVisible.
  ///
  /// In fr, this message translates to:
  /// **'Rendez-vous visible'**
  String get becomeVisible;

  /// No description provided for @artistsCantFind.
  ///
  /// In fr, this message translates to:
  /// **'Les artistes ne peuvent pas encore vous trouver'**
  String get artistsCantFind;

  /// No description provided for @claimStudio.
  ///
  /// In fr, this message translates to:
  /// **'Revendiquez votre studio pour apparaître sur la carte et recevoir des demandes de session.'**
  String get claimStudio;

  /// No description provided for @calendar.
  ///
  /// In fr, this message translates to:
  /// **'Calendrier'**
  String get calendar;

  /// No description provided for @availability.
  ///
  /// In fr, this message translates to:
  /// **'Disponibilités'**
  String get availability;

  /// No description provided for @manageSlots.
  ///
  /// In fr, this message translates to:
  /// **'Gérer mes créneaux'**
  String get manageSlots;

  /// No description provided for @participants.
  ///
  /// In fr, this message translates to:
  /// **'{count} participants'**
  String participants(int count);

  /// No description provided for @copy.
  ///
  /// In fr, this message translates to:
  /// **'Copier'**
  String get copy;

  /// No description provided for @deleteMessage.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get deleteMessage;

  /// No description provided for @version.
  ///
  /// In fr, this message translates to:
  /// **'Use Me v{version}'**
  String version(String version);

  /// No description provided for @studiosPlatform.
  ///
  /// In fr, this message translates to:
  /// **'La plateforme des studios'**
  String get studiosPlatform;

  /// No description provided for @versionBuild.
  ///
  /// In fr, this message translates to:
  /// **'Version {version} ({build})'**
  String versionBuild(String version, String build);

  /// No description provided for @legalInfo.
  ///
  /// In fr, this message translates to:
  /// **'Informations légales'**
  String get legalInfo;

  /// No description provided for @termsOfService.
  ///
  /// In fr, this message translates to:
  /// **'Conditions d\'utilisation'**
  String get termsOfService;

  /// No description provided for @privacyPolicy.
  ///
  /// In fr, this message translates to:
  /// **'Politique de confidentialité'**
  String get privacyPolicy;

  /// No description provided for @legalNotices.
  ///
  /// In fr, this message translates to:
  /// **'Mentions légales'**
  String get legalNotices;

  /// No description provided for @support.
  ///
  /// In fr, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @helpCenter.
  ///
  /// In fr, this message translates to:
  /// **'Centre d\'aide'**
  String get helpCenter;

  /// No description provided for @contactUs.
  ///
  /// In fr, this message translates to:
  /// **'Nous contacter'**
  String get contactUs;

  /// No description provided for @followUs.
  ///
  /// In fr, this message translates to:
  /// **'Suivez-nous'**
  String get followUs;

  /// No description provided for @copyright.
  ///
  /// In fr, this message translates to:
  /// **'© {year} Use Me. Tous droits réservés.'**
  String copyright(String year);

  /// No description provided for @archive.
  ///
  /// In fr, this message translates to:
  /// **'Archiver'**
  String get archive;

  /// No description provided for @unarchive.
  ///
  /// In fr, this message translates to:
  /// **'Désarchiver'**
  String get unarchive;

  /// No description provided for @mySessions.
  ///
  /// In fr, this message translates to:
  /// **'Mes sessions'**
  String get mySessions;

  /// No description provided for @book.
  ///
  /// In fr, this message translates to:
  /// **'Réserver'**
  String get book;

  /// No description provided for @noSession.
  ///
  /// In fr, this message translates to:
  /// **'Pas de session'**
  String get noSession;

  /// No description provided for @enjoyYourDay.
  ///
  /// In fr, this message translates to:
  /// **'Profitez de votre journée !'**
  String get enjoyYourDay;

  /// No description provided for @inProgressStatus.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get inProgressStatus;

  /// No description provided for @upcomingStatus.
  ///
  /// In fr, this message translates to:
  /// **'À venir'**
  String get upcomingStatus;

  /// No description provided for @pastStatus.
  ///
  /// In fr, this message translates to:
  /// **'Passées'**
  String get pastStatus;

  /// No description provided for @noSessions.
  ///
  /// In fr, this message translates to:
  /// **'Aucune session'**
  String get noSessions;

  /// No description provided for @bookFirstSession.
  ///
  /// In fr, this message translates to:
  /// **'Réservez votre première session'**
  String get bookFirstSession;

  /// No description provided for @pendingStatus.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get pendingStatus;

  /// No description provided for @confirmedStatus.
  ///
  /// In fr, this message translates to:
  /// **'Confirmée'**
  String get confirmedStatus;

  /// No description provided for @completedStatus.
  ///
  /// In fr, this message translates to:
  /// **'Terminée'**
  String get completedStatus;

  /// No description provided for @cancelledStatus.
  ///
  /// In fr, this message translates to:
  /// **'Annulée'**
  String get cancelledStatus;

  /// No description provided for @noShowStatus.
  ///
  /// In fr, this message translates to:
  /// **'Absent'**
  String get noShowStatus;

  /// No description provided for @hoursOfSession.
  ///
  /// In fr, this message translates to:
  /// **'{hours}h de session'**
  String hoursOfSession(int hours);

  /// No description provided for @sessionAt.
  ///
  /// In fr, this message translates to:
  /// **'Session chez {studio}'**
  String sessionAt(String studio);

  /// No description provided for @sessionRequest.
  ///
  /// In fr, this message translates to:
  /// **'Demande de session'**
  String get sessionRequest;

  /// No description provided for @noStudioSelected.
  ///
  /// In fr, this message translates to:
  /// **'Aucun studio sélectionné'**
  String get noStudioSelected;

  /// No description provided for @selectStudioFirst.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez d\'abord un studio pour voir ses disponibilités.'**
  String get selectStudioFirst;

  /// No description provided for @back.
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get back;

  /// No description provided for @sessionType.
  ///
  /// In fr, this message translates to:
  /// **'Type de session'**
  String get sessionType;

  /// No description provided for @sessionDuration.
  ///
  /// In fr, this message translates to:
  /// **'Durée de la session'**
  String get sessionDuration;

  /// No description provided for @chooseSlot.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez votre créneau'**
  String get chooseSlot;

  /// No description provided for @engineerPreference.
  ///
  /// In fr, this message translates to:
  /// **'Préférence d\'ingénieur'**
  String get engineerPreference;

  /// No description provided for @notesOptional.
  ///
  /// In fr, this message translates to:
  /// **'Notes (optionnel)'**
  String get notesOptional;

  /// No description provided for @describeProject.
  ///
  /// In fr, this message translates to:
  /// **'Décrivez votre projet, vos besoins...'**
  String get describeProject;

  /// No description provided for @sendRequest.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer la demande'**
  String get sendRequest;

  /// No description provided for @summaryLabel.
  ///
  /// In fr, this message translates to:
  /// **'Récapitulatif'**
  String get summaryLabel;

  /// No description provided for @noPreference.
  ///
  /// In fr, this message translates to:
  /// **'Pas de préférence'**
  String get noPreference;

  /// No description provided for @engineerSelectedLabel.
  ///
  /// In fr, this message translates to:
  /// **'Ingénieur sélectionné'**
  String get engineerSelectedLabel;

  /// No description provided for @letStudioChoose.
  ///
  /// In fr, this message translates to:
  /// **'Laisser le studio choisir'**
  String get letStudioChoose;

  /// No description provided for @availableCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} dispo'**
  String availableCount(int count);

  /// No description provided for @requestSent.
  ///
  /// In fr, this message translates to:
  /// **'Demande envoyée ! Le studio vous répondra bientôt.'**
  String get requestSent;

  /// No description provided for @slotInfoText.
  ///
  /// In fr, this message translates to:
  /// **'Les créneaux verts ont plus d\'ingénieurs disponibles. Vous pouvez aussi choisir votre ingénieur préféré.'**
  String get slotInfoText;

  /// No description provided for @engineer.
  ///
  /// In fr, this message translates to:
  /// **'Ingénieur'**
  String get engineer;

  /// No description provided for @notSpecified.
  ///
  /// In fr, this message translates to:
  /// **'Non spécifié'**
  String get notSpecified;

  /// No description provided for @goodMorning.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In fr, this message translates to:
  /// **'Bon après-midi'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In fr, this message translates to:
  /// **'Bonsoir'**
  String get goodEvening;

  /// No description provided for @quickAccess.
  ///
  /// In fr, this message translates to:
  /// **'Accès rapide'**
  String get quickAccess;

  /// No description provided for @sessionsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Sessions'**
  String get sessionsLabel;

  /// No description provided for @favoritesLabel.
  ///
  /// In fr, this message translates to:
  /// **'Favoris'**
  String get favoritesLabel;

  /// No description provided for @preferencesLabel.
  ///
  /// In fr, this message translates to:
  /// **'Préférences'**
  String get preferencesLabel;

  /// No description provided for @upcomingSessions.
  ///
  /// In fr, this message translates to:
  /// **'Sessions à venir'**
  String get upcomingSessions;

  /// No description provided for @viewAll.
  ///
  /// In fr, this message translates to:
  /// **'Voir tout'**
  String get viewAll;

  /// No description provided for @noUpcomingSessions.
  ///
  /// In fr, this message translates to:
  /// **'Aucune session prévue'**
  String get noUpcomingSessions;

  /// No description provided for @bookNextSession.
  ///
  /// In fr, this message translates to:
  /// **'Réserve ta prochaine session en studio'**
  String get bookNextSession;

  /// No description provided for @recentActivity.
  ///
  /// In fr, this message translates to:
  /// **'Activité récente'**
  String get recentActivity;

  /// No description provided for @noHistory.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore d\'historique'**
  String get noHistory;

  /// No description provided for @completedSessionsHere.
  ///
  /// In fr, this message translates to:
  /// **'Tes sessions terminées apparaîtront ici'**
  String get completedSessionsHere;

  /// No description provided for @waitingStatus.
  ///
  /// In fr, this message translates to:
  /// **'Attente'**
  String get waitingStatus;

  /// No description provided for @todaySessions.
  ///
  /// In fr, this message translates to:
  /// **'Sessions du jour'**
  String get todaySessions;

  /// No description provided for @today.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get today;

  /// No description provided for @noSessionToday.
  ///
  /// In fr, this message translates to:
  /// **'Pas de session aujourd\'hui'**
  String get noSessionToday;

  /// No description provided for @noSessionsPlanned.
  ///
  /// In fr, this message translates to:
  /// **'Aucune session prévue'**
  String get noSessionsPlanned;

  /// No description provided for @noAssignedSessions.
  ///
  /// In fr, this message translates to:
  /// **'Vous n\'avez pas de sessions assignées'**
  String get noAssignedSessions;

  /// No description provided for @notConnected.
  ///
  /// In fr, this message translates to:
  /// **'Non connecté'**
  String get notConnected;

  /// No description provided for @myAvailabilities.
  ///
  /// In fr, this message translates to:
  /// **'Mes disponibilités'**
  String get myAvailabilities;

  /// No description provided for @workingHours.
  ///
  /// In fr, this message translates to:
  /// **'Horaires de travail'**
  String get workingHours;

  /// No description provided for @unavailabilities.
  ///
  /// In fr, this message translates to:
  /// **'Indispos'**
  String get unavailabilities;

  /// No description provided for @add.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get add;

  /// No description provided for @noTimeOff.
  ///
  /// In fr, this message translates to:
  /// **'Aucune indisponibilité'**
  String get noTimeOff;

  /// No description provided for @addTimeOffHint.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez vos vacances, congés ou absences'**
  String get addTimeOffHint;

  /// No description provided for @myStudio.
  ///
  /// In fr, this message translates to:
  /// **'Mon Studio'**
  String get myStudio;

  /// No description provided for @overview.
  ///
  /// In fr, this message translates to:
  /// **'Vue d\'ensemble'**
  String get overview;

  /// No description provided for @session.
  ///
  /// In fr, this message translates to:
  /// **'Session'**
  String get session;

  /// No description provided for @artist.
  ///
  /// In fr, this message translates to:
  /// **'Artiste'**
  String get artist;

  /// No description provided for @artists.
  ///
  /// In fr, this message translates to:
  /// **'Artistes'**
  String get artists;

  /// No description provided for @artistsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Artistes'**
  String get artistsLabel;

  /// No description provided for @planning.
  ///
  /// In fr, this message translates to:
  /// **'Planning'**
  String get planning;

  /// No description provided for @stats.
  ///
  /// In fr, this message translates to:
  /// **'Stats'**
  String get stats;

  /// No description provided for @thisMonth.
  ///
  /// In fr, this message translates to:
  /// **'Ce mois'**
  String get thisMonth;

  /// No description provided for @freeDay.
  ///
  /// In fr, this message translates to:
  /// **'Journée libre'**
  String get freeDay;

  /// No description provided for @noSessionScheduled.
  ///
  /// In fr, this message translates to:
  /// **'Aucune session programmée'**
  String get noSessionScheduled;

  /// No description provided for @pendingRequests.
  ///
  /// In fr, this message translates to:
  /// **'Demandes en attente'**
  String get pendingRequests;

  /// No description provided for @recentArtists.
  ///
  /// In fr, this message translates to:
  /// **'Artistes récents'**
  String get recentArtists;

  /// No description provided for @filterByStatus.
  ///
  /// In fr, this message translates to:
  /// **'Filtrer par statut'**
  String get filterByStatus;

  /// No description provided for @all.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get all;

  /// No description provided for @confirmed.
  ///
  /// In fr, this message translates to:
  /// **'Confirmées'**
  String get confirmed;

  /// No description provided for @sessionCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} session'**
  String sessionCount(int count);

  /// No description provided for @sessionsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} sessions'**
  String sessionsCount(int count);

  /// No description provided for @noSessionThisDay.
  ///
  /// In fr, this message translates to:
  /// **'Pas de session ce jour'**
  String get noSessionThisDay;

  /// No description provided for @noSessionTodayScheduled.
  ///
  /// In fr, this message translates to:
  /// **'Aucune session programmée aujourd\'hui'**
  String get noSessionTodayScheduled;

  /// No description provided for @scheduleSession.
  ///
  /// In fr, this message translates to:
  /// **'Planifier une session'**
  String get scheduleSession;

  /// No description provided for @serviceCatalogTitle.
  ///
  /// In fr, this message translates to:
  /// **'Catalogue services'**
  String get serviceCatalogTitle;

  /// No description provided for @noService.
  ///
  /// In fr, this message translates to:
  /// **'Aucun service'**
  String get noService;

  /// No description provided for @createServiceCatalog.
  ///
  /// In fr, this message translates to:
  /// **'Créez votre catalogue de services'**
  String get createServiceCatalog;

  /// No description provided for @newService.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau service'**
  String get newService;

  /// No description provided for @active.
  ///
  /// In fr, this message translates to:
  /// **'Actif'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In fr, this message translates to:
  /// **'Inactif'**
  String get inactive;

  /// No description provided for @rooms.
  ///
  /// In fr, this message translates to:
  /// **'Salles'**
  String get rooms;

  /// No description provided for @noRooms.
  ///
  /// In fr, this message translates to:
  /// **'Aucune salle'**
  String get noRooms;

  /// No description provided for @createRoomsHint.
  ///
  /// In fr, this message translates to:
  /// **'Configurez les salles de votre studio'**
  String get createRoomsHint;

  /// No description provided for @addRoom.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une salle'**
  String get addRoom;

  /// No description provided for @editRoom.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la salle'**
  String get editRoom;

  /// No description provided for @roomName.
  ///
  /// In fr, this message translates to:
  /// **'Nom de la salle'**
  String get roomName;

  /// No description provided for @roomNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex: Studio A, Cabine 1...'**
  String get roomNameHint;

  /// No description provided for @roomDescriptionHint.
  ///
  /// In fr, this message translates to:
  /// **'Décrivez la salle et ses caractéristiques'**
  String get roomDescriptionHint;

  /// No description provided for @accessType.
  ///
  /// In fr, this message translates to:
  /// **'Type d\'accès'**
  String get accessType;

  /// No description provided for @withEngineer.
  ///
  /// In fr, this message translates to:
  /// **'Avec ingénieur'**
  String get withEngineer;

  /// No description provided for @withEngineerDesc.
  ///
  /// In fr, this message translates to:
  /// **'Ingénieur son requis'**
  String get withEngineerDesc;

  /// No description provided for @selfService.
  ///
  /// In fr, this message translates to:
  /// **'Libre accès'**
  String get selfService;

  /// No description provided for @selfServiceDesc.
  ///
  /// In fr, this message translates to:
  /// **'Sans ingénieur'**
  String get selfServiceDesc;

  /// No description provided for @equipment.
  ///
  /// In fr, this message translates to:
  /// **'Équipements'**
  String get equipment;

  /// No description provided for @equipmentHint.
  ///
  /// In fr, this message translates to:
  /// **'Micro, console, enceintes... (séparés par virgule)'**
  String get equipmentHint;

  /// No description provided for @roomActive.
  ///
  /// In fr, this message translates to:
  /// **'Salle active'**
  String get roomActive;

  /// No description provided for @roomVisibleForBooking.
  ///
  /// In fr, this message translates to:
  /// **'Visible pour les réservations'**
  String get roomVisibleForBooking;

  /// No description provided for @roomHiddenForBooking.
  ///
  /// In fr, this message translates to:
  /// **'Masquée des réservations'**
  String get roomHiddenForBooking;

  /// No description provided for @deleteRoom.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la salle'**
  String get deleteRoom;

  /// No description provided for @deleteRoomConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous vraiment supprimer cette salle ?'**
  String get deleteRoomConfirm;

  /// No description provided for @selectRoom.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une salle'**
  String get selectRoom;

  /// No description provided for @noRoomAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Aucune salle disponible'**
  String get noRoomAvailable;

  /// No description provided for @restDay.
  ///
  /// In fr, this message translates to:
  /// **'Fermé'**
  String get restDay;

  /// No description provided for @inProgress.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get inProgress;

  /// No description provided for @upcoming.
  ///
  /// In fr, this message translates to:
  /// **'À venir'**
  String get upcoming;

  /// No description provided for @past.
  ///
  /// In fr, this message translates to:
  /// **'Passées'**
  String get past;

  /// No description provided for @listView.
  ///
  /// In fr, this message translates to:
  /// **'Vue liste'**
  String get listView;

  /// No description provided for @calendarView.
  ///
  /// In fr, this message translates to:
  /// **'Vue calendrier'**
  String get calendarView;

  /// No description provided for @deleteTimeOff.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get deleteTimeOff;

  /// No description provided for @deleteTimeOffConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer cette indisponibilité ?'**
  String get deleteTimeOffConfirm;

  /// No description provided for @daysCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} jour'**
  String daysCount(int count);

  /// No description provided for @daysCountPlural.
  ///
  /// In fr, this message translates to:
  /// **'{count} jours'**
  String daysCountPlural(int count);

  /// No description provided for @addTimeOff.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une indisponibilité'**
  String get addTimeOff;

  /// No description provided for @fromDate.
  ///
  /// In fr, this message translates to:
  /// **'Du'**
  String get fromDate;

  /// No description provided for @toDate.
  ///
  /// In fr, this message translates to:
  /// **'Au'**
  String get toDate;

  /// No description provided for @reasonOptional.
  ///
  /// In fr, this message translates to:
  /// **'Raison (optionnel)'**
  String get reasonOptional;

  /// No description provided for @enterCustomReason.
  ///
  /// In fr, this message translates to:
  /// **'Ou saisissez une raison...'**
  String get enterCustomReason;

  /// No description provided for @errorLoadingAvailability.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors du chargement des disponibilités'**
  String get errorLoadingAvailability;

  /// No description provided for @available.
  ///
  /// In fr, this message translates to:
  /// **'Dispo'**
  String get available;

  /// No description provided for @limited.
  ///
  /// In fr, this message translates to:
  /// **'Limité'**
  String get limited;

  /// No description provided for @unavailable.
  ///
  /// In fr, this message translates to:
  /// **'Indispo'**
  String get unavailable;

  /// No description provided for @slotsForDate.
  ///
  /// In fr, this message translates to:
  /// **'Créneaux du {date}'**
  String slotsForDate(String date);

  /// No description provided for @noSlotAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Aucun créneau disponible'**
  String get noSlotAvailable;

  /// No description provided for @tryAnotherDate.
  ///
  /// In fr, this message translates to:
  /// **'Essayez une autre date'**
  String get tryAnotherDate;

  /// No description provided for @fullyAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Parfaitement disponibles'**
  String get fullyAvailable;

  /// No description provided for @partiallyAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Partiellement disponibles'**
  String get partiallyAvailable;

  /// No description provided for @noEngineerAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Aucun ingénieur dispo'**
  String get noEngineerAvailable;

  /// No description provided for @studioUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Studio indisponible'**
  String get studioUnavailable;

  /// No description provided for @noEngineerTryAnotherDate.
  ///
  /// In fr, this message translates to:
  /// **'Aucun ingénieur disponible ce jour. Essayez une autre date.'**
  String get noEngineerTryAnotherDate;

  /// No description provided for @chooseEngineer.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un ingénieur'**
  String get chooseEngineer;

  /// No description provided for @availableCountLabel.
  ///
  /// In fr, this message translates to:
  /// **'{count} disponible(s)'**
  String availableCountLabel(int count);

  /// No description provided for @optionalEngineerInfo.
  ///
  /// In fr, this message translates to:
  /// **'Optionnel : laissez le studio assigner un ingénieur automatiquement'**
  String get optionalEngineerInfo;

  /// No description provided for @availableLabel.
  ///
  /// In fr, this message translates to:
  /// **'DISPONIBLES'**
  String get availableLabel;

  /// No description provided for @unavailableLabel.
  ///
  /// In fr, this message translates to:
  /// **'INDISPONIBLES'**
  String get unavailableLabel;

  /// No description provided for @studioWillAssignEngineer.
  ///
  /// In fr, this message translates to:
  /// **'Le studio assignera un ingénieur'**
  String get studioWillAssignEngineer;

  /// No description provided for @bookNextSessionSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Réservez votre prochaine session'**
  String get bookNextSessionSubtitle;

  /// No description provided for @emailHint.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get emailHint;

  /// No description provided for @emailRequired.
  ///
  /// In fr, this message translates to:
  /// **'Email requis'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Email invalide'**
  String get emailInvalid;

  /// No description provided for @passwordHint.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get passwordHint;

  /// No description provided for @passwordRequired.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe requis'**
  String get passwordRequired;

  /// No description provided for @minCharacters.
  ///
  /// In fr, this message translates to:
  /// **'Minimum {count} caractères'**
  String minCharacters(int count);

  /// No description provided for @forgotPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié ?'**
  String get forgotPassword;

  /// No description provided for @signIn.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get signIn;

  /// No description provided for @or.
  ///
  /// In fr, this message translates to:
  /// **'ou'**
  String get or;

  /// No description provided for @noAccountYet.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore de compte ?'**
  String get noAccountYet;

  /// No description provided for @signUp.
  ///
  /// In fr, this message translates to:
  /// **'S\'inscrire'**
  String get signUp;

  /// No description provided for @demoAccess.
  ///
  /// In fr, this message translates to:
  /// **'Accès démo'**
  String get demoAccess;

  /// No description provided for @enterEmailFirst.
  ///
  /// In fr, this message translates to:
  /// **'Entrez votre email d\'abord'**
  String get enterEmailFirst;

  /// No description provided for @demoMode.
  ///
  /// In fr, this message translates to:
  /// **'Mode Démo'**
  String get demoMode;

  /// No description provided for @browseWithoutLogin.
  ///
  /// In fr, this message translates to:
  /// **'Naviguer sans connexion'**
  String get browseWithoutLogin;

  /// No description provided for @studioAdmin.
  ///
  /// In fr, this message translates to:
  /// **'Studio (Admin)'**
  String get studioAdmin;

  /// No description provided for @manageSessionsArtistsServices.
  ///
  /// In fr, this message translates to:
  /// **'Gérer sessions, artistes, services'**
  String get manageSessionsArtistsServices;

  /// No description provided for @soundEngineer.
  ///
  /// In fr, this message translates to:
  /// **'Ingénieur son'**
  String get soundEngineer;

  /// No description provided for @viewAndTrackSessions.
  ///
  /// In fr, this message translates to:
  /// **'Voir et tracker les sessions'**
  String get viewAndTrackSessions;

  /// No description provided for @bookSessions.
  ///
  /// In fr, this message translates to:
  /// **'Réserver des sessions'**
  String get bookSessions;

  /// No description provided for @createAccount.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get createAccount;

  /// No description provided for @joinCommunity.
  ///
  /// In fr, this message translates to:
  /// **'Rejoignez la communauté'**
  String get joinCommunity;

  /// No description provided for @iAm.
  ///
  /// In fr, this message translates to:
  /// **'Je suis...'**
  String get iAm;

  /// No description provided for @orByEmail.
  ///
  /// In fr, this message translates to:
  /// **'ou par email'**
  String get orByEmail;

  /// No description provided for @stageNameOrName.
  ///
  /// In fr, this message translates to:
  /// **'Nom de scène ou nom'**
  String get stageNameOrName;

  /// No description provided for @fullName.
  ///
  /// In fr, this message translates to:
  /// **'Nom complet'**
  String get fullName;

  /// No description provided for @nameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Nom requis'**
  String get nameRequired;

  /// No description provided for @confirmPassword.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le mot de passe'**
  String get confirmPassword;

  /// No description provided for @confirmationRequired.
  ///
  /// In fr, this message translates to:
  /// **'Confirmation requise'**
  String get confirmationRequired;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In fr, this message translates to:
  /// **'Mots de passe différents'**
  String get passwordsDontMatch;

  /// No description provided for @createMyAccount.
  ///
  /// In fr, this message translates to:
  /// **'Créer mon compte'**
  String get createMyAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In fr, this message translates to:
  /// **'Déjà un compte ?'**
  String get alreadyHaveAccount;

  /// No description provided for @chooseYourProfile.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez votre profil'**
  String get chooseYourProfile;

  /// No description provided for @actionIsPermanent.
  ///
  /// In fr, this message translates to:
  /// **'Cette action est définitive'**
  String get actionIsPermanent;

  /// No description provided for @howToUseApp.
  ///
  /// In fr, this message translates to:
  /// **'Comment souhaitez-vous utiliser l\'app ?'**
  String get howToUseApp;

  /// No description provided for @iOwnStudio.
  ///
  /// In fr, this message translates to:
  /// **'Je possède un studio'**
  String get iOwnStudio;

  /// No description provided for @iWorkInStudio.
  ///
  /// In fr, this message translates to:
  /// **'Je travaille dans un studio'**
  String get iWorkInStudio;

  /// No description provided for @iWantToBookSessions.
  ///
  /// In fr, this message translates to:
  /// **'Je veux réserver des sessions'**
  String get iWantToBookSessions;

  /// No description provided for @acceptBooking.
  ///
  /// In fr, this message translates to:
  /// **'Accepter la réservation'**
  String get acceptBooking;

  /// No description provided for @choosePaymentMethod.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez le mode de paiement'**
  String get choosePaymentMethod;

  /// No description provided for @noPaymentMethodConfigured.
  ///
  /// In fr, this message translates to:
  /// **'Aucun moyen de paiement configuré. Allez dans Réglages > Moyens de paiement.'**
  String get noPaymentMethodConfigured;

  /// No description provided for @paymentMode.
  ///
  /// In fr, this message translates to:
  /// **'Mode de paiement'**
  String get paymentMode;

  /// No description provided for @depositRequested.
  ///
  /// In fr, this message translates to:
  /// **'Acompte demandé'**
  String get depositRequested;

  /// No description provided for @customMessageOptional.
  ///
  /// In fr, this message translates to:
  /// **'Message personnalisé (optionnel)'**
  String get customMessageOptional;

  /// No description provided for @customMessageHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex: Merci pour ta confiance !'**
  String get customMessageHint;

  /// No description provided for @totalAmount.
  ///
  /// In fr, this message translates to:
  /// **'Montant total'**
  String get totalAmount;

  /// No description provided for @depositToPay.
  ///
  /// In fr, this message translates to:
  /// **'Acompte à régler'**
  String get depositToPay;

  /// No description provided for @paymentBy.
  ///
  /// In fr, this message translates to:
  /// **'Paiement par'**
  String get paymentBy;

  /// No description provided for @ofTotalAmount.
  ///
  /// In fr, this message translates to:
  /// **'{percent}% du montant total'**
  String ofTotalAmount(int percent);

  /// No description provided for @acceptAndSendInfo.
  ///
  /// In fr, this message translates to:
  /// **'Accepter et envoyer les infos'**
  String get acceptAndSendInfo;

  /// No description provided for @welcome.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue !'**
  String get welcome;

  /// No description provided for @discoverAppFeatures.
  ///
  /// In fr, this message translates to:
  /// **'Découvrez comment tirer le meilleur de Use Me'**
  String get discoverAppFeatures;

  /// No description provided for @nearbyStudios.
  ///
  /// In fr, this message translates to:
  /// **'Studios à proximité'**
  String get nearbyStudios;

  /// No description provided for @discoverWhereToRecord.
  ///
  /// In fr, this message translates to:
  /// **'Découvre où enregistrer'**
  String get discoverWhereToRecord;

  /// No description provided for @noStudioFound.
  ///
  /// In fr, this message translates to:
  /// **'Aucun studio trouvé'**
  String get noStudioFound;

  /// No description provided for @enableLocationToDiscover.
  ///
  /// In fr, this message translates to:
  /// **'Active ta localisation pour découvrir les studios près de toi'**
  String get enableLocationToDiscover;

  /// No description provided for @partner.
  ///
  /// In fr, this message translates to:
  /// **'Partner'**
  String get partner;

  /// No description provided for @missingStudio.
  ///
  /// In fr, this message translates to:
  /// **'Studio manquant ?'**
  String get missingStudio;

  /// No description provided for @tellUsWhichStudio.
  ///
  /// In fr, this message translates to:
  /// **'Dis-nous quel studio tu cherches'**
  String get tellUsWhichStudio;

  /// No description provided for @studioName.
  ///
  /// In fr, this message translates to:
  /// **'Nom du studio'**
  String get studioName;

  /// No description provided for @studioNameExample.
  ///
  /// In fr, this message translates to:
  /// **'Ex: Studio XYZ'**
  String get studioNameExample;

  /// No description provided for @pleaseEnterStudioName.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer le nom du studio'**
  String get pleaseEnterStudioName;

  /// No description provided for @city.
  ///
  /// In fr, this message translates to:
  /// **'Ville'**
  String get city;

  /// No description provided for @cityExample.
  ///
  /// In fr, this message translates to:
  /// **'Ex: Paris, Lyon...'**
  String get cityExample;

  /// No description provided for @pleaseEnterCity.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer la ville'**
  String get pleaseEnterCity;

  /// No description provided for @notesOptionalLabel.
  ///
  /// In fr, this message translates to:
  /// **'Notes (optionnel)'**
  String get notesOptionalLabel;

  /// No description provided for @notesHint.
  ///
  /// In fr, this message translates to:
  /// **'Adresse, site web, infos utiles...'**
  String get notesHint;

  /// No description provided for @sending.
  ///
  /// In fr, this message translates to:
  /// **'Envoi en cours...'**
  String get sending;

  /// No description provided for @sendRequestLabel.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer la demande'**
  String get sendRequestLabel;

  /// No description provided for @requestSubmitted.
  ///
  /// In fr, this message translates to:
  /// **'Demande envoyée !'**
  String get requestSubmitted;

  /// No description provided for @weWillVerifyAndAddStudio.
  ///
  /// In fr, this message translates to:
  /// **'Nous allons vérifier et ajouter ce studio prochainement.'**
  String get weWillVerifyAndAddStudio;

  /// No description provided for @searchingStudios.
  ///
  /// In fr, this message translates to:
  /// **'Recherche de studios...'**
  String get searchingStudios;

  /// No description provided for @partnerLabel.
  ///
  /// In fr, this message translates to:
  /// **'Partenaire'**
  String get partnerLabel;

  /// No description provided for @newConversation.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle conversation'**
  String get newConversation;

  /// No description provided for @searchContact.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un contact...'**
  String get searchContact;

  /// No description provided for @errorLoadingContacts.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors du chargement des contacts'**
  String get errorLoadingContacts;

  /// No description provided for @user.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateur'**
  String get user;

  /// No description provided for @contact.
  ///
  /// In fr, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @noResult.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat'**
  String get noResult;

  /// No description provided for @noContactAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Aucun contact disponible'**
  String get noContactAvailable;

  /// No description provided for @myContacts.
  ///
  /// In fr, this message translates to:
  /// **'Mes contacts'**
  String get myContacts;

  /// No description provided for @searchResults.
  ///
  /// In fr, this message translates to:
  /// **'Résultats de recherche'**
  String get searchResults;

  /// No description provided for @tryOtherTerms.
  ///
  /// In fr, this message translates to:
  /// **'Essayez avec d\'autres termes'**
  String get tryOtherTerms;

  /// No description provided for @contactsWillAppearHere.
  ///
  /// In fr, this message translates to:
  /// **'Vos contacts apparaîtront ici'**
  String get contactsWillAppearHere;

  /// No description provided for @noName.
  ///
  /// In fr, this message translates to:
  /// **'Sans nom'**
  String get noName;

  /// No description provided for @searchByNameOrEmail.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher par nom ou email...'**
  String get searchByNameOrEmail;

  /// No description provided for @searchArtist.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un artiste'**
  String get searchArtist;

  /// No description provided for @typeAtLeastTwoChars.
  ///
  /// In fr, this message translates to:
  /// **'Tapez au moins 2 caractères pour rechercher parmi les artistes inscrits'**
  String get typeAtLeastTwoChars;

  /// No description provided for @noArtistFound.
  ///
  /// In fr, this message translates to:
  /// **'Aucun artiste trouvé'**
  String get noArtistFound;

  /// No description provided for @artistNotRegistered.
  ///
  /// In fr, this message translates to:
  /// **'Cet artiste n\'est pas encore inscrit. Invitez-le ou créez sa fiche manuellement.'**
  String get artistNotRegistered;

  /// No description provided for @link.
  ///
  /// In fr, this message translates to:
  /// **'Lier'**
  String get link;

  /// No description provided for @createNewArtist.
  ///
  /// In fr, this message translates to:
  /// **'Créer un nouvel artiste'**
  String get createNewArtist;

  /// No description provided for @artistNotOnApp.
  ///
  /// In fr, this message translates to:
  /// **'L\'artiste n\'est pas sur l\'app ? Créez sa fiche et invitez-le'**
  String get artistNotOnApp;

  /// No description provided for @home.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get home;

  /// No description provided for @favorites.
  ///
  /// In fr, this message translates to:
  /// **'Favoris'**
  String get favorites;

  /// No description provided for @myFavorites.
  ///
  /// In fr, this message translates to:
  /// **'Mes favoris'**
  String get myFavorites;

  /// No description provided for @studios.
  ///
  /// In fr, this message translates to:
  /// **'Studios'**
  String get studios;

  /// No description provided for @studiosLabel.
  ///
  /// In fr, this message translates to:
  /// **'Studios'**
  String get studiosLabel;

  /// No description provided for @engineers.
  ///
  /// In fr, this message translates to:
  /// **'Ingénieurs'**
  String get engineers;

  /// No description provided for @engineersLabel.
  ///
  /// In fr, this message translates to:
  /// **'Ingénieurs'**
  String get engineersLabel;

  /// No description provided for @noFavoriteStudio.
  ///
  /// In fr, this message translates to:
  /// **'Aucun studio favori'**
  String get noFavoriteStudio;

  /// No description provided for @noFavoriteStudios.
  ///
  /// In fr, this message translates to:
  /// **'Aucun studio favori'**
  String get noFavoriteStudios;

  /// No description provided for @exploreStudiosAndAddFavorites.
  ///
  /// In fr, this message translates to:
  /// **'Explorez les studios et ajoutez-les à vos favoris'**
  String get exploreStudiosAndAddFavorites;

  /// No description provided for @exploreStudiosToFavorite.
  ///
  /// In fr, this message translates to:
  /// **'Explorez les studios et ajoutez-les à vos favoris'**
  String get exploreStudiosToFavorite;

  /// No description provided for @noFavoriteEngineer.
  ///
  /// In fr, this message translates to:
  /// **'Aucun ingénieur favori'**
  String get noFavoriteEngineer;

  /// No description provided for @noFavoriteEngineers.
  ///
  /// In fr, this message translates to:
  /// **'Aucun ingénieur favori'**
  String get noFavoriteEngineers;

  /// No description provided for @discoverEngineersAndAddFavorites.
  ///
  /// In fr, this message translates to:
  /// **'Découvrez les ingénieurs et ajoutez-les à vos favoris'**
  String get discoverEngineersAndAddFavorites;

  /// No description provided for @discoverEngineersToFavorite.
  ///
  /// In fr, this message translates to:
  /// **'Découvrez les ingénieurs et ajoutez-les à vos favoris'**
  String get discoverEngineersToFavorite;

  /// No description provided for @noFavoriteArtists.
  ///
  /// In fr, this message translates to:
  /// **'Aucun artiste favori'**
  String get noFavoriteArtists;

  /// No description provided for @addArtistsToFavorite.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez des artistes à vos favoris depuis la liste des artistes'**
  String get addArtistsToFavorite;

  /// No description provided for @unnamed.
  ///
  /// In fr, this message translates to:
  /// **'Sans nom'**
  String get unnamed;

  /// No description provided for @claimStudioTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mon studio'**
  String get claimStudioTitle;

  /// No description provided for @nearbyStudiosTitle.
  ///
  /// In fr, this message translates to:
  /// **'Studios à proximité'**
  String get nearbyStudiosTitle;

  /// No description provided for @selectStudioToClaim.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez votre studio pour le revendiquer'**
  String get selectStudioToClaim;

  /// No description provided for @connectGoogleCalendarDesc.
  ///
  /// In fr, this message translates to:
  /// **'Connectez votre agenda Google pour synchroniser automatiquement vos disponibilités.'**
  String get connectGoogleCalendarDesc;

  /// No description provided for @connectGoogleCalendar.
  ///
  /// In fr, this message translates to:
  /// **'Connecter Google Calendar'**
  String get connectGoogleCalendar;

  /// No description provided for @claimYourStudioTitle.
  ///
  /// In fr, this message translates to:
  /// **'Revendiquez votre studio'**
  String get claimYourStudioTitle;

  /// No description provided for @claimYourStudio.
  ///
  /// In fr, this message translates to:
  /// **'Revendiquez votre studio'**
  String get claimYourStudio;

  /// No description provided for @claimYourStudioDesc.
  ///
  /// In fr, this message translates to:
  /// **'Rendez votre studio visible aux artistes et recevez des demandes de session.'**
  String get claimYourStudioDesc;

  /// No description provided for @claimStudioDescription.
  ///
  /// In fr, this message translates to:
  /// **'Rendez votre studio visible aux artistes et recevez des demandes de session.'**
  String get claimStudioDescription;

  /// No description provided for @noStudioFoundNearby.
  ///
  /// In fr, this message translates to:
  /// **'Aucun studio trouvé à proximité'**
  String get noStudioFoundNearby;

  /// No description provided for @createStudioManually.
  ///
  /// In fr, this message translates to:
  /// **'Créez votre studio manuellement ci-dessous'**
  String get createStudioManually;

  /// No description provided for @createStudioManuallyBelow.
  ///
  /// In fr, this message translates to:
  /// **'Créez votre studio manuellement ci-dessous'**
  String get createStudioManuallyBelow;

  /// No description provided for @studioNotAppearing.
  ///
  /// In fr, this message translates to:
  /// **'Mon studio n\'apparaît pas'**
  String get studioNotAppearing;

  /// No description provided for @studioNotListed.
  ///
  /// In fr, this message translates to:
  /// **'Mon studio n\'apparaît pas'**
  String get studioNotListed;

  /// No description provided for @createStudioProfileManually.
  ///
  /// In fr, this message translates to:
  /// **'Créer manuellement mon profil studio'**
  String get createStudioProfileManually;

  /// No description provided for @createManualProfile.
  ///
  /// In fr, this message translates to:
  /// **'Créer manuellement mon profil studio'**
  String get createManualProfile;

  /// No description provided for @claimThisStudio.
  ///
  /// In fr, this message translates to:
  /// **'Revendiquer ce studio ?'**
  String get claimThisStudio;

  /// No description provided for @claimStudioExplanation.
  ///
  /// In fr, this message translates to:
  /// **'En revendiquant ce studio, vous le rendez visible aux artistes sur Use Me. Ils pourront voir vos disponibilités et vous envoyer des demandes de session.'**
  String get claimStudioExplanation;

  /// No description provided for @claimStudioInfo.
  ///
  /// In fr, this message translates to:
  /// **'En revendiquant ce studio, vous le rendez visible aux artistes sur Use Me. Ils pourront voir vos disponibilités et vous envoyer des demandes de session.'**
  String get claimStudioInfo;

  /// No description provided for @claim.
  ///
  /// In fr, this message translates to:
  /// **'Revendiquer'**
  String get claim;

  /// No description provided for @studioClaimedSuccess.
  ///
  /// In fr, this message translates to:
  /// **'{name} revendiqué avec succès !'**
  String studioClaimedSuccess(String name);

  /// No description provided for @studioClaims.
  ///
  /// In fr, this message translates to:
  /// **'Revendications studios'**
  String get studioClaims;

  /// No description provided for @studioClaimsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Approuver ou refuser les demandes'**
  String get studioClaimsSubtitle;

  /// No description provided for @unclaim.
  ///
  /// In fr, this message translates to:
  /// **'Retirer'**
  String get unclaim;

  /// No description provided for @unclaimStudioTitle.
  ///
  /// In fr, this message translates to:
  /// **'Retirer le studio ?'**
  String get unclaimStudioTitle;

  /// No description provided for @unclaimStudioMessage.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous vraiment retirer \"{name}\" ? Votre studio ne sera plus visible par les artistes.'**
  String unclaimStudioMessage(String name);

  /// No description provided for @studioUnclaimed.
  ///
  /// In fr, this message translates to:
  /// **'Studio retiré avec succès'**
  String get studioUnclaimed;

  /// No description provided for @configurePayments.
  ///
  /// In fr, this message translates to:
  /// **'Configurez vos paiements'**
  String get configurePayments;

  /// No description provided for @paymentOptionsDescription.
  ///
  /// In fr, this message translates to:
  /// **'Ces options seront proposées aux artistes lors de la confirmation de réservation.'**
  String get paymentOptionsDescription;

  /// No description provided for @defaultDeposit.
  ///
  /// In fr, this message translates to:
  /// **'Acompte par défaut'**
  String get defaultDeposit;

  /// No description provided for @depositPercentDescription.
  ///
  /// In fr, this message translates to:
  /// **'Pourcentage du montant total demandé en acompte'**
  String get depositPercentDescription;

  /// No description provided for @acceptedPaymentMethods.
  ///
  /// In fr, this message translates to:
  /// **'Moyens de paiement acceptés'**
  String get acceptedPaymentMethods;

  /// No description provided for @instructionsOptional.
  ///
  /// In fr, this message translates to:
  /// **'Instructions (optionnel)'**
  String get instructionsOptional;

  /// No description provided for @instructionsHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex: Mettre le nom de l\'artiste en référence'**
  String get instructionsHint;

  /// No description provided for @paypalEmail.
  ///
  /// In fr, this message translates to:
  /// **'Email PayPal'**
  String get paypalEmail;

  /// No description provided for @cardInfo.
  ///
  /// In fr, this message translates to:
  /// **'Informations'**
  String get cardInfo;

  /// No description provided for @details.
  ///
  /// In fr, this message translates to:
  /// **'Détails'**
  String get details;

  /// No description provided for @iban.
  ///
  /// In fr, this message translates to:
  /// **'IBAN'**
  String get iban;

  /// No description provided for @createMyStudio.
  ///
  /// In fr, this message translates to:
  /// **'Créer mon studio'**
  String get createMyStudio;

  /// No description provided for @studioNameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Nom du studio *'**
  String get studioNameRequired;

  /// No description provided for @studioNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex: Studio Harmonie'**
  String get studioNameHint;

  /// No description provided for @studioNameRequiredError.
  ///
  /// In fr, this message translates to:
  /// **'Le nom du studio est requis'**
  String get studioNameRequiredError;

  /// No description provided for @studioNameIsRequired.
  ///
  /// In fr, this message translates to:
  /// **'Le nom du studio est requis'**
  String get studioNameIsRequired;

  /// No description provided for @description.
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @describeStudioHint.
  ///
  /// In fr, this message translates to:
  /// **'Décrivez votre studio en quelques mots...'**
  String get describeStudioHint;

  /// No description provided for @describeYourStudio.
  ///
  /// In fr, this message translates to:
  /// **'Décrivez votre studio en quelques mots...'**
  String get describeYourStudio;

  /// No description provided for @location.
  ///
  /// In fr, this message translates to:
  /// **'Localisation'**
  String get location;

  /// No description provided for @address.
  ///
  /// In fr, this message translates to:
  /// **'Adresse'**
  String get address;

  /// No description provided for @addressHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex: 123 rue de la Musique'**
  String get addressHint;

  /// No description provided for @postalCode.
  ///
  /// In fr, this message translates to:
  /// **'Code postal'**
  String get postalCode;

  /// No description provided for @cityRequired.
  ///
  /// In fr, this message translates to:
  /// **'Ville *'**
  String get cityRequired;

  /// No description provided for @cityRequiredError.
  ///
  /// In fr, this message translates to:
  /// **'La ville est requise'**
  String get cityRequiredError;

  /// No description provided for @cityIsRequired.
  ///
  /// In fr, this message translates to:
  /// **'La ville est requise'**
  String get cityIsRequired;

  /// No description provided for @phone.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get phone;

  /// No description provided for @phoneHint.
  ///
  /// In fr, this message translates to:
  /// **'06 12 34 56 78'**
  String get phoneHint;

  /// No description provided for @website.
  ///
  /// In fr, this message translates to:
  /// **'Site web'**
  String get website;

  /// No description provided for @websiteHint.
  ///
  /// In fr, this message translates to:
  /// **'https://www.monstudio.com'**
  String get websiteHint;

  /// No description provided for @offeredServices.
  ///
  /// In fr, this message translates to:
  /// **'Services proposés'**
  String get offeredServices;

  /// No description provided for @servicesOffered.
  ///
  /// In fr, this message translates to:
  /// **'Services proposés'**
  String get servicesOffered;

  /// No description provided for @creating.
  ///
  /// In fr, this message translates to:
  /// **'Création en cours...'**
  String get creating;

  /// No description provided for @creatingInProgress.
  ///
  /// In fr, this message translates to:
  /// **'Création en cours...'**
  String get creatingInProgress;

  /// No description provided for @studioCreatedSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Studio créé avec succès !'**
  String get studioCreatedSuccess;

  /// No description provided for @manualCreation.
  ///
  /// In fr, this message translates to:
  /// **'Création manuelle'**
  String get manualCreation;

  /// No description provided for @studioVisibleAfterCreation.
  ///
  /// In fr, this message translates to:
  /// **'Votre studio sera visible aux artistes dès sa création. Vous pourrez compléter votre profil plus tard.'**
  String get studioVisibleAfterCreation;

  /// No description provided for @manualCreationDescription.
  ///
  /// In fr, this message translates to:
  /// **'Votre studio sera visible aux artistes dès sa création. Vous pourrez compléter votre profil plus tard.'**
  String get manualCreationDescription;

  /// No description provided for @editSession.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la session'**
  String get editSession;

  /// No description provided for @newSession.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle session'**
  String get newSession;

  /// No description provided for @dateAndTime.
  ///
  /// In fr, this message translates to:
  /// **'Date et heure'**
  String get dateAndTime;

  /// No description provided for @duration.
  ///
  /// In fr, this message translates to:
  /// **'Durée'**
  String get duration;

  /// No description provided for @save.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get save;

  /// No description provided for @createSession.
  ///
  /// In fr, this message translates to:
  /// **'Créer la session'**
  String get createSession;

  /// No description provided for @addArtistFirst.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un artiste d\'abord'**
  String get addArtistFirst;

  /// No description provided for @selectArtist.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner un artiste'**
  String get selectArtist;

  /// No description provided for @addAnotherArtist.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un autre artiste'**
  String get addAnotherArtist;

  /// No description provided for @allArtistsSelected.
  ///
  /// In fr, this message translates to:
  /// **'Tous les artistes sont déjà sélectionnés'**
  String get allArtistsSelected;

  /// No description provided for @selectAtLeastOneArtist.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez au moins un artiste'**
  String get selectAtLeastOneArtist;

  /// No description provided for @deleteSession.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la session'**
  String get deleteSession;

  /// No description provided for @actionIrreversible.
  ///
  /// In fr, this message translates to:
  /// **'Cette action est irréversible.'**
  String get actionIrreversible;

  /// No description provided for @editService.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le service'**
  String get editService;

  /// No description provided for @newServiceTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau service'**
  String get newServiceTitle;

  /// No description provided for @serviceName.
  ///
  /// In fr, this message translates to:
  /// **'Nom du service'**
  String get serviceName;

  /// No description provided for @serviceNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex: Mix, Mastering, Recording...'**
  String get serviceNameHint;

  /// No description provided for @fieldRequired.
  ///
  /// In fr, this message translates to:
  /// **'Champ requis'**
  String get fieldRequired;

  /// No description provided for @serviceDescription.
  ///
  /// In fr, this message translates to:
  /// **'Description (optionnel)'**
  String get serviceDescription;

  /// No description provided for @serviceDescriptionHint.
  ///
  /// In fr, this message translates to:
  /// **'Description du service...'**
  String get serviceDescriptionHint;

  /// No description provided for @hourlyRate.
  ///
  /// In fr, this message translates to:
  /// **'Tarif horaire (€)'**
  String get hourlyRate;

  /// No description provided for @perHour.
  ///
  /// In fr, this message translates to:
  /// **'€/h'**
  String get perHour;

  /// No description provided for @invalidNumber.
  ///
  /// In fr, this message translates to:
  /// **'Nombre invalide'**
  String get invalidNumber;

  /// No description provided for @minimumDuration.
  ///
  /// In fr, this message translates to:
  /// **'Durée minimum'**
  String get minimumDuration;

  /// No description provided for @serviceActive.
  ///
  /// In fr, this message translates to:
  /// **'Service actif'**
  String get serviceActive;

  /// No description provided for @availableForBooking.
  ///
  /// In fr, this message translates to:
  /// **'Disponible à la réservation'**
  String get availableForBooking;

  /// No description provided for @notAvailableForBooking.
  ///
  /// In fr, this message translates to:
  /// **'Non disponible'**
  String get notAvailableForBooking;

  /// No description provided for @createService.
  ///
  /// In fr, this message translates to:
  /// **'Créer le service'**
  String get createService;

  /// No description provided for @deleteService.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le service'**
  String get deleteService;

  /// No description provided for @teamMembers.
  ///
  /// In fr, this message translates to:
  /// **'Membres de l\'équipe'**
  String get teamMembers;

  /// No description provided for @pendingInvitations.
  ///
  /// In fr, this message translates to:
  /// **'Invitations en attente'**
  String get pendingInvitations;

  /// No description provided for @noMember.
  ///
  /// In fr, this message translates to:
  /// **'Aucun membre'**
  String get noMember;

  /// No description provided for @addEngineersToTeam.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez des ingénieurs à votre équipe'**
  String get addEngineersToTeam;

  /// No description provided for @noInvitation.
  ///
  /// In fr, this message translates to:
  /// **'Aucune invitation'**
  String get noInvitation;

  /// No description provided for @pendingInvitationsHere.
  ///
  /// In fr, this message translates to:
  /// **'Les invitations en attente apparaîtront ici'**
  String get pendingInvitationsHere;

  /// No description provided for @codeCopied.
  ///
  /// In fr, this message translates to:
  /// **'Code copié'**
  String get codeCopied;

  /// No description provided for @removeFromTeam.
  ///
  /// In fr, this message translates to:
  /// **'Retirer de l\'équipe'**
  String get removeFromTeam;

  /// No description provided for @removeMemberConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Retirer ce membre ?'**
  String get removeMemberConfirm;

  /// No description provided for @memberNoAccessAnymore.
  ///
  /// In fr, this message translates to:
  /// **'{name} ne pourra plus accéder aux sessions du studio.'**
  String memberNoAccessAnymore(String name);

  /// No description provided for @memberRemoved.
  ///
  /// In fr, this message translates to:
  /// **'Membre retiré'**
  String get memberRemoved;

  /// No description provided for @remove.
  ///
  /// In fr, this message translates to:
  /// **'Retirer'**
  String get remove;

  /// No description provided for @invitationCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Invitation annulée'**
  String get invitationCancelled;

  /// No description provided for @addMember.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un membre'**
  String get addMember;

  /// No description provided for @searchByEmailOrInvite.
  ///
  /// In fr, this message translates to:
  /// **'Recherchez par email ou invitez un nouvel ingénieur'**
  String get searchByEmailOrInvite;

  /// No description provided for @userNotRegistered.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateur non inscrit'**
  String get userNotRegistered;

  /// No description provided for @sendInvitationToJoin.
  ///
  /// In fr, this message translates to:
  /// **'Envoyez-lui une invitation pour rejoindre votre équipe.'**
  String get sendInvitationToJoin;

  /// No description provided for @sendInvitation.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer l\'invitation'**
  String get sendInvitation;

  /// No description provided for @enterValidEmail.
  ///
  /// In fr, this message translates to:
  /// **'Entrez un email valide'**
  String get enterValidEmail;

  /// No description provided for @invitationCreated.
  ///
  /// In fr, this message translates to:
  /// **'Invitation créée'**
  String get invitationCreated;

  /// No description provided for @shareCodeWithEngineer.
  ///
  /// In fr, this message translates to:
  /// **'Partagez ce code avec l\'ingénieur :'**
  String get shareCodeWithEngineer;

  /// No description provided for @searchArtistHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un artiste...'**
  String get searchArtistHint;

  /// No description provided for @noArtistEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun artiste'**
  String get noArtistEmpty;

  /// No description provided for @addFirstArtist.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez votre premier artiste'**
  String get addFirstArtist;

  /// No description provided for @addArtist.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un artiste'**
  String get addArtist;

  /// No description provided for @tryAnotherSearch.
  ///
  /// In fr, this message translates to:
  /// **'Essayez une autre recherche'**
  String get tryAnotherSearch;

  /// No description provided for @search.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher'**
  String get search;

  /// No description provided for @create.
  ///
  /// In fr, this message translates to:
  /// **'Créer'**
  String get create;

  /// No description provided for @findExistingArtist.
  ///
  /// In fr, this message translates to:
  /// **'Trouvez un artiste existant'**
  String get findExistingArtist;

  /// No description provided for @searchAmongRegistered.
  ///
  /// In fr, this message translates to:
  /// **'Recherchez parmi les artistes déjà inscrits sur Use Me pour le lier à votre studio.'**
  String get searchAmongRegistered;

  /// No description provided for @artistAddedToStudio.
  ///
  /// In fr, this message translates to:
  /// **'{name} ajouté à votre studio !'**
  String artistAddedToStudio(String name);

  /// No description provided for @artistName.
  ///
  /// In fr, this message translates to:
  /// **'Nom d\'artiste'**
  String get artistName;

  /// No description provided for @stageNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Le nom de scène...'**
  String get stageNameHint;

  /// No description provided for @civilName.
  ///
  /// In fr, this message translates to:
  /// **'Nom civil'**
  String get civilName;

  /// No description provided for @firstAndLastName.
  ///
  /// In fr, this message translates to:
  /// **'Prénom et nom...'**
  String get firstAndLastName;

  /// No description provided for @emailHintArtist.
  ///
  /// In fr, this message translates to:
  /// **'Email de l\'artiste...'**
  String get emailHintArtist;

  /// No description provided for @emailRequiredForInvitation.
  ///
  /// In fr, this message translates to:
  /// **'Email requis pour l\'invitation'**
  String get emailRequiredForInvitation;

  /// No description provided for @phoneOptional.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone (optionnel)'**
  String get phoneOptional;

  /// No description provided for @phoneHintGeneric.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone...'**
  String get phoneHintGeneric;

  /// No description provided for @musicalGenres.
  ///
  /// In fr, this message translates to:
  /// **'Genres musicaux'**
  String get musicalGenres;

  /// No description provided for @sendInvitationToggle.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer une invitation'**
  String get sendInvitationToggle;

  /// No description provided for @artistWillReceiveCode.
  ///
  /// In fr, this message translates to:
  /// **'L\'artiste recevra un code pour rejoindre votre studio'**
  String get artistWillReceiveCode;

  /// No description provided for @createAndInvite.
  ///
  /// In fr, this message translates to:
  /// **'Créer et inviter'**
  String get createAndInvite;

  /// No description provided for @createProfile.
  ///
  /// In fr, this message translates to:
  /// **'Créer la fiche'**
  String get createProfile;

  /// No description provided for @createArtistProfile.
  ///
  /// In fr, this message translates to:
  /// **'Créer une fiche artiste'**
  String get createArtistProfile;

  /// No description provided for @createProfileAndInvite.
  ///
  /// In fr, this message translates to:
  /// **'Créez la fiche et invitez l\'artiste. Son compte sera automatiquement lié quand il s\'inscrira.'**
  String get createProfileAndInvite;

  /// No description provided for @artistCreated.
  ///
  /// In fr, this message translates to:
  /// **'Artiste créé !'**
  String get artistCreated;

  /// No description provided for @shareCodeWithArtist.
  ///
  /// In fr, this message translates to:
  /// **'Partagez ce code avec l\'artiste pour qu\'il rejoigne votre studio'**
  String get shareCodeWithArtist;

  /// No description provided for @share.
  ///
  /// In fr, this message translates to:
  /// **'Partager'**
  String get share;

  /// No description provided for @done.
  ///
  /// In fr, this message translates to:
  /// **'Terminé'**
  String get done;

  /// No description provided for @notificationsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @markAllRead.
  ///
  /// In fr, this message translates to:
  /// **'Tout marquer lu'**
  String get markAllRead;

  /// No description provided for @markAllAsRead.
  ///
  /// In fr, this message translates to:
  /// **'Tout marquer lu'**
  String get markAllAsRead;

  /// No description provided for @noNotification.
  ///
  /// In fr, this message translates to:
  /// **'Aucune notification'**
  String get noNotification;

  /// No description provided for @noNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Aucune notification'**
  String get noNotifications;

  /// No description provided for @notifiedForNewSessions.
  ///
  /// In fr, this message translates to:
  /// **'Vous serez notifié des nouvelles sessions'**
  String get notifiedForNewSessions;

  /// No description provided for @notifyNewSessions.
  ///
  /// In fr, this message translates to:
  /// **'Vous serez notifié des nouvelles sessions'**
  String get notifyNewSessions;

  /// No description provided for @loadingError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de chargement'**
  String get loadingError;

  /// No description provided for @personalInformation.
  ///
  /// In fr, this message translates to:
  /// **'Informations personnelles'**
  String get personalInformation;

  /// No description provided for @fullNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom complet'**
  String get fullNameLabel;

  /// No description provided for @required.
  ///
  /// In fr, this message translates to:
  /// **'Requis'**
  String get required;

  /// No description provided for @stageName.
  ///
  /// In fr, this message translates to:
  /// **'Nom de scène'**
  String get stageName;

  /// No description provided for @bio.
  ///
  /// In fr, this message translates to:
  /// **'Bio'**
  String get bio;

  /// No description provided for @tellAboutYourself.
  ///
  /// In fr, this message translates to:
  /// **'Parlez de vous...'**
  String get tellAboutYourself;

  /// No description provided for @accountSection.
  ///
  /// In fr, this message translates to:
  /// **'Compte'**
  String get accountSection;

  /// No description provided for @changePasswordAction.
  ///
  /// In fr, this message translates to:
  /// **'Changer le mot de passe'**
  String get changePasswordAction;

  /// No description provided for @logoutAction.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get logoutAction;

  /// No description provided for @signOut.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get signOut;

  /// No description provided for @deleteMyAccount.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer mon compte'**
  String get deleteMyAccount;

  /// No description provided for @resetEmailSent.
  ///
  /// In fr, this message translates to:
  /// **'Email de réinitialisation envoyé'**
  String get resetEmailSent;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le compte'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountFinalWarning.
  ///
  /// In fr, this message translates to:
  /// **'Cette action est irréversible. Toutes vos données seront supprimées définitivement.'**
  String get deleteAccountFinalWarning;

  /// No description provided for @sessionTracking.
  ///
  /// In fr, this message translates to:
  /// **'Suivi session'**
  String get sessionTracking;

  /// No description provided for @hoursPlanned.
  ///
  /// In fr, this message translates to:
  /// **'{hours}h prévues'**
  String hoursPlanned(int hours);

  /// No description provided for @checkIn.
  ///
  /// In fr, this message translates to:
  /// **'Pointage'**
  String get checkIn;

  /// No description provided for @checkInArrival.
  ///
  /// In fr, this message translates to:
  /// **'Pointer l\'arrivée'**
  String get checkInArrival;

  /// No description provided for @arrivalChecked.
  ///
  /// In fr, this message translates to:
  /// **'Arrivée pointée'**
  String get arrivalChecked;

  /// No description provided for @checkOutDeparture.
  ///
  /// In fr, this message translates to:
  /// **'Pointer le départ'**
  String get checkOutDeparture;

  /// No description provided for @sessionNotes.
  ///
  /// In fr, this message translates to:
  /// **'Notes de session'**
  String get sessionNotes;

  /// No description provided for @addSessionNotes.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter des notes sur la session...'**
  String get addSessionNotes;

  /// No description provided for @photos.
  ///
  /// In fr, this message translates to:
  /// **'Photos'**
  String get photos;

  /// No description provided for @addPhoto.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une photo'**
  String get addPhoto;

  /// No description provided for @arrivalCheckedSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Arrivée pointée !'**
  String get arrivalCheckedSuccess;

  /// No description provided for @endSession.
  ///
  /// In fr, this message translates to:
  /// **'Terminer la session ?'**
  String get endSession;

  /// No description provided for @endSessionConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous pointer votre départ et terminer cette session ?'**
  String get endSessionConfirm;

  /// No description provided for @finish.
  ///
  /// In fr, this message translates to:
  /// **'Terminer'**
  String get finish;

  /// No description provided for @contactArtist.
  ///
  /// In fr, this message translates to:
  /// **'Contacter l\'artiste'**
  String get contactArtist;

  /// No description provided for @reportProblemAction.
  ///
  /// In fr, this message translates to:
  /// **'Signaler un problème'**
  String get reportProblemAction;

  /// No description provided for @editArtist.
  ///
  /// In fr, this message translates to:
  /// **'Modifier l\'artiste'**
  String get editArtist;

  /// No description provided for @newArtistTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouvel artiste'**
  String get newArtistTitle;

  /// No description provided for @emailHintGeneric.
  ///
  /// In fr, this message translates to:
  /// **'Email...'**
  String get emailHintGeneric;

  /// No description provided for @cityHint.
  ///
  /// In fr, this message translates to:
  /// **'Ville...'**
  String get cityHint;

  /// No description provided for @bioOptional.
  ///
  /// In fr, this message translates to:
  /// **'Bio (optionnel)'**
  String get bioOptional;

  /// No description provided for @fewWordsAboutArtist.
  ///
  /// In fr, this message translates to:
  /// **'Quelques mots sur l\'artiste...'**
  String get fewWordsAboutArtist;

  /// No description provided for @createArtist.
  ///
  /// In fr, this message translates to:
  /// **'Créer l\'artiste'**
  String get createArtist;

  /// No description provided for @deleteArtist.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer l\'artiste'**
  String get deleteArtist;

  /// No description provided for @calendarTitle.
  ///
  /// In fr, this message translates to:
  /// **'Calendrier'**
  String get calendarTitle;

  /// No description provided for @unavailabilityAdded.
  ///
  /// In fr, this message translates to:
  /// **'Indisponibilité ajoutée'**
  String get unavailabilityAdded;

  /// No description provided for @unavailabilityDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Indisponibilité supprimée'**
  String get unavailabilityDeleted;

  /// No description provided for @calendarConnected.
  ///
  /// In fr, this message translates to:
  /// **'Calendrier connecté'**
  String get calendarConnected;

  /// No description provided for @never.
  ///
  /// In fr, this message translates to:
  /// **'Jamais'**
  String get never;

  /// No description provided for @lastSync.
  ///
  /// In fr, this message translates to:
  /// **'Dernier sync'**
  String get lastSync;

  /// No description provided for @synchronize.
  ///
  /// In fr, this message translates to:
  /// **'Synchroniser'**
  String get synchronize;

  /// No description provided for @disconnect.
  ///
  /// In fr, this message translates to:
  /// **'Déconnecter'**
  String get disconnect;

  /// No description provided for @disconnectCalendar.
  ///
  /// In fr, this message translates to:
  /// **'Déconnecter le calendrier ?'**
  String get disconnectCalendar;

  /// No description provided for @disconnectCalendarWarning.
  ///
  /// In fr, this message translates to:
  /// **'Vos indisponibilités synchronisées seront supprimées. Les indisponibilités manuelles seront conservées.'**
  String get disconnectCalendarWarning;

  /// No description provided for @tipsSectionGettingStarted.
  ///
  /// In fr, this message translates to:
  /// **'Premiers pas'**
  String get tipsSectionGettingStarted;

  /// No description provided for @tipsSectionBookings.
  ///
  /// In fr, this message translates to:
  /// **'Réservations'**
  String get tipsSectionBookings;

  /// No description provided for @tipsSectionProTips.
  ///
  /// In fr, this message translates to:
  /// **'Astuces pro'**
  String get tipsSectionProTips;

  /// No description provided for @tipsSectionSetup.
  ///
  /// In fr, this message translates to:
  /// **'Configuration'**
  String get tipsSectionSetup;

  /// No description provided for @tipsSectionSessions.
  ///
  /// In fr, this message translates to:
  /// **'Sessions'**
  String get tipsSectionSessions;

  /// No description provided for @tipsSectionTips.
  ///
  /// In fr, this message translates to:
  /// **'Astuces'**
  String get tipsSectionTips;

  /// No description provided for @tipsSectionStudioSetup.
  ///
  /// In fr, this message translates to:
  /// **'Configuration du studio'**
  String get tipsSectionStudioSetup;

  /// No description provided for @tipsSectionTeamManagement.
  ///
  /// In fr, this message translates to:
  /// **'Gestion d\'équipe'**
  String get tipsSectionTeamManagement;

  /// No description provided for @tipsSectionVisibility.
  ///
  /// In fr, this message translates to:
  /// **'Visibilité'**
  String get tipsSectionVisibility;

  /// No description provided for @tipExploreMapTitle.
  ///
  /// In fr, this message translates to:
  /// **'Explorez la carte'**
  String get tipExploreMapTitle;

  /// No description provided for @tipExploreMapDesc.
  ///
  /// In fr, this message translates to:
  /// **'La carte vous montre tous les studios autour de vous. Les pins verts sont des studios partenaires avec des avantages exclusifs. Zoomez et déplacez-vous pour découvrir plus de studios.'**
  String get tipExploreMapDesc;

  /// No description provided for @tipCompleteProfileTitle.
  ///
  /// In fr, this message translates to:
  /// **'Complétez votre profil'**
  String get tipCompleteProfileTitle;

  /// No description provided for @tipCompleteProfileDesc.
  ///
  /// In fr, this message translates to:
  /// **'Un profil complet avec photo et genres musicaux aide les studios à mieux vous connaître. Allez dans Réglages > Mon profil pour ajouter ces infos.'**
  String get tipCompleteProfileDesc;

  /// No description provided for @tipChooseSlotTitle.
  ///
  /// In fr, this message translates to:
  /// **'Choisir le bon créneau'**
  String get tipChooseSlotTitle;

  /// No description provided for @tipChooseSlotDesc.
  ///
  /// In fr, this message translates to:
  /// **'Les créneaux verts indiquent une forte disponibilité d\'ingénieurs. Les créneaux orange sont plus limités. Préférez les créneaux verts pour plus de flexibilité.'**
  String get tipChooseSlotDesc;

  /// No description provided for @tipSelectEngineerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez votre ingénieur'**
  String get tipSelectEngineerTitle;

  /// No description provided for @tipSelectEngineerDesc.
  ///
  /// In fr, this message translates to:
  /// **'Vous pouvez choisir un ingénieur spécifique ou laisser le studio assigner. Si vous avez déjà travaillé avec quelqu\'un, retrouvez-le dans la liste !'**
  String get tipSelectEngineerDesc;

  /// No description provided for @tipPrepareSessionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Préparez votre session'**
  String get tipPrepareSessionTitle;

  /// No description provided for @tipPrepareSessionDesc.
  ///
  /// In fr, this message translates to:
  /// **'Utilisez le champ \"Notes\" pour décrire votre projet : style, références, ce que vous voulez accomplir. Ça aide l\'ingénieur à se préparer.'**
  String get tipPrepareSessionDesc;

  /// No description provided for @tipBookAdvanceTitle.
  ///
  /// In fr, this message translates to:
  /// **'Réservez à l\'avance'**
  String get tipBookAdvanceTitle;

  /// No description provided for @tipBookAdvanceDesc.
  ///
  /// In fr, this message translates to:
  /// **'Les meilleurs créneaux partent vite ! Réservez 2-3 jours à l\'avance pour avoir le choix des horaires et des ingénieurs.'**
  String get tipBookAdvanceDesc;

  /// No description provided for @tipManageFavoritesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Gérez vos favoris'**
  String get tipManageFavoritesTitle;

  /// No description provided for @tipManageFavoritesDesc.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez vos studios préférés en favoris pour les retrouver rapidement. Appuyez sur le cœur sur la page du studio.'**
  String get tipManageFavoritesDesc;

  /// No description provided for @tipTrackSessionsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Suivez vos sessions'**
  String get tipTrackSessionsTitle;

  /// No description provided for @tipTrackSessionsDesc.
  ///
  /// In fr, this message translates to:
  /// **'Dans l\'onglet Sessions, retrouvez tout votre historique. C\'est pratique pour re-réserver avec le même ingénieur ou studio.'**
  String get tipTrackSessionsDesc;

  /// No description provided for @tipSetScheduleTitle.
  ///
  /// In fr, this message translates to:
  /// **'Définissez vos horaires'**
  String get tipSetScheduleTitle;

  /// No description provided for @tipSetScheduleDesc.
  ///
  /// In fr, this message translates to:
  /// **'Allez dans Réglages > Disponibilités pour configurer vos jours et heures de travail. Les artistes ne pourront réserver que sur vos créneaux actifs.'**
  String get tipSetScheduleDesc;

  /// No description provided for @tipAddUnavailabilityTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez vos indisponibilités'**
  String get tipAddUnavailabilityTitle;

  /// No description provided for @tipAddUnavailabilityDesc.
  ///
  /// In fr, this message translates to:
  /// **'Vacances, RDV, ou jour off ? Ajoutez une indisponibilité pour bloquer ces périodes. Vous pouvez ajouter une raison optionnelle.'**
  String get tipAddUnavailabilityDesc;

  /// No description provided for @tipViewSessionsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Voir vos sessions'**
  String get tipViewSessionsTitle;

  /// No description provided for @tipViewSessionsDesc.
  ///
  /// In fr, this message translates to:
  /// **'L\'onglet Sessions affiche toutes vos sessions à venir. Les sessions \"Confirmées\" sont validées, \"En attente\" doivent être confirmées par le studio.'**
  String get tipViewSessionsDesc;

  /// No description provided for @tipStartSessionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Démarrer une session'**
  String get tipStartSessionTitle;

  /// No description provided for @tipStartSessionDesc.
  ///
  /// In fr, this message translates to:
  /// **'Le jour J, appuyez sur \"Démarrer\" pour lancer le chrono. À la fin, appuyez sur \"Terminer\" et ajoutez vos notes de session.'**
  String get tipStartSessionDesc;

  /// No description provided for @tipSessionNotesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Notes de session'**
  String get tipSessionNotesTitle;

  /// No description provided for @tipSessionNotesDesc.
  ///
  /// In fr, this message translates to:
  /// **'Après chaque session, ajoutez des notes : réglages utilisés, fichiers exportés, remarques. C\'est utile pour vous et pour l\'artiste.'**
  String get tipSessionNotesDesc;

  /// No description provided for @tipStayUpdatedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Restez à jour'**
  String get tipStayUpdatedTitle;

  /// No description provided for @tipStayUpdatedDesc.
  ///
  /// In fr, this message translates to:
  /// **'Mettez à jour vos disponibilités régulièrement. Un planning à jour = plus de réservations pour vous !'**
  String get tipStayUpdatedDesc;

  /// No description provided for @tipProfileMattersTitle.
  ///
  /// In fr, this message translates to:
  /// **'Votre profil compte'**
  String get tipProfileMattersTitle;

  /// No description provided for @tipProfileMattersDesc.
  ///
  /// In fr, this message translates to:
  /// **'Les artistes peuvent vous choisir spécifiquement. Une photo pro et une bio avec vos spécialités attirent plus de clients.'**
  String get tipProfileMattersDesc;

  /// No description provided for @tipCompleteStudioProfileTitle.
  ///
  /// In fr, this message translates to:
  /// **'Complétez votre profil studio'**
  String get tipCompleteStudioProfileTitle;

  /// No description provided for @tipCompleteStudioProfileDesc.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez photos, description, équipements et services. Un profil complet apparaît plus haut dans les résultats et attire plus d\'artistes.'**
  String get tipCompleteStudioProfileDesc;

  /// No description provided for @tipSetStudioHoursTitle.
  ///
  /// In fr, this message translates to:
  /// **'Définissez vos horaires'**
  String get tipSetStudioHoursTitle;

  /// No description provided for @tipSetStudioHoursDesc.
  ///
  /// In fr, this message translates to:
  /// **'Configurez les horaires d\'ouverture du studio dans Réglages. Les artistes ne pourront réserver que pendant ces heures.'**
  String get tipSetStudioHoursDesc;

  /// No description provided for @tipAddServicesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez vos services'**
  String get tipAddServicesTitle;

  /// No description provided for @tipAddServicesDesc.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrement, mix, mastering... Définissez vos services avec leurs tarifs. Ça aide les artistes à choisir.'**
  String get tipAddServicesDesc;

  /// No description provided for @tipInviteEngineersTitle.
  ///
  /// In fr, this message translates to:
  /// **'Invitez vos ingénieurs'**
  String get tipInviteEngineersTitle;

  /// No description provided for @tipInviteEngineersDesc.
  ///
  /// In fr, this message translates to:
  /// **'Allez dans Équipe > Inviter pour ajouter vos ingénieurs. Ils recevront un lien pour rejoindre votre studio.'**
  String get tipInviteEngineersDesc;

  /// No description provided for @tipManageAvailabilitiesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Gérez les disponibilités'**
  String get tipManageAvailabilitiesTitle;

  /// No description provided for @tipManageAvailabilitiesDesc.
  ///
  /// In fr, this message translates to:
  /// **'Chaque ingénieur gère ses propres disponibilités. Vous pouvez voir la vue d\'ensemble dans le planning du studio.'**
  String get tipManageAvailabilitiesDesc;

  /// No description provided for @tipAssignSessionsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Assignez les sessions'**
  String get tipAssignSessionsTitle;

  /// No description provided for @tipAssignSessionsDesc.
  ///
  /// In fr, this message translates to:
  /// **'Quand un artiste ne choisit pas d\'ingénieur, c\'est à vous de l\'assigner. Vérifiez les disponibilités avant d\'assigner.'**
  String get tipAssignSessionsDesc;

  /// No description provided for @tipManageRequestsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Gérer les demandes'**
  String get tipManageRequestsTitle;

  /// No description provided for @tipManageRequestsDesc.
  ///
  /// In fr, this message translates to:
  /// **'Les nouvelles demandes apparaissent dans \"En attente\". Validez rapidement pour fidéliser les artistes !'**
  String get tipManageRequestsDesc;

  /// No description provided for @tipInviteArtistsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Invitez vos artistes'**
  String get tipInviteArtistsTitle;

  /// No description provided for @tipInviteArtistsDesc.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez des artistes réguliers ? Invitez-les via Clients > Inviter. Ils pourront réserver plus facilement.'**
  String get tipInviteArtistsDesc;

  /// No description provided for @tipTrackActivityTitle.
  ///
  /// In fr, this message translates to:
  /// **'Suivez l\'activité'**
  String get tipTrackActivityTitle;

  /// No description provided for @tipTrackActivityDesc.
  ///
  /// In fr, this message translates to:
  /// **'Le dashboard vous montre les stats : sessions du mois, revenus, artistes actifs. Gardez un œil sur votre activité.'**
  String get tipTrackActivityDesc;

  /// No description provided for @tipBecomePartnerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Devenez partenaire'**
  String get tipBecomePartnerTitle;

  /// No description provided for @tipBecomePartnerDesc.
  ///
  /// In fr, this message translates to:
  /// **'Les studios partenaires apparaissent en vert sur la carte et en priorité. Contactez-nous pour en savoir plus !'**
  String get tipBecomePartnerDesc;

  /// No description provided for @tipEncourageReviewsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Encouragez les avis'**
  String get tipEncourageReviewsTitle;

  /// No description provided for @tipEncourageReviewsDesc.
  ///
  /// In fr, this message translates to:
  /// **'Après une session réussie, invitez l\'artiste à laisser un avis. Les bons avis attirent plus de clients.'**
  String get tipEncourageReviewsDesc;

  /// No description provided for @tipsSectionAIAssistant.
  ///
  /// In fr, this message translates to:
  /// **'Assistant IA'**
  String get tipsSectionAIAssistant;

  /// No description provided for @tipAIAssistantTitle.
  ///
  /// In fr, this message translates to:
  /// **'Parle à ton assistant'**
  String get tipAIAssistantTitle;

  /// No description provided for @tipAIAssistantDesc.
  ///
  /// In fr, this message translates to:
  /// **'L\'assistant IA connaît toutes tes données. Demande-lui tes sessions, stats, ou de l\'aide pour n\'importe quelle question !'**
  String get tipAIAssistantDesc;

  /// No description provided for @tipAIActionsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Actions par la voix'**
  String get tipAIActionsTitle;

  /// No description provided for @tipAIActionsStudioDesc.
  ///
  /// In fr, this message translates to:
  /// **'Tu peux demander à l\'assistant de créer des sessions, accepter des réservations, gérer tes services... Tout par le chat !'**
  String get tipAIActionsStudioDesc;

  /// No description provided for @tipAIActionsEngineerDesc.
  ///
  /// In fr, this message translates to:
  /// **'Demande à l\'assistant de démarrer ou terminer tes sessions, gérer tes indisponibilités, et plus encore.'**
  String get tipAIActionsEngineerDesc;

  /// No description provided for @tipAIActionsArtistDesc.
  ///
  /// In fr, this message translates to:
  /// **'L\'assistant peut rechercher des studios, gérer tes favoris, créer des demandes de réservation pour toi.'**
  String get tipAIActionsArtistDesc;

  /// No description provided for @tipAIContextTitle.
  ///
  /// In fr, this message translates to:
  /// **'Il te connaît'**
  String get tipAIContextTitle;

  /// No description provided for @tipAIContextDesc.
  ///
  /// In fr, this message translates to:
  /// **'L\'assistant sait qui tu es et adapte ses réponses selon ton profil. Il peut accéder à tes vraies données en temps réel.'**
  String get tipAIContextDesc;

  /// No description provided for @teamInvitations.
  ///
  /// In fr, this message translates to:
  /// **'Invitations d\'équipe'**
  String get teamInvitations;

  /// No description provided for @noEmailConfigured.
  ///
  /// In fr, this message translates to:
  /// **'Email non configuré'**
  String get noEmailConfigured;

  /// No description provided for @noInvitations.
  ///
  /// In fr, this message translates to:
  /// **'Aucune invitation'**
  String get noInvitations;

  /// No description provided for @noInvitationsDescription.
  ///
  /// In fr, this message translates to:
  /// **'Vous n\'avez pas d\'invitation en attente.'**
  String get noInvitationsDescription;

  /// No description provided for @invitationSentOn.
  ///
  /// In fr, this message translates to:
  /// **'Envoyée le {date}'**
  String invitationSentOn(String date);

  /// No description provided for @teamInvitationMessage.
  ///
  /// In fr, this message translates to:
  /// **'{studioName} vous invite à rejoindre son équipe en tant qu\'ingénieur du son.'**
  String teamInvitationMessage(String studioName);

  /// No description provided for @expiresOn.
  ///
  /// In fr, this message translates to:
  /// **'Expire le {date}'**
  String expiresOn(String date);

  /// No description provided for @decline.
  ///
  /// In fr, this message translates to:
  /// **'Refuser'**
  String get decline;

  /// No description provided for @accept.
  ///
  /// In fr, this message translates to:
  /// **'Accepter'**
  String get accept;

  /// No description provided for @invitationAccepted.
  ///
  /// In fr, this message translates to:
  /// **'Invitation acceptée ! Vous faites maintenant partie de l\'équipe.'**
  String get invitationAccepted;

  /// No description provided for @declineInvitation.
  ///
  /// In fr, this message translates to:
  /// **'Refuser l\'invitation'**
  String get declineInvitation;

  /// No description provided for @declineInvitationConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Êtes-vous sûr de vouloir refuser l\'invitation de {studioName} ?'**
  String declineInvitationConfirm(String studioName);

  /// No description provided for @invitationDeclined.
  ///
  /// In fr, this message translates to:
  /// **'Invitation refusée.'**
  String get invitationDeclined;

  /// No description provided for @errorOccurred.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue'**
  String get errorOccurred;

  /// No description provided for @sessionDetails.
  ///
  /// In fr, this message translates to:
  /// **'Détails de la session'**
  String get sessionDetails;

  /// No description provided for @toBeAssigned.
  ///
  /// In fr, this message translates to:
  /// **'À attribuer par le studio'**
  String get toBeAssigned;

  /// No description provided for @acceptSession.
  ///
  /// In fr, this message translates to:
  /// **'Accepter la session'**
  String get acceptSession;

  /// No description provided for @confirmAcceptSession.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous accepter cette demande de session ?'**
  String get confirmAcceptSession;

  /// No description provided for @sessionAccepted.
  ///
  /// In fr, this message translates to:
  /// **'Session acceptée !'**
  String get sessionAccepted;

  /// No description provided for @declineSession.
  ///
  /// In fr, this message translates to:
  /// **'Refuser la session'**
  String get declineSession;

  /// No description provided for @confirmDeclineSession.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous refuser cette demande de session ?'**
  String get confirmDeclineSession;

  /// No description provided for @sessionDeclined.
  ///
  /// In fr, this message translates to:
  /// **'Session refusée'**
  String get sessionDeclined;

  /// No description provided for @cancelSession.
  ///
  /// In fr, this message translates to:
  /// **'Annuler la session'**
  String get cancelSession;

  /// No description provided for @confirmCancelSession.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous annuler cette session ? Cette action est irréversible.'**
  String get confirmCancelSession;

  /// No description provided for @bic.
  ///
  /// In fr, this message translates to:
  /// **'BIC / SWIFT'**
  String get bic;

  /// No description provided for @accountHolder.
  ///
  /// In fr, this message translates to:
  /// **'Titulaire du compte'**
  String get accountHolder;

  /// No description provided for @bankName.
  ///
  /// In fr, this message translates to:
  /// **'Nom de la banque'**
  String get bankName;

  /// No description provided for @cancellationPolicy.
  ///
  /// In fr, this message translates to:
  /// **'Politique d\'annulation'**
  String get cancellationPolicy;

  /// No description provided for @cancellationPolicyDescription.
  ///
  /// In fr, this message translates to:
  /// **'Définissez vos conditions de remboursement en cas d\'annulation'**
  String get cancellationPolicyDescription;

  /// No description provided for @customCancellationTerms.
  ///
  /// In fr, this message translates to:
  /// **'Conditions personnalisées'**
  String get customCancellationTerms;

  /// No description provided for @customCancellationHint.
  ///
  /// In fr, this message translates to:
  /// **'Décrivez vos conditions d\'annulation...'**
  String get customCancellationHint;

  /// No description provided for @saveAsDefault.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer par défaut'**
  String get saveAsDefault;

  /// No description provided for @saveAsDefaultDescription.
  ///
  /// In fr, this message translates to:
  /// **'Utiliser ce choix pour les prochaines sessions'**
  String get saveAsDefaultDescription;

  /// No description provided for @proposeToEngineers.
  ///
  /// In fr, this message translates to:
  /// **'Proposer'**
  String get proposeToEngineers;

  /// No description provided for @assignLater.
  ///
  /// In fr, this message translates to:
  /// **'Plus tard'**
  String get assignLater;

  /// No description provided for @assignLaterDescription.
  ///
  /// In fr, this message translates to:
  /// **'Vous pourrez assigner un ingénieur depuis les détails de la session'**
  String get assignLaterDescription;

  /// No description provided for @selectAtLeastOne.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez au moins 1'**
  String get selectAtLeastOne;

  /// No description provided for @assignEngineer.
  ///
  /// In fr, this message translates to:
  /// **'Ingénieur son'**
  String get assignEngineer;

  /// No description provided for @noEngineersAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Aucun ingénieur disponible pour ce créneau'**
  String get noEngineersAvailable;

  /// No description provided for @proposedSessions.
  ///
  /// In fr, this message translates to:
  /// **'Sessions proposées'**
  String get proposedSessions;

  /// No description provided for @proposedSessionsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune proposition en attente'**
  String get proposedSessionsEmpty;

  /// No description provided for @acceptProposal.
  ///
  /// In fr, this message translates to:
  /// **'Accepter'**
  String get acceptProposal;

  /// No description provided for @declineProposal.
  ///
  /// In fr, this message translates to:
  /// **'Refuser'**
  String get declineProposal;

  /// No description provided for @joinAsCoEngineer.
  ///
  /// In fr, this message translates to:
  /// **'Rejoindre'**
  String get joinAsCoEngineer;

  /// No description provided for @sessionProposedToYou.
  ///
  /// In fr, this message translates to:
  /// **'Session proposée'**
  String get sessionProposedToYou;

  /// No description provided for @sessionTaken.
  ///
  /// In fr, this message translates to:
  /// **'Session prise'**
  String get sessionTaken;

  /// No description provided for @sessionTakenDesc.
  ///
  /// In fr, this message translates to:
  /// **'Cette session a été acceptée par un autre ingénieur. Vous pouvez demander à rejoindre.'**
  String get sessionTakenDesc;

  /// No description provided for @requestToJoin.
  ///
  /// In fr, this message translates to:
  /// **'Demander à rejoindre'**
  String get requestToJoin;

  /// No description provided for @joinedAsCoEngineer.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez rejoint la session !'**
  String get joinedAsCoEngineer;

  /// No description provided for @proposalAccepted.
  ///
  /// In fr, this message translates to:
  /// **'Proposition acceptée !'**
  String get proposalAccepted;

  /// No description provided for @proposalDeclined.
  ///
  /// In fr, this message translates to:
  /// **'Proposition refusée'**
  String get proposalDeclined;

  /// No description provided for @youAreAssigned.
  ///
  /// In fr, this message translates to:
  /// **'Vous êtes assigné'**
  String get youAreAssigned;

  /// No description provided for @pendingProposal.
  ///
  /// In fr, this message translates to:
  /// **'En attente de réponse'**
  String get pendingProposal;

  /// No description provided for @openingHours.
  ///
  /// In fr, this message translates to:
  /// **'Horaires d\'ouverture'**
  String get openingHours;

  /// No description provided for @openingHoursSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Définissez quand votre studio est ouvert'**
  String get openingHoursSubtitle;

  /// No description provided for @noOpeningHoursConfigured.
  ///
  /// In fr, this message translates to:
  /// **'Aucun horaire configuré'**
  String get noOpeningHoursConfigured;

  /// No description provided for @openingHoursSaved.
  ///
  /// In fr, this message translates to:
  /// **'Horaires enregistrés'**
  String get openingHoursSaved;

  /// No description provided for @allowNoEngineer.
  ///
  /// In fr, this message translates to:
  /// **'Réservation sans ingénieur'**
  String get allowNoEngineer;

  /// No description provided for @allowNoEngineerSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Permet aux artistes de réserver même si aucun ingénieur n\'est disponible'**
  String get allowNoEngineerSubtitle;

  /// No description provided for @settingsSaved.
  ///
  /// In fr, this message translates to:
  /// **'Paramètre enregistré'**
  String get settingsSaved;

  /// No description provided for @selectStudio.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un studio'**
  String get selectStudio;

  /// No description provided for @selectStudioDescription.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez le studio pour votre session'**
  String get selectStudioDescription;

  /// No description provided for @noLinkedStudios.
  ///
  /// In fr, this message translates to:
  /// **'Aucun studio lié'**
  String get noLinkedStudios;

  /// No description provided for @noLinkedStudiosDescription.
  ///
  /// In fr, this message translates to:
  /// **'Vous n\'êtes lié à aucun studio. Explorez les studios pour commencer.'**
  String get noLinkedStudiosDescription;

  /// No description provided for @discoverStudios.
  ///
  /// In fr, this message translates to:
  /// **'Découvrir les studios'**
  String get discoverStudios;

  /// No description provided for @exploreMapHint.
  ///
  /// In fr, this message translates to:
  /// **'Explorez la carte pour trouver des studios à proximité'**
  String get exploreMapHint;

  /// No description provided for @changePhoto.
  ///
  /// In fr, this message translates to:
  /// **'Changer la photo'**
  String get changePhoto;

  /// No description provided for @takePhoto.
  ///
  /// In fr, this message translates to:
  /// **'Prendre une photo'**
  String get takePhoto;

  /// No description provided for @useCamera.
  ///
  /// In fr, this message translates to:
  /// **'Utiliser l\'appareil photo'**
  String get useCamera;

  /// No description provided for @chooseFromGallery.
  ///
  /// In fr, this message translates to:
  /// **'Choisir depuis la galerie'**
  String get chooseFromGallery;

  /// No description provided for @selectExistingPhoto.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner une photo existante'**
  String get selectExistingPhoto;

  /// No description provided for @photoUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Photo mise à jour'**
  String get photoUpdated;

  /// No description provided for @aiGuideTitle.
  ///
  /// In fr, this message translates to:
  /// **'Guide de l\'assistant IA'**
  String get aiGuideTitle;

  /// No description provided for @aiGuideHeaderTitle.
  ///
  /// In fr, this message translates to:
  /// **'Votre assistant personnel'**
  String get aiGuideHeaderTitle;

  /// No description provided for @aiGuideHeaderSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Découvrez tout ce que l\'IA peut faire pour vous'**
  String get aiGuideHeaderSubtitle;

  /// No description provided for @aiGuideSecurityTitle.
  ///
  /// In fr, this message translates to:
  /// **'Toujours sous votre contrôle'**
  String get aiGuideSecurityTitle;

  /// No description provided for @aiGuideSecurityDesc.
  ///
  /// In fr, this message translates to:
  /// **'L\'assistant vous demandera TOUJOURS confirmation avant d\'effectuer une action. Rien ne sera fait sans votre accord explicite.'**
  String get aiGuideSecurityDesc;

  /// No description provided for @aiGuideIntroTitle.
  ///
  /// In fr, this message translates to:
  /// **'Comment ça marche ?'**
  String get aiGuideIntroTitle;

  /// No description provided for @aiGuideWhatIsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Un assistant intelligent'**
  String get aiGuideWhatIsTitle;

  /// No description provided for @aiGuideWhatIsDesc.
  ///
  /// In fr, this message translates to:
  /// **'L\'assistant IA comprend vos demandes en langage naturel et peut consulter vos données ou effectuer des actions pour vous. Posez-lui des questions ou demandez-lui d\'agir !'**
  String get aiGuideWhatIsDesc;

  /// No description provided for @aiGuideConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Confirmation obligatoire'**
  String get aiGuideConfirmTitle;

  /// No description provided for @aiGuideConfirmDesc.
  ///
  /// In fr, this message translates to:
  /// **'Avant chaque action (réservation, annulation, modification...), l\'assistant vous résumera ce qu\'il va faire et attendra votre confirmation. Vous gardez le contrôle total.'**
  String get aiGuideConfirmDesc;

  /// No description provided for @aiGuideReadTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ce que l\'IA peut consulter'**
  String get aiGuideReadTitle;

  /// No description provided for @aiGuideActionsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Actions possibles'**
  String get aiGuideActionsTitle;

  /// No description provided for @aiGuideExamplesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Exemples de demandes'**
  String get aiGuideExamplesTitle;

  /// No description provided for @aiGuideSessionsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vos sessions'**
  String get aiGuideSessionsTitle;

  /// No description provided for @aiGuideArtistSessionsDesc.
  ///
  /// In fr, this message translates to:
  /// **'Consultez vos réservations passées, en cours ou à venir. Filtrez par date ou statut.'**
  String get aiGuideArtistSessionsDesc;

  /// No description provided for @aiGuideEngineerSessionsDesc.
  ///
  /// In fr, this message translates to:
  /// **'Voyez les sessions qui vous sont assignées, les propositions en attente et votre planning.'**
  String get aiGuideEngineerSessionsDesc;

  /// No description provided for @aiGuideStudioSessionsDesc.
  ///
  /// In fr, this message translates to:
  /// **'Accédez à toutes les sessions de votre studio, filtrez par statut, date ou artiste.'**
  String get aiGuideStudioSessionsDesc;

  /// No description provided for @aiGuideAvailabilityTitle.
  ///
  /// In fr, this message translates to:
  /// **'Disponibilités'**
  String get aiGuideAvailabilityTitle;

  /// No description provided for @aiGuideAvailabilityDesc.
  ///
  /// In fr, this message translates to:
  /// **'Vérifiez les créneaux disponibles d\'un studio pour une date donnée.'**
  String get aiGuideAvailabilityDesc;

  /// No description provided for @aiGuideConversationsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Conversations'**
  String get aiGuideConversationsTitle;

  /// No description provided for @aiGuideConversationsDesc.
  ///
  /// In fr, this message translates to:
  /// **'Consultez vos conversations récentes et les messages non lus.'**
  String get aiGuideConversationsDesc;

  /// No description provided for @aiGuideTimeOffTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vos indisponibilités'**
  String get aiGuideTimeOffTitle;

  /// No description provided for @aiGuideTimeOffDesc.
  ///
  /// In fr, this message translates to:
  /// **'Consultez vos périodes d\'indisponibilité planifiées (vacances, congés...).'**
  String get aiGuideTimeOffDesc;

  /// No description provided for @aiGuidePendingTitle.
  ///
  /// In fr, this message translates to:
  /// **'Demandes en attente'**
  String get aiGuidePendingTitle;

  /// No description provided for @aiGuidePendingDesc.
  ///
  /// In fr, this message translates to:
  /// **'Voyez toutes les demandes de réservation qui attendent votre réponse.'**
  String get aiGuidePendingDesc;

  /// No description provided for @aiGuideStatsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Statistiques'**
  String get aiGuideStatsTitle;

  /// No description provided for @aiGuideStatsDesc.
  ///
  /// In fr, this message translates to:
  /// **'Obtenez un aperçu de vos sessions (complétées, en attente, annulées) sur une période.'**
  String get aiGuideStatsDesc;

  /// No description provided for @aiGuideRevenueTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rapport de revenus'**
  String get aiGuideRevenueTitle;

  /// No description provided for @aiGuideRevenueDesc.
  ///
  /// In fr, this message translates to:
  /// **'Générez un rapport de revenus détaillé, groupé par service, ingénieur ou jour.'**
  String get aiGuideRevenueDesc;

  /// No description provided for @aiGuideTeamTitle.
  ///
  /// In fr, this message translates to:
  /// **'Votre équipe'**
  String get aiGuideTeamTitle;

  /// No description provided for @aiGuideTeamDesc.
  ///
  /// In fr, this message translates to:
  /// **'Listez les ingénieurs de votre équipe et leurs disponibilités.'**
  String get aiGuideTeamDesc;

  /// No description provided for @aiGuideBookingTitle.
  ///
  /// In fr, this message translates to:
  /// **'Réserver une session'**
  String get aiGuideBookingTitle;

  /// No description provided for @aiGuideBookingDesc.
  ///
  /// In fr, this message translates to:
  /// **'Demandez à l\'IA de créer une demande de réservation. Elle vous guidera dans le choix du studio, service, date et créneau.'**
  String get aiGuideBookingDesc;

  /// No description provided for @aiGuideFavoritesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Gérer les favoris'**
  String get aiGuideFavoritesTitle;

  /// No description provided for @aiGuideFavoritesDesc.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez ou retirez des studios de vos favoris, ou consultez votre liste de favoris.'**
  String get aiGuideFavoritesDesc;

  /// No description provided for @aiGuideSearchStudiosTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher des studios'**
  String get aiGuideSearchStudiosTitle;

  /// No description provided for @aiGuideSearchStudiosDesc.
  ///
  /// In fr, this message translates to:
  /// **'Trouvez des studios par nom, ville ou type de service proposé.'**
  String get aiGuideSearchStudiosDesc;

  /// No description provided for @aiGuideSendMessageTitle.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer un message'**
  String get aiGuideSendMessageTitle;

  /// No description provided for @aiGuideSendMessageDesc.
  ///
  /// In fr, this message translates to:
  /// **'Envoyez un message à un studio ou un artiste directement via l\'assistant.'**
  String get aiGuideSendMessageDesc;

  /// No description provided for @aiGuideStartSessionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Démarrer une session'**
  String get aiGuideStartSessionTitle;

  /// No description provided for @aiGuideStartSessionDesc.
  ///
  /// In fr, this message translates to:
  /// **'Pointez votre arrivée en démarrant une session confirmée le jour J.'**
  String get aiGuideStartSessionDesc;

  /// No description provided for @aiGuideCompleteSessionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Terminer une session'**
  String get aiGuideCompleteSessionTitle;

  /// No description provided for @aiGuideCompleteSessionDesc.
  ///
  /// In fr, this message translates to:
  /// **'Marquez une session comme terminée et ajoutez des notes si nécessaire.'**
  String get aiGuideCompleteSessionDesc;

  /// No description provided for @aiGuideRespondProposalTitle.
  ///
  /// In fr, this message translates to:
  /// **'Répondre à une proposition'**
  String get aiGuideRespondProposalTitle;

  /// No description provided for @aiGuideRespondProposalDesc.
  ///
  /// In fr, this message translates to:
  /// **'Acceptez ou refusez les sessions que le studio vous propose.'**
  String get aiGuideRespondProposalDesc;

  /// No description provided for @aiGuideManageTimeOffTitle.
  ///
  /// In fr, this message translates to:
  /// **'Gérer les indisponibilités'**
  String get aiGuideManageTimeOffTitle;

  /// No description provided for @aiGuideManageTimeOffDesc.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez ou supprimez des périodes d\'indisponibilité (vacances, rendez-vous...).'**
  String get aiGuideManageTimeOffDesc;

  /// No description provided for @aiGuideAcceptDeclineTitle.
  ///
  /// In fr, this message translates to:
  /// **'Accepter/Refuser demandes'**
  String get aiGuideAcceptDeclineTitle;

  /// No description provided for @aiGuideAcceptDeclineDesc.
  ///
  /// In fr, this message translates to:
  /// **'Gérez les demandes de réservation en les acceptant ou refusant via l\'assistant.'**
  String get aiGuideAcceptDeclineDesc;

  /// No description provided for @aiGuideRescheduleTitle.
  ///
  /// In fr, this message translates to:
  /// **'Reprogrammer une session'**
  String get aiGuideRescheduleTitle;

  /// No description provided for @aiGuideRescheduleDesc.
  ///
  /// In fr, this message translates to:
  /// **'Changez la date ou l\'heure d\'une session existante. L\'artiste sera notifié.'**
  String get aiGuideRescheduleDesc;

  /// No description provided for @aiGuideAssignEngineerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Assigner un ingénieur'**
  String get aiGuideAssignEngineerTitle;

  /// No description provided for @aiGuideAssignEngineerDesc.
  ///
  /// In fr, this message translates to:
  /// **'Assignez un ingénieur disponible à une session confirmée.'**
  String get aiGuideAssignEngineerDesc;

  /// No description provided for @aiGuideCreateSessionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Créer une session'**
  String get aiGuideCreateSessionTitle;

  /// No description provided for @aiGuideCreateSessionDesc.
  ///
  /// In fr, this message translates to:
  /// **'Créez une session manuellement pour un artiste, même sans demande préalable.'**
  String get aiGuideCreateSessionDesc;

  /// No description provided for @aiGuideBlockSlotsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Bloquer des créneaux'**
  String get aiGuideBlockSlotsTitle;

  /// No description provided for @aiGuideBlockSlotsDesc.
  ///
  /// In fr, this message translates to:
  /// **'Marquez des périodes d\'indisponibilité pour fermeture exceptionnelle du studio.'**
  String get aiGuideBlockSlotsDesc;

  /// No description provided for @aiGuideManageServicesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Gérer les services'**
  String get aiGuideManageServicesTitle;

  /// No description provided for @aiGuideManageServicesDesc.
  ///
  /// In fr, this message translates to:
  /// **'Créez ou modifiez vos services (nom, prix, durée, description).'**
  String get aiGuideManageServicesDesc;

  /// No description provided for @aiGuideExample1ArtistTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mes prochaines sessions'**
  String get aiGuideExample1ArtistTitle;

  /// No description provided for @aiGuideExample1ArtistDesc.
  ///
  /// In fr, this message translates to:
  /// **'\"Quelles sont mes sessions cette semaine ?\" - L\'IA vous montrera toutes vos réservations à venir.'**
  String get aiGuideExample1ArtistDesc;

  /// No description provided for @aiGuideExample2ArtistTitle.
  ///
  /// In fr, this message translates to:
  /// **'Trouver un studio'**
  String get aiGuideExample2ArtistTitle;

  /// No description provided for @aiGuideExample2ArtistDesc.
  ///
  /// In fr, this message translates to:
  /// **'\"Je cherche un studio à Paris pour du mix\" - L\'IA recherchera les studios correspondants.'**
  String get aiGuideExample2ArtistDesc;

  /// No description provided for @aiGuideExample3ArtistTitle.
  ///
  /// In fr, this message translates to:
  /// **'Réserver un créneau'**
  String get aiGuideExample3ArtistTitle;

  /// No description provided for @aiGuideExample3ArtistDesc.
  ///
  /// In fr, this message translates to:
  /// **'\"Je veux réserver demain à 14h au Studio X\" - L\'IA vérifiera la disponibilité et vous guidera.'**
  String get aiGuideExample3ArtistDesc;

  /// No description provided for @aiGuideExample1EngineerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Sessions du jour'**
  String get aiGuideExample1EngineerTitle;

  /// No description provided for @aiGuideExample1EngineerDesc.
  ///
  /// In fr, this message translates to:
  /// **'\"Qu\'est-ce que j\'ai aujourd\'hui ?\" - L\'IA vous montrera les sessions assignées pour aujourd\'hui.'**
  String get aiGuideExample1EngineerDesc;

  /// No description provided for @aiGuideExample2EngineerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Poser des congés'**
  String get aiGuideExample2EngineerTitle;

  /// No description provided for @aiGuideExample2EngineerDesc.
  ///
  /// In fr, this message translates to:
  /// **'\"Je serai absent du 15 au 20 janvier\" - L\'IA créera l\'indisponibilité après confirmation.'**
  String get aiGuideExample2EngineerDesc;

  /// No description provided for @aiGuideExample3EngineerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Répondre à une proposition'**
  String get aiGuideExample3EngineerTitle;

  /// No description provided for @aiGuideExample3EngineerDesc.
  ///
  /// In fr, this message translates to:
  /// **'\"Accepte la session de demain\" - L\'IA confirmera la proposition en attente.'**
  String get aiGuideExample3EngineerDesc;

  /// No description provided for @aiGuideExample1StudioTitle.
  ///
  /// In fr, this message translates to:
  /// **'Demandes en attente'**
  String get aiGuideExample1StudioTitle;

  /// No description provided for @aiGuideExample1StudioDesc.
  ///
  /// In fr, this message translates to:
  /// **'\"Montre-moi les demandes en attente\" - L\'IA affichera toutes les réservations à traiter.'**
  String get aiGuideExample1StudioDesc;

  /// No description provided for @aiGuideExample2StudioTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rapport de revenus'**
  String get aiGuideExample2StudioTitle;

  /// No description provided for @aiGuideExample2StudioDesc.
  ///
  /// In fr, this message translates to:
  /// **'\"Quel est mon chiffre d\'affaires ce mois-ci ?\" - L\'IA générera un rapport détaillé.'**
  String get aiGuideExample2StudioDesc;

  /// No description provided for @aiGuideExample3StudioTitle.
  ///
  /// In fr, this message translates to:
  /// **'Reprogrammer une session'**
  String get aiGuideExample3StudioTitle;

  /// No description provided for @aiGuideExample3StudioDesc.
  ///
  /// In fr, this message translates to:
  /// **'\"Décale la session de Lundi à Mardi 10h\" - L\'IA reprogrammera après votre confirmation.'**
  String get aiGuideExample3StudioDesc;

  /// No description provided for @aiGuideSettingsLink.
  ///
  /// In fr, this message translates to:
  /// **'Guide de l\'assistant IA'**
  String get aiGuideSettingsLink;

  /// No description provided for @importFromGoogleCalendar.
  ///
  /// In fr, this message translates to:
  /// **'Importer depuis Google Calendar'**
  String get importFromGoogleCalendar;

  /// No description provided for @importAsSession.
  ///
  /// In fr, this message translates to:
  /// **'Session'**
  String get importAsSession;

  /// No description provided for @importAsUnavailability.
  ///
  /// In fr, this message translates to:
  /// **'Indispo'**
  String get importAsUnavailability;

  /// No description provided for @skipImport.
  ///
  /// In fr, this message translates to:
  /// **'Ignorer'**
  String get skipImport;

  /// No description provided for @selectArtistForSession.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner un artiste'**
  String get selectArtistForSession;

  /// No description provided for @createExternalArtist.
  ///
  /// In fr, this message translates to:
  /// **'Artiste externe'**
  String get createExternalArtist;

  /// No description provided for @externalArtistName.
  ///
  /// In fr, this message translates to:
  /// **'Nom de l\'artiste'**
  String get externalArtistName;

  /// No description provided for @externalArtistHint.
  ///
  /// In fr, this message translates to:
  /// **'Nom de l\'artiste externe...'**
  String get externalArtistHint;

  /// No description provided for @importSummary.
  ///
  /// In fr, this message translates to:
  /// **'{sessions} sessions, {unavailabilities} indispos'**
  String importSummary(int sessions, int unavailabilities);

  /// No description provided for @importButton.
  ///
  /// In fr, this message translates to:
  /// **'Importer'**
  String get importButton;

  /// No description provided for @noEventsToImport.
  ///
  /// In fr, this message translates to:
  /// **'Aucun événement à importer'**
  String get noEventsToImport;

  /// No description provided for @eventsToReview.
  ///
  /// In fr, this message translates to:
  /// **'{count} événements à traiter'**
  String eventsToReview(int count);

  /// No description provided for @importSuccessMessage.
  ///
  /// In fr, this message translates to:
  /// **'Import réussi ! {sessions} sessions et {unavailabilities} indisponibilités créées.'**
  String importSuccessMessage(int sessions, int unavailabilities);

  /// No description provided for @allDay.
  ///
  /// In fr, this message translates to:
  /// **'Toute la journée'**
  String get allDay;

  /// No description provided for @selectAnArtist.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un artiste'**
  String get selectAnArtist;

  /// No description provided for @orCreateExternal.
  ///
  /// In fr, this message translates to:
  /// **'ou créer un artiste externe'**
  String get orCreateExternal;

  /// No description provided for @reviewAndImport.
  ///
  /// In fr, this message translates to:
  /// **'Vérifier et importer'**
  String get reviewAndImport;

  /// No description provided for @tipsSectionCalendar.
  ///
  /// In fr, this message translates to:
  /// **'Calendrier'**
  String get tipsSectionCalendar;

  /// No description provided for @tipConnectCalendarTitle.
  ///
  /// In fr, this message translates to:
  /// **'Connectez votre calendrier'**
  String get tipConnectCalendarTitle;

  /// No description provided for @tipConnectCalendarDesc.
  ///
  /// In fr, this message translates to:
  /// **'Liez votre Google Calendar pour synchroniser vos événements. Allez dans Réglages > Calendrier pour connecter votre compte Google.'**
  String get tipConnectCalendarDesc;

  /// No description provided for @tipImportEventsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Importez vos événements'**
  String get tipImportEventsTitle;

  /// No description provided for @tipImportEventsDesc.
  ///
  /// In fr, this message translates to:
  /// **'Utilisez \"Vérifier et importer\" pour récupérer vos événements Google Calendar et les catégoriser comme sessions ou indisponibilités.'**
  String get tipImportEventsDesc;

  /// No description provided for @tipCategorizeEventsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Catégorisez vos événements'**
  String get tipCategorizeEventsTitle;

  /// No description provided for @tipCategorizeEventsDesc.
  ///
  /// In fr, this message translates to:
  /// **'Pour chaque événement importé, choisissez : Session (avec artiste), Indispo (bloquer le créneau), ou Ignorer. Les sessions sont créées en statut \"En attente\".'**
  String get tipCategorizeEventsDesc;

  /// No description provided for @allNotificationsMarkedAsRead.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les notifications ont été marquées comme lues'**
  String get allNotificationsMarkedAsRead;

  /// No description provided for @comingSoon.
  ///
  /// In fr, this message translates to:
  /// **'Prochainement'**
  String get comingSoon;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
