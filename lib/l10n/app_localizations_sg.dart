// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Sango (`sg`).
class AppLocalizationsSg extends AppLocalizations {
  AppLocalizationsSg([String locale = 'sg']) : super(locale);

  @override
  String get appName => 'UZME';

  @override
  String get settings => 'Sêse';

  @override
  String get profile => 'Profîli';

  @override
  String get myProfile => 'Profîli tî mbi';

  @override
  String get personalInfo => 'Sêse tî mbi';

  @override
  String get application => 'Application';

  @override
  String get account => 'Kömändë';

  @override
  String get emailPassword => 'Email, tëngbi-da';

  @override
  String get about => 'Na ndâ tî';

  @override
  String get versionLegal => 'Version, mbëtï tî ndiä';

  @override
  String get logout => 'Fä';

  @override
  String get logoutConfirmTitle => 'Fä';

  @override
  String get logoutConfirmMessage => 'Mo yê töngana mo sü fä tî pëpe?';

  @override
  String get cancel => 'Lä';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsEnabled => 'A-duti';

  @override
  String get notificationsDisabled => 'A-duti pëpe';

  @override
  String get notificationsMuted => 'Notifications na gï-ngû';

  @override
  String get enableNotificationsInSettings =>
      'Zîa notifications na sêse tî téléphone tî mo';

  @override
  String get rememberEmail => 'Bâa email na ndö';

  @override
  String get rememberEmailEnabled => 'Email a-duti kôzo na connexion';

  @override
  String get rememberEmailDisabled => 'Email a-bâa na ndö pëpe';

  @override
  String get appearance => 'Pandöö';

  @override
  String get themeLight => 'Vûru';

  @override
  String get themeDark => 'Bîm';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeLightSubtitle => 'Pandöö vûru';

  @override
  String get themeDarkSubtitle => 'Pandöö bîm';

  @override
  String get themeSystemSubtitle => 'Tökua sêse tî téléphone';

  @override
  String get language => 'Yângâ';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSango => 'Sängö';

  @override
  String get languageSystem => 'Système';

  @override
  String get languageSystemSubtitle => 'Tökua sêse tî téléphone';

  @override
  String get languageFrenchSubtitle => 'Farânzi';

  @override
  String get languageEnglishSubtitle => 'Anglëe';

  @override
  String get languageSangoSubtitle => 'Bêafrîka';

  @override
  String get userGuide => 'Ndiä tî sära na';

  @override
  String get tipsAndAdvice => 'Kpälë na ndiä';

  @override
  String get artistGuide => 'Ndiä tî artiste';

  @override
  String get engineerGuide => 'Ndiä tî enjëniëre';

  @override
  String get studioGuide => 'Ndiä tî studio';

  @override
  String get messages => 'Mbëtï';

  @override
  String get noConversations => 'Bîanî tî tënë pëpe';

  @override
  String get startNewConversation => 'Kôzo bîanî tî tënë tî finî';

  @override
  String get newMessage => 'Mbëtï tî finî';

  @override
  String get loading => 'A-ga sara...';

  @override
  String get error => 'Pörö';

  @override
  String get retry => 'Tene ngbii';

  @override
  String get conversationSettings => 'Sêse';

  @override
  String get viewProfile => 'Yê profîli';

  @override
  String get viewParticipants => 'Yê âzo';

  @override
  String get information => 'Sêse';

  @override
  String get block => 'Kangbi';

  @override
  String get blockContact => 'Kangbi zo sô';

  @override
  String get blockConfirmTitle => 'Kangbi';

  @override
  String blockConfirmMessage(String name) {
    return 'Mo sü kangbi $name? Mo sï mbëtï tî lo ngbii pëpe.';
  }

  @override
  String blocked(String name) {
    return '$name a-kangbi awe';
  }

  @override
  String get report => 'Tene na ndâ';

  @override
  String get reportProblem => 'Tene pörö';

  @override
  String get reportConfirmTitle => 'Tene na ndâ';

  @override
  String get reportConfirmMessage => 'Ngâ nî mo sü tene na ndâ tî bîanî sô?';

  @override
  String get reportReason => 'Ndâ tî tene na ndâ';

  @override
  String get reportSent => 'Mbëtï tî tene na ndâ a-tö awe';

  @override
  String get leaveConversation => 'Fä bîanî';

  @override
  String get deleteFromList => 'Zïa na liste tî mo';

  @override
  String get leaveConfirmTitle => 'Fä bîanî';

  @override
  String leaveConfirmMessage(String name) {
    return 'Mo sü fä bîanî na $name? Mbëtï ôke a-zïa.';
  }

  @override
  String get leave => 'Fä';

  @override
  String get actions => 'Sara';

  @override
  String get accountSettings => 'Kömändë';

  @override
  String get credentials => 'Sêse tî duti';

  @override
  String get email => 'Email';

  @override
  String get notAvailable => 'Pëpe';

  @override
  String get changePassword => 'Sêngö tëngbi-da';

  @override
  String oauthNoPasswordReset(String provider) {
    return 'Mo duti na $provider. Sêngö tëngbi-da na sêse tî $provider.';
  }

  @override
  String get sendResetEmail => 'Tö email tî sêngö tëngbi-da';

  @override
  String emailSentTo(String email) {
    return 'Email a-tö na $email';
  }

  @override
  String get sendError => 'Pörö na tö';

  @override
  String get dangerZone => 'Ndö tî sïönî';

  @override
  String get deleteAccount => 'Zïa kömändë tî mbi';

  @override
  String get deleteAccountWarning => 'Sara sô a-kîri pëpe';

  @override
  String get deleteAccountConfirmTitle => 'Zïa kömändë';

  @override
  String get deleteAccountConfirmMessage =>
      'Mo bê töngana mo sü zïa kömändë tî mo? Sêse ôke tî mo a-bûngi. Sara sô a-kîri pëpe.';

  @override
  String get delete => 'Zïa';

  @override
  String get confirmDeletion => 'Tene éé tî zïa';

  @override
  String get enterPassword => 'Sü tëngbi-da tî mo tî tene éé:';

  @override
  String get password => 'Tëngbi-da';

  @override
  String get confirm => 'Tene éé';

  @override
  String get deletionError => 'Pörö na zïa';

  @override
  String oauthReauthRequired(String provider) {
    return 'Tî zïa kömändë tî mo, mo lîngbi tî duti ngbii na $provider.';
  }

  @override
  String continueWithProvider(String provider) {
    return 'Sü na $provider';
  }

  @override
  String get studio => 'Studio';

  @override
  String get studioProfile => 'Profîli tî studio';

  @override
  String get nameAddressContact => 'Ïrï, adresse, ndö tî bâta';

  @override
  String get services => 'Services';

  @override
  String get serviceCatalog => 'Catalogue tî services';

  @override
  String get team => 'Equipe';

  @override
  String get manageEngineers => 'Kämä enjëniëre';

  @override
  String get paymentMethods => 'Lêgë tî fûta';

  @override
  String get paymentMethodsSubtitle => 'Wâlë, virement, PayPal...';

  @override
  String get aiAssistant => 'Wala-bata IA';

  @override
  String get aiSettingsSubtitle => 'Sêse tî mbëtï otomätîki';

  @override
  String get visibility => 'Pandöö';

  @override
  String get studioVisible => 'Studio a-yê';

  @override
  String get artistsCanSee =>
      'Artiste akë lîngbi tî yê studio tî mo na tî tö demande tî session.';

  @override
  String get edit => 'Sêngö';

  @override
  String get becomeVisible => 'Bâa ködörö tî mo pandöö';

  @override
  String get artistsCantFind => 'Artiste akë lîngbi tî gï mo pëpe';

  @override
  String get claimStudio =>
      'Tene na ndâ tî studio tî mo tî pandöö na carte na tî sï demande tî session.';

  @override
  String get calendar => 'Calendrier';

  @override
  String get availability => 'Ndö tî sara';

  @override
  String get manageSlots => 'Kämä créneaux tî mbi';

  @override
  String participants(int count) {
    return '$count âzo';
  }

  @override
  String get copy => 'Kopîe';

  @override
  String get deleteMessage => 'Zïa';

  @override
  String version(String version) {
    return 'UZME v$version';
  }

  @override
  String get studiosPlatform => 'Plateforme tî studio';

  @override
  String versionBuild(String version, String build) {
    return 'Version $version ($build)';
  }

  @override
  String get legalInfo => 'Sêse tî ndiä';

  @override
  String get termsOfService => 'Ndiä tî sära na';

  @override
  String get privacyPolicy => 'Ndiä tî sêse tî mbi';

  @override
  String get legalNotices => 'Mbëtï tî ndiä';

  @override
  String get support => 'Bata';

  @override
  String get helpCenter => 'Ndö tî bata';

  @override
  String get contactUs => 'Bîanî na âla';

  @override
  String get followUs => 'Tökua âla';

  @override
  String copyright(String year) {
    return '© $year UZME. Ndiä ôke a-bâa.';
  }

  @override
  String get archive => 'Bâa na ndö';

  @override
  String get unarchive => 'Ûse na ndö';

  @override
  String get mySessions => 'Sessions tî mbi';

  @override
  String get book => 'Réserver';

  @override
  String get noSession => 'Session pëpe';

  @override
  String get enjoyYourDay => 'Nzönî lâ!';

  @override
  String get inProgressStatus => 'A-ga sara';

  @override
  String get upcomingStatus => 'A-sï';

  @override
  String get pastStatus => 'A-hûnzi';

  @override
  String get noSessions => 'Session pëpe';

  @override
  String get bookFirstSession => 'Réserver session tî kôzo tî mo';

  @override
  String get pendingStatus => 'A-tära';

  @override
  String get confirmedStatus => 'A-tene éé';

  @override
  String get completedStatus => 'A-hûnzi';

  @override
  String get cancelledStatus => 'A-lä';

  @override
  String get noShowStatus => 'A-sï pëpe';

  @override
  String hoursOfSession(int hours) {
    return '${hours}h tî session';
  }

  @override
  String sessionAt(String studio) {
    return 'Session na $studio';
  }

  @override
  String get sessionRequest => 'Demande tî session';

  @override
  String get noStudioSelected => 'Studio pëpe a-lêkë';

  @override
  String get selectStudioFirst => 'Lêkë studio kôzo tî yê ndö tî sara.';

  @override
  String get back => 'Kîri';

  @override
  String get sessionType => 'Lêgë tî session';

  @override
  String get sessionDuration => 'Ngâ tî session';

  @override
  String get chooseSlot => 'Lêkë créneau tî mo';

  @override
  String get engineerPreference => 'Lêkë enjëniëre';

  @override
  String get notesOptional => 'Mbëtï (sô mo sü)';

  @override
  String get describeProject => 'Tene na ndâ tî projet tî mo, sêse tî mo sü...';

  @override
  String get sendRequest => 'Tö demande';

  @override
  String get summaryLabel => 'Ôke na ndö ôko';

  @override
  String get noPreference => 'Préférence pëpe';

  @override
  String get engineerSelectedLabel => 'Enjëniëre a-lêkë';

  @override
  String get letStudioChoose => 'Studio a-lêkë';

  @override
  String availableCount(int count) {
    return '$count dispo';
  }

  @override
  String get requestSent => 'Demande a-tö! Studio a-kîri mbëtï na mo mbï.';

  @override
  String get slotInfoText =>
      'Créneaux vêrë a-lîngbi mingi. Mo lîngbi tî lêkë enjëniëre tî mo ngâ.';

  @override
  String get engineer => 'Enjëniëre';

  @override
  String get notSpecified => 'Pëpe';

  @override
  String get goodMorning => 'Balaö';

  @override
  String get goodAfternoon => 'Balaö';

  @override
  String get goodEvening => 'Nzönî kekerê';

  @override
  String get quickAccess => 'Ndö tî duti mbï';

  @override
  String get sessionsLabel => 'Sessions';

  @override
  String get favoritesLabel => 'Â-nzönî';

  @override
  String get preferencesLabel => 'Sêse';

  @override
  String get upcomingSessions => 'Sessions tî sï';

  @override
  String get viewAll => 'Yê ôke';

  @override
  String get noUpcomingSessions => 'Session tî sï pëpe';

  @override
  String get bookNextSession => 'Réserver session tî mo tî sô a-sï na studio';

  @override
  String get recentActivity => 'Sara tî mbï sô';

  @override
  String get noHistory => 'Mbëtï tî kôzo pëpe';

  @override
  String get completedSessionsHere => 'Sessions tî mo tî hûnzi a-pandöö ôko';

  @override
  String get waitingStatus => 'Tära';

  @override
  String get todaySessions => 'Sessions tî lâsô';

  @override
  String get today => 'Lâsô';

  @override
  String get noSessionToday => 'Session pëpe lâsô';

  @override
  String get noSessionsPlanned => 'Session pëpe a-bâa';

  @override
  String get noAssignedSessions => 'Session pëpe a-mu na mo';

  @override
  String get notConnected => 'Duti pëpe';

  @override
  String get myAvailabilities => 'Ndö tî sara tî mbi';

  @override
  String get workingHours => 'Ngâ tî sara';

  @override
  String get unavailabilities => 'Ndö tî sara pëpe';

  @override
  String get add => 'Bâa';

  @override
  String get noTimeOff => 'Ndö tî sara pëpe pëpe';

  @override
  String get addTimeOffHint => 'Bâa vacances, congés, wala ndö tî fä';

