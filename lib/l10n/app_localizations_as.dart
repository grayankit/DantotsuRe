// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Assamese (`as`).
class AppLocalizationsAs extends AppLocalizations {
  AppLocalizationsAs([String locale = 'as']) : super(locale);

  @override
  String get appName => 'Dartotsu';

  @override
  String get appTagline => 'এনিমে আৰু মাংগা ট্ৰেকিংৰ\nবাবে শ্ৰেষ্ঠ নতুন এপ';

  @override
  String get anilist => 'AniList';

  @override
  String get mal => 'MyAnimeList';

  @override
  String get simkl => 'Simkl';

  @override
  String get kitsu => 'Kitsu';

  @override
  String get mangaBaka => 'MangaBaka';

  @override
  String get discord => 'Discord';

  @override
  String get loadMore => 'Load more';

  @override
  String get login => 'লগইন';

  @override
  String get continueAsGuest => 'Continue as guest';

  @override
  String get getStarted => 'Get Started';

  @override
  String get loginWithToken => 'Login with token';

  @override
  String get pasteTokenHint => 'Paste your access token';

  @override
  String loginTo(String service) {
    return '$service ত লগইন কৰক';
  }

  @override
  String get settings => 'ছেটিংছ';

  @override
  String get account => 'একাউণ্ট';

  @override
  String get about => 'সম্পৰ্কীয়';

  @override
  String get language => 'ভাষা';

  @override
  String get animationSpeed => 'Animations';

  @override
  String get animationSpeedDesc =>
      'Speed of transitions and entrance effects across the app';

  @override
  String get animationSpeedOff => 'Off';

