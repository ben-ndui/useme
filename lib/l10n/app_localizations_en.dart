// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Use Me';

  @override
  String get settings => 'Settings';

  @override
  String get profile => 'Profile';

  @override
  String get myProfile => 'My profile';

  @override
  String get personalInfo => 'Personal information';

  @override
  String get application => 'Application';

  @override
  String get account => 'Account';

  @override
  String get emailPassword => 'Email, password';

  @override
  String get about => 'About';

  @override
  String get versionLegal => 'Version, legal notices';

  @override
  String get logout => 'Log out';

  @override
  String get logoutConfirmTitle => 'Log out';

  @override
  String get logoutConfirmMessage => 'Are you sure you want to log out?';

  @override
  String get cancel => 'Cancel';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsEnabled => 'Enabled';

  @override
  String get notificationsDisabled => 'Disabled';

  @override
  String get notificationsMuted => 'Mute notifications';

  @override
  String get enableNotificationsInSettings =>
      'Please enable notifications in settings';

  @override
  String get rememberEmail => 'Remember email';

  @override
  String get rememberEmailEnabled => 'Email pre-filled at login';

  @override
  String get rememberEmailDisabled => 'Email not remembered';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLightSubtitle => 'Light theme';

  @override
  String get themeDarkSubtitle => 'Dark theme';

  @override
  String get themeSystemSubtitle => 'Follows device settings';

  @override
  String get language => 'Language';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSystem => 'System';

  @override
  String get languageSystemSubtitle => 'Follows device settings';

  @override
  String get userGuide => 'User guide';

  @override
  String get tipsAndAdvice => 'Tips and advice';

  @override
  String get artistGuide => 'Artist guide';

  @override
  String get engineerGuide => 'Engineer guide';

  @override
  String get studioGuide => 'Studio guide';

  @override
  String get messages => 'Messages';

  @override
  String get noConversations => 'No conversations';

  @override
  String get startNewConversation => 'Start a new conversation';

  @override
  String get newMessage => 'New message';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Retry';

  @override
  String get conversationSettings => 'Settings';

  @override
  String get viewProfile => 'View profile';

  @override
  String get viewParticipants => 'View participants';

  @override
  String get information => 'Information';

  @override
  String get block => 'Block';

  @override
  String get blockContact => 'Block this contact';

  @override
  String get blockConfirmTitle => 'Block';

  @override
  String blockConfirmMessage(String name) {
    return 'Do you want to block $name? You will no longer receive messages from this contact.';
  }

  @override
  String blocked(String name) {
    return '$name has been blocked';
  }

  @override
  String get report => 'Report';

  @override
  String get reportProblem => 'Report a problem';

  @override
  String get reportConfirmTitle => 'Report';

  @override
  String get reportConfirmMessage =>
      'Why do you want to report this conversation?';

  @override
  String get reportSent => 'Report sent';

  @override
  String get leaveConversation => 'Leave conversation';

  @override
  String get deleteFromList => 'Remove from your list';

  @override
  String get leaveConfirmTitle => 'Leave conversation';

  @override
  String leaveConfirmMessage(String name) {
    return 'Do you want to leave the conversation with $name? The history will be deleted.';
  }

  @override
  String get leave => 'Leave';

  @override
  String get actions => 'Actions';

  @override
  String get accountSettings => 'Account';

  @override
  String get credentials => 'Credentials';

  @override
  String get email => 'Email';

  @override
  String get notAvailable => 'Not available';

  @override
  String get changePassword => 'Change password';

  @override
  String get sendResetEmail => 'Receive a reset email';

  @override
  String emailSentTo(String email) {
    return 'Email sent to $email';
  }

  @override
  String get sendError => 'Error sending email';

  @override
  String get dangerZone => 'Danger zone';

  @override
  String get deleteAccount => 'Delete my account';

  @override
  String get deleteAccountWarning => 'This action is irreversible';

  @override
  String get deleteAccountConfirmTitle => 'Delete account';

  @override
  String get deleteAccountConfirmMessage =>
      'Are you sure you want to delete your account? All your data will be lost. This action is irreversible.';

  @override
  String get delete => 'Delete';

  @override
  String get confirmDeletion => 'Confirm deletion';

  @override
  String get enterPassword => 'Enter your password to confirm:';

  @override
  String get password => 'Password';

  @override
  String get confirm => 'Confirm';

  @override
  String get deletionError => 'Error deleting account';

  @override
  String get studio => 'Studio';

  @override
  String get studioProfile => 'Studio profile';

  @override
  String get nameAddressContact => 'Name, address, contact';

  @override
  String get services => 'Services';

  @override
  String get serviceCatalog => 'Service catalog';

  @override
  String get team => 'Team';

  @override
  String get manageEngineers => 'Manage engineers';

  @override
  String get paymentMethods => 'Payment methods';

  @override
  String get paymentMethodsSubtitle => 'Cash, transfer, PayPal...';

  @override
  String get aiAssistant => 'AI Assistant';

  @override
  String get aiSettingsSubtitle => 'Configure automatic responses';

  @override
  String get visibility => 'Visibility';

  @override
  String get studioVisible => 'Studio visible';

  @override
  String get artistsCanSee =>
      'Artists can see your studio and send you session requests.';

  @override
  String get edit => 'Edit';

  @override
  String get becomeVisible => 'Become visible';

  @override
  String get artistsCantFind => 'Artists can\'t find you yet';

  @override
  String get claimStudio =>
      'Claim your studio to appear on the map and receive session requests.';

  @override
  String get calendar => 'Calendar';

  @override
  String get availability => 'Availability';

  @override
  String get manageSlots => 'Manage my slots';

  @override
  String participants(int count) {
    return '$count participants';
  }

  @override
  String get copy => 'Copy';

  @override
  String get deleteMessage => 'Delete';

  @override
  String version(String version) {
    return 'Use Me v$version';
  }

  @override
  String get studiosPlatform => 'The studios platform';

  @override
  String versionBuild(String version, String build) {
    return 'Version $version ($build)';
  }

  @override
  String get legalInfo => 'Legal information';

  @override
  String get termsOfService => 'Terms of service';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get legalNotices => 'Legal notices';

  @override
  String get support => 'Support';

  @override
  String get helpCenter => 'Help center';

  @override
  String get contactUs => 'Contact us';

  @override
  String get followUs => 'Follow us';

  @override
  String copyright(String year) {
    return '© $year Use Me. All rights reserved.';
  }

  @override
  String get archive => 'Archive';

  @override
  String get unarchive => 'Unarchive';

  @override
  String get mySessions => 'My sessions';

  @override
  String get book => 'Book';

  @override
  String get noSession => 'No session';

  @override
  String get enjoyYourDay => 'Enjoy your day!';

  @override
  String get inProgressStatus => 'In progress';

  @override
  String get upcomingStatus => 'Upcoming';

  @override
  String get pastStatus => 'Past';

  @override
  String get noSessions => 'No sessions';

  @override
  String get bookFirstSession => 'Book your first session';

  @override
  String get pendingStatus => 'Pending';

  @override
  String get confirmedStatus => 'Confirmed';

  @override
  String get completedStatus => 'Completed';

  @override
  String get cancelledStatus => 'Cancelled';

  @override
  String get noShowStatus => 'No show';

  @override
  String hoursOfSession(int hours) {
    return '${hours}h session';
  }

  @override
  String sessionAt(String studio) {
    return 'Session at $studio';
  }

  @override
  String get sessionRequest => 'Session request';

  @override
  String get noStudioSelected => 'No studio selected';

  @override
  String get selectStudioFirst =>
      'Select a studio first to see its availability.';

  @override
  String get back => 'Back';

  @override
  String get sessionType => 'Session type';

  @override
  String get sessionDuration => 'Session duration';

  @override
  String get chooseSlot => 'Choose your slot';

  @override
  String get engineerPreference => 'Engineer preference';

  @override
  String get notesOptional => 'Notes (optional)';

  @override
  String get describeProject => 'Describe your project, your needs...';

  @override
  String get sendRequest => 'Send request';

  @override
  String get summaryLabel => 'Summary';

  @override
  String get noPreference => 'No preference';

  @override
  String get engineerSelectedLabel => 'Engineer selected';

  @override
  String get letStudioChoose => 'Let the studio choose';

  @override
  String availableCount(int count) {
    return '$count available';
  }

  @override
  String get requestSent => 'Request sent! The studio will respond soon.';

  @override
  String get slotInfoText =>
      'Green slots have more engineers available. You can also choose your preferred engineer.';

  @override
  String get engineer => 'Engineer';

  @override
  String get notSpecified => 'Not specified';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get quickAccess => 'Quick access';

  @override
  String get sessionsLabel => 'Sessions';

  @override
  String get favoritesLabel => 'Favorites';

  @override
  String get preferencesLabel => 'Preferences';

  @override
  String get upcomingSessions => 'Upcoming sessions';

  @override
  String get viewAll => 'View all';

  @override
  String get noUpcomingSessions => 'No upcoming sessions';

  @override
  String get bookNextSession => 'Book your next studio session';

  @override
  String get recentActivity => 'Recent activity';

  @override
  String get noHistory => 'No history yet';

  @override
  String get completedSessionsHere =>
      'Your completed sessions will appear here';

  @override
  String get waitingStatus => 'Waiting';

  @override
  String get todaySessions => 'Today\'s sessions';

  @override
  String get today => 'Today';

  @override
  String get noSessionToday => 'No session today';

  @override
  String get noSessionsPlanned => 'No sessions planned';

  @override
  String get noAssignedSessions => 'You have no assigned sessions';

  @override
  String get notConnected => 'Not connected';

  @override
  String get myAvailabilities => 'My availability';

  @override
  String get workingHours => 'Working hours';

  @override
  String get unavailabilities => 'Unavail.';

  @override
  String get add => 'Add';

  @override
  String get noTimeOff => 'No time off';

  @override
  String get addTimeOffHint => 'Add your vacations, leaves or absences';

  @override
  String get myStudio => 'My Studio';

  @override
  String get overview => 'Overview';

  @override
  String get session => 'Session';

  @override
  String get artist => 'Artist';

  @override
  String get artists => 'Artists';

  @override
  String get artistsLabel => 'Artists';

  @override
  String get planning => 'Planning';

  @override
  String get stats => 'Stats';

  @override
  String get thisMonth => 'This month';

  @override
  String get freeDay => 'Free day';

  @override
  String get noSessionScheduled => 'No session scheduled';

  @override
  String get pendingRequests => 'Pending requests';

  @override
  String get recentArtists => 'Recent artists';

  @override
  String get filterByStatus => 'Filter by status';

  @override
  String get all => 'All';

  @override
  String get confirmed => 'Confirmed';

  @override
  String sessionCount(int count) {
    return '$count session';
  }

  @override
  String sessionsCount(int count) {
    return '$count sessions';
  }

  @override
  String get noSessionThisDay => 'No session this day';

  @override
  String get noSessionTodayScheduled => 'No session scheduled today';

  @override
  String get scheduleSession => 'Schedule a session';

  @override
  String get serviceCatalogTitle => 'Service catalog';

  @override
  String get noService => 'No service';

  @override
  String get createServiceCatalog => 'Create your service catalog';

  @override
  String get newService => 'New service';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get rooms => 'Rooms';

  @override
  String get noRooms => 'No rooms';

  @override
  String get createRoomsHint => 'Configure your studio rooms';

  @override
  String get addRoom => 'Add room';

  @override
  String get editRoom => 'Edit room';

  @override
  String get roomName => 'Room name';

  @override
  String get roomNameHint => 'Ex: Studio A, Booth 1...';

  @override
  String get roomDescriptionHint => 'Describe the room and its features';

  @override
  String get accessType => 'Access type';

  @override
  String get withEngineer => 'With engineer';

  @override
  String get withEngineerDesc => 'Sound engineer required';

  @override
  String get selfService => 'Self-service';

  @override
  String get selfServiceDesc => 'No engineer needed';

  @override
  String get equipment => 'Equipment';

  @override
  String get equipmentHint => 'Mic, console, speakers... (comma separated)';

  @override
  String get roomActive => 'Room active';

  @override
  String get roomVisibleForBooking => 'Visible for bookings';

  @override
  String get roomHiddenForBooking => 'Hidden from bookings';

  @override
  String get deleteRoom => 'Delete room';

  @override
  String get deleteRoomConfirm => 'Are you sure you want to delete this room?';

  @override
  String get selectRoom => 'Select room';

  @override
  String get noRoomAvailable => 'No room available';

  @override
  String get restDay => 'Closed';

  @override
  String get inProgress => 'In progress';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get past => 'Past';

  @override
  String get listView => 'List view';

  @override
  String get calendarView => 'Calendar view';

  @override
  String get deleteTimeOff => 'Delete';

  @override
  String get deleteTimeOffConfirm => 'Delete this time off?';

  @override
  String daysCount(int count) {
    return '$count day';
  }

  @override
  String daysCountPlural(int count) {
    return '$count days';
  }

  @override
  String get addTimeOff => 'Add time off';

  @override
  String get fromDate => 'From';

  @override
  String get toDate => 'To';

  @override
  String get reasonOptional => 'Reason (optional)';

  @override
  String get enterCustomReason => 'Or enter a reason...';

  @override
  String get errorLoadingAvailability => 'Error loading availability';

  @override
  String get available => 'Available';

  @override
  String get limited => 'Limited';

  @override
  String get unavailable => 'Unavailable';

  @override
  String slotsForDate(String date) {
    return 'Slots for $date';
  }

  @override
  String get noSlotAvailable => 'No slot available';

  @override
  String get tryAnotherDate => 'Try another date';

  @override
  String get fullyAvailable => 'Fully available';

  @override
  String get partiallyAvailable => 'Partially available';

  @override
  String get noEngineerAvailable => 'No engineer available';

  @override
  String get studioUnavailable => 'Studio unavailable';

  @override
  String get noEngineerTryAnotherDate =>
      'No engineer available this day. Try another date.';

  @override
  String get chooseEngineer => 'Choose an engineer';

  @override
  String availableCountLabel(int count) {
    return '$count available';
  }

  @override
  String get optionalEngineerInfo =>
      'Optional: let the studio assign an engineer automatically';

  @override
  String get availableLabel => 'AVAILABLE';

  @override
  String get unavailableLabel => 'UNAVAILABLE';

  @override
  String get studioWillAssignEngineer => 'The studio will assign an engineer';

  @override
  String get bookNextSessionSubtitle => 'Book your next session';

  @override
  String get emailHint => 'Email';

  @override
  String get emailRequired => 'Email required';

  @override
  String get emailInvalid => 'Invalid email';

  @override
  String get passwordHint => 'Password';

  @override
  String get passwordRequired => 'Password required';

  @override
  String minCharacters(int count) {
    return 'Minimum $count characters';
  }

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get signIn => 'Sign in';

  @override
  String get or => 'or';

  @override
  String get noAccountYet => 'No account yet?';

  @override
  String get signUp => 'Sign up';

  @override
  String get demoAccess => 'Demo access';

  @override
  String get enterEmailFirst => 'Enter your email first';

  @override
  String get demoMode => 'Demo Mode';

  @override
  String get browseWithoutLogin => 'Browse without login';

  @override
  String get studioAdmin => 'Studio (Admin)';

  @override
  String get manageSessionsArtistsServices =>
      'Manage sessions, artists, services';

  @override
  String get soundEngineer => 'Sound engineer';

  @override
  String get viewAndTrackSessions => 'View and track sessions';

  @override
  String get bookSessions => 'Book sessions';

  @override
  String get createAccount => 'Create account';

  @override
  String get joinCommunity => 'Join the community';

  @override
  String get iAm => 'I am...';

  @override
  String get orByEmail => 'or by email';

  @override
  String get stageNameOrName => 'Stage name or name';

  @override
  String get fullName => 'Full name';

  @override
  String get nameRequired => 'Name required';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get confirmationRequired => 'Confirmation required';

  @override
  String get passwordsDontMatch => 'Passwords don\'t match';

  @override
  String get createMyAccount => 'Create my account';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get chooseYourProfile => 'Choose your profile';

  @override
  String get actionIsPermanent => 'This action is permanent';

  @override
  String get howToUseApp => 'How would you like to use the app?';

  @override
  String get iOwnStudio => 'I own a studio';

  @override
  String get iWorkInStudio => 'I work in a studio';

  @override
  String get iWantToBookSessions => 'I want to book sessions';

  @override
  String get acceptBooking => 'Accept booking';

  @override
  String get choosePaymentMethod => 'Choose payment method';

  @override
  String get noPaymentMethodConfigured =>
      'No payment method configured. Go to Settings > Payment methods.';

  @override
  String get paymentMode => 'Payment method';

  @override
  String get depositRequested => 'Deposit requested';

  @override
  String get customMessageOptional => 'Custom message (optional)';

  @override
  String get customMessageHint => 'Ex: Thanks for your trust!';

  @override
  String get totalAmount => 'Total amount';

  @override
  String get depositToPay => 'Deposit to pay';

  @override
  String get paymentBy => 'Payment by';

  @override
  String ofTotalAmount(int percent) {
    return '$percent% of total amount';
  }

  @override
  String get acceptAndSendInfo => 'Accept and send info';

  @override
  String get welcome => 'Welcome!';

  @override
  String get discoverAppFeatures =>
      'Discover how to get the most out of Use Me';

  @override
  String get nearbyStudios => 'Nearby studios';

  @override
  String get discoverWhereToRecord => 'Discover where to record';

  @override
  String get noStudioFound => 'No studio found';

  @override
  String get enableLocationToDiscover =>
      'Enable location to discover studios near you';

  @override
  String get partner => 'Partner';

  @override
  String get missingStudio => 'Missing studio?';

  @override
  String get tellUsWhichStudio => 'Tell us which studio you\'re looking for';

  @override
  String get studioName => 'Studio name';

  @override
  String get studioNameExample => 'Ex: Studio XYZ';

  @override
  String get pleaseEnterStudioName => 'Please enter the studio name';

  @override
  String get city => 'City';

  @override
  String get cityExample => 'Ex: New York, Los Angeles...';

  @override
  String get pleaseEnterCity => 'Please enter the city';

  @override
  String get notesOptionalLabel => 'Notes (optional)';

  @override
  String get notesHint => 'Address, website, useful info...';

  @override
  String get sending => 'Sending...';

  @override
  String get sendRequestLabel => 'Send request';

  @override
  String get requestSubmitted => 'Request submitted!';

  @override
  String get weWillVerifyAndAddStudio =>
      'We will verify and add this studio soon.';

  @override
  String get searchingStudios => 'Searching for studios...';

  @override
  String get partnerLabel => 'Partner';

  @override
  String get newConversation => 'New conversation';

  @override
  String get searchContact => 'Search a contact...';

  @override
  String get errorLoadingContacts => 'Error loading contacts';

  @override
  String get user => 'User';

  @override
  String get contact => 'Contact';

  @override
  String get noResult => 'No result';

  @override
  String get noContactAvailable => 'No contact available';

  @override
  String get myContacts => 'My contacts';

  @override
  String get searchResults => 'Search results';

  @override
  String get tryOtherTerms => 'Try with other terms';

  @override
  String get contactsWillAppearHere => 'Your contacts will appear here';

  @override
  String get noName => 'No name';

  @override
  String get searchByNameOrEmail => 'Search by name or email...';

  @override
  String get searchArtist => 'Search an artist';

  @override
  String get typeAtLeastTwoChars =>
      'Type at least 2 characters to search among registered artists';

  @override
  String get noArtistFound => 'No artist found';

  @override
  String get artistNotRegistered =>
      'This artist is not yet registered. Invite them or create their profile manually.';

  @override
  String get link => 'Link';

  @override
  String get createNewArtist => 'Create new artist';

  @override
  String get artistNotOnApp =>
      'Artist not on the app? Create their profile and invite them';

  @override
  String get home => 'Home';

  @override
  String get favorites => 'Favorites';

  @override
  String get myFavorites => 'My favorites';

  @override
  String get studios => 'Studios';

  @override
  String get studiosLabel => 'Studios';

  @override
  String get engineers => 'Engineers';

  @override
  String get engineersLabel => 'Engineers';

  @override
  String get noFavoriteStudio => 'No favorite studio';

  @override
  String get noFavoriteStudios => 'No favorite studio';

  @override
  String get exploreStudiosAndAddFavorites =>
      'Explore studios and add them to your favorites';

  @override
  String get exploreStudiosToFavorite =>
      'Explore studios and add them to your favorites';

  @override
  String get noFavoriteEngineer => 'No favorite engineer';

  @override
  String get noFavoriteEngineers => 'No favorite engineer';

  @override
  String get discoverEngineersAndAddFavorites =>
      'Discover engineers and add them to your favorites';

  @override
  String get discoverEngineersToFavorite =>
      'Discover engineers and add them to your favorites';

  @override
  String get noFavoriteArtists => 'No favorite artist';

  @override
  String get addArtistsToFavorite =>
      'Add artists to your favorites from the artists list';

  @override
  String get unnamed => 'Unnamed';

  @override
  String get claimStudioTitle => 'My studio';

  @override
  String get nearbyStudiosTitle => 'Nearby studios';

  @override
  String get selectStudioToClaim => 'Select your studio to claim it';

  @override
  String get connectGoogleCalendarDesc =>
      'Connect your Google Calendar to automatically sync your availability.';

  @override
  String get connectGoogleCalendar => 'Connect Google Calendar';

  @override
  String get claimYourStudioTitle => 'Claim your studio';

  @override
  String get claimYourStudio => 'Claim your studio';

  @override
  String get claimYourStudioDesc =>
      'Make your studio visible to artists and receive session requests.';

  @override
  String get claimStudioDescription =>
      'Make your studio visible to artists and receive session requests.';

  @override
  String get noStudioFoundNearby => 'No studio found nearby';

  @override
  String get createStudioManually => 'Create your studio manually below';

  @override
  String get createStudioManuallyBelow => 'Create your studio manually below';

  @override
  String get studioNotAppearing => 'My studio doesn\'t appear';

  @override
  String get studioNotListed => 'My studio doesn\'t appear';

  @override
  String get createStudioProfileManually => 'Manually create my studio profile';

  @override
  String get createManualProfile => 'Manually create my studio profile';

  @override
  String get claimThisStudio => 'Claim this studio?';

  @override
  String get claimStudioExplanation =>
      'By claiming this studio, you make it visible to artists on Use Me. They will be able to see your availability and send you session requests.';

  @override
  String get claimStudioInfo =>
      'By claiming this studio, you make it visible to artists on Use Me. They will be able to see your availability and send you session requests.';

  @override
  String get claim => 'Claim';

  @override
  String studioClaimedSuccess(String name) {
    return '$name claimed successfully!';
  }

  @override
  String get studioClaims => 'Studio claims';

  @override
  String get studioClaimsSubtitle => 'Approve or reject requests';

  @override
  String get unclaim => 'Remove';

  @override
  String get unclaimStudioTitle => 'Remove studio?';

  @override
  String unclaimStudioMessage(String name) {
    return 'Are you sure you want to remove \"$name\"? Your studio will no longer be visible to artists.';
  }

  @override
  String get studioUnclaimed => 'Studio removed successfully';

  @override
  String get configurePayments => 'Configure your payments';

  @override
  String get paymentOptionsDescription =>
      'These options will be offered to artists when confirming a booking.';

  @override
  String get defaultDeposit => 'Default deposit';

  @override
  String get depositPercentDescription =>
      'Percentage of total amount requested as deposit';

  @override
  String get acceptedPaymentMethods => 'Accepted payment methods';

  @override
  String get instructionsOptional => 'Instructions (optional)';

  @override
  String get instructionsHint => 'Ex: Put the artist\'s name as reference';

  @override
  String get paypalEmail => 'PayPal Email';

  @override
  String get cardInfo => 'Information';

  @override
  String get details => 'Details';

  @override
  String get iban => 'IBAN';

  @override
  String get createMyStudio => 'Create my studio';

  @override
  String get studioNameRequired => 'Studio name *';

  @override
  String get studioNameHint => 'Ex: Harmony Studio';

  @override
  String get studioNameRequiredError => 'Studio name is required';

  @override
  String get studioNameIsRequired => 'Studio name is required';

  @override
  String get description => 'Description';

  @override
  String get describeStudioHint => 'Describe your studio in a few words...';

  @override
  String get describeYourStudio => 'Describe your studio in a few words...';

  @override
  String get location => 'Location';

  @override
  String get address => 'Address';

  @override
  String get addressHint => 'Ex: 123 Music Street';

  @override
  String get postalCode => 'Postal code';

  @override
  String get cityRequired => 'City *';

  @override
  String get cityRequiredError => 'City is required';

  @override
  String get cityIsRequired => 'City is required';

  @override
  String get phone => 'Phone';

  @override
  String get phoneHint => '123-456-7890';

  @override
  String get website => 'Website';

  @override
  String get websiteHint => 'https://www.mystudio.com';

  @override
  String get offeredServices => 'Offered services';

  @override
  String get servicesOffered => 'Offered services';

  @override
  String get creating => 'Creating...';

  @override
  String get creatingInProgress => 'Creating...';

  @override
  String get studioCreatedSuccess => 'Studio created successfully!';

  @override
  String get manualCreation => 'Manual creation';

  @override
  String get studioVisibleAfterCreation =>
      'Your studio will be visible to artists once created. You can complete your profile later.';

  @override
  String get manualCreationDescription =>
      'Your studio will be visible to artists once created. You can complete your profile later.';

  @override
  String get editSession => 'Edit session';

  @override
  String get newSession => 'New session';

  @override
  String get dateAndTime => 'Date and time';

  @override
  String get duration => 'Duration';

  @override
  String get save => 'Save';

  @override
  String get createSession => 'Create session';

  @override
  String get addArtistFirst => 'Add an artist first';

  @override
  String get selectArtist => 'Select an artist';

  @override
  String get addAnotherArtist => 'Add another artist';

  @override
  String get allArtistsSelected => 'All artists are already selected';

  @override
  String get selectAtLeastOneArtist => 'Select at least one artist';

  @override
  String get deleteSession => 'Delete session';

  @override
  String get actionIrreversible => 'This action is irreversible.';

  @override
  String get editService => 'Edit service';

  @override
  String get newServiceTitle => 'New service';

  @override
  String get serviceName => 'Service name';

  @override
  String get serviceNameHint => 'Ex: Mix, Mastering, Recording...';

  @override
  String get fieldRequired => 'Field required';

  @override
  String get serviceDescription => 'Description (optional)';

  @override
  String get serviceDescriptionHint => 'Service description...';

  @override
  String get hourlyRate => 'Hourly rate (€)';

  @override
  String get perHour => '€/h';

  @override
  String get invalidNumber => 'Invalid number';

  @override
  String get minimumDuration => 'Minimum duration';

  @override
  String get serviceActive => 'Service active';

  @override
  String get availableForBooking => 'Available for booking';

  @override
  String get notAvailableForBooking => 'Not available';

  @override
  String get createService => 'Create service';

  @override
  String get deleteService => 'Delete service';

  @override
  String get teamMembers => 'Team members';

  @override
  String get pendingInvitations => 'Pending invitations';

  @override
  String get noMember => 'No member';

  @override
  String get addEngineersToTeam => 'Add engineers to your team';

  @override
  String get noInvitation => 'No invitation';

  @override
  String get pendingInvitationsHere => 'Pending invitations will appear here';

  @override
  String get codeCopied => 'Code copied';

  @override
  String get removeFromTeam => 'Remove from team';

  @override
  String get removeMemberConfirm => 'Remove this member?';

  @override
  String memberNoAccessAnymore(String name) {
    return '$name will no longer have access to the studio\'s sessions.';
  }

  @override
  String get memberRemoved => 'Member removed';

  @override
  String get remove => 'Remove';

  @override
  String get invitationCancelled => 'Invitation cancelled';

  @override
  String get addMember => 'Add member';

  @override
  String get searchByEmailOrInvite =>
      'Search by email or invite a new engineer';

  @override
  String get userNotRegistered => 'User not registered';

  @override
  String get sendInvitationToJoin =>
      'Send them an invitation to join your team.';

  @override
  String get sendInvitation => 'Send invitation';

  @override
  String get enterValidEmail => 'Enter a valid email';

  @override
  String get invitationCreated => 'Invitation created';

  @override
  String get shareCodeWithEngineer => 'Share this code with the engineer:';

  @override
  String get searchArtistHint => 'Search for an artist...';

  @override
  String get noArtistEmpty => 'No artist';

  @override
  String get addFirstArtist => 'Add your first artist';

  @override
  String get addArtist => 'Add artist';

  @override
  String get tryAnotherSearch => 'Try another search';

  @override
  String get search => 'Search';

  @override
  String get create => 'Create';

  @override
  String get findExistingArtist => 'Find an existing artist';

  @override
  String get searchAmongRegistered =>
      'Search among artists already registered on Use Me to link them to your studio.';

  @override
  String artistAddedToStudio(String name) {
    return '$name added to your studio!';
  }

  @override
  String get artistName => 'Artist name';

  @override
  String get stageNameHint => 'The stage name...';

  @override
  String get civilName => 'Legal name';

  @override
  String get firstAndLastName => 'First and last name...';

  @override
  String get emailHintArtist => 'Artist\'s email...';

  @override
  String get emailRequiredForInvitation => 'Email required for invitation';

  @override
  String get phoneOptional => 'Phone (optional)';

  @override
  String get phoneHintGeneric => 'Phone...';

  @override
  String get musicalGenres => 'Musical genres';

  @override
  String get sendInvitationToggle => 'Send an invitation';

  @override
  String get artistWillReceiveCode =>
      'The artist will receive a code to join your studio';

  @override
  String get createAndInvite => 'Create and invite';

  @override
  String get createProfile => 'Create profile';

  @override
  String get createArtistProfile => 'Create an artist profile';

  @override
  String get createProfileAndInvite =>
      'Create the profile and invite the artist. Their account will be automatically linked when they sign up.';

  @override
  String get artistCreated => 'Artist created!';

  @override
  String get shareCodeWithArtist =>
      'Share this code with the artist so they can join your studio';

  @override
  String get share => 'Share';

  @override
  String get done => 'Done';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get markAllRead => 'Mark all read';

  @override
  String get markAllAsRead => 'Mark all read';

  @override
  String get noNotification => 'No notification';

  @override
  String get noNotifications => 'No notification';

  @override
  String get notifiedForNewSessions => 'You will be notified of new sessions';

  @override
  String get notifyNewSessions => 'You will be notified of new sessions';

  @override
  String get loadingError => 'Loading error';

  @override
  String get personalInformation => 'Personal information';

  @override
  String get fullNameLabel => 'Full name';

  @override
  String get required => 'Required';

  @override
  String get stageName => 'Stage name';

  @override
  String get bio => 'Bio';

  @override
  String get tellAboutYourself => 'Tell about yourself...';

  @override
  String get accountSection => 'Account';

  @override
  String get changePasswordAction => 'Change password';

  @override
  String get logoutAction => 'Log out';

  @override
  String get signOut => 'Log out';

  @override
  String get deleteMyAccount => 'Delete my account';

  @override
  String get resetEmailSent => 'Reset email sent';

  @override
  String get deleteAccountTitle => 'Delete account';

  @override
  String get deleteAccountFinalWarning =>
      'This action is irreversible. All your data will be permanently deleted.';

  @override
  String get sessionTracking => 'Session tracking';

  @override
  String hoursPlanned(int hours) {
    return '${hours}h planned';
  }

  @override
  String get checkIn => 'Check-in';

  @override
  String get checkInArrival => 'Check in arrival';

  @override
  String get arrivalChecked => 'Arrival checked';

  @override
  String get checkOutDeparture => 'Check out departure';

  @override
  String get sessionNotes => 'Session notes';

  @override
  String get addSessionNotes => 'Add notes about the session...';

  @override
  String get photos => 'Photos';

  @override
  String get addPhoto => 'Add a photo';

  @override
  String get arrivalCheckedSuccess => 'Arrival checked!';

  @override
  String get endSession => 'End session?';

  @override
  String get endSessionConfirm =>
      'Do you want to check out and end this session?';

  @override
  String get finish => 'Finish';

  @override
  String get contactArtist => 'Contact artist';

  @override
  String get reportProblemAction => 'Report a problem';

  @override
  String get editArtist => 'Edit artist';

  @override
  String get newArtistTitle => 'New artist';

  @override
  String get emailHintGeneric => 'Email...';

  @override
  String get cityHint => 'City...';

  @override
  String get bioOptional => 'Bio (optional)';

  @override
  String get fewWordsAboutArtist => 'A few words about the artist...';

  @override
  String get createArtist => 'Create artist';

  @override
  String get deleteArtist => 'Delete artist';

  @override
  String get calendarTitle => 'Calendar';

  @override
  String get unavailabilityAdded => 'Unavailability added';

  @override
  String get unavailabilityDeleted => 'Unavailability deleted';

  @override
  String get calendarConnected => 'Calendar connected';

  @override
  String get never => 'Never';

  @override
  String get lastSync => 'Last sync';

  @override
  String get synchronize => 'Synchronize';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get disconnectCalendar => 'Disconnect calendar?';

  @override
  String get disconnectCalendarWarning =>
      'Your synced unavailabilities will be deleted. Manual unavailabilities will be kept.';

  @override
  String get tipsSectionGettingStarted => 'Getting started';

  @override
  String get tipsSectionBookings => 'Bookings';

  @override
  String get tipsSectionProTips => 'Pro tips';

  @override
  String get tipsSectionSetup => 'Setup';

  @override
  String get tipsSectionSessions => 'Sessions';

  @override
  String get tipsSectionTips => 'Tips';

  @override
  String get tipsSectionStudioSetup => 'Studio setup';

  @override
  String get tipsSectionTeamManagement => 'Team management';

  @override
  String get tipsSectionVisibility => 'Visibility';

  @override
  String get tipExploreMapTitle => 'Explore the map';

  @override
  String get tipExploreMapDesc =>
      'The map shows you all studios around you. Green pins are partner studios with exclusive benefits. Zoom and move around to discover more studios.';

  @override
  String get tipCompleteProfileTitle => 'Complete your profile';

  @override
  String get tipCompleteProfileDesc =>
      'A complete profile with photo and musical genres helps studios know you better. Go to Settings > My profile to add this info.';

  @override
  String get tipChooseSlotTitle => 'Choose the right slot';

  @override
  String get tipChooseSlotDesc =>
      'Green slots indicate high engineer availability. Orange slots are more limited. Prefer green slots for more flexibility.';

  @override
  String get tipSelectEngineerTitle => 'Select your engineer';

  @override
  String get tipSelectEngineerDesc =>
      'You can choose a specific engineer or let the studio assign one. If you\'ve worked with someone before, find them in the list!';

  @override
  String get tipPrepareSessionTitle => 'Prepare your session';

  @override
  String get tipPrepareSessionDesc =>
      'Use the \"Notes\" field to describe your project: style, references, what you want to accomplish. It helps the engineer prepare.';

  @override
  String get tipBookAdvanceTitle => 'Book in advance';

  @override
  String get tipBookAdvanceDesc =>
      'The best slots go fast! Book 2-3 days in advance to have your pick of times and engineers.';

  @override
  String get tipManageFavoritesTitle => 'Manage your favorites';

  @override
  String get tipManageFavoritesDesc =>
      'Add your favorite studios to find them quickly. Tap the heart on the studio page.';

  @override
  String get tipTrackSessionsTitle => 'Track your sessions';

  @override
  String get tipTrackSessionsDesc =>
      'In the Sessions tab, find your complete history. It\'s handy for rebooking with the same engineer or studio.';

  @override
  String get tipSetScheduleTitle => 'Set your schedule';

  @override
  String get tipSetScheduleDesc =>
      'Go to Settings > Availability to configure your work days and hours. Artists can only book during your active slots.';

  @override
  String get tipAddUnavailabilityTitle => 'Add your unavailabilities';

  @override
  String get tipAddUnavailabilityDesc =>
      'Vacation, appointment, or day off? Add an unavailability to block these periods. You can add an optional reason.';

  @override
  String get tipViewSessionsTitle => 'View your sessions';

  @override
  String get tipViewSessionsDesc =>
      'The Sessions tab shows all your upcoming sessions. \"Confirmed\" sessions are validated, \"Pending\" need studio confirmation.';

  @override
  String get tipStartSessionTitle => 'Start a session';

  @override
  String get tipStartSessionDesc =>
      'On the day, tap \"Start\" to launch the timer. At the end, tap \"Finish\" and add your session notes.';

  @override
  String get tipSessionNotesTitle => 'Session notes';

  @override
  String get tipSessionNotesDesc =>
      'After each session, add notes: settings used, exported files, remarks. It\'s useful for you and the artist.';

  @override
  String get tipStayUpdatedTitle => 'Stay up to date';

  @override
  String get tipStayUpdatedDesc =>
      'Update your availability regularly. An up-to-date schedule = more bookings for you!';

  @override
  String get tipProfileMattersTitle => 'Your profile matters';

  @override
  String get tipProfileMattersDesc =>
      'Artists can specifically choose you. A professional photo and bio with your specialties attract more clients.';

  @override
  String get tipCompleteStudioProfileTitle => 'Complete your studio profile';

  @override
  String get tipCompleteStudioProfileDesc =>
      'Add photos, description, equipment, and services. A complete profile appears higher in results and attracts more artists.';

  @override
  String get tipSetStudioHoursTitle => 'Set your hours';

  @override
  String get tipSetStudioHoursDesc =>
      'Configure studio opening hours in Settings. Artists can only book during these hours.';

  @override
  String get tipAddServicesTitle => 'Add your services';

  @override
  String get tipAddServicesDesc =>
      'Recording, mixing, mastering... Define your services with their rates. It helps artists choose.';

  @override
  String get tipInviteEngineersTitle => 'Invite your engineers';

  @override
  String get tipInviteEngineersDesc =>
      'Go to Team > Invite to add your engineers. They\'ll receive a link to join your studio.';

  @override
  String get tipManageAvailabilitiesTitle => 'Manage availabilities';

  @override
  String get tipManageAvailabilitiesDesc =>
      'Each engineer manages their own availability. You can see the overview in the studio planning.';

  @override
  String get tipAssignSessionsTitle => 'Assign sessions';

  @override
  String get tipAssignSessionsDesc =>
      'When an artist doesn\'t choose an engineer, it\'s up to you to assign one. Check availability before assigning.';

  @override
  String get tipManageRequestsTitle => 'Manage requests';

  @override
  String get tipManageRequestsDesc =>
      'New requests appear in \"Pending\". Validate quickly to retain artists!';

  @override
  String get tipInviteArtistsTitle => 'Invite your artists';

  @override
  String get tipInviteArtistsDesc =>
      'Have regular artists? Invite them via Clients > Invite. They\'ll be able to book more easily.';

  @override
  String get tipTrackActivityTitle => 'Track activity';

  @override
  String get tipTrackActivityDesc =>
      'The dashboard shows you stats: month\'s sessions, revenue, active artists. Keep an eye on your activity.';

  @override
  String get tipBecomePartnerTitle => 'Become a partner';

  @override
  String get tipBecomePartnerDesc =>
      'Partner studios appear in green on the map and get priority. Contact us to learn more!';

  @override
  String get tipEncourageReviewsTitle => 'Encourage reviews';

  @override
  String get tipEncourageReviewsDesc =>
      'After a successful session, invite the artist to leave a review. Good reviews attract more clients.';

  @override
  String get tipsSectionAIAssistant => 'AI Assistant';

  @override
  String get tipAIAssistantTitle => 'Talk to your assistant';

  @override
  String get tipAIAssistantDesc =>
      'The AI assistant knows all your data. Ask about your sessions, stats, or get help with any question!';

  @override
  String get tipAIActionsTitle => 'Voice actions';

  @override
  String get tipAIActionsStudioDesc =>
      'Ask the assistant to create sessions, accept bookings, manage your services... All through chat!';

  @override
  String get tipAIActionsEngineerDesc =>
      'Ask the assistant to start or complete your sessions, manage your time off, and more.';

  @override
  String get tipAIActionsArtistDesc =>
      'The assistant can search studios, manage your favorites, create booking requests for you.';

  @override
  String get tipAIContextTitle => 'It knows you';

  @override
  String get tipAIContextDesc =>
      'The assistant knows who you are and adapts its responses to your profile. It can access your real data in real-time.';

  @override
  String get teamInvitations => 'Team invitations';

  @override
  String get noEmailConfigured => 'Email not configured';

  @override
  String get noInvitations => 'No invitations';

  @override
  String get noInvitationsDescription => 'You have no pending invitations.';

  @override
  String invitationSentOn(String date) {
    return 'Sent on $date';
  }

  @override
  String teamInvitationMessage(String studioName) {
    return '$studioName invites you to join their team as a sound engineer.';
  }

  @override
  String expiresOn(String date) {
    return 'Expires on $date';
  }

  @override
  String get decline => 'Decline';

  @override
  String get accept => 'Accept';

  @override
  String get invitationAccepted =>
      'Invitation accepted! You are now part of the team.';

  @override
  String get declineInvitation => 'Decline invitation';

  @override
  String declineInvitationConfirm(String studioName) {
    return 'Are you sure you want to decline the invitation from $studioName?';
  }

  @override
  String get invitationDeclined => 'Invitation declined.';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String get sessionDetails => 'Session details';

  @override
  String get toBeAssigned => 'To be assigned by studio';

  @override
  String get acceptSession => 'Accept session';

  @override
  String get confirmAcceptSession =>
      'Do you want to accept this session request?';

  @override
  String get sessionAccepted => 'Session accepted!';

  @override
  String get declineSession => 'Decline session';

  @override
  String get confirmDeclineSession =>
      'Do you want to decline this session request?';

  @override
  String get sessionDeclined => 'Session declined';

  @override
  String get cancelSession => 'Cancel session';

  @override
  String get confirmCancelSession =>
      'Do you want to cancel this session? This action cannot be undone.';

  @override
  String get bic => 'BIC / SWIFT';

  @override
  String get accountHolder => 'Account holder name';

  @override
  String get bankName => 'Bank name';

  @override
  String get cancellationPolicy => 'Cancellation policy';

  @override
  String get cancellationPolicyDescription =>
      'Define your refund conditions in case of cancellation';

  @override
  String get customCancellationTerms => 'Custom terms';

  @override
  String get customCancellationHint =>
      'Describe your cancellation conditions...';

  @override
  String get saveAsDefault => 'Save as default';

  @override
  String get saveAsDefaultDescription => 'Use this choice for future sessions';

  @override
  String get proposeToEngineers => 'Propose';

  @override
  String get assignLater => 'Later';

  @override
  String get assignLaterDescription =>
      'You can assign an engineer from the session details later';

  @override
  String get selectAtLeastOne => 'Select at least 1';

  @override
  String get assignEngineer => 'Sound engineer';

  @override
  String get noEngineersAvailable => 'No engineer available for this time slot';

  @override
  String get proposedSessions => 'Proposed sessions';

  @override
  String get proposedSessionsEmpty => 'No pending proposals';

  @override
  String get acceptProposal => 'Accept';

  @override
  String get declineProposal => 'Decline';

  @override
  String get joinAsCoEngineer => 'Join';

  @override
  String get sessionProposedToYou => 'Session proposed';

  @override
  String get sessionTaken => 'Session taken';

  @override
  String get sessionTakenDesc =>
      'This session was accepted by another engineer. You can request to join.';

  @override
  String get requestToJoin => 'Request to join';

  @override
  String get joinedAsCoEngineer => 'You joined the session!';

  @override
  String get proposalAccepted => 'Proposal accepted!';

  @override
  String get proposalDeclined => 'Proposal declined';

  @override
  String get youAreAssigned => 'You are assigned';

  @override
  String get pendingProposal => 'Pending response';

  @override
  String get openingHours => 'Opening hours';

  @override
  String get openingHoursSubtitle => 'Define when your studio is open';

  @override
  String get noOpeningHoursConfigured => 'No opening hours configured';

  @override
  String get openingHoursSaved => 'Opening hours saved';

  @override
  String get allowNoEngineer => 'Booking without engineer';

  @override
  String get allowNoEngineerSubtitle =>
      'Allow artists to book even if no engineer is available';

  @override
  String get settingsSaved => 'Setting saved';

  @override
  String get selectStudio => 'Select a studio';

  @override
  String get selectStudioDescription => 'Choose the studio for your session';

  @override
  String get noLinkedStudios => 'No linked studios';

  @override
  String get noLinkedStudiosDescription =>
      'You are not linked to any studio. Explore studios to get started.';

  @override
  String get discoverStudios => 'Discover studios';

  @override
  String get exploreMapHint => 'Explore the map to find nearby studios';

  @override
  String get changePhoto => 'Change photo';

  @override
  String get takePhoto => 'Take a photo';

  @override
  String get useCamera => 'Use camera';

  @override
  String get chooseFromGallery => 'Choose from gallery';

  @override
  String get selectExistingPhoto => 'Select existing photo';

  @override
  String get photoUpdated => 'Photo updated';

  @override
  String get aiGuideTitle => 'AI Assistant Guide';

  @override
  String get aiGuideHeaderTitle => 'Your personal assistant';

  @override
  String get aiGuideHeaderSubtitle => 'Discover everything AI can do for you';

  @override
  String get aiGuideSecurityTitle => 'Always in your control';

  @override
  String get aiGuideSecurityDesc =>
      'The assistant will ALWAYS ask for confirmation before performing an action. Nothing will be done without your explicit approval.';

  @override
  String get aiGuideIntroTitle => 'How does it work?';

  @override
  String get aiGuideWhatIsTitle => 'An intelligent assistant';

  @override
  String get aiGuideWhatIsDesc =>
      'The AI assistant understands your requests in natural language and can access your data or perform actions for you. Ask questions or request actions!';

  @override
  String get aiGuideConfirmTitle => 'Confirmation required';

  @override
  String get aiGuideConfirmDesc =>
      'Before any action (booking, cancellation, modification...), the assistant will summarize what it\'s about to do and wait for your confirmation. You stay in full control.';

  @override
  String get aiGuideReadTitle => 'What AI can access';

  @override
  String get aiGuideActionsTitle => 'Available actions';

  @override
  String get aiGuideExamplesTitle => 'Example requests';

  @override
  String get aiGuideSessionsTitle => 'Your sessions';

  @override
  String get aiGuideArtistSessionsDesc =>
      'View your past, current, or upcoming bookings. Filter by date or status.';

  @override
  String get aiGuideEngineerSessionsDesc =>
      'See sessions assigned to you, pending proposals, and your schedule.';

  @override
  String get aiGuideStudioSessionsDesc =>
      'Access all your studio sessions, filter by status, date, or artist.';

  @override
  String get aiGuideAvailabilityTitle => 'Availability';

  @override
  String get aiGuideAvailabilityDesc =>
      'Check available time slots for a studio on a given date.';

  @override
  String get aiGuideConversationsTitle => 'Conversations';

  @override
  String get aiGuideConversationsDesc =>
      'View your recent conversations and unread messages.';

  @override
  String get aiGuideTimeOffTitle => 'Your time off';

  @override
  String get aiGuideTimeOffDesc =>
      'View your scheduled unavailability periods (vacation, time off...).';

  @override
  String get aiGuidePendingTitle => 'Pending requests';

  @override
  String get aiGuidePendingDesc =>
      'See all booking requests waiting for your response.';

  @override
  String get aiGuideStatsTitle => 'Statistics';

  @override
  String get aiGuideStatsDesc =>
      'Get an overview of your sessions (completed, pending, cancelled) over a period.';

  @override
  String get aiGuideRevenueTitle => 'Revenue report';

  @override
  String get aiGuideRevenueDesc =>
      'Generate a detailed revenue report, grouped by service, engineer, or day.';

  @override
  String get aiGuideTeamTitle => 'Your team';

  @override
  String get aiGuideTeamDesc =>
      'List your team engineers and their availabilities.';

  @override
  String get aiGuideBookingTitle => 'Book a session';

  @override
  String get aiGuideBookingDesc =>
      'Ask the AI to create a booking request. It will guide you through studio, service, date, and time slot selection.';

  @override
  String get aiGuideFavoritesTitle => 'Manage favorites';

  @override
  String get aiGuideFavoritesDesc =>
      'Add or remove studios from favorites, or view your favorites list.';

  @override
  String get aiGuideSearchStudiosTitle => 'Search studios';

  @override
  String get aiGuideSearchStudiosDesc =>
      'Find studios by name, city, or service type.';

  @override
  String get aiGuideSendMessageTitle => 'Send a message';

  @override
  String get aiGuideSendMessageDesc =>
      'Send a message to a studio or artist directly through the assistant.';

  @override
  String get aiGuideStartSessionTitle => 'Start a session';

  @override
  String get aiGuideStartSessionDesc =>
      'Check in by starting a confirmed session on the day.';

  @override
  String get aiGuideCompleteSessionTitle => 'Complete a session';

  @override
  String get aiGuideCompleteSessionDesc =>
      'Mark a session as completed and add notes if needed.';

  @override
  String get aiGuideRespondProposalTitle => 'Respond to proposal';

  @override
  String get aiGuideRespondProposalDesc =>
      'Accept or decline sessions proposed by the studio.';

  @override
  String get aiGuideManageTimeOffTitle => 'Manage time off';

  @override
  String get aiGuideManageTimeOffDesc =>
      'Add or remove unavailability periods (vacation, appointments...).';

  @override
  String get aiGuideAcceptDeclineTitle => 'Accept/Decline requests';

  @override
  String get aiGuideAcceptDeclineDesc =>
      'Manage booking requests by accepting or declining them via the assistant.';

  @override
  String get aiGuideRescheduleTitle => 'Reschedule a session';

  @override
  String get aiGuideRescheduleDesc =>
      'Change the date or time of an existing session. The artist will be notified.';

  @override
  String get aiGuideAssignEngineerTitle => 'Assign an engineer';

  @override
  String get aiGuideAssignEngineerDesc =>
      'Assign an available engineer to a confirmed session.';

  @override
  String get aiGuideCreateSessionTitle => 'Create a session';

  @override
  String get aiGuideCreateSessionDesc =>
      'Create a session manually for an artist, even without a prior request.';

  @override
  String get aiGuideBlockSlotsTitle => 'Block time slots';

  @override
  String get aiGuideBlockSlotsDesc =>
      'Mark unavailability periods for exceptional studio closures.';

  @override
  String get aiGuideManageServicesTitle => 'Manage services';

  @override
  String get aiGuideManageServicesDesc =>
      'Create or update your services (name, price, duration, description).';

  @override
  String get aiGuideExample1ArtistTitle => 'My upcoming sessions';

  @override
  String get aiGuideExample1ArtistDesc =>
      '\"What sessions do I have this week?\" - The AI will show all your upcoming bookings.';

  @override
  String get aiGuideExample2ArtistTitle => 'Find a studio';

  @override
  String get aiGuideExample2ArtistDesc =>
      '\"I\'m looking for a studio in Paris for mixing\" - The AI will search for matching studios.';

  @override
  String get aiGuideExample3ArtistTitle => 'Book a slot';

  @override
  String get aiGuideExample3ArtistDesc =>
      '\"I want to book tomorrow at 2pm at Studio X\" - The AI will check availability and guide you.';

  @override
  String get aiGuideExample1EngineerTitle => 'Today\'s sessions';

  @override
  String get aiGuideExample1EngineerDesc =>
      '\"What do I have today?\" - The AI will show sessions assigned to you for today.';

  @override
  String get aiGuideExample2EngineerTitle => 'Request time off';

  @override
  String get aiGuideExample2EngineerDesc =>
      '\"I\'ll be away from January 15 to 20\" - The AI will create the unavailability after confirmation.';

  @override
  String get aiGuideExample3EngineerTitle => 'Respond to a proposal';

  @override
  String get aiGuideExample3EngineerDesc =>
      '\"Accept tomorrow\'s session\" - The AI will confirm the pending proposal.';

  @override
  String get aiGuideExample1StudioTitle => 'Pending requests';

  @override
  String get aiGuideExample1StudioDesc =>
      '\"Show me pending requests\" - The AI will display all booking requests to process.';

  @override
  String get aiGuideExample2StudioTitle => 'Revenue report';

  @override
  String get aiGuideExample2StudioDesc =>
      '\"What\'s my revenue this month?\" - The AI will generate a detailed report.';

  @override
  String get aiGuideExample3StudioTitle => 'Reschedule a session';

  @override
  String get aiGuideExample3StudioDesc =>
      '\"Move Monday\'s session to Tuesday 10am\" - The AI will reschedule after your confirmation.';

  @override
  String get aiGuideSettingsLink => 'AI Assistant Guide';

  @override
  String get importFromGoogleCalendar => 'Import from Google Calendar';

  @override
  String get importAsSession => 'Session';

  @override
  String get importAsUnavailability => 'Unavail.';

  @override
  String get skipImport => 'Skip';

  @override
  String get selectArtistForSession => 'Select an artist';

  @override
  String get createExternalArtist => 'External artist';

  @override
  String get externalArtistName => 'Artist name';

  @override
  String get externalArtistHint => 'External artist name...';

  @override
  String importSummary(int sessions, int unavailabilities) {
    return '$sessions sessions, $unavailabilities unavail.';
  }

  @override
  String get importButton => 'Import';

  @override
  String get noEventsToImport => 'No events to import';

  @override
  String eventsToReview(int count) {
    return '$count events to review';
  }

  @override
  String importSuccessMessage(int sessions, int unavailabilities) {
    return 'Import successful! $sessions sessions and $unavailabilities unavailabilities created.';
  }

  @override
  String get allDay => 'All day';

  @override
  String get selectAnArtist => 'Select an artist';

  @override
  String get orCreateExternal => 'or create external artist';

  @override
  String get reviewAndImport => 'Review and import';

  @override
  String get tipsSectionCalendar => 'Calendar';

  @override
  String get tipConnectCalendarTitle => 'Connect your calendar';

  @override
  String get tipConnectCalendarDesc =>
      'Link your Google Calendar to sync your events. Go to Settings > Calendar to connect your Google account.';

  @override
  String get tipImportEventsTitle => 'Import your events';

  @override
  String get tipImportEventsDesc =>
      'Use \"Review and import\" to fetch your Google Calendar events and categorize them as sessions or unavailabilities.';

  @override
  String get tipCategorizeEventsTitle => 'Categorize your events';

  @override
  String get tipCategorizeEventsDesc =>
      'For each imported event, choose: Session (with artist), Unavailable (block the slot), or Skip. Sessions are created with \"Pending\" status.';

  @override
  String get allNotificationsMarkedAsRead => 'All notifications marked as read';

  @override
  String get comingSoon => 'Coming Soon';
}