  @override
  String get myStudio => 'Studio tî mbi';

  @override
  String get overview => 'Yê ôke';

  @override
  String get session => 'Session';

  @override
  String get artist => 'Artiste';

  @override
  String get artists => 'Artiste akë';

  @override
  String get artistsLabel => 'Artiste akë';

  @override
  String get planning => 'Planning';

  @override
  String get stats => 'Stats';

  @override
  String get thisMonth => 'Nze sô';

  @override
  String get freeDay => 'Lâ tî pâsi';

  @override
  String get noSessionScheduled => 'Session pëpe a-bâa';

  @override
  String get pendingRequests => 'Demande tî tära';

  @override
  String get recentArtists => 'Artiste akë tî mbï sô';

  @override
  String get filterByStatus => 'Filtrer na statut';

  @override
  String get all => 'Ôke';

  @override
  String get confirmed => 'A-tene éé';

  @override
  String sessionCount(int count) {
    return '$count session';
  }

  @override
  String sessionsCount(int count) {
    return '$count sessions';
  }

  @override
  String get noSessionThisDay => 'Session pëpe lâ sô';

  @override
  String get noSessionTodayScheduled => 'Session pëpe a-bâa lâsô';

  @override
  String get scheduleSession => 'Bâa session';

  @override
  String get serviceCatalogTitle => 'Catalogue services';

  @override
  String get noService => 'Service pëpe';

  @override
  String get createServiceCatalog => 'Ga catalogue tî services tî mo';

  @override
  String get newService => 'Service tî finî';

  @override
  String get active => 'A-duti';

  @override
  String get inactive => 'A-duti pëpe';

  @override
  String get rooms => 'Da akë';

  @override
  String get noRooms => 'Da pëpe';

  @override
  String get createRoomsHint => 'Sêse da akë tî studio tî mo';

  @override
  String get addRoom => 'Bâa da';

  @override
  String get editRoom => 'Sêngö da';

  @override
  String get roomName => 'Ïrï tî da';

  @override
  String get roomNameHint => 'Ex: Studio A, Cabine 1...';

  @override
  String get roomDescriptionHint => 'Tene na ndâ tî da na sêse tî lo';

  @override
  String get accessType => 'Lêgë tî duti';

  @override
  String get withEngineer => 'Na enjëniëre';

  @override
  String get withEngineerDesc => 'Enjëniëre tî sön a-lîngbi';

  @override
  String get selfService => 'Tî mbi ôko';

  @override
  String get selfServiceDesc => 'Na enjëniëre pëpe';

  @override
  String get equipment => 'Matériels';

  @override
  String get equipmentHint => 'Micro, console, enceintes... (na virgule)';

  @override
  String get roomActive => 'Da a-duti';

  @override
  String get roomVisibleForBooking => 'A-pandöö tî réservation';

  @override
  String get roomHiddenForBooking => 'A-pandöö pëpe tî réservation';

  @override
  String get deleteRoom => 'Zïa da';

  @override
  String get deleteRoomConfirm => 'Mo bê töngana mo sü zïa da sô?';

  @override
  String get selectRoom => 'Lêkë da';

  @override
  String get noRoomAvailable => 'Da pëpe a-duti';

  @override
  String get restDay => 'Pâsi';

  @override
  String get inProgress => 'A-ga sara';

  @override
  String get upcoming => 'A-sï';

  @override
  String get past => 'A-hûnzi';

  @override
  String get listView => 'Yê na liste';

  @override
  String get calendarView => 'Yê na calendrier';

  @override
  String get deleteTimeOff => 'Zïa';

  @override
  String get deleteTimeOffConfirm => 'Zïa ndö tî sara pëpe sô?';

  @override
  String daysCount(int count) {
    return '$count lâ';
  }

  @override
  String daysCountPlural(int count) {
    return '$count lâ';
  }

  @override
  String get addTimeOff => 'Bâa ndö tî sara pëpe';

  @override
  String get fromDate => 'Kôzo';

  @override
  String get toDate => 'Sô';

  @override
  String get reasonOptional => 'Ngâ nî (sô mo sü)';

  @override
  String get enterCustomReason => 'Wala sü ngâ nî...';

  @override
  String get errorLoadingAvailability => 'Pörö na chargement tî ndö tî sara';

  @override
  String get available => 'Dispo';

  @override
  String get limited => 'Na ndïä';

  @override
  String get unavailable => 'Dispo pëpe';

  @override
  String slotsForDate(String date) {
    return 'Créneaux tî $date';
  }

  @override
  String get noSlotAvailable => 'Créneau pëpe a-duti';

  @override
  String get tryAnotherDate => 'Tene na lâ ôko';

  @override
  String get fullyAvailable => 'Dispo nzönî';

  @override
  String get partiallyAvailable => 'Dispo na ndïä';

  @override
  String get noEngineerAvailable => 'Enjëniëre pëpe a-duti';

  @override
  String get studioUnavailable => 'Studio a-duti pëpe';

  @override
  String get noEngineerTryAnotherDate =>
      'Enjëniëre pëpe a-duti lâ sô. Tene na lâ ôko.';

  @override
  String get chooseEngineer => 'Lêkë enjëniëre';

  @override
  String availableCountLabel(int count) {
    return '$count dispo';
  }

  @override
  String get optionalEngineerInfo =>
      'Sô mo sü: studio a-mu enjëniëre otomätîki';

  @override
  String get availableLabel => 'DISPO';

  @override
  String get unavailableLabel => 'DISPO PËPE';

  @override
  String get studioWillAssignEngineer => 'Studio a-mu enjëniëre';

  @override
  String get bookNextSessionSubtitle => 'Réserver session tî mo tî sô a-sï';

  @override
  String get emailHint => 'Email';

  @override
  String get emailRequired => 'Email a-lîngbi';

  @override
  String get emailInvalid => 'Email nzönî pëpe';

  @override
  String get passwordHint => 'Tëngbi-da';

  @override
  String get passwordRequired => 'Tëngbi-da a-lîngbi';

  @override
  String minCharacters(int count) {
    return 'Minimum $count caractères';
  }

  @override
  String get forgotPassword => 'Mo düngo tëngbi-da?';

  @override
  String get signIn => 'Duti';

  @override
  String get or => 'wala';

  @override
  String get noAccountYet => 'Kömändë pëpe?';

  @override
  String get signUp => 'Sü kömändë';

  @override
  String get demoAccess => 'Yê demo';

  @override
  String get enterEmailFirst => 'Sü email tî mo kôzo';

  @override
  String get demoMode => 'Mode Démo';

  @override
  String get browseWithoutLogin => 'Yê na duti pëpe';

  @override
  String get studioAdmin => 'Studio (Admin)';

  @override
  String get manageSessionsArtistsServices =>
      'Kämä sessions, artiste akë, services';

  @override
  String get soundEngineer => 'Enjëniëre tî sön';

  @override
  String get viewAndTrackSessions => 'Yê na tökua sessions';

  @override
  String get bookSessions => 'Réserver sessions';

  @override
  String get createAccount => 'Ga kömändë';

  @override
  String get joinCommunity => 'Duti na âla';

  @override
  String get iAm => 'Mbi sï...';

  @override
  String get orByEmail => 'wala na email';

  @override
  String get stageNameOrName => 'Ïrï tî scène wala ïrï';

  @override
  String get fullName => 'Ïrï ôke';

  @override
  String get nameRequired => 'Ïrï a-lîngbi';

  @override
  String get confirmPassword => 'Tene éé tëngbi-da';

  @override
  String get confirmationRequired => 'Tene éé a-lîngbi';

  @override
  String get passwordsDontMatch => 'Tëngbi-da akë a-kängö pëpe';

  @override
  String get createMyAccount => 'Ga kömändë tî mbi';

  @override
  String get alreadyHaveAccount => 'Kömändë fadë a-duti?';

  @override
  String get chooseYourProfile => 'Lêkë profîli tî mo';

  @override
  String get actionIsPermanent => 'Sara sô a-kîri pëpe';

  @override
  String get howToUseApp => 'Mo sü sära na app töngana nî?';

  @override
  String get iOwnStudio => 'Studio tî mbi a-duti';

  @override
  String get iWorkInStudio => 'Mbi sara na studio';

  @override
  String get iWantToBookSessions => 'Mbi sü réserver sessions';

  @override
  String get acceptBooking => 'Sï réservation';

  @override
  String get choosePaymentMethod => 'Lêkë lêgë tî fûta';

  @override
  String get noPaymentMethodConfigured =>
      'Lêgë tî fûta pëpe. Gue na Sêse > Lêgë tî fûta.';

  @override
  String get paymentMode => 'Lêgë tî fûta';

  @override
  String get depositRequested => 'Acompte a-sü';

  @override
  String get customMessageOptional => 'Mbëtï (sô mo sü)';

  @override
  String get customMessageHint => 'Ex: Singîla mingi!';

  @override
  String get totalAmount => 'Wâlë ôke';

  @override
  String get depositToPay => 'Acompte tî fûta';

  @override
  String get paymentBy => 'Fûta na';

  @override
  String ofTotalAmount(int percent) {
    return '$percent% tî wâlë ôke';
  }

  @override
  String get acceptAndSendInfo => 'Sï na tö sêse';

  @override
  String get welcome => 'Balao!';

  @override
  String get discoverAppFeatures => 'Gï töngana nî tî sära na UZME nzönî';

  @override
  String get nearbyStudios => 'Studio akë tî pëtï';

  @override
  String get discoverWhereToRecord => 'Gï ndö tî enregistrer';

  @override
  String get noStudioFound => 'Studio pëpe a-gï';

  @override
  String get enableLocationToDiscover =>
      'Zîa localisation tî gï studio akë tî pëtï';

  @override
  String get partner => 'Partner';

  @override
  String get verified => 'A-vérifier';

  @override
  String get missingStudio => 'Studio a-duti pëpe?';

  @override
  String get tellUsWhichStudio => 'Tene na âla studio nî mo gï';

  @override
  String get studioName => 'Ïrï tî studio';

  @override
  String get studioNameExample => 'Ex: Studio XYZ';

  @override
  String get pleaseEnterStudioName => 'Sü ïrï tî studio';

  @override
  String get city => 'Ködörö';

  @override
  String get cityExample => 'Ex: Bangui, Bimbo...';

  @override
  String get pleaseEnterCity => 'Sü ködörö';

  @override
  String get notesOptionalLabel => 'Mbëtï (sô mo sü)';

  @override
  String get notesHint => 'Adresse, site web, sêse...';

  @override
  String get sending => 'A-tö...';

  @override
  String get sendRequestLabel => 'Tö demande';

  @override
  String get requestSubmitted => 'Demande a-tö!';

  @override
  String get weWillVerifyAndAddStudio => 'Âla a-vérifier na bâa studio sô mbï.';

  @override
  String get searchingStudios => 'A-gï studio akë...';

  @override
  String get partnerLabel => 'Partner';

  @override
  String get newConversation => 'Bîanî tî finî';

  @override
  String get searchContact => 'Gï zo...';

  @override
  String get searchNewContact => 'Kôzo bîanî tî finî tî gï zo sô';

  @override
  String get errorLoadingContacts => 'Pörö na chargement tî âzo';

  @override
  String get user => 'Zo';

  @override
  String get contact => 'Zo';

  @override
  String get noResult => 'Ködörö pëpe';

  @override
  String get noContactAvailable => 'Zo pëpe a-duti';

  @override
  String get myContacts => 'Âzo tî mbi';

  @override
  String get searchResults => 'Ködörö tî gï';

  @override
  String get tryOtherTerms => 'Tene na mbëtï ôko';

  @override
  String get contactsWillAppearHere => 'Âzo tî mo a-pandöö ôko';

  @override
  String get noName => 'Ïrï pëpe';

  @override
  String get searchByNameOrEmail => 'Gï na ïrï wala email...';

  @override
  String get searchArtist => 'Gï artiste';

  @override
  String get typeAtLeastTwoChars => 'Sü 2 caractères kôzo tî gï artiste akë';

  @override
  String get noArtistFound => 'Artiste pëpe a-gï';

  @override
  String get artistNotRegistered =>
      'Artiste sô a-sü pëpe. Inviter lo wala ga fiche na nzönî.';

  @override
  String get link => 'Lier';

  @override
  String get createNewArtist => 'Ga artiste tî finî';

  @override
  String get artistNotOnApp =>
      'Artiste a-duti na app pëpe? Ga fiche tî lo na inviter lo';

  @override
  String get home => 'Da';

  @override
  String get favorites => 'Â-nzönî';

  @override
  String get myFavorites => 'Â-nzönî tî mbi';

  @override
  String get studios => 'Studios';

  @override
  String get studiosLabel => 'Studios';

  @override
  String get engineers => 'Enjëniëre akë';

  @override
  String get engineersLabel => 'Enjëniëre akë';

  @override
  String get noFavoriteStudio => 'Studio nzönî pëpe';

  @override
  String get noFavoriteStudios => 'Studio nzönî pëpe';

  @override
  String get exploreStudiosAndAddFavorites =>
      'Gï studio akë na bâa na â-nzönî tî mo';

  @override
  String get exploreStudiosToFavorite =>
      'Gï studio akë na bâa na â-nzönî tî mo';

  @override
  String get noFavoriteEngineer => 'Enjëniëre nzönî pëpe';

  @override
  String get noFavoriteEngineers => 'Enjëniëre nzönî pëpe';