  @override
  String extension(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'এক্সটেনশ্যনসমূহ',
      one: 'এক্সটেনশ্যন',
    );
    return '$_temp0';
  }

  @override
  String get unknownSource => 'Unknown Source';

  @override
  String get install => 'Install';

  @override
  String get update => 'Update';

  @override
  String get uninstall => 'Uninstall';

  @override
  String get installFailed => 'Install failed';

  @override
  String get updateFailed => 'Update failed';

  @override
  String get noSourceSettings => 'Source doesn\'t have any settings';

  @override
  String get addPluginRepository => 'Add Plugin Repository';

  @override
  String get pluginIndexUrlHint => 'Plugin index URL';

  @override
  String get addRepository => 'Add Repository';

  @override
  String get pluginRepoUpdated => 'Plugin repository updated';

  @override
  String get pluginRepoUpdateFailed => 'Failed to refresh plugin repository';

  @override
  String get ok => 'ঠিক আছে';

  @override
  String get cancel => 'বাতিল কৰক';

  @override
  String get yes => 'হয়';

  @override
  String get no => 'নহয়';

  @override
  String get save => 'Save';

  @override
  String get reset => 'Reset';

  @override
  String get clear => 'Clear';

  @override
  String get test => 'Test';

  @override
  String get testing => 'Testing…';

  @override
  String get resolving => 'Resolving…';

  @override
  String get none => 'None';

  @override
  String get selectMediaService => 'মিডিয়া সেৱা বাছক';

  @override
  String get pickColor => 'ৰঙ বাছক';

  @override
  String get colorPickerDefault => 'ডিফল্ট';

  @override
  String get colorPickerCustom => 'কাষ্টম';

  @override
  String get utd => 'ওপৰৰ পৰা তললৈ';

  @override
  String get dtu => 'তলৰ পৰা ওপৰলৈ';

  @override
  String get rtl => 'সোঁফালৰ পৰা বাওঁফাললৈ';

  @override
  String get ltr => 'বাওঁফালৰ পৰা সোঁফাললৈ';

  @override
  String get searchSettings => 'Search settings';

  @override
  String nothingMatches(String query) {
    return 'Nothing matches \"$query\"';
  }

  @override
  String searchCategory(String category) {
    return 'Search $category';
  }

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsAppearanceDesc => 'Theme, colours, glass mode';

  @override
  String get settingsGeneral => 'General';

  @override
  String get settingsGeneralDesc => 'Language and behaviour';

  @override
  String get settingsAccountDesc => 'Tracking service and sign-in';

  @override
  String get settingsUpdates => 'Updates';

  @override
  String get settingsUpdatesDesc => 'Release channel and checks';

  @override
  String get settingsNetwork => 'Network';

  @override
  String get settingsNetworkDesc => 'User-Agent, DNS, proxy, cookies';

  @override
  String get settingsAboutDesc => 'Version, links, support';

  @override
  String get amoledBlack => 'AMOLED black';

  @override
  String get amoledBlackDesc => 'Pure black surfaces on dark mode';

  @override
  String get glassMode => 'Glass mode';

  @override
  String get glassModeDesc => 'Frosted surfaces over your library art';

  @override
  String get settingsExtensionsDesc =>
      'Source managers, repositories and extension options';

  @override
  String get settingsAddons => 'Addons';

  @override
  String get settingsAddonsDesc =>
      'Optional components such as the torrent server';

  @override
  String get customPath => 'কাষ্টম পথ';

  @override
  String get customPathDesc => 'Where app data is kept. Long-press to reset';

  @override
  String get selectDirectory => 'ডাইৰেক্টৰি বাছক';

  @override
  String get differentCacheManager => 'বেলেগ কেশ্ব মেনেজাৰ';

  @override
  String get differentCacheManagerDesc => 'বেলেগ ছবি কেশ্ব মেনেজাৰ ব্যৱহাৰ কৰক';

  @override
  String get backupAndRestore => 'Backup and restore';

  @override
  String get backupAndRestoreDesc => 'Save or load your preferences';

  @override
  String get backup => 'Backup';

  @override
  String get restore => 'Restore';

  @override
  String get loadExtensionsIcon => 'এক্সটেনশ্যনৰ আইকন লোড কৰক';

  @override
  String get loadExtensionsIconDesc => 'এক্সটেনশ্যন পৃষ্ঠা লেগ কৰিলে অক্ষম কৰক';

  @override
  String get sectionStorage => 'Storage';

  @override
  String get sectionBackup => 'Backup';

  @override
  String get sectionManagers => 'Managers';

  @override
  String get sectionOptions => 'Options';

  @override
  String get backupTabBackup => 'Back up';

  @override
  String get backupTabRestore => 'Restore';

  @override
  String backupSummary(Object keys, Object categories) {
    return '$keys settings in $categories categories';
  }

  @override
  String backupLastBackup(Object time) {
    return 'Last backup $time';
  }

  @override
  String get backupNever => 'No backup yet';

  @override
  String get backupSelectAll => 'Select all';

  @override
  String get backupClearAll => 'Clear';

  @override
  String backupKeys(Object count) {
    return '$count settings';
  }

  @override
  String get backupShowKeys => 'Show settings';

  @override
  String get backupPassword => 'Password (optional)';

  @override
  String get backupPasswordHint => 'Leave empty to use the default';

  @override
  String get backupSensitive => 'Includes login tokens. Keep this file private';

  @override
  String get backupCreate => 'Create backup';

  @override
  String backupSaved(Object name) {
    return 'Backup saved to $name';
  }

  @override
  String backupFailed(Object error) {
    return 'Backup failed: $error';
  }

  @override
  String get backupPickFile => 'Choose a backup file';

  @override
  String get backupPickFileDesc => 'Pick a .json file made by Dartotsu';

  @override
  String get backupChooseAnother => 'Choose another file';

  @override
  String get backupCreatedAt => 'Created';

  @override
  String get backupAppVersion => 'App version';

  @override
  String get backupDevice => 'Device';

  @override
  String get backupAccounts => 'Accounts';

  @override
  String get backupSize => 'Size';

  @override
  String get backupEncrypted => 'Password protected';

  @override
  String get backupUnlock => 'Unlock';

  @override
  String get backupWrongPassword =>
      'Could not read this file. Check the password';

  @override
  String get backupRestoreSelected => 'Restore selected';

  @override
  String backupRestoreConfirm(Object count) {
    return 'Restore $count settings? Existing values in these categories are overwritten.';
  }

  @override
  String get backupRestored => 'Restored. Restart the app to apply everything';

  @override
  String backupRestoreFailed(Object error) {
    return 'Restore failed: $error';
  }

  @override
  String get backupSelectOne => 'Select at least one category';

  @override
  String get backupCatTheme => 'Appearance';

  @override
  String get backupCatThemeDesc => 'Theme, colors, glass, fonts and card style';

  @override
  String get backupCatCommon => 'General';

  @override
  String get backupCatCommonDesc =>
      'Language, storage, network and extension options';

  @override
  String get backupCatPlayer => 'Player';

  @override
  String get backupCatPlayerDesc => 'Player preferences';

  @override
  String get backupCatReader => 'Reader';

  @override
  String get backupCatReaderDesc => 'Reader preferences';

  @override
  String get backupCatProtected => 'Accounts';

  @override
  String get backupCatProtectedDesc => 'Login tokens and sign-in data';

  @override
  String get backupCatOther => 'Services and feeds';

  @override
  String get backupCatOtherDesc => 'Feed layouts, lists and service options';

  @override
  String get logFile => 'লগ ফাইল';

  @override
  String get logFileDesc => 'Share the app log, or copy its path on Linux';

  @override
  String get logFileCopied => 'Log path copied';

  @override
  String get donateSheetTitle => 'Enjoying Dartotsu?';

  @override
  String get donateSheetMessage =>
      'Dartotsu is built and maintained by one person. If it is useful to you, consider supporting development.';

  @override
  String get donateLater => 'Maybe later';

  @override
  String get glassBackground => 'Glass background';

  @override
  String get glassBackgroundDesc =>
      'Your profile banner unless you set an image link';

  @override
  String get glassBackgroundHint => 'Image link (leave empty for your banner)';

  @override
  String get followCover => 'Follow cover';

  @override
  String get followCoverDesc =>
      'Colors follow the background, and the cover on detail pages';

  @override
  String get cardStyle => 'Card style';

  @override
  String get cardStyleDesc => 'Title placement, size, progress and badges';

  @override
  String get customFont => 'Font';

  @override
  String get customFontDesc =>
      'Default, a file from your device, or Google Fonts';

  @override
  String get customFontError => 'Couldn\'t load that font file';

  @override
  String get googleFontError => 'Couldn\'t download that font';

  @override
  String get yourFonts => 'Your fonts';

  @override
  String get addFontFile => 'Add font file…';

  @override
  String get browseGoogleFonts => 'Browse Google Fonts…';

  @override
  String get searchGoogleFonts => 'Search Google Fonts';

  @override
  String get defaultFont => 'Default';

  @override
  String get materialYou => 'Material You';

  @override
  String get materialYouDesc => 'Dynamic colour from the system';

  @override
  String get customAccent => 'Custom accent colour';

  @override
  String get customAccentDesc => 'Pick your own primary colour';

  @override
  String get jsonTheme => 'Custom theme file';

  @override
  String get jsonThemeDesc =>
      'Live colours from ~/.config/dartotsu/theme.json (a custom script, or your own edits)';

  @override
  String get customAccentDisabledDesc =>
      'Turn off Material You to use a custom colour';

  @override
  String get themeMode => 'Theme mode';

  @override
  String get mode => 'Mode';

  @override
  String get trackingService => 'Tracking service';

  @override
  String get signOut => 'Sign out';

  @override
  String get signIn => 'Sign in';

  @override
  String get notSignedIn => 'Not signed in';

  @override
  String signOutOf(String service) {
    return 'Sign out of $service?';
  }

  @override
  String get checkForUpdates => 'Check for updates';

  @override
  String get checkForUpdatesDesc => 'Notify on a new GitHub release';

  @override
  String get updateChannel => 'Update channel';

  @override
  String get channel => 'Channel';

  @override
  String get stable => 'Stable';

  @override
  String get preRelease => 'Pre-release';

  @override
  String get alpha => 'Alpha';

  @override
  String get checkNow => 'Check now';

  @override
  String get userAgent => 'User-Agent';

  @override
  String get settingDefault => 'Default';

  @override
  String currentlyUsing(String value) {
    return 'Currently: $value';
  }

  @override
  String get dnsOverHttps => 'DNS-over-HTTPS';

  @override
  String get dnsDefault => 'Default (Cloudflare)';

  @override
  String get proxy => 'Proxy';

  @override
  String get proxyProtocol => 'Type';

  @override
  String get proxyHost => 'Host';

  @override
  String get proxyPort => 'Port';

  @override
  String get proxyUsername => 'Username';

  @override
  String get proxyPassword => 'Password';

  @override
  String get optional => 'Optional';

  @override
  String get clearCookies => 'Clear cookies';

  @override
  String get clearCookiesDesc => 'Remove every stored cookie';

  @override
  String get clearCookiesConfirm =>
      'Remove all stored cookies? This may sign you out of some sources.';

  @override
  String get version => 'Version';

  @override
  String get gitHub => 'GitHub';

  @override
  String get gitHubDesc => 'Source, issues and releases';

  @override
  String get discordDesc => 'Community and support';

  @override
  String get donate => 'Buy me a coffee';

  @override
  String get donateDesc => 'Support development';

  @override
  String get contributors => 'Contributors';

  @override
  String get contributorsDesc => 'The people who built Dartotsu';

  @override
  String get contributorsLoadFailed => 'Couldn\'t load contributors';

  @override
  String get forks => 'Forks';

  @override
  String get forksDesc => 'Projects built on top of Dartotsu';

  @override
  String get forksEmpty => 'No forks found';

  @override
  String get sectionColors => 'Colors';

  @override
  String get sectionDisplay => 'Display';

  @override
  String get sectionStyle => 'Style';

  @override
  String get sectionCommunity => 'Community';

  @override
  String get sectionAppInfo => 'App Info';

  @override
  String get sectionCache => 'Cache';

  @override
  String get sectionRequests => 'Requests';

  @override
  String get sectionDnsProxy => 'DNS & Proxy';

  @override
  String get onboardingBack => 'Back';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingPaletteTitle => 'Make it yours';

  @override
  String get onboardingPaletteBody =>
      'Pick a palette. Every accent, from cards to the player, follows it.';

  @override
  String get themeModeAuto => 'Auto';

  @override
  String get themeModeLight => 'Light';

  @override
  String get themeModeDark => 'Dark';

  @override
  String get onboardingSyncTitle => 'Sync your library';

  @override
  String get onboardingSyncBody =>
      'Sign in with AniList to bring your lists, progress and scores with you. Or skip and browse as a guest.';

  @override
  String get onboardingOpenLinks => 'Open AniList and repo links in Dartotsu';

  @override
  String get linkOpenInApp => 'Open links in Dartotsu';

  @override
  String get linkOpenInAppDesc => 'Let AniList and repo links open the app';

  @override
  String get reviewsTitle => 'Reviews';

  @override
  String get reviewsEmpty => 'No reviews yet';

  @override
  String get reviewsFailed => 'Couldn\'t load reviews';

  @override
  String get reviewHelpfulQuestion => 'Was this review helpful?';

  @override
  String get reviewVoteFailed => 'Couldn\'t save your vote';

  @override
  String reviewHelpful(int n, int total) {
    return '$n of $total found this helpful';
  }

  @override
  String get calendarTitle => 'Airing schedule';

  @override
  String get calendarToday => 'Today';

  @override
  String get calendarEmpty => 'Nothing airs this day';

  @override
  String get calendarFailed => 'Couldn\'t load the schedule';

  @override
  String calendarEpisode(int n) {
    return 'Episode $n';
  }

  @override
  String get shareAnalytics => 'Share anonymous usage data';

  @override
  String get shareAnalyticsDesc =>
      'Anonymous user counts and crash reports. No account or personal data';

  @override
  String get linkOpenAnilist => 'Open AniList links in Dartotsu';

  @override
  String get linkOpenAnilistDesc =>
      'Turn on link handling so anilist.co links open the app';

  @override
  String get linkSettingsFailed => 'Could not open the system settings';

  @override
  String get discordRichPresence => 'Rich Presence';

  @override
  String get discordRichPresenceTokenDesc =>
      'Show what you are doing on your Discord profile. Needs your Discord token.';

  @override
  String get discordRichPresenceDesktopDesc =>
      'Show what you are doing on your Discord profile. Needs the Discord desktop app running.';

  @override
  String get discordBrowsing => 'Show browsing activity';

  @override
  String get discordBrowsingDesc =>
      'Also show the tab, page or profile you are looking at, not only what you watch or read.';

  @override
  String get discordLookHeader => 'Presence look';

  @override
  String get discordActivityType => 'Activity type';

  @override
  String get discordActivityTypeDesc =>
      'How Discord words it: \"Watching …\" or \"Playing …\". Auto uses Watching for anime and Playing for everything else.';

  @override
  String get discordWatching => 'Watching';

  @override
  String get discordPlaying => 'Playing';

  @override
  String get discordCovers => 'Show covers';

  @override
  String get discordCoversDesc =>
      'Cover art and the Dartotsu icon on the card.';

  @override
  String get discordTimer => 'Show timer';

  @override
  String get discordTimerDesc => 'Elapsed or remaining time under the title.';

  @override
  String get discordButtons => 'Show buttons';

  @override
  String get discordButtonsDesc =>
      '\"View anime / manga\" and \"Open Dartotsu\" buttons.';

  @override
  String get discordHideTitles => 'Hide titles';

  @override
  String get discordHideTitlesDesc =>
      'Replace anime and manga names (and their cover and link) with \"Something private\".';

  @override
  String get discordConnectionHeader => 'Connection';

  @override
  String get discordToken => 'Discord token';

  @override
  String get discordTokenSaved =>
      'Saved. Tap to replace, long press to remove.';

  @override
  String get discordTokenNotSet => 'Not set. Tap to add.';

  @override
  String get discordTokenPrompt =>
      'Paste the token of the Discord account to show the presence on. It stays on this device.';

  @override
  String get discordTokenHint => 'Token';

  @override
  String get discordTokenSavedSnack => 'Discord token saved';

  @override
  String get discordTokenRemovedSnack => 'Discord token removed';

  @override
  String get discordRichPresenceRow => 'Discord Rich Presence';

  @override
  String get discordRichPresenceRowOn => 'On · tap to change how it looks';

  @override
  String get discordRichPresenceRowOff =>
      'Show what you are doing on your Discord profile';

  @override
  String get loginCancelled => 'Login cancelled';

  @override
  String get invalidToken => 'Invalid token';

  @override
  String loginFailed(String error) {
    return 'Login failed: $error';
  }

  @override
  String get malLoginFailed => 'MyAnimeList login failed';

  @override
  String get kitsuLoginFailed =>
      'Kitsu login failed. Check your email and password.';

  @override
  String get kitsuLoginTitle => 'Sign in to Kitsu';

  @override
  String get emailOrUsername => 'Email or username';

  @override
  String get password => 'Password';

  @override
  String get kitsuProfile => 'Kitsu profile';

  @override
  String get mangaBakaLoginFailed => 'MangaBaka login failed';

  @override
  String get mangaBakaProfile => 'MangaBaka profile';

  @override
  String get refreshFromMangaBaka => 'Refresh from MangaBaka';

  @override
  String get artistsLabel => 'Artists';

  @override
  String get authorsLabel => 'Authors';

  @override
  String get publishersLabel => 'Publishers';

  @override
  String get originalLanguage => 'Original language';

  @override
  String get licensedLabel => 'Licensed';

  @override
  String get contentRatingLabel => 'Content rating';

  @override
  String get yesLabel => 'Yes';

  @override
  String get noLabel => 'No';

  @override
  String get ratingSteps => 'Rating steps';

  @override
  String get hideNsfw => 'Hide NSFW';

  @override
  String get hideNsfwDesc =>
      'Keep adult titles out of feeds and search, and list your own adult entries under Hidden Media.';

  @override
  String get kitsuAccountOptions => 'Kitsu account options';

  @override
  String get couldNotUpdateKitsuSettings =>
      'Could not update your Kitsu settings';

  @override
  String get titleCanonical => 'Canonical';

  @override
  String get titleRomanized => 'Romanized';

  @override
  String get titleLocalized => 'Localized';

  @override
  String get ratingSystem => 'Rating system';

  @override
  String get ratingSimple => 'Simple (3 faces)';

  @override
  String get ratingRegular => 'Regular (5 stars)';

  @override
  String get ratingAdvanced => 'Advanced (10 points)';

  @override
  String get contentFilter => 'Content filter';

  @override
  String get contentSfw => 'Safe for work only';

  @override
  String get contentSometimes => 'Mature content in searches';

  @override
  String get contentEverywhere => 'Mature content everywhere';

  @override
  String get shareToGlobal => 'Share to global feed';

  @override
  String get shareToGlobalDesc =>
      'Let your activity appear in Kitsu\'s global feed.';

  @override
  String get memberSince => 'Member since';

  @override
  String get location => 'Location';

  @override
  String get accountType => 'Account type';

  @override
  String get accountSupporter => 'Supporter';

  @override
  String get accountFree => 'Free';

  @override
  String get accountDetails => 'Account details';

  @override
  String get refreshFromKitsu => 'Refresh from Kitsu';

  @override
  String get simklReadOnly => 'Simkl granted read-only access';

  @override
  String get incognitoEditsBlocked => 'Incognito: list edits are blocked';

  @override
  String serviceError(String service, String error) {
    return '$service: $error';
  }

  @override
  String get incognitoProgressNotSaved => 'Incognito: progress not saved';

  @override
  String progressSet(int progress) {
    return 'Progress set to $progress';
  }

  @override
  String removedFromList(String title) {
    return 'Removed $title from your list';
  }

  @override
  String get following => 'Following';

  @override
  String get homeSections => 'Home sections';

  @override
  String get homeSectionsHint =>
      'Drag to reorder. Hidden sections are never fetched.';

  @override
  String get customListDeleteFailed => 'Failed to delete custom list';

  @override
  String get customListsSaveFailed => 'Failed to save custom lists';

  @override
  String get customListsSaved => 'Custom lists saved';

  @override
  String get listName => 'List name';

  @override
  String get addList => 'Add list';

  @override
  String voiceActorsIn(String name) {
    return 'Voice actors · $name';
  }

  @override
  String get animeAppearances => 'Anime appearances';

  @override
  String get mangaAppearances => 'Manga appearances';

  @override
  String get voicedCharacters => 'Voiced characters';

  @override
  String get animeCredits => 'Anime credits';

  @override
  String get mangaCredits => 'Manga credits';

  @override
  String get mainProductions => 'Main productions';

  @override
  String get otherWorks => 'Other works';

  @override
  String get prequelSequel => 'Prequel & Sequel';

  @override
  String get previousSeason => 'পূৰ্বৰ ছিজন';

  @override
  String get thisSeason => 'এই ছিজন';

  @override
  String get nextSeason => 'পৰৱৰ্তী ছিজন';

  @override
  String get voiceRoles => 'Voice roles';

  @override
  String get staffPositions => 'Staff positions';

  @override
  String get mangaWorks => 'Manga works';

  @override
  String get malProfile => 'MyAnimeList profile';

  @override
  String get refreshFromMal => 'Refresh from MyAnimeList';

  @override
  String get repullProfileCounts => 'Re-pull your profile and counts';

  @override
  String get refreshed => 'Refreshed';

  @override
  String get simklProfile => 'Simkl profile';

  @override
  String get refreshFromSimkl => 'Refresh from Simkl';

  @override
  String get repullProfileLibrary => 'Re-pull your profile and library';

  @override
  String get simklSignInToSearch => 'Sign in to Simkl to search';

  @override
  String get dropRate => 'Drop rate';

  @override
  String get simklAttribution =>
      'Data and artwork provided by Simkl. View on Simkl';

  @override
  String get onHold => 'স্থগিত null';

  @override
  String get scoredBy => 'Scored by';

  @override
  String get planToWatch => 'Plan to watch';

  @override
  String get planToRead => 'Plan to read';

  @override
  String get timesRewatched => 'Times rewatched';

  @override
  String get timesReread => 'Times reread';

  @override
  String get comments => 'মন্তব্য';

  @override
  String get moviesAndSeries => 'Movies & Series';

  @override
  String get trackingOnly => 'Tracking only';

  @override
  String get signedIn => 'Signed in';

  @override
  String get searchLanguage => 'Search language';

  @override
  String get savedToList => 'Saved to your list';

  @override
  String get removedFromYourList => 'Removed from your list';

  @override
  String get retry => 'Retry';

  @override
  String get synopsis => 'সাৰাংশ';

  @override
  String get details => 'Details';

  @override
  String get addToList => 'তালিকাত যোগ কৰক';

  @override
  String get trailer => 'Trailer';

  @override
  String get titleCopied => 'Title copied';

  @override
  String get linkCopied => 'Link copied';

  @override
  String get watchTrailer => 'Watch trailer';

  @override
  String get copyTitle => 'Copy title';

  @override
  String get copyLink => 'Copy link';

  @override
  String get openInBrowser => 'Open in browser';

  @override
  String viewOnSource(String source) {
    return 'View on $source';
  }

  @override
  String episodeAirsIn(int ep, String time) {
    return 'Episode $ep airs in $time';
  }

  @override
  String nextEpisodeIn(String time) {
    return 'Next episode in $time';
  }

  @override
  String get logPathCopied => 'Log file path copied to clipboard';

  @override
  String get animeSource => 'Anime source';

  @override
  String get mangaSource => 'Manga source';

  @override
  String get popular => 'জনপ্ৰিয় null';

  @override
  String get latest => 'Latest';

  @override
  String get saved => 'Saved';

  @override
  String get nothingMatched => 'Nothing matched';

  @override
  String get nothingSavedFromSource => 'Nothing saved from this source yet';

  @override
  String get sourceReturnedNothing => 'This source returned nothing';

  @override
  String get checkConnectionOrSource =>
      'Check your connection or try another source.';

  @override
  String get tryDifferentSearch => 'Try a different search term.';

  @override
  String get savedTitlesAppearHere =>
      'Titles you add to your list appear here.';

  @override
  String get tryOtherFeed => 'Try the other feed or search instead.';

  @override
  String searchSource(String source) {
    return 'Search $source';
  }

  @override
  String get animeExtensions => 'Anime Extensions';

  @override
  String get mangaExtensions => 'Manga Extensions';

  @override
  String get nothingHereYet => 'Nothing here yet';

  @override
  String get savedOnDeviceUntilLogin =>
      'Everything below is saved on this device until you do.';

  @override
  String get yourProfile => 'Your profile';

  @override
  String get activity => 'null';

  @override
  String get extensions => 'Extensions';

  @override
  String get logOut => 'Log out';

  @override
  String get logIn => 'Log in';

  @override
  String get logOutConfirm => 'Are you sure you want to log out?';

  @override
  String get incognitoMode => 'ইনকগনিটো মোড';

  @override
  String get alsoBlockListEdits => 'Also block list edits';

  @override
  String get offlineMode => 'অফলাইন মোড';

  @override
  String get switchService => 'Switch service';

  @override
  String logOutOf(String name) {
    return 'Log out of $name';
  }

  @override
  String get loggedIn => 'Logged in';

  @override
  String get notifications => 'জাননীসমূহ';

  @override
  String get nothingNew => 'Nothing new';

  @override
  String get thisWeek => 'This week';

  @override
  String get listOnly => 'List Only';

  @override
  String get filter => 'Filter';

  @override
  String get searchResults => 'Search Results';

  @override
  String get recentSearches => 'Recent searches';

  @override
  String get searchOrSetFilter => 'Search or set a filter';

  @override
  String get filters => 'Filters';

  @override
  String get showLess => 'Show less';

  @override
  String get showAll => 'Show all';

  @override
  String get apply => 'Apply';

  @override
  String get preview => 'Preview';

  @override
  String get preset => 'Preset';

  @override
  String get cardNormal => 'Normal';

  @override
  String get cardOnCard => 'On card';

  @override
  String get cardInCard => 'In card';

  @override
  String get size => 'Size';

  @override
  String get cardWidth => 'Card width';

  @override
  String get compact => 'Compact';

  @override
  String get coverAndTitleOnly => 'Cover and title only';

  @override
  String get titleLines => 'Title lines';

  @override
  String get shape => 'Shape';

  @override
  String get posterShape => 'Poster shape';

  @override
  String get cornerRadius => 'Corner radius';

  @override
  String get off => 'Off';

  @override
  String get topLeft => 'Top left';

  @override
  String get topRight => 'Top right';

  @override
  String get bottomLeft => 'Bottom left';

  @override
  String get bottomRight => 'Bottom right';

  @override
  String get overlays => 'Overlays';

  @override
  String get progressCount => 'Progress / count';

  @override
  String get pill => 'Pill';

  @override
  String get bar => 'Bar';

  @override
  String get outside => 'Outside';

  @override
  String get scoreBadge => 'Score badge';

  @override
  String get airingDot => 'Airing dot';

  @override
  String get updateAvailable => 'Update available';

  @override
  String get notInstalled => 'Not installed';

  @override
  String get done => 'Done';

  @override
  String get searchOrEnterUrl => 'Search or enter URL';

  @override
  String get refresh => 'Refresh';

  @override
  String get share => 'Share';

  @override
  String get characters => 'চৰিত্ৰসমূহ';

  @override
  String get staff => 'কৰ্মী';

  @override
  String get readMore => 'Read more';

  @override
  String get couldNotLoadList => 'Could not load the list';

  @override
  String get logInToFavourite => 'Log in to add favourites';

  @override
  String get alsoKnownAs => 'Also known as';

  @override
  String get hideSpoilerNames => 'Hide spoiler names';

  @override
  String get showSpoilerNames => 'Show spoiler names';

  @override
  String get favourited => 'Favourited';

  @override
  String get favourite => 'Favourite';

  @override
  String get couldNotOpenTitle => 'Could not open this title';

  @override
  String get nobodyHereYet => 'Nobody here yet';

  @override
  String get noMatches => 'No matches';

  @override
  String get gridView => 'গ্ৰিড দৰ্শন';

  @override
  String get fullWidth => 'Full width';

  @override
  String get userNotFound => 'User not found';

  @override
  String get couldNotUpdateFollow => 'Could not update follow';

  @override
  String followedUser(String name) {
    return 'Followed $name';
  }

  @override
  String unfollowedUser(String name) {
    return 'Unfollowed $name';
  }

  @override
  String get messages => 'Messages';

  @override
  String get logInToSeeMessages => 'Log in to see your messages';

  @override
  String get editActivity => 'Edit activity';

  @override
  String get newActivity => 'New activity';

  @override
  String get editMessage => 'Edit message';

  @override
  String get writeMessage => 'Write a message';

  @override
  String get editReply => 'Edit reply';

  @override
  String get posted => 'Posted';

  @override
  String get couldNotPost => 'Could not post';

  @override
  String get nothingToPreview => 'Nothing to preview';

  @override
  String get writeSomethingHint =>
      'Write something… AniList markdown works here';

  @override
  String get privateMessage => 'Private message';

  @override
  String get post => 'Post';

  @override
  String get nothingHere => 'Nothing here';

  @override
  String get noAnimeProgress => 'No anime progress';

  @override
  String get noMangaProgress => 'No manga progress';

  @override
  String get noMessages => 'No messages';

  @override
  String get writeMessageHint => 'Write a message…';

  @override
  String get shareSomethingHint => 'Share something…';

  @override
  String get all => 'All';

  @override
  String get anime => 'এনিমে';

  @override
  String get manga => 'মাংগা';

  @override
  String get count => 'Count';

  @override
  String get hoursWatched => 'Hours watched';

  @override
  String get chaptersRead => 'Chapters read';

  @override
  String get meanScore => 'গড় স্ক’ৰ';

  @override
  String get noStatsYet => 'No stats yet';

  @override
  String get totalEntries => 'Total entries';

  @override
  String get episodesWatched => 'Episodes watched';

  @override
  String get daysWatched => 'Days watched';

  @override
  String get volumesRead => 'Volumes read';

  @override
  String get standardDeviation => 'Standard deviation';

  @override
  String get showMore => 'Show more';

  @override
  String get followsYou => 'Follows you';

  @override
  String get nobodyYet => 'Nobody yet';

  @override
  String get logInToLike => 'Log in to like';

  @override
  String get failedToLikeActivity => 'Failed to like activity';

  @override
  String get deleteActivityConfirm => 'Delete activity?';

  @override
  String get deletedActivity => 'Deleted activity';

  @override
  String get failedToDeleteActivity => 'Failed to delete activity';

  @override
  String get subscribed => 'Subscribed';

  @override
  String get unsubscribed => 'Unsubscribed';

  @override
  String get failedToUpdateSubscription => 'Failed to update subscription';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get likedBy => 'Liked by';

  @override
  String get follow => 'Follow';

  @override
  String get nameCopied => 'Name copied';

  @override
  String get followsEachOther => 'Follows each other';

  @override
  String get unfollow => 'Unfollow';

  @override
  String get userIdCopied => 'User id copied';

  @override
  String get shareProfile => 'Share profile';

  @override
  String get copyUserId => 'Copy user id';

  @override
  String get failedToDelete => 'Failed to delete';

  @override
  String get failedToLike => 'Failed to like';

  @override
  String get replies => 'Replies';

  @override
  String get reply => 'Reply';

  @override
  String get noRepliesYet => 'No replies yet';

  @override
  String get favouriteAnime => 'Favourite anime';

  @override
  String get favouriteManga => 'Favourite manga';

  @override
  String get favouriteCharacters => 'Favourite characters';

  @override
  String get favouriteStaff => 'Favourite staff';

  @override
  String get favouriteStudios => 'Favourite studios';

  @override
  String get noFavouritesYet => 'No favourites yet';

  @override
  String get yourStory => 'Your story';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get justNow => 'Just now';

  @override
  String get openImage => 'Open image';

  @override
  String get hideSpoiler => 'Hide spoiler';

  @override
  String get showSpoiler => 'Show spoiler';

  @override
  String get status => 'স্থিতি';

  @override
  String get score => 'Score';

  @override
  String get started => 'Started';

  @override
  String get completed => 'Completed';

  @override
  String get private => 'Private';

  @override
  String get hideFromStatusLists => 'Hide from status lists';

  @override
  String get totalRepeats => 'Total repeats';

  @override
  String get other => 'Other';

  @override
  String get customLists => 'Custom lists';

  @override
  String get activeDays => 'Active days';

  @override
  String get longestStreak => 'Longest streak';

  @override
  String get currentStreak => 'Current streak';

  @override
  String get tapOrHoverDay => 'Tap or hover a day';

  @override
  String get less => 'Less';

  @override
  String get more => 'More';

  @override
  String epIn(int ep, String time) {
    return 'Ep $ep in $time';
  }

  @override
  String get sectionLoading => 'Loading';

  @override
  String get querySize => 'Query size';

  @override
  String get querySizeDesc =>
      'One big query loads every row (and a whole profile) in a single request. Split queries send a small request per row or per profile part: each is quick and parts appear as they arrive.';

  @override
  String get oneBig => 'One big';

  @override
  String get split => 'Split';

  @override
  String get sectionSocial => 'Social';

  @override
  String get systemNotifications => 'System notifications';

  @override
  String get systemNotificationsDesc =>
      'Show a notification for each unread AniList notification while the app is running. Opening the notifications page marks them read.';

  @override
  String get feedLayout => 'Feed layout';

  @override
  String sectionsShown(int shown, int total) {
    return '$shown of $total shown — tap to pick and reorder';
  }

  @override
  String labelSections(String label) {
    return '$label sections';
  }

  @override
  String get accountOptions => 'Account options';

  @override
  String get accountOptionsDesc =>
      'Names, score format, list order, notifications and more';

  @override
  String get anilistAccountOptions => 'AniList account options';

  @override
  String get sectionPrivacy => 'Privacy';

  @override
  String get hidePrivateEntries => 'Hide private entries';

  @override
  String get hidePrivateEntriesDesc =>
      'Keep entries marked private on AniList out of the feed';

  @override
  String get anilistProfile => 'AniList profile';

  @override
  String get refreshFromAnilist => 'Refresh from AniList';

  @override
  String get couldNotUpdateAnilistSettings =>
      'Could not update AniList settings';

  @override
  String get sectionNames => 'Names';

  @override
  String get titleLanguage => 'Title language';

  @override
  String get titleLanguageDesc =>
      'How titles are written everywhere, e.g. Attack on Titan / Shingeki no Kyojin / 進撃の巨人.';

  @override
  String get staffCharacterNames => 'Staff and character names';

  @override
  String get sectionLists => 'Lists';

  @override
  String get scoreFormat => 'Score format';

  @override
  String get sortListsBy => 'Sort lists by';

  @override
  String labelCustomLists(String label) {
    return '$label custom lists';
  }

  @override
  String customListsCount(int count) {
    return '$count lists — tap to add or remove';
  }

  @override
  String get mergeActivities => 'Merge activities';

  @override
  String minutesCount(int count) {
    return '$count mins';
  }

  @override
  String get timezone => 'Timezone';

  @override
  String get notSet => 'Not set';

  @override
  String get airingNotifications => 'Airing notifications';

  @override
  String get airingNotificationsDesc =>
      'Get notified when an episode of a followed show airs';

  @override
  String get displayAdultContent => 'Display adult content';

  @override
  String get displayAdultContentDesc =>
      'Include 18+ titles in browse, search and feeds';

  @override
  String get restrictMessages => 'Restrict messages to following';

  @override
  String get restrictMessagesDesc => 'Only people you follow can message you';

  @override
  String get sectionServices => 'Services';

  @override
  String get novel => 'নভেল';

  @override
  String labelService(String label) {
    return '$label service';
  }

  @override
  String nameSettings(String name) {
    return '$name settings';
  }

  @override
  String extensionBridgeOptions(String name) {
    return 'Options from the $name extension bridge';
  }

  @override
  String get importLists => 'Import lists';

  @override
  String get importListsDesc =>
      'From Aniyomi, Mihon / Tachiyomi or Kotatsu backups';

  @override
  String get exportLists => 'Export lists';

  @override
  String get exportListsDesc => 'To an Aniyomi, Mihon or Kotatsu backup';

  @override
  String get sectionBrowse => 'Browse';

  @override
  String get readingTab => 'Reading tab';

  @override
  String get readingTabDesc => 'Which extensions the third tab shows';

  @override
  String get defaultFeed => 'Default feed';

  @override
  String get defaultFeedDesc => 'Which list a source opens with';

  @override
  String noServiceSupports(String type) {
    return 'No service supports $type';
  }

  @override
  String sourcesLoading(String name, int loaded, int installed) {
    return '$name · $loaded of $installed sources loading';
  }

  @override
  String noExtensionServiceSupportsHere(String type) {
    return 'No extension service supports $type here.';
  }

  @override
  String get loadDataFrom => 'Load data from';

  @override
  String noInstalledSourcesYet(String type) {
    return 'No installed $type sources yet.';
  }

  @override
  String extensionNotInstalled(String name) {
    return 'The extension for $name is not installed';
  }

  @override
  String get thisSource => 'this source';

  @override
  String failedToAddRepository(String error) {
    return 'Failed to add repository: $error';
  }

  @override
  String installedType(String type) {
    return 'Installed $type';
  }

  @override
  String availableType(String type) {
    return 'Available $type';
  }

  @override
  String noInstalledExtensions(String type) {
    return 'No installed $type extensions';
  }

  @override
  String noAvailableExtensions(String type) {
    return 'No available $type extensions';
  }

  @override
  String get nothingToShowYet => 'Nothing to show yet';

  @override
  String get addTitlesHint =>
      'Add some titles to your list and they\'ll appear here.';

  @override
  String get couldntLoad => 'Couldn\'t load';

  @override
  String get progressStyleHint =>
      'Pill and bar overlay the poster; outside shows the same count as plain text instead — pick one.';

  @override
  String get nixManagedUpdate =>
      'This build is managed by Nix — run \"nix flake update\" on your flake and rebuild instead of updating from here';

  @override
  String autoUpdateFailed(String error) {
    return 'Automatic update failed ($error) — opening the download page instead';
  }

  @override
  String get unknownPreference => 'Unknown preference';

  @override
  String unsupportedPreferenceType(String type) {
    return 'Unsupported preference type $type';
  }

  @override
  String get notYetReleased => 'Not Yet Released';

  @override
  String get notStarted => 'Not Started';

  @override
  String get country => 'Country';

  @override
  String get sort => 'সজাওক';

  @override
  String get chooseBackupDialog => 'Choose an Aniyomi, Mihon or Kotatsu backup';

  @override
  String get importListsHint =>
      'Bring a library over from Aniyomi, Mihon / Tachiyomi or Kotatsu. Titles, covers, progress and categories are kept.';

  @override
  String get chooseBackupFile => 'Choose backup file';

  @override
  String importAnimeCount(int count) {
    return 'Import $count anime';
  }

  @override
  String importMangaCount(int count) {
    return 'Import $count manga';
  }

  @override
  String get mergeWithExisting => 'Merge with existing lists';

  @override
  String get mergeWithExistingDesc =>
      'Keeps what you already have; off replaces matching titles';

  @override
  String get chooseAnother => 'Choose another';

  @override
  String get import => 'Import';

  @override
  String animeCount(int count) {
    return '$count anime';
  }

  @override
  String mangaCount(int count) {
    return '$count manga';
  }

  @override
  String get chooseSaveLocation => 'Choose where to save the backup';

  @override
  String savedPath(String path) {
    return 'Saved $path';
  }

  @override
  String exportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String get nothingInLocalLists => 'Nothing in your local lists yet.';

  @override
  String exportsSummary(int anime, int manga) {
    return 'Exports $anime anime and $manga manga from your local lists. Kotatsu only supports manga.';
  }

  @override
  String get saveToFolder => 'Save to folder';

  @override
  String get formatAnimeManga => 'Anime and manga · .tachibk';

  @override
  String get formatMangaTachibk => 'Manga only · .tachibk';

  @override
  String get formatMangaZip => 'Manga only · .zip';

  @override
  String get genres => 'ধৰণ';

  @override
  String get relations => 'সম্পৰ্ক';

  @override
  String get recommendations => 'Recommendations';

  @override
  String get openings => 'Openings';

  @override
  String get endings => 'Endings';

  @override
  String get background => 'Background';

  @override
  String get links => 'Links';

  @override
  String get rank => 'Rank';

  @override
  String get members => 'Members';

  @override
  String get favorites => 'প্ৰিয়সমূহ';

  @override
  String get episodes => 'Episodes';

  @override
  String get chapters => 'Chapters';

  @override
  String get volumes => 'Volumes';

  @override
  String get format => 'ফৰ্মেট';

  @override
  String get source => 'উৎস';

  @override
  String get duration => 'Duration';

  @override
  String minutesPerEpisode(int minutes) {
    return '$minutes min per ep';
  }

  @override
  String get rating => 'Rating';

  @override
  String get studio => 'ষ্টুডিঅ’';

  @override
  String get serialization => 'Serialization';

  @override
  String get season => 'ছিজন';

  @override
  String get broadcast => 'Broadcast';

  @override
  String get aired => 'Aired';

  @override
  String get published => 'Published';

  @override
  String get popularity => 'জনপ্ৰিয়তা';

  @override
  String get community => 'Community';

  @override
  String get watching => 'চাই আছে';

  @override
  String get reading => 'পঢ়ি আছে';

  @override
  String get dropped => 'Dropped';

  @override
  String get planned => 'পৰিকল্পিত null';

  @override
  String get trailers => 'Trailers';

  @override
  String get ratings => 'Ratings';

  @override
  String get originalTitle => 'Original';

  @override
  String get titleLabel => 'Title';

  @override
  String get votes => 'Votes';

  @override
  String get watchedStat => 'Watched';

  @override
  String get runtime => 'Runtime';

  @override
  String get director => 'Director';

  @override
  String get network => 'Network';

  @override
  String get certification => 'Certification';

  @override
  String get airs => 'Airs';

  @override
  String get budget => 'Budget';

  @override
  String get revenue => 'Revenue';

  @override
  String get released => 'Released';

  @override
  String get tags => 'টেগসমূহ';

  @override
  String get author => 'লেখক';

  @override
  String get born => 'Born';

  @override
  String get website => 'Website';

  @override
  String get established => 'Established';

  @override
  String get manhwa => 'মানহৱা';

  @override
  String get manhua => 'মানহুৱা';

  @override
  String get novels => 'Novels';

  @override
  String get thisMonth => 'This month';

  @override
  String get movies => 'Movies';

  @override
  String get shows => 'Shows';

  @override
  String get rewatching => 'Rewatching';

  @override
  String get rereading => 'Rereading';

  @override
  String get watchedStatus => 'Watched';

  @override
  String get planning => 'Planning';

  @override
  String get paused => 'Paused';

  @override
  String get watch => 'চাওক';

  @override
  String get read => 'পঢ়ক';

  @override
  String get finished => 'Finished';

  @override
  String get releasing => 'Releasing';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get hiatus => 'Hiatus';

  @override
  String get remove => 'Remove';

  @override
  String syncToService(String service) {
    return 'Sync to $service';
  }

  @override
  String syncedToService(String service) {
    return 'Synced to $service';
  }

  @override
  String get latestReleases => 'Latest Releases';

  @override
  String get topRated => 'শীৰ্ষ ৰেটেড null';

  @override
  String localSection(String title) {
    return '$title · Local';
  }

  @override
  String get localEntryNote =>
      'This title is only in your local list on this device. Editing is turned off here because it could clash with your account list; you can still remove it.';

  @override
  String get cardPresetPoster => 'Poster';

  @override
  String get cardPresetCard => 'Card';

  @override
  String get cardPresetCozy => 'Cozy';

  @override
  String get sortTopRated => 'Top rated';

  @override
  String get sortMostPopular => 'Most popular';

  @override
  String get sortTrending => 'Trending';

  @override
  String get sortNewest => 'Newest';

  @override
  String get sortAz => 'A–Z';

  @override
  String get sortMostFavourited => 'Most favourited';

  @override
  String get anyCountry => 'Any country';

  @override
  String get orderScore => 'Score';

  @override
  String get orderTitle => 'Title';

  @override
  String get orderLastUpdated => 'Last Updated';

  @override
  String get orderLastAdded => 'Last Added';

  @override
  String get never => 'Never';

  @override
  String get always => 'Always';

  @override
  String get scorePoint100 => '100 Point';

  @override
  String get scorePoint10Decimal => '10 Point Decimal';

  @override
  String get scorePoint10 => '10 Point';

  @override
  String get scorePoint5 => '5 Star';

  @override
  String get scorePoint3 => '3 Point Smiley';

  @override
  String hoursCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours',
      one: '1 hour',
    );
    return '$_temp0';
  }

  @override
  String daysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String weeksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weeks',
      one: '1 week',
    );
    return '$_temp0';
  }

  @override
  String get continueWatching => 'চাই যাওক';

  @override
  String get continueReading => 'পঢ়ি যাওক';

  @override
  String get favouriteAnimeSection => 'Favourite Anime';

  @override
  String get favouriteMangaSection => 'Favourite Manga';

  @override
  String get plannedAnime => 'Planned Anime';

  @override
  String get plannedManga => 'Planned Manga';

  @override
  String get completedAnime => 'Completed Anime';

  @override
  String get completedManga => 'Completed Manga';

  @override
  String get hiddenMedia => 'গোপন মিডিয়া';

  @override
  String get recentUpdates => 'শেহতীয়া আপডেট';

  @override
  String get trendingNow => 'Trending Now';

  @override
  String get popularThisSeason => 'Popular This Season';

  @override
  String get trendingMovies => 'Trending Movies';

  @override
  String get topRatedSeries => 'Top Rated Series';

  @override
  String get mostFavouriteSeries => 'Most Favourite Series';

  @override
  String get popularAnime => 'Popular Anime';

  @override
  String get trendingManhwa => 'Trending Manhwa';

  @override
  String get trendingNovels => 'Trending Novels';

  @override
  String get topRatedManga => 'Top Rated Manga';

  @override
  String get mostFavouriteManga => 'Most Favourite Manga';

  @override
  String get popularManga => 'Popular Manga';

  @override
  String get topMovies => 'Top Movies';

  @override
  String get topOna => 'Top ONA';

  @override
  String get topOva => 'Top OVA';

  @override
  String get mostPopular => 'Most Popular';

  @override
  String get mostFavourite => 'সৰ্বাধিক প্ৰিয় null';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get topManga => 'Top Manga';

  @override
  String get topManhwa => 'Top Manhwa';

  @override
  String get topManhua => 'Top Manhua';

  @override
  String get topNovels => 'Top Novels';

  @override
  String get topOneShots => 'Top One-shots';

  @override
  String get trendingMoviesToday => 'Trending Movies Today';

  @override
  String get trendingShowsToday => 'Trending Shows Today';

  @override
  String get trendingMoviesWeek => 'Trending Movies This Week';

  @override
  String get trendingShowsWeek => 'Trending Shows This Week';

  @override
  String get mostWatchedMoviesMonth => 'Most Watched Movies This Month';

  @override
  String get mostWatchedShowsMonth => 'Most Watched Shows This Month';

  @override
  String get trendingThisWeek => 'Trending This Week';

  @override
  String get mostWatchedThisMonth => 'Most Watched This Month';

  @override
  String get repoLinksAdded => 'Added Repo Links Successfully!';

  @override
  String get errorGettingAnilistData => 'Error getting data from AniList.';

  @override
  String get navInfo => 'INFO';

  @override
  String get navComments => 'COMMENTS';

  @override
  String get playerNotAvailable => 'The player is not available yet';

  @override
  String deepLinkInitialError(String error) {
    return 'Error getting initial deep link: $error';
  }

  @override
  String deepLinkOpenError(String error) {
    return 'Error Opening link: $error';
  }

  @override
  String linkCantBeOpened(String link) {
    return 'This link can\'t be opened: $link';
  }

  @override
  String linkOpenError(String error) {
    return 'Error opening link: $error';
  }

  @override
  String get forReleasingTitles => 'for currently releasing titles';

  @override
  String get progress => 'Progress';

  @override
  String get notes => 'Notes';

  @override
  String serviceNotFound(String id) {
    return 'Service \"$id\" not found';
  }

  @override
  String get glassEffectEnabled => 'Glass effect enabled';

  @override
  String get glassEffectDisabled => 'Glass effect disabled';

  @override
  String get materialYouEnabled => 'Material You enabled';

  @override
  String get materialYouDisabled => 'Material You disabled';

  @override
  String get darkModeEnabled => 'Dark mode enabled';

  @override
  String get darkModeDisabled => 'Dark mode disabled';

  @override
  String get animeList => 'Anime list';

  @override
  String get mangaList => 'Manga list';

  @override
  String ownerAnimeList(String owner) {
    return '$owner\'s anime list';
  }

  @override
  String ownerMangaList(String owner) {
    return '$owner\'s manga list';
  }

  @override
  String get loadingList => 'Loading list';

  @override
  String get earlier => 'Earlier';

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String hoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String minutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes ago',
      one: '1 minute ago',
    );
    return '$_temp0';
  }

  @override
  String minutesAgoShort(int count) {
    return '${count}m ago';
  }

  @override
  String hoursAgoShort(int count) {
    return '${count}h ago';
  }

  @override
  String daysAgoShort(int count) {
    return '${count}d ago';
  }

  @override
  String weeksAgoShort(int count) {
    return '${count}w ago';
  }

  @override
  String get couldntLoadSource => 'Couldn\'t load this source';

  @override
  String get followers => 'Followers';

  @override
  String couldntLoadTitle(String title) {
    return 'Couldn\'t load $title';
  }

  @override
  String userTitle(String name, String title) {
    return '$name · $title';
  }

  @override
  String get couldntLoadProfile => 'Couldn\'t load this profile';

  @override
  String get profile => 'Profile';

  @override
  String get feed => 'Feed';

  @override
  String get stats => 'Stats';

  @override
  String get received => 'Received';

  @override
  String get sent => 'Sent';

  @override
  String get global => 'Global';

  @override
  String get couldntLoadPage => 'Couldn\'t load this page';

  @override
  String get couldntLoadAllDetails => 'Couldn\'t load all details';

  @override
  String get series => 'ধাৰাবাহিক';

  @override
  String get studios => 'Studios';

  @override
  String get users => 'Users';

  @override
  String repositoriesTitle(String type) {
    return '$type Repositories';
  }

  @override
  String get repositoryUrl => 'Repository URL';

  @override
  String get downloadingRepository => 'Downloading repository…';

  @override
  String get noRepositories => 'No repositories added';

  @override
  String repoExtensionsCount(String count) {
    return '$count extensions';
  }

  @override
  String get searchExtensions => 'Search extensions...';

  @override
  String deletePluginTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get deletePluginMessage =>
      'Are you sure you want to delete this plugin?';

  @override
  String pluginDeleted(String name) {
    return '$name deleted';
  }

  @override
  String pluginNotInRepo(String name) {
    return '$name is not available in the configured repo';
  }

  @override
  String get pluginFetchFailed => 'Failed to fetch plugin info';

  @override
  String installPluginTitle(String name) {
    return 'Install $name';
  }

  @override
  String sizeLabel(String size) {
    return 'Size: $size';
  }

  @override
  String get installedState => 'Installed';

  @override
  String get errorLabel => 'Error:';

  @override
  String get stackTraceDetails => 'Details (Stack Trace)';

  @override
  String get shareLogFile => 'Share log file';

  @override
  String get copyLogs => 'Copy Logs';

  @override
  String noListToEdit(String service) {
    return '$service has no list to edit';
  }

  @override
  String get couldNotReadFile => 'Could not read that file';

  @override
  String importedSummary(int anime, int manga) {
    return 'Imported $anime anime and $manga manga';
  }

  @override
  String alreadyThere(int count) {
    return ' · $count already there';
  }

  @override
  String get airingNow => 'Airing now';

  @override
  String get topRatedMovies => 'Top rated movies';

  @override
  String get topRatedShows => 'Top rated shows';

  @override
  String get recommendedSection => 'Recommended';

  @override
  String get syncRow => 'Sync lists';

  @override
  String get syncRowDesc =>
      'Mirror one service\'s list onto your other accounts';

  @override
  String get syncTitle => 'Sync';

  @override
  String get syncMainService => 'Main service';

  @override
  String get syncMainServiceDesc =>
      'Its list is the source of truth; every other signed-in service is updated to match';

  @override
  String get syncAuto => 'Auto sync';

  @override
  String get syncAutoDesc =>
      'Fetch and sync in the background when the app opens and every 30 minutes';

  @override
  String get syncAddMissing => 'Add missing entries';

  @override
  String get syncAddMissingDesc =>
      'Also add entries the other service doesn\'t have yet';

  @override
  String get syncOnlyForward => 'Keep further progress';

  @override
  String get syncOnlyForwardDesc =>
      'Don\'t lower the progress of a service that is already ahead';

  @override
  String get syncFetch => 'Fetch';

  @override
  String get syncFetchAgain => 'Fetch again';

  @override
  String get syncAll => 'Sync all';

  @override
  String get syncStop => 'Stop';

  @override
  String get syncResume => 'Resume';

  @override
  String get syncNothingToSync => 'This service can\'t be synced for this type';

  @override
  String get syncNoTargets => 'Sign in to another service to sync with';

  @override
  String get syncLoadingMap => 'Loading ID mapping';

  @override
  String get syncComparing => 'Comparing lists';

  @override
  String get syncIntro =>
      'Pick a main service and press Fetch. Each service is queried once for your list, then compared with the main one.';

  @override
  String get syncStateSynced => 'Synced';

  @override
  String get syncStateOutdated => 'Out of sync';

  @override
  String get syncStateMissing => 'Not in list';

  @override
  String get syncStateUnmapped => 'No match';

  @override
  String get syncStateFailed => 'Failed';

  @override
  String syncToSync(int count) {
    return '$count to sync';
  }

  @override
  String syncPaused(String time) {
    return 'Waiting for the rate limit, resumes in $time';
  }

  @override
  String syncOnlyIn(int count, String name) {
    return '$count only on $name, left untouched';
  }

  @override
  String syncProgressOf(int done, int total) {
    return '$done of $total';
  }

  @override
  String syncFetched(String time) {
    return 'Fetched $time';
  }

  @override
  String get syncNothingHere => 'Nothing to show';

  @override
  String get syncAllSynced => 'Everything is in sync';

  @override
  String syncSelectedMain(String name) {
    return '$name is the main service';
  }

  @override
  String syncLimits(int used, int max, String window) {
    return '$used of $max requests used this $window';
  }

  @override
  String get syncMinute => 'minute';

  @override
  String get syncDay => 'day';

  @override
  String get syncNotInList => 'Not in list yet';

  @override
  String get syncCleared => 'Plan cleared';

  @override
  String get syncClear => 'Clear';

  @override
  String get syncOptions => 'Options';

  @override
  String get syncShared => 'Shares its entry with another item';

  @override
  String syncFromTo(String from, String to) {
    return '$from to $to';
  }

  @override
  String syncNotFound(String service) {
    return 'Not found on $service';
  }

  @override
  String syncService(String service, int count) {
    return 'Sync $service ($count)';
  }

  @override
  String get syncOnEdit => 'Sync to other services';

  @override
  String get syncOnEditDesc =>
      'Also push this change to your other signed-in services';

  @override
  String syncPushed(String services) {
    return 'Synced to $services';
  }

  @override
  String syncPushFailed(String service, String error) {
    return '$service: $error';
  }

  @override
  String get syncRateLimited => 'Rate limited, try again in a moment';

  @override
  String get syncAhead => 'Whichever is ahead';

  @override
  String get syncAheadDesc =>
      'Two-way: for every title the entry that is furthest along wins and is copied to all your other services';

  @override
  String syncAheadFrom(String service) {
    return 'From $service';
  }

  @override
  String get syncConfirm => 'Review before syncing';

  @override
  String get syncConfirmDesc =>
      'Show what Sync all will change and how many requests it needs';

  @override
  String get syncPreviewTitle => 'Ready to sync';

  @override
  String syncPreviewLine(int updates, int adds) {
    return '$updates updates, $adds to add';
  }

  @override
  String syncPreviewRequests(int count) {
    return 'About $count requests';
  }

  @override
  String syncPreviewLookups(int count) {
    return '$count ids need a lookup first';
  }

  @override
  String get syncPreviewNothing => 'Nothing to change';

  @override
  String get syncStart => 'Start';

  @override
  String get syncRetry => 'Retry';

  @override
  String get syncSkip => 'Skip this item';

  @override
  String get syncInclude => 'Include this item again';

  @override
  String get syncSkippedLabel => 'Skipped';

  @override
  String get syncChanges => 'Differences';

  @override
  String get syncChangeStatus => 'Status';

  @override
  String get syncChangeProgress => 'Progress';

  @override
  String get syncChangeScore => 'Score';

  @override
  String get syncChangeDates => 'Dates';

  @override
  String get syncChangeRepeat => 'Rewatch count';

  @override
  String get syncFailedReason => 'Why it failed';

  @override
  String get syncSkippedHint =>
      'Skipped items are left alone, even after fetching again';
}