  @override
  String get discoverEngineersAndAddFavorites =>
      'Gï enjëniëre akë na bâa na â-nzönî tî mo';

  @override
  String get discoverEngineersToFavorite =>
      'Gï enjëniëre akë na bâa na â-nzönî tî mo';

  @override
  String get noFavoriteArtists => 'Artiste nzönî pëpe';

  @override
  String get addArtistsToFavorite => 'Bâa artiste akë na â-nzönî tî mo';

  @override
  String get prosLabel => 'Pros';

  @override
  String get noFavoritePros => 'Pro nzönî pëpe';

  @override
  String get discoverProsToFavorite => 'Gï pro akë na bâa na â-nzönî tî mo';

  @override
  String get unnamed => 'Ïrï pëpe';

  @override
  String get claimStudioTitle => 'Studio tî mbi';

  @override
  String get nearbyStudiosTitle => 'Studio akë tî pëtï';

  @override
  String get selectStudioToClaim => 'Lêkë studio tî mo tî tene na ndâ';

  @override
  String get connectGoogleCalendarDesc =>
      'Bâa Google Calendar tî mo tî synchroniser ndö tî sara otomätîki.';

  @override
  String get connectGoogleCalendar => 'Bâa Google Calendar';

  @override
  String get claimYourStudioTitle => 'Tene na ndâ tî studio tî mo';

  @override
  String get claimYourStudio => 'Tene na ndâ tî studio tî mo';

  @override
  String get claimYourStudioDesc =>
      'Bâa studio tî mo pandöö na artiste akë na sï demande tî session.';

  @override
  String get claimStudioDescription =>
      'Bâa studio tî mo pandöö na artiste akë na sï demande tî session.';

  @override
  String get noStudioFoundNearby => 'Studio pëpe a-gï na pëtï';

  @override
  String get createStudioManually => 'Ga studio tî mo na nzönî ôko';

  @override
  String get createStudioManuallyBelow => 'Ga studio tî mo na nzönî ôko';

  @override
  String get studioNotAppearing => 'Studio tî mbi a-pandöö pëpe';

  @override
  String get studioNotListed => 'Studio tî mbi a-pandöö pëpe';

  @override
  String get createStudioProfileManually => 'Ga profîli tî studio na nzönî';

  @override
  String get createManualProfile => 'Ga profîli tî studio na nzönî';

  @override
  String get claimThisStudio => 'Tene na ndâ tî studio sô?';

  @override
  String get claimStudioExplanation =>
      'Na tene na ndâ tî studio sô, mo bâa lo pandöö na artiste akë na UZME. Ala lîngbi tî yê ndö tî sara tî mo na tî tö demande tî session.';

  @override
  String get claimStudioInfo =>
      'Na tene na ndâ tî studio sô, mo bâa lo pandöö na artiste akë na UZME. Ala lîngbi tî yê ndö tî sara tî mo na tî tö demande tî session.';

  @override
  String get claim => 'Tene na ndâ';

  @override
  String studioClaimedSuccess(String name) {
    return '$name a-tene na ndâ nzönî!';
  }

  @override
  String get studioClaims => 'Demande tî studio';

  @override
  String get studioClaimsSubtitle => 'Sï wala lä demande akë';

  @override
  String get unclaim => 'Ûse';

  @override
  String get unclaimStudioTitle => 'Ûse studio?';

  @override
  String unclaimStudioMessage(String name) {
    return 'Mo bê töngana mo sü ûse \"$name\"? Studio tî mo a-pandöö na artiste akë pëpe ngbii.';
  }

  @override
  String get studioUnclaimed => 'Studio a-ûse nzönî';

  @override
  String get configurePayments => 'Sêse fûta tî mo';

  @override
  String get paymentOptionsDescription =>
      'Lêgë sô a-mu na artiste akë na tene éé tî réservation.';

  @override
  String get defaultDeposit => 'Acompte tî kôzo';

  @override
  String get depositPercentDescription =>
      'Pourcentage tî wâlë ôke tî sü na acompte';

  @override
  String get acceptedPaymentMethods => 'Lêgë tî fûta a-sï';

  @override
  String get instructionsOptional => 'Ndiä (sô mo sü)';

  @override
  String get instructionsHint => 'Ex: Bâa ïrï tî artiste na référence';

  @override
  String get paypalEmail => 'Email PayPal';

  @override
  String get cardInfo => 'Sêse';

  @override
  String get details => 'Sêse ôke';

  @override
  String get iban => 'IBAN';

  @override
  String get createMyStudio => 'Ga studio tî mbi';

  @override
  String get studioNameRequired => 'Ïrï tî studio *';

  @override
  String get studioNameHint => 'Ex: Studio Harmonie';

  @override
  String get studioNameRequiredError => 'Ïrï tî studio a-lîngbi';

  @override
  String get studioNameIsRequired => 'Ïrï tî studio a-lîngbi';

  @override
  String get description => 'Na ndâ';

  @override
  String get describeStudioHint => 'Tene na ndâ tî studio tî mo...';

  @override
  String get describeYourStudio => 'Tene na ndâ tî studio tî mo...';

  @override
  String get location => 'Ndö';

  @override
  String get address => 'Adresse';

  @override
  String get addressHint => 'Ex: 123 rue tî Mûzîki';

  @override
  String get postalCode => 'Code postal';

  @override
  String get cityRequired => 'Ködörö *';

  @override
  String get cityRequiredError => 'Ködörö a-lîngbi';

  @override
  String get cityIsRequired => 'Ködörö a-lîngbi';

  @override
  String get phone => 'Téléphone';

  @override
  String get phoneHint => '06 12 34 56 78';

  @override
  String get website => 'Site web';

  @override
  String get websiteHint => 'https://www.monstudio.com';

  @override
  String get offeredServices => 'Services a-mu';

  @override
  String get servicesOffered => 'Services a-mu';

  @override
  String get creating => 'A-ga ga...';

  @override
  String get creatingInProgress => 'A-ga ga...';

  @override
  String get studioCreatedSuccess => 'Studio a-ga nzönî!';

  @override
  String get manualCreation => 'Ga na nzönî';

  @override
  String get studioVisibleAfterCreation =>
      'Studio tî mo a-pandöö na artiste akë mbï. Mo lîngbi tî sêngö profîli tî mo mbï sô.';

  @override
  String get manualCreationDescription =>
      'Studio tî mo a-pandöö na artiste akë mbï. Mo lîngbi tî sêngö profîli tî mo mbï sô.';

  @override
  String get editSession => 'Sêngö session';

  @override
  String get newSession => 'Session tî finî';

  @override
  String get dateAndTime => 'Lâ na ngâ';

  @override
  String get duration => 'Ngâ';

  @override
  String get save => 'Bâa';

  @override
  String get createSession => 'Ga session';

  @override
  String get addArtistFirst => 'Bâa artiste kôzo';

  @override
  String get selectArtist => 'Lêkë artiste';

  @override
  String get addAnotherArtist => 'Bâa artiste ôko';

  @override
  String get allArtistsSelected => 'Artiste ôke a-lêkë fadë';

  @override
  String get selectAtLeastOneArtist => 'Lêkë artiste ôko kôzo';

  @override
  String get deleteSession => 'Zïa session';

  @override
  String get actionIrreversible => 'Sara sô a-kîri pëpe.';

  @override
  String get editService => 'Sêngö service';

  @override
  String get newServiceTitle => 'Service tî finî';

  @override
  String get serviceName => 'Ïrï tî service';

  @override
  String get serviceNameHint => 'Ex: Mix, Mastering, Recording...';

  @override
  String get fieldRequired => 'Ndö sô a-lîngbi';

  @override
  String get serviceDescription => 'Na ndâ (sô mo sü)';

  @override
  String get serviceDescriptionHint => 'Na ndâ tî service...';

  @override
  String get hourlyRate => 'Tarif na ngâ (€)';

  @override
  String get perHour => '€/h';

  @override
  String get invalidNumber => 'Nombre nzönî pëpe';

  @override
  String get minimumDuration => 'Ngâ minimum';

  @override
  String get serviceActive => 'Service a-duti';

  @override
  String get availableForBooking => 'A-duti tî réservation';

  @override
  String get notAvailableForBooking => 'A-duti pëpe';

  @override
  String get createService => 'Ga service';

  @override
  String get deleteService => 'Zïa service';

  @override
  String get teamMembers => 'Âzo tî equipe';

  @override
  String get pendingInvitations => 'Invitation akë tî tära';

  @override
  String get noMember => 'Zo pëpe';

  @override
  String get addEngineersToTeam => 'Bâa enjëniëre akë na equipe tî mo';

  @override
  String get noInvitation => 'Invitation pëpe';

  @override
  String get pendingInvitationsHere => 'Invitation akë tî tära a-pandöö ôko';

  @override
  String get codeCopied => 'Code a-kopîe';

  @override
  String get removeFromTeam => 'Ûse na equipe';

  @override
  String get removeMemberConfirm => 'Ûse zo sô?';

  @override
  String memberNoAccessAnymore(String name) {
    return '$name a-lîngbi tî yê sessions tî studio pëpe ngbii.';
  }

  @override
  String get memberRemoved => 'Zo a-ûse';

  @override
  String get remove => 'Ûse';

  @override
  String get invitationCancelled => 'Invitation a-lä';

  @override
  String get addMember => 'Bâa zo';

  @override
  String get searchByEmailOrInvite =>
      'Gï na email wala inviter enjëniëre tî finî';

  @override
  String get userNotRegistered => 'Zo sô a-sü pëpe';

  @override
  String get sendInvitationToJoin =>
      'Tö invitation na lo tî duti na equipe tî mo.';

  @override
  String get sendInvitation => 'Tö invitation';

  @override
  String get enterValidEmail => 'Sü email nzönî';

  @override
  String get invitationCreated => 'Invitation a-ga';

  @override
  String get shareCodeWithEngineer => 'Kêtê code sô na enjëniëre:';

  @override
  String get searchArtistHint => 'Gï artiste...';

  @override
  String get noArtistEmpty => 'Artiste pëpe';

  @override
  String get addFirstArtist => 'Bâa artiste tî kôzo tî mo';

  @override
  String get addArtist => 'Bâa artiste';

  @override
  String get tryAnotherSearch => 'Tene na mbëtï ôko';

  @override
  String get search => 'Gï';

  @override
  String get create => 'Ga';

  @override
  String get findExistingArtist => 'Gï artiste tî duti fadë';

  @override
  String get searchAmongRegistered =>
      'Gï artiste akë tî sü fadë na UZME tî lier na studio tî mo.';

  @override
  String artistAddedToStudio(String name) {
    return '$name a-bâa na studio tî mo!';
  }

  @override
  String get artistName => 'Ïrï tî artiste';

  @override
  String get stageNameHint => 'Ïrï tî scène...';

  @override
  String get civilName => 'Ïrï tî lêgë';

  @override
  String get firstAndLastName => 'Ïrï kôzo na ïrï tî da...';

  @override
  String get emailHintArtist => 'Email tî artiste...';

  @override
  String get emailRequiredForInvitation => 'Email a-lîngbi tî invitation';

  @override
  String get phoneOptional => 'Téléphone (sô mo sü)';

  @override
  String get phoneHintGeneric => 'Téléphone...';

  @override
  String get musicalGenres => 'Lêgë tî mûzîki';

  @override
  String get sendInvitationToggle => 'Tö invitation';

  @override
  String get artistWillReceiveCode =>
      'Artiste a-sï code tî duti na studio tî mo';

  @override
  String get createAndInvite => 'Ga na inviter';

  @override
  String get createProfile => 'Ga fiche';

  @override
  String get createArtistProfile => 'Ga fiche tî artiste';

  @override
  String get createProfileAndInvite =>
      'Ga fiche na inviter artiste. Kömändë tî lo a-lier otomätîki na lo duti.';

  @override
  String get artistCreated => 'Artiste a-ga!';

  @override
  String get shareCodeWithArtist =>
      'Kêtê code sô na artiste tî duti na studio tî mo';

  @override
  String get share => 'Kêtê';

  @override
  String get done => 'Awe';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get markAllRead => 'Bâa ôke lu';

  @override
  String get markAllAsRead => 'Bâa ôke lu';

  @override
  String get noNotification => 'Notification pëpe';

  @override
  String get noNotifications => 'Notification pëpe';

  @override
  String get notifiedForNewSessions =>
      'Mo a-sï notification tî session akë tî finî';

  @override
  String get notifyNewSessions => 'Mo a-sï notification tî session akë tî finî';

  @override
  String get loadingError => 'Pörö na charger';

  @override
  String get personalInformation => 'Sêse tî mbi';

  @override
  String get fullNameLabel => 'Ïrï ôke';

  @override
  String get required => 'A-lîngbi';

  @override
  String get stageName => 'Ïrï tî scène';

  @override
  String get bio => 'Bio';

  @override
  String get tellAboutYourself => 'Tene na ndâ tî mo...';

  @override
  String get accountSection => 'Kömändë';

  @override
  String get changePasswordAction => 'Sêngö tëngbi-da';

  @override
  String get logoutAction => 'Fä';

  @override
  String get signOut => 'Fä';

  @override
  String get deleteMyAccount => 'Zïa kömändë tî mbi';

  @override
  String get resetEmailSent => 'Email tî sêngö a-tö';

  @override
  String get deleteAccountTitle => 'Zïa kömändë';

  @override
  String get deleteAccountFinalWarning =>
      'Sara sô a-kîri pëpe. Sêse ôke tî mo a-zïa.';

  @override
  String get sessionTracking => 'Tökua session';

  @override
  String hoursPlanned(int hours) {
    return '${hours}h a-bâa';
  }

  @override
  String get checkIn => 'Pointage';

  @override
  String get checkInArrival => 'Pointer arrivée';

  @override
  String get arrivalChecked => 'Arrivée a-pointer';

  @override
  String get checkOutDeparture => 'Pointer départ';

  @override
  String get sessionNotes => 'Mbëtï tî session';

  @override
  String get addSessionNotes => 'Bâa mbëtï na session...';

  @override
  String get photos => 'Photos';

  @override
  String get addPhoto => 'Bâa';

  @override
  String get sessionNotFound => 'Session a-düngö pëpe';

  @override
  String get notesSaved => 'Notes a-bâa na ndö';

  @override
  String get photoAdded => 'Photo a-äpe';

  @override
  String get photoUploadError => 'Problème na tëngö tî photo';

  @override
  String get arrivalCheckedSuccess => 'Arrivée a-pointer!';

  @override
  String get endSession => 'Hûnzi session?';

  @override
  String get endSessionConfirm =>
      'Mo sü pointer départ tî mo na hûnzi session sô?';

  @override
  String get finish => 'Hûnzi';

  @override
  String get contactArtist => 'Bîanî na artiste';

  @override
  String get reportProblemAction => 'Tene pörö';

  @override
  String get editArtist => 'Sêngö artiste';

  @override
  String get newArtistTitle => 'Artiste tî finî';

  @override
  String get emailHintGeneric => 'Email...';

  @override
  String get cityHint => 'Ködörö...';

  @override
  String get bioOptional => 'Bio (sô mo sü)';

  @override
  String get fewWordsAboutArtist => 'Mbëtï na ndâ tî artiste...';

  @override
  String get createArtist => 'Ga artiste';

  @override
  String get deleteArtist => 'Zïa artiste';

  @override
  String get calendarTitle => 'Calendrier';

  @override
  String get unavailabilityAdded => 'Ndö tî sara pëpe a-bâa';

  @override
  String get unavailabilityDeleted => 'Ndö tî sara pëpe a-zïa';

  @override
  String get calendarConnected => 'Calendrier a-bâa';

  @override
  String get never => 'Pëpe';

  @override
  String get lastSync => 'Sync tî sô a-hûnzi';

  @override
  String get synchronize => 'Synchroniser';

  @override
  String get disconnect => 'Ûse';

  @override
  String get disconnectCalendar => 'Ûse calendrier?';

  @override
  String get disconnectCalendarWarning =>
      'Ndö tî sara pëpe tî synchroniser a-zïa. Ndö tî sara pëpe tî nzönî a-duti.';

  @override
  String get tipsSectionGettingStarted => 'Kôzo';

  @override
  String get tipsSectionBookings => 'Réservations';

  @override
  String get tipsSectionProTips => 'Kpälë tî pro';

  @override
  String get tipsSectionSetup => 'Sêse';

  @override
  String get tipsSectionSessions => 'Sessions';

  @override
  String get tipsSectionTips => 'Kpälë';

  @override
  String get tipsSectionStudioSetup => 'Sêse tî studio';

  @override
  String get tipsSectionTeamManagement => 'Kämä equipe';

  @override
  String get tipsSectionVisibility => 'Pandöö';

  @override
  String get tipExploreMapTitle => 'Gï na carte';

  @override
  String get tipExploreMapDesc =>
      'Carte a-pandöö studio ôke tî pëtï tî mo. Pin vêrë sï studio partner. Zoom na gue tî gï studio akë mingi.';

  @override
  String get tipCompleteProfileTitle => 'Hûnzi profîli tî mo';

  @override
  String get tipCompleteProfileDesc =>
      'Profîli ôke na photo na lêgë tî mûzîki a-bata studio akë tî hînga mo nzönî. Gue na Sêse > Profîli tî mbi.';

  @override
  String get tipChooseSlotTitle => 'Lêkë créneau nzönî';

  @override
  String get tipChooseSlotDesc =>
      'Créneaux vêrë a-tene enjëniëre mingi a-duti. Créneaux orange a-na ndïä. Lêkë créneaux vêrë tî duti nzönî.';

  @override
  String get tipSelectEngineerTitle => 'Lêkë enjëniëre tî mo';

  @override
  String get tipSelectEngineerDesc =>
      'Mo lîngbi tî lêkë enjëniëre wala studio a-mu. Töngana mo sara na zo kôzo fadë, gï lo na liste!';

  @override
  String get tipPrepareSessionTitle => 'Ga session tî mo prêt';

  @override
  String get tipPrepareSessionDesc =>
      'Sära na ndö \"Mbëtï\" tî tene na ndâ tî projet tî mo: style, référence, sêse tî mo sü. Lo a-bata enjëniëre.';

  @override
  String get tipBookAdvanceTitle => 'Réserver kôzo';

  @override
  String get tipBookAdvanceDesc =>
      'Créneaux nzönî a-fä mbï! Réserver 2-3 lâ kôzo tî gï ngâ na enjëniëre akë.';

  @override
  String get tipManageFavoritesTitle => 'Kämä â-nzönî tî mo';

  @override
  String get tipManageFavoritesDesc =>
      'Bâa studio akë nzönî tî mo na â-nzönî tî gï ala mbï. Appuyer na coeur na page tî studio.';

  @override
  String get tipTrackSessionsTitle => 'Tökua sessions tî mo';

  @override
  String get tipTrackSessionsDesc =>
      'Na onglet Sessions, gï mbëtï ôke tî mo. Nzönî tî réserver ngbii na enjëniëre wala studio kängö.';

  @override
  String get tipSetScheduleTitle => 'Bâa ngâ tî sara tî mo';

  @override
  String get tipSetScheduleDesc =>
      'Gue na Sêse > Ndö tî sara tî sêse lâ na ngâ tî sara tî mo. Artiste akë a-lîngbi réserver na créneaux tî mo ôko.';

  @override
  String get tipAddUnavailabilityTitle => 'Bâa ndö tî sara pëpe tî mo';

  @override
  String get tipAddUnavailabilityDesc =>
      'Vacances, RDV, wala lâ tî pâsi? Bâa ndö tî sara pëpe tî kangbi ngâ sô. Mo lîngbi bâa ngâ nî.';

  @override
  String get tipViewSessionsTitle => 'Yê sessions tî mo';

  @override
  String get tipViewSessionsDesc =>
      'Onglet Sessions a-pandöö sessions ôke tî sï. Sessions \"A-tene éé\" nzönî, \"A-tära\" a-tära studio.';

  @override
  String get tipStartSessionTitle => 'Kôzo session';

  @override
  String get tipStartSessionDesc =>
      'Lâ sô, appuyer na \"Kôzo\" tî lancer chrono. Na hûnzi, appuyer na \"Hûnzi\" na bâa mbëtï tî session.';

  @override
  String get tipSessionNotesTitle => 'Mbëtï tî session';

  @override
  String get tipSessionNotesDesc =>
      'Na session ôke, bâa mbëtï: sêse, fichiers, remarques. Nzönî tî mo na artiste.';

  @override
  String get tipStayUpdatedTitle => 'Bâa sêse tî mo na lâ';

  @override
  String get tipStayUpdatedDesc =>
      'Sêngö ndö tî sara tî mo na lâ. Planning nzönî = réservation mingi tî mo!';

  @override
  String get tipProfileMattersTitle => 'Profîli tî mo a-lîngbi';

  @override
  String get tipProfileMattersDesc =>
      'Artiste akë lîngbi tî lêkë mo. Photo nzönî na bio na spécialités tî mo a-bata mingi.';

  @override
  String get tipCompleteStudioProfileTitle => 'Hûnzi profîli tî studio tî mo';

  @override
  String get tipCompleteStudioProfileDesc =>
      'Bâa photos, na ndâ, matériels na services. Profîli ôke a-pandöö kôzo na artiste akë mingi a-sï.';

  @override
  String get tipSetStudioHoursTitle => 'Bâa ngâ tî sara';

  @override
  String get tipSetStudioHoursDesc =>
      'Sêse ngâ tî sû tî studio na Sêse. Artiste akë a-lîngbi réserver na ngâ sô ôko.';

  @override
  String get tipAddServicesTitle => 'Bâa services tî mo';

  @override
  String get tipAddServicesDesc =>
      'Enregistrement, mix, mastering... Bâa services na tarifs tî ala. Lo a-bata artiste akë tî lêkë.';

  @override
  String get tipInviteEngineersTitle => 'Inviter enjëniëre akë tî mo';

  @override
  String get tipInviteEngineersDesc =>
      'Gue na Equipe > Inviter tî bâa enjëniëre akë. Ala a-sï lien tî duti na studio tî mo.';

  @override
  String get tipManageAvailabilitiesTitle => 'Kämä ndö tî sara';

  @override
  String get tipManageAvailabilitiesDesc =>
      'Enjëniëre ôke a-kämä ndö tî sara tî ala. Mo lîngbi yê ôke na planning tî studio.';

  @override
  String get tipAssignSessionsTitle => 'Mu sessions';

  @override
  String get tipAssignSessionsDesc =>
      'Na artiste lêkë enjëniëre pëpe, mo a-mu lo. Vérifier ndö tî sara kôzo.';

  @override
  String get tipManageRequestsTitle => 'Kämä demande akë';

  @override
  String get tipManageRequestsDesc =>
      'Demande tî finî a-pandöö na \"A-tära\". Tene éé mbï tî bâa artiste akë nzönî!';

  @override
  String get tipInviteArtistsTitle => 'Inviter artiste akë tî mo';

  @override
  String get tipInviteArtistsDesc =>
      'Artiste akë tî mo a-sï? Inviter ala na Clients > Inviter. Ala a-lîngbi réserver mbï.';

  @override
  String get tipTrackActivityTitle => 'Tökua sara';

  @override
  String get tipTrackActivityDesc =>
      'Dashboard a-pandöö stats: sessions tî nze, wâlë, artiste akë. Yê sara tî mo.';

  @override
  String get tipBecomePartnerTitle => 'Duti partner';

  @override
  String get tipBecomePartnerDesc =>
      'Studio partner a-pandöö na vêrë na carte na kôzo. Bîanî na âla tî hînga mingi!';

  @override
  String get tipEncourageReviewsTitle => 'Sü avis akë';

  @override
  String get tipEncourageReviewsDesc =>
      'Na session nzönî, inviter artiste tî bâa avis. Avis nzönî a-bata artiste akë mingi.';

  @override
  String get tipsSectionAIAssistant => 'Wala-bata IA';

  @override
  String get tipAIAssistantTitle => 'Tene na wala-bata tî mo';

  @override
  String get tipAIAssistantDesc =>
      'Wala-bata IA a-hînga sêse ôke tî mo. Sü lo sessions, stats, wala bata tî sêse ôke!';

  @override
  String get tipAIActionsTitle => 'Sara na tënë';

  @override
  String get tipAIActionsStudioDesc =>
      'Mo lîngbi sü wala-bata tî ga sessions, sï réservations, kämä services... Ôke na chat!';

  @override
  String get tipAIActionsEngineerDesc =>
      'Sü wala-bata tî kôzo wala hûnzi sessions tî mo, kämä ndö tî sara pëpe, na mingi.';

  @override
  String get tipAIActionsArtistDesc =>
      'Wala-bata lîngbi gï studios, kämä â-nzönî tî mo, ga demande tî réservation tî mo.';

  @override
  String get tipAIContextTitle => 'Lo hînga mo';

  @override
  String get tipAIContextDesc =>
      'Wala-bata hînga zo nî mo na lo sêngö mbëtï tî lo na profîli tî mo. Lo lîngbi yê sêse tî mo na ngâ tî kängö.';

  @override
  String get teamInvitations => 'Invitation akë tî equipe';

  @override
  String get noEmailConfigured => 'Email a-sêse pëpe';

  @override
  String get noInvitations => 'Invitation pëpe';

  @override
  String get noInvitationsDescription => 'Invitation tî tära pëpe na mo.';

  @override
  String invitationSentOn(String date) {
    return 'A-tö lâ $date';
  }

  @override
  String teamInvitationMessage(String studioName) {
    return '$studioName a-inviter mo tî duti na equipe tî lo töngana enjëniëre tî sön.';
  }

  @override
  String expiresOn(String date) {
    return 'A-hûnzi lâ $date';
  }

  @override
  String get decline => 'Lä';

  @override
  String get accept => 'Sï';

  @override
  String get invitationAccepted => 'Invitation a-sï! Mo duti na equipe fadë.';

  @override
  String get declineInvitation => 'Lä invitation';

  @override
  String declineInvitationConfirm(String studioName) {
    return 'Mo bê töngana mo sü lä invitation tî $studioName?';
  }

  @override
  String get invitationDeclined => 'Invitation a-lä.';

  @override
  String get errorOccurred => 'Pörö a-sï';

  @override
  String get sessionDetails => 'Sêse tî session';

  @override
  String get toBeAssigned => 'Studio a-mu';

  @override
  String get acceptSession => 'Sï session';

  @override
  String get confirmAcceptSession => 'Mo sü sï demande tî session sô?';

  @override
  String get sessionAccepted => 'Session a-sï!';

  @override
  String get declineSession => 'Lä session';

  @override
  String get confirmDeclineSession => 'Mo sü lä demande tî session sô?';

  @override
  String get sessionDeclined => 'Session a-lä';

  @override
  String get cancelSession => 'Lä session';

  @override
  String get confirmCancelSession =>
      'Mo sü lä session sô? Sara sô a-kîri pëpe.';

  @override
  String get bic => 'BIC / SWIFT';

  @override
  String get accountHolder => 'Ïrï tî compte';

  @override
  String get bankName => 'Ïrï tî banque';

  @override
  String get cancellationPolicy => 'Ndiä tî lä';

  @override
  String get cancellationPolicyDescription => 'Bâa ndiä tî kîri wâlë na lä';

  @override
  String get customCancellationTerms => 'Ndiä tî mbi';

  @override
  String get customCancellationHint => 'Tene na ndâ tî ndiä tî lä tî mo...';

  @override
  String get saveAsDefault => 'Bâa töngana kôzo';

  @override
  String get saveAsDefaultDescription =>
      'Sära na lêkë sô tî sessions tî sô a-sï';

  @override
  String get proposeToEngineers => 'Proposer';

  @override
  String get assignLater => 'Mbï sô';

  @override
  String get assignLaterDescription =>
      'Mo lîngbi mu enjëniëre na sêse tî session';

  @override
  String get selectAtLeastOne => 'Lêkë 1 kôzo';

  @override
  String get assignEngineer => 'Enjëniëre tî sön';

  @override
  String get noEngineersAvailable => 'Enjëniëre pëpe a-duti tî créneau sô';

  @override
  String get proposedSessions => 'Sessions a-proposer';

  @override
  String get proposedSessionsEmpty => 'Proposition pëpe a-tära';

  @override
  String get acceptProposal => 'Sï';

  @override
  String get declineProposal => 'Lä';

  @override
  String get joinAsCoEngineer => 'Duti na';

  @override
  String get sessionProposedToYou => 'Session a-proposer';

  @override
  String get sessionTaken => 'Session a-lêkë';

  @override
  String get sessionTakenDesc =>
      'Enjëniëre ôko a-sï session sô. Mo lîngbi sü tî duti na.';

  @override
  String get requestToJoin => 'Sü tî duti na';

  @override
  String get joinedAsCoEngineer => 'Mo duti na session!';

  @override
  String get proposalAccepted => 'Proposition a-sï!';

  @override
  String get proposalDeclined => 'Proposition a-lä';

  @override
  String get youAreAssigned => 'Mo a-mu';

  @override
  String get pendingProposal => 'A-tära';

  @override
  String get openingHours => 'Ngâ tî sû';

  @override
  String get openingHoursSubtitle => 'Bâa ngâ tî sû tî studio tî mo';

  @override
  String get noOpeningHoursConfigured => 'Ngâ tî sû pëpe a-sêse';

  @override
  String get openingHoursSaved => 'Ngâ a-bâa';

  @override
  String get allowNoEngineer => 'Réservation na enjëniëre pëpe';

  @override
  String get allowNoEngineerSubtitle =>
      'Artiste akë lîngbi réserver na enjëniëre pëpe a-duti';

  @override
  String get settingsSaved => 'Sêse a-bâa';

  @override
  String get selectStudio => 'Lêkë studio';

  @override
  String get selectStudioDescription => 'Lêkë studio tî session tî mo';

  @override
  String get noLinkedStudios => 'Studio pëpe a-lier';

  @override
  String get noLinkedStudiosDescription =>
      'Studio pëpe a-lier na mo. Gï studio akë tî kôzo.';

  @override
  String get discoverStudios => 'Gï studio akë';

  @override
  String get exploreMapHint => 'Gï na carte tî gï studio akë tî pëtï';

  @override
  String get exploreStudiosTitle => 'Gï na carte';

  @override
  String get exploreStudiosDescription =>
      'Glisser liste na ngö tî yê carte na gï studio akë tî pëtï. Cliquer na studio tî yê sêse tî lo na bîanî na lo.';

  @override
  String get understood => 'Mbi hînga';

  @override
  String get changePhoto => 'Sêngö photo';

  @override
  String get takePhoto => 'Lêkë photo';

  @override
  String get useCamera => 'Sära na caméra';

  @override
  String get chooseFromGallery => 'Lêkë na galerie';

  @override
  String get selectExistingPhoto => 'Lêkë photo tî duti';

  @override
  String get photoUpdated => 'Photo a-sêngö';

  @override
  String get aiGuideTitle => 'Ndiä tî wala-bata IA';

  @override
  String get aiGuideHeaderTitle => 'Wala-bata tî mo';

  @override
  String get aiGuideHeaderSubtitle => 'Gï ôke tî IA lîngbi ga tî mo';

  @override
  String get aiGuideSecurityTitle => 'Na nzönî tî mo na ngâ ôke';

  @override
  String get aiGuideSecurityDesc =>
      'Wala-bata a-sü mo tene éé kôzo tî ga sara ôke. Ködörö a-ga na tene éé tî mo pëpe.';

  @override
  String get aiGuideIntroTitle => 'Lo sara töngana nî?';

  @override
  String get aiGuideWhatIsTitle => 'Wala-bata intelligent';

  @override
  String get aiGuideWhatIsDesc =>
      'Wala-bata IA a-hînga mbëtï tî mo na lîngbi yê sêse tî mo wala ga sara tî mo. Sü lo sêse wala sü lo tî sara!';

  @override
  String get aiGuideConfirmTitle => 'Tene éé a-lîngbi';

  @override
  String get aiGuideConfirmDesc =>
      'Kôzo sara ôke (réservation, lä, sêngö...), wala-bata a-tene na mo sêse tî lo sü ga na tära tene éé tî mo. Mo kämä ôke.';

  @override
  String get aiGuideReadTitle => 'Sêse tî IA lîngbi yê';

  @override
  String get aiGuideActionsTitle => 'Sara akë tî lîngbi';

  @override
  String get aiGuideExamplesTitle => 'Kpälë tî demande';

  @override
  String get aiGuideSessionsTitle => 'Sessions tî mo';

  @override
  String get aiGuideArtistSessionsDesc =>
      'Yê réservations tî mo tî hûnzi, tî fadë wala tî sï. Filtrer na lâ wala statut.';

  @override
  String get aiGuideEngineerSessionsDesc =>
      'Yê sessions tî mu na mo, propositions tî tära na planning tî mo.';

  @override
  String get aiGuideStudioSessionsDesc =>
      'Yê sessions ôke tî studio tî mo, filtrer na statut, lâ wala artiste.';

  @override
  String get aiGuideAvailabilityTitle => 'Ndö tî sara';

  @override
  String get aiGuideAvailabilityDesc =>
      'Vérifier créneaux tî duti tî studio tî lâ nî.';

  @override
  String get aiGuideConversationsTitle => 'Bîanî akë';

  @override
  String get aiGuideConversationsDesc =>
      'Yê bîanî akë tî mbï sô na mbëtï tî lu pëpe.';

  @override
  String get aiGuideTimeOffTitle => 'Ndö tî sara pëpe tî mo';

  @override
  String get aiGuideTimeOffDesc =>
      'Yê ngâ tî sara pëpe tî mo (vacances, congés...).';

  @override
  String get aiGuidePendingTitle => 'Demande akë tî tära';

  @override
  String get aiGuidePendingDesc =>
      'Yê demande ôke tî réservation tî tära mbëtï tî mo.';

  @override
  String get aiGuideStatsTitle => 'Stats';

  @override
  String get aiGuideStatsDesc =>
      'Yê sêse tî sessions tî mo (a-hûnzi, a-tära, a-lä) na ngâ nî.';

  @override
  String get aiGuideRevenueTitle => 'Rapport tî wâlë';

  @override
  String get aiGuideRevenueDesc =>
      'Ga rapport tî wâlë ôke, na service, enjëniëre wala lâ.';

  @override
  String get aiGuideTeamTitle => 'Equipe tî mo';

  @override
  String get aiGuideTeamDesc =>
      'Yê enjëniëre akë tî equipe tî mo na ndö tî sara tî ala.';

  @override
  String get aiGuideBookingTitle => 'Réserver session';

  @override
  String get aiGuideBookingDesc =>
      'Sü IA tî ga demande tî réservation. Lo a-bata mo tî lêkë studio, service, lâ na créneau.';

  @override
  String get aiGuideFavoritesTitle => 'Kämä â-nzönî';

  @override
  String get aiGuideFavoritesDesc =>
      'Bâa wala ûse studio akë na â-nzönî tî mo, wala yê liste tî â-nzönî tî mo.';

  @override
  String get aiGuideSearchStudiosTitle => 'Gï studio akë';

  @override
  String get aiGuideSearchStudiosDesc =>
      'Gï studio akë na ïrï, ködörö wala lêgë tî service.';

  @override
  String get aiGuideSendMessageTitle => 'Tö mbëtï';

  @override
  String get aiGuideSendMessageDesc =>
      'Tö mbëtï na studio wala artiste na wala-bata.';

  @override
  String get aiGuideStartSessionTitle => 'Kôzo session';

  @override
  String get aiGuideStartSessionDesc =>
      'Pointer arrivée tî mo na kôzo session tî tene éé lâ sô.';

  @override
  String get aiGuideCompleteSessionTitle => 'Hûnzi session';

  @override
  String get aiGuideCompleteSessionDesc =>
      'Bâa session töngana a-hûnzi na bâa mbëtï.';

  @override
  String get aiGuideRespondProposalTitle => 'Kîri mbëtï tî proposition';

  @override
  String get aiGuideRespondProposalDesc =>
      'Sï wala lä sessions tî studio a-proposer na mo.';

  @override
  String get aiGuideManageTimeOffTitle => 'Kämä ndö tî sara pëpe';

  @override
  String get aiGuideManageTimeOffDesc =>
      'Bâa wala zïa ngâ tî sara pëpe (vacances, RDV...).';

  @override
  String get aiGuideAcceptDeclineTitle => 'Sï/Lä demande akë';

  @override
  String get aiGuideAcceptDeclineDesc =>
      'Kämä demande tî réservation na sï wala lä na wala-bata.';

  @override
  String get aiGuideRescheduleTitle => 'Sêngö ngâ tî session';

  @override
  String get aiGuideRescheduleDesc =>
      'Sêngö lâ wala ngâ tî session tî duti. Artiste a-sï notification.';

  @override
  String get aiGuideAssignEngineerTitle => 'Mu enjëniëre';

  @override
  String get aiGuideAssignEngineerDesc =>
      'Mu enjëniëre tî duti na session tî tene éé.';

  @override
  String get aiGuideCreateSessionTitle => 'Ga session';

  @override
  String get aiGuideCreateSessionDesc =>
      'Ga session na nzönî tî artiste, na demande pëpe.';

  @override
  String get aiGuideBlockSlotsTitle => 'Kangbi créneaux';

  @override
  String get aiGuideBlockSlotsDesc =>
      'Bâa ngâ tî sara pëpe tî studio a-kangbi.';

  @override
  String get aiGuideManageServicesTitle => 'Kämä services';

  @override
  String get aiGuideManageServicesDesc =>
      'Ga wala sêngö services tî mo (ïrï, tarif, ngâ, na ndâ).';

  @override
  String get aiGuideExample1ArtistTitle => 'Sessions tî sï tî mbi';

  @override
  String get aiGuideExample1ArtistDesc =>
      '\"Sessions tî mbi tî bîkua sô nî?\" - IA a-pandöö réservations ôke tî sï tî mo.';

  @override
  String get aiGuideExample2ArtistTitle => 'Gï studio';

  @override
  String get aiGuideExample2ArtistDesc =>
      '\"Mbi gï studio na Bangui tî mix\" - IA a-gï studio akë tî kängö.';

  @override
  String get aiGuideExample3ArtistTitle => 'Réserver créneau';

  @override
  String get aiGuideExample3ArtistDesc =>
      '\"Mbi sü réserver kêkerê na 14h na Studio X\" - IA a-vérifier ndö tî sara na bata mo.';

  @override
  String get aiGuideExample1EngineerTitle => 'Sessions tî lâsô';

  @override
  String get aiGuideExample1EngineerDesc =>
      '\"Nî mbi sü ga lâsô?\" - IA a-pandöö sessions tî mu na mo tî lâsô.';

  @override
  String get aiGuideExample2EngineerTitle => 'Bâa congés';

  @override
  String get aiGuideExample2EngineerDesc =>
      '\"Mbi sï pëpe kôzo 15 sô 20 janvier\" - IA a-ga ndö tî sara pëpe na tene éé tî mo.';

  @override
  String get aiGuideExample3EngineerTitle => 'Kîri mbëtï tî proposition';

  @override
  String get aiGuideExample3EngineerDesc =>
      '\"Sï session tî kêkerê\" - IA a-tene éé proposition tî tära.';

  @override
  String get aiGuideExample1StudioTitle => 'Demande tî tära';

  @override
  String get aiGuideExample1StudioDesc =>
      '\"Pandöö demande tî tära\" - IA a-pandöö réservations ôke tî traiter.';

  @override
  String get aiGuideExample2StudioTitle => 'Rapport tî wâlë';

  @override
  String get aiGuideExample2StudioDesc =>
      '\"Wâlë tî mbi tî nze sô nî?\" - IA a-ga rapport ôke.';

  @override
  String get aiGuideExample3StudioTitle => 'Sêngö ngâ tî session';

  @override
  String get aiGuideExample3StudioDesc =>
      '\"Sêngö session tî Lundi na Mardi 10h\" - IA a-sêngö na tene éé tî mo.';

  @override
  String get aiGuideSettingsLink => 'Ndiä tî wala-bata IA';

  @override
  String get importFromGoogleCalendar => 'Lêkë na Google Calendar';

  @override
  String get importAsSession => 'Session';

  @override
  String get importAsUnavailability => 'Dispo pëpe';

  @override
  String get skipImport => 'Fä';

  @override
  String get selectArtistForSession => 'Lêkë artiste';

  @override
  String get createExternalArtist => 'Artiste tî ngâ';

  @override
  String get externalArtistName => 'Ïrï tî artiste';

  @override
  String get externalArtistHint => 'Ïrï tî artiste tî ngâ...';

  @override
  String importSummary(int sessions, int unavailabilities) {
    return '$sessions sessions, $unavailabilities dispo pëpe';
  }

  @override
  String get importButton => 'Lêkë';

  @override
  String get noEventsToImport => 'Événement pëpe tî lêkë';

  @override
  String eventsToReview(int count) {
    return '$count événements tî yê';
  }

  @override
  String importSuccessMessage(int sessions, int unavailabilities) {
    return 'Lêkë nzönî! $sessions sessions na $unavailabilities ndö tî sara pëpe a-ga.';
  }

  @override
  String get allDay => 'Lâ ôke';

  @override
  String get selectAnArtist => 'Lêkë artiste';

  @override
  String get orCreateExternal => 'wala ga artiste tî ngâ';

  @override
  String get reviewAndImport => 'Vérifier na lêkë';

  @override
  String get dateRange => 'Ngâ tî lâ';

  @override
  String get selectDateRange => 'Lêkë ngâ tî lâ';

  @override
  String get tryChangingDateRange => 'Tene na sêngö ngâ tî lâ';

  @override
  String get changeDateRange => 'Sêngö lâ akë';

  @override
  String get tipsSectionCalendar => 'Calendrier';

  @override
  String get tipConnectCalendarTitle => 'Bâa calendrier tî mo';

  @override
  String get tipConnectCalendarDesc =>
      'Lier Google Calendar tî mo tî synchroniser événements. Gue na Sêse > Calendrier tî bâa kömändë Google tî mo.';

  @override
  String get tipImportEventsTitle => 'Lêkë événements tî mo';

  @override
  String get tipImportEventsDesc =>
      'Sära na \"Vérifier na lêkë\" tî sï événements Google Calendar tî mo na bâa ala töngana sessions wala ndö tî sara pëpe.';

  @override
  String get tipCategorizeEventsTitle => 'Bâa événements na ndö';

  @override
  String get tipCategorizeEventsDesc =>
      'Tî événement ôke, lêkë: Session (na artiste), Dispo pëpe (kangbi créneau), wala Fä. Sessions a-ga na statut \"A-tära\".';

  @override
  String get allNotificationsMarkedAsRead => 'Notification ôke a-bâa lu';

  @override
  String get comingSoon => 'A-sï mbï sô';

  @override
  String get onboardingWelcomeTitle => 'Balao na UZME';

  @override
  String get onboardingWelcomeDesc =>
      'Plateforme tî réservation tî studio tî mûzîki tî mo';

  @override
  String get onboardingStudioSessionsTitle => 'Kämä réservations tî mo';

  @override
  String get onboardingStudioSessionsDesc =>
      'Bâa sessions tî mo, kämä calendrier na tökua sara na ngâ tî kängö';

  @override
  String get onboardingStudioTeamTitle => 'Ga equipe tî mo';

  @override
  String get onboardingStudioTeamDesc =>
      'Inviter enjëniëre akë tî sön na kämä artiste akë tî studio tî mo';

  @override
  String get onboardingEngineerSessionsTitle => 'Sessions tî mo na yê ôko';

  @override
  String get onboardingEngineerSessionsDesc =>
      'Yê planning tî mo na tökua sessions tî ga sara';

  @override
  String get onboardingEngineerAvailabilityTitle => 'Kämä ndö tî sara tî mo';

  @override
  String get onboardingEngineerAvailabilityDesc =>
      'Bâa ngâ na congés tî mo tî kämä nzönî';

  @override
  String get onboardingArtistSearchTitle => 'Gï studio nzönî';

  @override
  String get onboardingArtistSearchDesc =>
      'Gï studio akë tî pëtï tî mo na comparer services tî ala';

  @override
  String get onboardingArtistBookingTitle => 'Réserver mbï';

  @override
  String get onboardingArtistBookingDesc =>
      'Sü sessions na clics na kämä réservations tî mo';

  @override
  String get onboardingAITitle => 'Wala-bata IA tî mo';

  @override
  String get onboardingAIDesc => 'Sü sêse tî mo na sï bata mbï';

  @override
  String get onboardingReadyTitle => 'Mo prêt!';

  @override
  String get onboardingReadyDesc => 'Kôzo sära na UZME fadë sô';

  @override
  String get onboardingSkip => 'Fä';

  @override
  String get onboardingNext => 'Sô a-sï';

  @override
  String get onboardingGetStarted => 'Kôzo';

  @override
  String get onboardingLocationTitle => 'Zîa localisation';

  @override
  String get onboardingLocationDescArtist => 'Tî gï studio akë tî pëtï tî mo';

  @override
  String get onboardingLocationDescStudio => 'Tî artiste akë lîngbi gï mo';

  @override
  String get onboardingEnableLocation => 'Zîa';

  @override
  String get onboardingLater => 'Mbï sô';

  @override
  String get onboardingLocationGranted => 'Localisation a-zîa';

  @override
  String get onboardingNotificationTitle => 'Duti na sêse';

  @override
  String get onboardingNotificationDesc =>
      'Sï alertes tî sessions na mbëtï tî mo';

  @override
  String get onboardingEnableNotifications => 'Zîa';

  @override
  String get onboardingNotificationGranted => 'Notifications a-zîa';

  @override
  String get onboardingTermsTitle => 'Ndiä tî sära na';

  @override
  String get onboardingTermsDesc =>
      'Tî sära na UZME, mo lîngbi sï ndiä tî sära na na ndiä tî sêse tî mbi.';

  @override
  String get onboardingTermsAccept => 'Mbi sï CGU na Ndiä tî sêse tî mbi';

  @override
  String get onboardingTermsLink => 'Lu ndiä';

  @override
  String get onboardingPrivacyLink => 'Ndiä tî sêse tî mbi';

  @override
  String get onboardingLetsGo => 'Âla gue!';

  @override
  String get searchAddressHint => 'Gï ködörö, adresse...';

  @override
  String get searchInThisZone => 'Gï na ndö sô';

  @override
  String get filterStudios => 'Filtrer studio akë';

  @override
  String get filterDescription => 'Ga gï tî mo nzönî';

  @override
  String get filterActive => 'A-duti';

  @override
  String get partnerStudiosOnly => 'Studio partner ôko';

  @override
  String get partnerStudiosDescription => 'Pandöö studio akë tî vérifier ôko';

  @override
  String get serviceTypes => 'Lêgë tî services';

  @override
  String get clearFilters => 'Zïa';

  @override
  String get applyFilters => 'Sära na';

  @override
  String get filterSessions => 'Filtrer sessions';

  @override
  String get filterSessionsDescription => 'Ga planning tî mo nzönî';

  @override
  String get statusLabel => 'Statut';

  @override
  String get studioLabel => 'Studio';

  @override
  String get addToCalendar => 'Bâa na calendrier';

  @override
  String get addedToCalendar => 'Session a-bâa na calendrier';

  @override
  String sessionCalendarTitle(Object type) {
    return 'Session $type - UZME';
  }

  @override
  String get studioTypePro => 'Studio Pro';

  @override
  String get studioTypeIndependent => 'Indépendant';

  @override
  String get studioTypeAmateur => 'Home Studio';

  @override
  String get studioTypeLabel => 'Lêgë tî studio';

  @override
  String get connectedDevices => 'Appareils tî bâa';

  @override
  String get thisDevice => 'Appareil sô';

  @override
  String get disconnectDevice => 'Ûse';

  @override
  String get disconnectAllOthers => 'Ûse appareils ôke ôko';

  @override
  String get disconnectDeviceTitle => 'Ûse appareil';

  @override
  String get disconnectDeviceConfirm => 'Mo sü ûse appareil sô?';

  @override
  String get disconnectAllConfirm => 'Mo sü ûse appareils ôke ôko?';

  @override
  String get deviceDisconnected => 'Appareil a-ûse';

  @override
  String get allDevicesDisconnected => 'Appareils ôke ôko a-ûse';

  @override
  String get activeNow => 'A-duti fadë sô';

  @override
  String activeAgo(String time) {
    return 'A-duti kôzo $time';
  }

  @override
  String get noConnectedDevices => 'Appareil pëpe a-bâa';

  @override
  String get securitySection => 'Sêse tî sïönî';

  @override
  String get manageDevices => 'Kämä appareils';

  @override
  String get sessionExpired => 'Session tî mo a-hûnzi';

  @override
  String get disconnectedRemotely => 'Mo a-ûse na appareil ôko';

  @override
  String oauthAccountResetError(String provider) {
    return 'Kömändë sô a-sära na $provider. Duti na $provider.';
  }

  @override
  String passwordResetSent(String email) {
    return 'Email tî sêngö tëngbi-da a-tö na $email';
  }

  @override
  String get permissionContinue => 'Sü';

  @override
  String get permissionNotNow => 'Pëpe fadë sô';

  @override
  String get permissionOpenSettings => 'Zîa sêse';

  @override
  String get permissionDeniedTitle => 'Permission a-lä';

  @override
  String get permissionDeniedDesc =>
      'Mo lä permission sô. Tî zîa lo, gue na sêse tî téléphone tî mo.';

  @override
  String get permissionCameraTitle => 'Duti na caméra';

  @override
  String get permissionCameraDesc =>
      'Tî lêkë photos tî studio tî mo, sessions wala sêngö photo tî mo.';

  @override
  String get permissionMicrophoneTitle => 'Duti na micro';

  @override
  String get permissionMicrophoneDesc => 'Tî tö mbëtï tî tënë na bîanî tî mo.';

  @override
  String get permissionLocationTitle => 'Duti na localisation';

  @override
  String get permissionLocationDesc =>
      'Tî gï studio akë tî mûzîki tî pëtï tî mo.';

  @override
  String get permissionPhotosTitle => 'Duti na photos tî mo';

  @override
  String get permissionPhotosDesc =>
      'Tî lêkë images na galerie na bâa na profîli wala mbëtï tî mo.';

  @override
  String get permissionNotificationTitle => 'Zîa notifications';

  @override
  String get permissionNotificationDesc =>
      'Tî sï sêse tî réservations, mbëtï na sêse tî finî.';

  @override
  String get proProfileTitle => 'Profîli Pro';

  @override
  String get proProfileSetup => 'Duti Pro';

  @override
  String get proProfileEdit => 'Sêngö profîli pro tî mbi';

  @override
  String get proProfileSetupDesc =>
      'Proposer services tî mo na artiste akë na studio akë na UZME. Hûnzi profîli tî mo tî pandöö na marketplace.';

  @override
  String get proProfileActivate => 'Zîa profîli pro tî mbi';

  @override
  String get proProfileActivateDesc => 'Proposer services tî mo na UZME';

  @override
  String get proProfileManage => 'Kämä profîli pro tî mo';

  @override
  String get proProfileActive => 'A-duti';

  @override
  String get proProfileInactive => 'A-duti pëpe';

  @override
  String get proProfileSelectType => 'Lêkë lêgë tî service ôko kôzo';

  @override
  String get proProfileTypeLabel => 'Mo proposer nî?';

  @override
  String get proProfileTypeHint => 'Lêkë rôle ôko wala mingi';

  @override
  String get proProfileDisplayName => 'Ïrï tî pro';

  @override
  String get proProfileBio => 'Na ndâ tî services tî mo';

  @override
  String get proProfileRate => 'Tarif na ngâ';

  @override
  String get proProfileCity => 'Ködörö / Adêrêsi';

  @override
  String get proProfileCityHelper => 'Fa tî hînga mô na carte';

  @override
  String get proProfileWebsite => 'Site web';

  @override
  String get proProfilePhone => 'Téléphone';

  @override
  String get proProfileSpecialties => 'Spécialités';

  @override
  String get proProfileSpecialtiesHint => 'Ex: Mix voix, Mastering...';

  @override
  String get proProfileGenres => 'Lêgë tî mûzîki';

  @override
  String get proProfileGenresHint => 'Ex: Hip-Hop, Pop, Jazz...';

  @override
  String get proProfileInstruments => 'Instruments';

  @override
  String get proProfileInstrumentsHint => 'Ex: Guitare, Piano...';

  @override
  String get proProfileDaws => 'DAWs';

  @override
  String get proProfileDawsHint => 'Ex: Pro Tools, Logic Pro...';

  @override
  String get proProfileRemote => 'Services na ngâ';

  @override
  String get proProfileRemoteDesc => 'Mo sï missions na remote';

  @override
  String get proProfileAvailable => 'A-duti';

  @override
  String get proProfileAvailableDesc => 'Profîli tî mo a-pandöö na marketplace';

  @override
  String get proPortfolio => 'Portfolio';

  @override
  String get uploadError => 'Problème tî upload';

  @override
  String get proPaymentMethods => 'Lêgë tî fûta';

  @override
  String get proPaymentMethodsDesc =>
      'Tene ndâ tî clients tî mo lîngbi fûta mo';

  @override
  String get paymentMethodName => 'Ïrï tî lêgë tî fûta';

  @override
  String get paymentInstructions => 'Instructions tî fûta';

  @override
  String get proProfilePhoto => 'Photo tî profîli';

  @override
  String get proProfilePhotoDesc => 'Lêkë photo tî pandöö na profîli pro tî mo';

  @override
  String get proDetailPortfolio => 'Portfolio';

  @override
  String get proDetailPaymentMethods => 'Lêgë tî fûta tî sï';

  @override
  String get requiredField => 'Ndö sô a-lîngbi';

  @override
  String get proDiscovery => 'Pros';

  @override
  String get proDiscoveryTitle => 'Gï pro';

  @override
  String get proDiscoverySubtitle => 'Enjëniëre, producteurs na mingi';

  @override
  String get seeAll => 'Yê ôke';

  @override
  String get proDiscoveryDesc => 'Gï pro akë tî duti';

  @override
  String get proDiscoveryEmpty => 'Pro pëpe a-gï';

  @override
  String get proDiscoveryEmptyDesc => 'Tene na sêngö filtres wala gï tî mo';

  @override
  String get proSearchHint => 'Ïrï, spécialité, lêgë...';

  @override
  String get proFilterTitle => 'Filtrer pro akë';

  @override
  String get proFilterDesc => 'Ga gï tî mo nzönî';

  @override
  String get proFilterRemoteOnly => 'Na ngâ ôko';

  @override
  String get proFilterRemoteDesc => 'Pro akë tî sï missions na remote';

  @override
  String get proFilterCity => 'Ködörö';

  @override
  String get proFilterCityHint => 'Ex: Bangui, Bimbo...';

  @override
  String get proDetailContact => 'Bîanî';

  @override
  String get proDetailRate => 'Tarif';

  @override
  String get proDetailSpecialties => 'Spécialités';

  @override
  String get proDetailGenres => 'Lêgë';

  @override
  String get proDetailInstruments => 'Instruments';

  @override
  String get proDetailDaws => 'DAWs';

  @override
  String get proDetailRemote => 'A-sï remote';

  @override
  String get proDetailOnQuote => 'Na devis';

  @override
  String get seeFullProfile => 'Yê profîli ôke';

  @override
  String proResultCount(int count) {
    return '$count pro akë a-gï';
  }

  @override
  String proBookingTitle(String proName) {
    return 'Réserver $proName';
  }

  @override
  String get proBookingDesc => 'Lêkë lâ, créneau na ngâ tî mo sü.';

  @override
  String get proBookingDate => 'Lâ';

  @override
  String get proBookingTime => 'Ngâ tî kôzo';

  @override
  String get proBookingDuration => 'Ngâ';

  @override
  String get proBookingNotes => 'Tene na ndâ tî projet tî mo';

  @override
  String get proBookingNotesHint => 'Ex: Mix tî EP 5 titres, style R&B...';

  @override
  String get proBookingRemote => 'Session na ngâ';

  @override
  String get proBookingSummary => 'Ôke na ndö ôko';

  @override
  String get proBookingSend => 'Tö demande';

  @override
  String get proBookingSent => 'Demande a-tö!';

  @override
  String get proBookingSelectDate => 'Lêkë lâ';

  @override
  String get proBookingSelectTime => 'Lêkë créneau';

  @override
  String get proBookingsReceived => 'Demande akë a-sï';

  @override
  String get proBookingsReceivedDesc => 'Kämä demande tî booking tî mo';

  @override
  String get proBookingsEmpty => 'Demande pëpe fadë sô';

  @override
  String get proBookingsEmptyDesc => 'Demande tî booking tî mo a-pandöö ôko';

  @override
  String proBookingFrom(String name) {
    return 'Demande tî $name';
  }

  @override
  String get proBookingAccept => 'Sï';

  @override
  String get proBookingDecline => 'Lä';

  @override
  String get proBookingAccepted => 'Demande a-sï';

  @override
  String get proBookingDeclined => 'Demande a-lä';

  @override
  String get proBookingPending => 'A-tära';

  @override
  String get proBookingConfirmed => 'A-tene éé';

  @override
  String get proBookingStatusCancelled => 'A-lä';

  @override
  String get myNetwork => 'Réseau tî mbi';

  @override
  String get networkEmpty => 'Zo pëpe';

  @override
  String get networkEmptyDesc => 'Bâa âzo tî sara tî mo tî ga réseau tî mo';

  @override
  String get addContact => 'Bâa zo';

  @override
  String get networkProducer => 'Producteurs';

  @override
  String get networkOther => 'Ôko';

  @override
  String get networkNote => 'Mbëtï';

  @override
  String get networkNoteHint => 'Mbëtï tî mbi (sô mo sü)';

  @override
  String get networkInvite => 'Inviter';

  @override
  String get networkInviteEmailSubject => 'Duti na mbi na UZME!';

  @override
  String get networkInviteEmailBody =>
      'Balao! Mbi sära na UZME tî bîanî na studio akë na pro akë tî mûzîki. Duti na mbi: https://uzme.app';

  @override
  String get networkManualAdd => 'Na nzönî';

  @override
  String get networkAddManually => 'Bâa zo sô na nzönî';

  @override
  String get networkContactName => 'Ïrï tî zo';

  @override
  String get permissionContactsTitle => 'Duti na âzo tî mo';

  @override
  String get permissionContactsDesc =>
      'Tî lêkë âzo tî mo na gï âzo tî duti fadë na UZME.';

  @override
  String get importContacts => 'Lêkë na téléphone';

  @override
  String get importContactsDesc => 'Gï âzo tî mo na UZME fadë';

  @override
  String importCount(int count) {
    return 'Lêkë ($count)';
  }

  @override
  String contactsOnPlatform(int count) {
    return '$count âzo tî mo a-duti na UZME!';
  }

  @override
  String get contactAlreadyOnUzme => 'A-duti na UZME fadë';

  @override
  String get aiAssistantTitle => 'Wala-bata UZME';

  @override
  String get alwaysAvailable => 'Na ndo oko kûê';

  @override
  String get aiAssistantLabel => 'Wala-bata IA';

  @override
  String get askYourQuestion => 'Tî mo...';

  @override
  String get aiErrorMessage =>
      'Pardon, mo kua yeke da âpe. Nzönî mo gbâ sô lêgë! 🙏';

  @override
  String get subscriptionRestored => 'Abonnement a-kîri nzönî';

  @override
  String get subscriptionActivated => 'Abonnement a-zîa nzönî';

  @override
  String get chooseSubscription => 'Lêkë abonnement';

  @override
  String get restorePurchases => 'Kîri achats';

  @override
  String get manageSubscription => 'Kämä abonnement tî mbi';

  @override
  String get viewPlans => 'Bâa offres';

  @override
  String get noSubscriptionAvailable => 'Abonnement pëpe a-duti';

  @override
  String get monthly => 'Na nze';

  @override
  String get yearly => 'Na ngû';

  @override
  String get twoMonthsFree => 'Nze 2 cadeau';

  @override
  String get userNotConnected => 'Zo a-duti pëpe';

  @override
  String get downgradeToFreeTitle => 'Gue na plan cadeau?';

  @override
  String get cancelViaAppStore =>
      'Tî lä abonnement tî mo, mo lîngbi ga lo na sêse tî App Store.';

  @override
  String get downgradeWarning =>
      'Mo a-bë fonctions premium. Sara sô a-kôzo na hûnzi tî ngâ tî mo fadë.';

  @override
  String get openAppStore => 'Zîa App Store';

  @override
  String subscriptionCancelledOn(String date) {
    return 'Abonnement a-lä lâ $date';
  }

  @override
  String get subscriptionCancelledEndPeriod =>
      'Abonnement a-lä na hûnzi tî ngâ';

  @override
  String get cancellationError => 'Pörö na lä';

  @override
  String get productNotAvailable => 'Produit a-duti pëpe';

  @override
  String purchaseError(String error) {
    return 'Pörö na achat: $error';
  }

  @override
  String get redirectingToPayment => 'Gue na paiement...';

  @override
  String get paymentCreationError => 'Pörö na ga paiement';

  @override
  String get restoreCompleted => 'Kîri a-hûnzi';

  @override
  String get restoreError => 'Pörö na kîri';

  @override
  String get cannotOpenPortal => 'Lîngbi pëpe tî zîa portail';

  @override
  String get recommended => 'A-tene éé';

  @override
  String get currentPlan => 'Tî fadë';

  @override
  String get free => 'Cadeau';

  @override
  String get perYear => '/ngû';

  @override
  String get perMonth => '/nze';

  @override
  String pricePerMonth(String price) {
    return '$price€/nze';
  }

  @override
  String get currentPlanButton => 'Plan tî fadë';

  @override
  String get switchToFree => 'Gue na cadeau';

  @override
  String choosePlan(String name) {
    return 'Lêkë $name';
  }

  @override
  String get unlimitedSessions => 'sessions a-zîa pëpe';

  @override
  String sessionsPerMonth(int count) {
    return '$count sessions/nze';
  }

  @override
  String get unlimitedRooms => 'Salles na ndïä pëpe';

  @override
  String roomsCount(int count) {
    return '$count salles';
  }

  @override
  String get unlimitedServices => 'services a-zîa pëpe';

  @override
  String servicesCount(int count) {
    return '$count services';
  }

  @override
  String get unlimitedAI => 'Wala-bata IA na ndïä pëpe';

  @override
  String aiMessagesPerMonth(int count) {
    return '$count mbëtï IA/nze';
  }

  @override
  String get advancedAI => 'IA avancée (rapports, actions)';

  @override
  String get discoveryVisibility => 'Pandöö Discovery';

  @override
  String get verifiedBadge => 'Badge tî vérifier';

  @override
  String get apiAccess => 'Duti na API';

  @override
  String get prioritySupport => 'Support tî kôzo';

  @override
  String errorWithMessage(String message) {
    return 'Pörö: $message';
  }

  @override
  String get aiAssistantDescription =>
      'Kîri mbëtï na sêse tî lâ kûê na bâa ngâ tî mo';

  @override
  String get enableAIAssistant => 'Zîa wala-bata IA';

  @override
  String get aiHelpsRespond => 'IA a-bata tî kîri mbëtï';

  @override
  String get aiDisabled => 'IA a-duti pëpe';

  @override
  String get operatingMode => 'Lêgë tî sara';

  @override
  String get toneProfessional => 'Professionnel';

  @override
  String get toneProfessionalDesc => 'Formel na nzönî';

  @override
  String get toneFriendly => 'Nzönî';

  @override
  String get toneFriendlyDesc => 'Na bêlêmbê na sïönî';

  @override
  String get toneCasual => 'Relax';

  @override
  String get toneCasualDesc => 'Relax na respect';

  @override
  String get responseTone => 'Lêgë tî mbëtï';

  @override
  String get advancedOptions => 'Options avancées';

  @override
  String get priceDiscussion => 'Tënë tî tarif';

  @override
  String get aiCanMentionDiscounts => 'IA lîngbi tene réductions';

  @override
  String get autoReplyDelay => 'Ngâ kôzo kîri mbëtï';

  @override
  String minutesCount(int minutes) {
    return '$minutes minutes';
  }

  @override
  String get customFAQs => 'FAQs tî mbi';

  @override
  String get customFAQsEmpty =>
      'Bâa sêse tî lâ kûê tî IA lîngbi kîri mbëtï na nzönî';

  @override
  String get addFAQ => 'Bâa FAQ';

  @override
  String get question => 'Sêse';

  @override
  String get questionHint => 'Ex: Ngâ tî sû tî âla nî?';

  @override
  String get answer => 'Mbëtï';

  @override
  String get answerHint => 'Ex: Âla sû kôzo lundi sô samedi...';

  @override
  String get welcomeBack => 'Balao na mo ngâ!';

  @override
  String get useAnotherAccount => 'Sâra na kua-compte ôko';

  @override
  String get chooseAccount => 'Sö compte ôko';

  @override
  String enterPasswordFor(String name) {
    return 'Sü mot de passe tî $name';
  }

  @override
  String get rememberMe => 'Bâa mbi';

  @override
  String get tipQuickLoginTitle => 'Connexion vîte';

  @override
  String get tipQuickLoginDesc =>
      'Tî mo cocher \'Bâa mbi\' tî mo sü, tî kôzo zo na compte tî mo vîte na ndo ôko.';

  @override
  String get tipSearchCityTitle => 'Gï na ville';

  @override
  String get tipSearchCityDesc =>
      'Sâra na icône loupe na carte tî gï studio na ville wala adresse ôko. Mo lîngbi tî sâra na bouton tî gï na zone tî carte.';

  @override
  String get tipsSectionNetwork => 'Réseau na Contact';

  @override
  String get tipNetworkTitle => 'Bâta réseau tî mo';

  @override
  String get tipNetworkDesc =>
      'Fâ contact, importer na téléphone tî mo na bâta réseau musique tî mo. Gï artiste, ingénieur na studio awe na ndo ôko.';

  @override
  String get tipNetworkInviteTitle => 'Voko contact tî mo';

  @override
  String get tipNetworkInviteDesc =>
      'Kângbi application na âzo tî musique tî mo tî gï âla na UZME na yângâ réservation.';

  @override
  String get addArtistTitle => 'Bâa artiste';

  @override
  String get noRoomConfigured => 'Salle pëpe a-sêse';

  @override
  String get serviceCreated => 'Service a-ga';

  @override
  String get serviceModified => 'Service a-sêngö';

  @override
  String get sessionCreated => 'Session a-ga';

  @override
  String get sessionModified => 'Session a-sêngö';

  @override
  String get additionalInfoHint => 'Sêse tî mingi...';

  @override
  String get roomsOptional => 'Salles (sô mo sü)';

  @override
  String get recordingTooShort => 'Enregistrement a-pötö mingi';

  @override
  String get descriptionHint => 'Na ndâ tî service...';

  @override
  String get createTheSession => 'Ga session';

  @override
  String get createTheArtist => 'Ga artiste';

  @override
  String get deleteTheService => 'Zïa service';

  @override
  String get deleteTheArtist => 'Zïa artiste';

  @override
  String get deleteTheSession => 'Zïa session';

  @override
  String userAddedToStudio(String name) {
    return '$name a-bâa na studio tî mo!';
  }

  @override
  String get descriptionOptional => 'Na ndâ (sô mo sü)';

  @override
  String get adminSubscriptionConfig => 'Configuration Abonnements';

  @override
  String get adminStripeConfigTooltip => 'Config Stripe';

  @override
  String get adminNoTierConfigured => 'Tier pëpe a-sêse';

  @override
  String get adminInitializeDefaults => 'Initialiser na valeurs tî kôzo?';

  @override
  String get adminInitialize => 'Initialiser';

  @override
  String get adminTiersInitialized => 'Tiers a-initialiser nzönî';

  @override
  String adminTierUpdated(String name) {
    return '$name a-sêngö';
  }

  @override
  String get adminDisabled => 'A-duti pëpe';

  @override
  String adminPricePerMonth(String price) {
    return '$price€/nze';
  }

  @override
  String get adminSessionsUnlimited => 'Sessions ∞';

  @override
  String adminSessionsCount(int count) {
    return '$count sessions';
  }

  @override
  String get adminRoomsUnlimited => 'Salles ∞';

  @override
  String adminRoomsCount(int count) {
    return '$count salles';
  }

  @override
  String get adminServicesUnlimited => 'Services ∞';

  @override
  String adminServicesCount(int count) {
    return '$count services';
  }

  @override
  String get adminEngineersUnlimited => 'Engineers ∞';

  @override
  String adminEngineersCount(int count) {
    return '$count engineers';
  }

  @override
  String get adminAiUnlimited => 'IA ∞';

  @override
  String adminAiCount(int count) {
    return '$count msg IA';
  }

  @override
  String get adminFeatureAiAssistant => 'Assistant IA';

  @override
  String get adminFeatureAdvancedAi => 'IA avancée';

  @override
  String get adminFeatureDiscovery => 'Discovery';

  @override
  String get adminFeatureAnalytics => 'Analytics';

  @override
  String get adminFeatureBadge => 'Badge';

  @override
  String get adminFeatureMultiStudios => 'Multi-studios';

  @override
  String get adminFeatureApi => 'API';

  @override
  String get adminFeaturePrioritySupport => 'Support+';

  @override
  String adminEditTier(String name) {
    return 'Sêngö $name';
  }

  @override
  String get adminSectionInformation => 'Sêse';

  @override
  String get adminLabelName => 'Ïrï';

  @override
  String get adminLabelDescription => 'Na ndâ';

  @override
  String get adminSectionPricing => 'Tarif';

  @override
  String get adminLabelMonthlyPrice => 'Tarif na nze €';

  @override
  String get adminLabelYearlyPrice => 'Tarif na ngû €';

  @override
  String get adminSectionLimits => 'Ndïä (-1 = na ndïä pëpe)';

  @override
  String get adminLabelSessionsPerMonth => 'Sessions/nze';

  @override
  String get adminLabelRooms => 'Salles';

  @override
  String get adminLabelServices => 'Services';

  @override
  String get adminLabelEngineers => 'Engineers';

  @override
  String get adminLabelAiMessagesPerMonth => 'Mbëtï IA/nze';

  @override
  String get adminSectionAiFeatures => 'Fonctions IA';

  @override
  String get adminAiAssistantSubtitle => 'Duti na wala-bata IA';

  @override
  String get adminAdvancedAiSubtitle => 'Outils tî sara, rapports, etc.';

  @override
  String get adminSectionFeatures => 'Fonctions';

  @override
  String get adminFeatureDiscoveryVisibility => 'Pandöö Discovery';

  @override
  String get adminDiscoverySubtitle => 'Artiste akë lîngbi yê';

  @override
  String get adminFeatureBasicAnalytics => 'Analytics tî kôzo';

  @override
  String get adminFeatureAdvancedAnalytics => 'Analytics avancés';

  @override
  String get adminFeatureVerifiedBadge => 'Badge tî vérifier';

  @override
  String get adminFeatureApiAccess => 'Duti na API';

  @override
  String get adminFeaturePrioritySupportFull => 'Support tî kôzo';

  @override
  String get adminSectionStatus => 'Statut';

  @override
  String get adminTierActive => 'Tier a-duti';

  @override
  String get adminTierActiveSubtitle => 'Studio akë lîngbi sï tier sô';

  @override
  String get adminStudioClaims => 'Demande tî studio';

  @override
  String get adminFilterPending => 'Pending';

  @override
  String get adminFilterAll => 'Ôke';

  @override
  String get adminNoClaimsPending => 'Demande pëpe a-tära';

  @override
  String get adminNewClaimsAppearHere => 'Demande tî finî a-pandöö ôko';

  @override
  String adminClaimApproved(String name) {
    return '$name a-sï!';
  }

  @override
  String get adminRejectClaim => 'Lä demande';

  @override
  String adminRejectClaimConfirm(String name) {
    return 'Lä \"$name\" ?';
  }

  @override
  String get adminReasonOptional => 'Raison (sô mo sü)';

  @override
  String get adminReasonHint => 'Ex: Sêse a-nzönî pëpe...';

  @override
  String get adminReject => 'Lä';

  @override
  String get adminClaimRejected => 'Demande a-lä';

  @override
  String get adminApprove => 'Sï';

  @override
  String get adminStatusPending => 'A-tära';

  @override
  String get adminStatusApproved => 'A-sï';

  @override
  String get adminStatusRejected => 'A-lä';

  @override
  String get adminAccessDenied => 'Duti pëpe';

  @override
  String get adminDevMasterRequired => 'DevMaster a-lîngbi';

  @override
  String get adminDevMasterOnly => 'DevMaster ôko lîngbi duti na page sô';

  @override
  String get adminStripeConfig => 'Configuration Stripe';

  @override
  String adminStripeLoadError(String message) {
    return 'Pörö na charger config: $message';
  }

  @override
  String get adminStripeKeysWarning =>
      'Clés a-crypter kôzo na bâa. Kêtê clés secrètes tî mo pëpe.';

  @override
  String get adminMode => 'Mode';

  @override
  String get adminProductionMode => 'Mode Production';

  @override
  String get adminLivePayments => 'Paiements tî nzönî a-duti';

  @override
  String get adminTestMode => 'Mode test - Paiement tî nzönî pëpe';

  @override
  String get adminApiKeys => 'Clés API';

  @override
  String get adminPublishableKey => 'Publishable Key';

  @override
  String get adminSecretKey => 'Secret Key';

  @override
  String get adminWebhookSecret => 'Webhook Secret';

  @override
  String get adminKeepCurrentKey => 'Fä na ndö tî bâa clé tî fadë';

  @override
  String get adminKeepCurrentSecret => 'Fä na ndö tî bâa secret tî fadë';

  @override
  String get adminStripePriceIds => 'Price IDs Stripe';

  @override
  String get adminStripePriceIdsHelp =>
      'Ga produits na tarifs na dashboard Stripe tî mo, na bâa IDs ôko.';

  @override
  String get adminProMonthly => 'Pro na nze';

  @override
  String get adminProYearly => 'Pro na ngû';

  @override
  String get adminEnterpriseMonthly => 'Enterprise na nze';

  @override
  String get adminEnterpriseYearly => 'Enterprise na ngû';

  @override
  String get adminSaving => 'A-bâa...';

  @override
  String adminLastUpdated(String date) {
    return 'Sêngö tî sô a-hûnzi: $date';
  }

  @override
  String get adminPublicKeyRequired => 'Clé publique a-lîngbi';

  @override
  String get adminInvalidPublicKeyFormat =>
      'Format tî clé publique a-nzönî pëpe';

  @override
  String get adminTestKeyInProduction => 'Clé test a-sâra na mode production';

  @override
  String get adminProdKeyInTestMode => 'Clé production a-sâra na mode test';

  @override
  String get adminStripeConfigSaved => 'Configuration Stripe a-bâa';

  @override
  String get claimRequestSent => 'Demande a-tö';

  @override
  String get ok => 'OK';

  @override
  String get nameOptional => 'Ïrï (optionnel)';

  @override
  String get send => 'Tene';

  @override
  String get uncertain => 'A-sûre pëpe';

  @override
  String get fileOrPhoto => 'Dosïe wala foto';

  @override
  String get sessionOrBooking => 'Session wala réservation';

  @override
  String get noEngineerInTeam => 'Ingénieur a-vöngo pëpe na équipe';

  @override
  String get statistics => 'Statistiques';

  @override
  String get availabilities => 'Disponibilités';

  @override
  String get remote => 'Remote';

  @override
  String get limitReached => 'Kötä a-sï';

  @override
  String limitReachedMessage(int max, String type, String tier) {
    return 'Mo sï na kötä tî $max $type na abonnement $tier.';
  }

  @override
  String limitUsage(int current, int max, String type) {
    return '$current / $max $type';
  }

  @override
  String upgradeToTier(String tier, String limit) {
    return 'Gä na $tier tî $limit';
  }

  @override
  String get maybeLater => 'Na pekô';

  @override
  String get upgrade => 'Upgrade';

  @override
  String get tierFree => 'Gratuit';

  @override
  String get tierPro => 'Pro';

  @override
  String get tierEnterprise => 'Enterprise';

  @override
  String get tenRooms => '10 da';

  @override
  String get tenEngineers => '10 ingénieurs';

  @override
  String get unlimited => 'a-zîa pëpe';

  @override
  String get more => 'mbênî';

  @override
  String get paymentStatusNone => 'Suivi pëpe';

  @override
  String get paymentStatusDepositPending => 'Acompte a-tära';

  @override
  String get paymentStatusDepositPaid => 'Acompte a-sï';

  @override
  String get paymentStatusFullyPaid => 'A-fûta ôke';

  @override
  String get markDepositReceived => 'Bâa acompte a-sï';

  @override
  String get markFullyPaid => 'Bâa a-fûta ôke';

  @override
  String get depositReceivedSuccess => 'Acompte a-bâa';

  @override
  String get fullyPaidSuccess => 'Fûta ôke a-sï';

  @override
  String get paymentTracking => 'Suivi tî fûta';

  @override
  String depositOf(String amount) {
    return 'Acompte tî $amount';
  }

  @override
  String remainingToPay(String amount) {
    return 'A-tîgî : $amount';
  }

  @override
  String paidOn(String date) {
    return 'A-sï na $date';
  }

  @override
  String get subscriptionAutoRenewNotice =>
      'Abonnement a-kîri ngbanga tî yê mängö. Mo sï lä na mbâgé ôse.';

  @override
  String get subscriptionLegalFooter =>
      'Na abonnement, mo tëne êe na Conditions tî sâra na Politique tî confidentialité.';

  @override
  String payDepositAmount(String amount) {
    return 'Fütä acompte ($amount)';
  }

  @override
  String payRemainingAmount(String amount) {
    return 'Fütä solde ($amount)';
  }

  @override
  String get paymentSuccessful => 'Fütä a-yeke nzönî !';

  @override
  String get paymentFailed => 'Fütä a-gä pëpe';

  @override
  String get paymentCancelled => 'Fütä a-lä';

  @override
  String get stripeConnect => 'Fütä na internet';

  @override
  String get stripeConnectSubtitle =>
      'Kängö compte Stripe tî mo ngbanga tî bâa môlengê na nzönî';

  @override
  String get stripeConnected => 'Compte Stripe a-kängö';

  @override
  String get stripeNotConnected => 'A-kängö pëpe';

  @override
  String get connectStripe => 'Kängö Stripe';

  @override
  String get stripeConnectPending => 'Onboarding a-yeke...';

  @override
  String get stripePaymentsEnabled => 'Fütä na carte a-duti';

  @override
  String get stripePayoutsEnabled => 'Virements a-duti';

  @override
  String get securePayment => 'Fütä na sêkûrîte na Stripe';

  @override
  String get platformFeeNotice =>
      'Commission tî 15% a-yeke na yâ tî fütä ôko ôko';

  @override
  String get refresh => 'Kîri yângâ';

  @override
  String get pioneerFreeSubscription => 'Abonnement Pro na cadeau';

  @override
  String get pioneerNoCommission => '0% tî commission';

  @override
  String get pioneerBadgePermanent => 'Badge Pioneer na sâra ôse';

  @override
  String pioneerDaysRemaining(String days) {
    return '$days lâ a-töngana';
  }

  @override
  String get pioneerNormalRates =>
      'Tarif normal a-gï sô. Badge Pioneer tî mo a-dûru na sâra ôse.';
}
