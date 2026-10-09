import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_am.dart';
import 'app_localizations_ar.dart';
import 'app_localizations_as.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_da.dart';
import 'app_localizations_de.dart';
import 'app_localizations_el.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fa.dart';
import 'app_localizations_fil.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ha.dart';
import 'app_localizations_he.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_hr.dart';
import 'app_localizations_id.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_kn.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_ml.dart';
import 'app_localizations_mr.dart';
import 'app_localizations_ms.dart';
import 'app_localizations_ne.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_or.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_ps.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_sa.dart';
import 'app_localizations_si.dart';
import 'app_localizations_so.dart';
import 'app_localizations_sw.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';
import 'app_localizations_th.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_uk.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

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
    Locale('am'),
    Locale('ar'),
    Locale('as'),
    Locale('bn'),
    Locale('da'),
    Locale('de'),
    Locale('el'),
    Locale('es'),
    Locale('fa'),
    Locale('fil'),
    Locale('fr'),
    Locale('ha'),
    Locale('he'),
    Locale('hi'),
    Locale('hr'),
    Locale('id'),
    Locale('it'),
    Locale('ja'),
    Locale('kn'),
    Locale('ko'),
    Locale('ml'),
    Locale('mr'),
    Locale('ms'),
    Locale('ne'),
    Locale('nl'),
    Locale('or'),
    Locale('pl'),
    Locale('ps'),
    Locale('pt'),
    Locale('pt', 'BR'),
    Locale('ru'),
    Locale('sa'),
    Locale('si'),
    Locale('so'),
    Locale('sw'),
    Locale('ta'),
    Locale('te'),
    Locale('th'),
    Locale('tr'),
    Locale('uk'),
    Locale('vi'),
    Locale('zh'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Dartotsu'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'The NEW Best App For\nTracking Anime & Manga'**
  String get appTagline;

  /// No description provided for @anilist.
  ///
  /// In en, this message translates to:
  /// **'AniList'**
  String get anilist;

  /// No description provided for @mal.
  ///
  /// In en, this message translates to:
  /// **'MyAnimeList'**
  String get mal;

  /// No description provided for @simkl.
  ///
  /// In en, this message translates to:
  /// **'Simkl'**
  String get simkl;

  /// No description provided for @discord.
  ///
  /// In en, this message translates to:
  /// **'Discord'**
  String get discord;

  /// No description provided for @loadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get loadMore;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as guest'**
  String get continueAsGuest;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @loginWithToken.
  ///
  /// In en, this message translates to:
  /// **'Login with token'**
  String get loginWithToken;

  /// No description provided for @pasteTokenHint.
  ///
  /// In en, this message translates to:
  /// **'Paste your access token'**
  String get pasteTokenHint;

  /// No description provided for @loginTo.
  ///
  /// In en, this message translates to:
  /// **'Login to {service}'**
  String loginTo(String service);

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @animationSpeed.
  ///
  /// In en, this message translates to:
  /// **'Animations'**
  String get animationSpeed;

  /// No description provided for @animationSpeedDesc.
  ///
  /// In en, this message translates to:
  /// **'Speed of transitions and entrance effects across the app'**
  String get animationSpeedDesc;

  /// No description provided for @animationSpeedOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get animationSpeedOff;

  /// No description provided for @extension.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1 {Extension} other {Extensions}}'**
  String extension(int count);

  /// No description provided for @unknownSource.
  ///
  /// In en, this message translates to:
  /// **'Unknown Source'**
  String get unknownSource;

  /// No description provided for @install.
  ///
  /// In en, this message translates to:
  /// **'Install'**
  String get install;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @uninstall.
  ///
  /// In en, this message translates to:
  /// **'Uninstall'**
  String get uninstall;

  /// No description provided for @installFailed.
  ///
  /// In en, this message translates to:
  /// **'Install failed'**
  String get installFailed;

  /// No description provided for @updateFailed.
  ///
  /// In en, this message translates to:
  /// **'Update failed'**
  String get updateFailed;

  /// No description provided for @noSourceSettings.
  ///
  /// In en, this message translates to:
  /// **'Source doesn\'t have any settings'**
  String get noSourceSettings;

  /// No description provided for @addPluginRepository.
  ///
  /// In en, this message translates to:
  /// **'Add Plugin Repository'**
  String get addPluginRepository;

  /// No description provided for @pluginIndexUrlHint.
  ///
  /// In en, this message translates to:
  /// **'Plugin index URL'**
  String get pluginIndexUrlHint;

  /// No description provided for @addRepository.
  ///
  /// In en, this message translates to:
  /// **'Add Repository'**
  String get addRepository;

  /// No description provided for @pluginRepoUpdated.
  ///
  /// In en, this message translates to:
  /// **'Plugin repository updated'**
  String get pluginRepoUpdated;

  /// No description provided for @pluginRepoUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to refresh plugin repository'**
  String get pluginRepoUpdateFailed;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @test.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get test;

  /// No description provided for @testing.
  ///
  /// In en, this message translates to:
  /// **'Testing…'**
  String get testing;

  /// No description provided for @resolving.
  ///
  /// In en, this message translates to:
  /// **'Resolving…'**
  String get resolving;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @selectMediaService.
  ///
  /// In en, this message translates to:
  /// **'Select Media Service'**
  String get selectMediaService;

  /// No description provided for @pickColor.
  ///
  /// In en, this message translates to:
  /// **'Pick a color'**
  String get pickColor;

  /// No description provided for @colorPickerDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get colorPickerDefault;

  /// No description provided for @colorPickerCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get colorPickerCustom;

  /// No description provided for @utd.
  ///
  /// In en, this message translates to:
  /// **'Up To Down'**
  String get utd;

  /// No description provided for @dtu.
  ///
  /// In en, this message translates to:
  /// **'Down To Up'**
  String get dtu;

  /// No description provided for @rtl.
  ///
  /// In en, this message translates to:
  /// **'Right To Left'**
  String get rtl;

  /// No description provided for @ltr.
  ///
  /// In en, this message translates to:
  /// **'Left To Right'**
  String get ltr;

  /// No description provided for @searchSettings.
  ///
  /// In en, this message translates to:
  /// **'Search settings'**
  String get searchSettings;

  /// No description provided for @nothingMatches.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches \"{query}\"'**
  String nothingMatches(String query);

  /// No description provided for @searchCategory.
  ///
  /// In en, this message translates to:
  /// **'Search {category}'**
  String searchCategory(String category);

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsAppearanceDesc.
  ///
  /// In en, this message translates to:
  /// **'Theme, colours, glass mode'**
  String get settingsAppearanceDesc;

  /// No description provided for @settingsGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsGeneral;

  /// No description provided for @settingsGeneralDesc.
  ///
  /// In en, this message translates to:
  /// **'Language and behaviour'**
  String get settingsGeneralDesc;

  /// No description provided for @settingsAccountDesc.
  ///
  /// In en, this message translates to:
  /// **'Tracking service and sign-in'**
  String get settingsAccountDesc;

  /// No description provided for @settingsUpdates.
  ///
  /// In en, this message translates to:
  /// **'Updates'**
  String get settingsUpdates;

  /// No description provided for @settingsUpdatesDesc.
  ///
  /// In en, this message translates to:
  /// **'Release channel and checks'**
  String get settingsUpdatesDesc;

  /// No description provided for @settingsNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get settingsNetwork;

  /// No description provided for @settingsNetworkDesc.
  ///
  /// In en, this message translates to:
  /// **'User-Agent, DNS, proxy, cookies'**
  String get settingsNetworkDesc;

  /// No description provided for @settingsAboutDesc.
  ///
  /// In en, this message translates to:
  /// **'Version, links, support'**
  String get settingsAboutDesc;

  /// No description provided for @amoledBlack.
  ///
  /// In en, this message translates to:
  /// **'AMOLED black'**
  String get amoledBlack;

  /// No description provided for @amoledBlackDesc.
  ///
  /// In en, this message translates to:
  /// **'Pure black surfaces on dark mode'**
  String get amoledBlackDesc;

  /// No description provided for @glassMode.
  ///
  /// In en, this message translates to:
  /// **'Glass mode'**
  String get glassMode;

  /// No description provided for @glassModeDesc.
  ///
  /// In en, this message translates to:
  /// **'Frosted surfaces over your library art'**
  String get glassModeDesc;

  /// No description provided for @settingsExtensionsDesc.
  ///
  /// In en, this message translates to:
  /// **'Source managers, repositories and extension options'**
  String get settingsExtensionsDesc;

  /// No description provided for @settingsAddons.
  ///
  /// In en, this message translates to:
  /// **'Addons'**
  String get settingsAddons;

  /// No description provided for @settingsAddonsDesc.
  ///
  /// In en, this message translates to:
  /// **'Optional components such as the torrent server'**
  String get settingsAddonsDesc;

  /// No description provided for @customPath.
  ///
  /// In en, this message translates to:
  /// **'Custom storage path'**
  String get customPath;

  /// No description provided for @customPathDesc.
  ///
  /// In en, this message translates to:
  /// **'Where app data is kept. Long-press to reset'**
  String get customPathDesc;

  /// No description provided for @selectDirectory.
  ///
  /// In en, this message translates to:
  /// **'Select directory'**
  String get selectDirectory;

  /// No description provided for @differentCacheManager.
  ///
  /// In en, this message translates to:
  /// **'Alternative image cache'**
  String get differentCacheManager;

  /// No description provided for @differentCacheManagerDesc.
  ///
  /// In en, this message translates to:
  /// **'Use a different cache manager for images'**
  String get differentCacheManagerDesc;

  /// No description provided for @backupAndRestore.
  ///
  /// In en, this message translates to:
  /// **'Backup and restore'**
  String get backupAndRestore;

  /// No description provided for @backupAndRestoreDesc.
  ///
  /// In en, this message translates to:
  /// **'Save or load your preferences'**
  String get backupAndRestoreDesc;

  /// No description provided for @backup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backup;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @loadExtensionsIcon.
  ///
  /// In en, this message translates to:
  /// **'Load extension icons'**
  String get loadExtensionsIcon;

  /// No description provided for @loadExtensionsIconDesc.
  ///
  /// In en, this message translates to:
  /// **'Show source icons in the extension lists'**
  String get loadExtensionsIconDesc;

  /// No description provided for @sectionStorage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get sectionStorage;

  /// No description provided for @sectionBackup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get sectionBackup;

  /// No description provided for @sectionManagers.
  ///
  /// In en, this message translates to:
  /// **'Managers'**
  String get sectionManagers;

  /// No description provided for @sectionOptions.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get sectionOptions;

  /// No description provided for @backupTabBackup.
  ///
  /// In en, this message translates to:
  /// **'Back up'**
  String get backupTabBackup;

  /// No description provided for @backupTabRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get backupTabRestore;

  /// No description provided for @backupSummary.
  ///
  /// In en, this message translates to:
  /// **'{keys} settings in {categories} categories'**
  String backupSummary(Object keys, Object categories);

  /// No description provided for @backupLastBackup.
  ///
  /// In en, this message translates to:
  /// **'Last backup {time}'**
  String backupLastBackup(Object time);

  /// No description provided for @backupNever.
  ///
  /// In en, this message translates to:
  /// **'No backup yet'**
  String get backupNever;

  /// No description provided for @backupSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get backupSelectAll;

  /// No description provided for @backupClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get backupClearAll;

  /// No description provided for @backupKeys.
  ///
  /// In en, this message translates to:
  /// **'{count} settings'**
  String backupKeys(Object count);

  /// No description provided for @backupShowKeys.
  ///
  /// In en, this message translates to:
  /// **'Show settings'**
  String get backupShowKeys;

  /// No description provided for @backupPassword.
  ///
  /// In en, this message translates to:
  /// **'Password (optional)'**
  String get backupPassword;

  /// No description provided for @backupPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to use the default'**
  String get backupPasswordHint;

  /// No description provided for @backupSensitive.
  ///
  /// In en, this message translates to:
  /// **'Includes login tokens. Keep this file private'**
  String get backupSensitive;

  /// No description provided for @backupCreate.
  ///
  /// In en, this message translates to:
  /// **'Create backup'**
  String get backupCreate;

  /// No description provided for @backupSaved.
  ///
  /// In en, this message translates to:
  /// **'Backup saved to {name}'**
  String backupSaved(Object name);

  /// No description provided for @backupFailed.
  ///
  /// In en, this message translates to:
  /// **'Backup failed: {error}'**
  String backupFailed(Object error);

  /// No description provided for @backupPickFile.
  ///
  /// In en, this message translates to:
  /// **'Choose a backup file'**
  String get backupPickFile;

  /// No description provided for @backupPickFileDesc.
  ///
  /// In en, this message translates to:
  /// **'Pick a .json file made by Dartotsu'**
  String get backupPickFileDesc;

  /// No description provided for @backupChooseAnother.
  ///
  /// In en, this message translates to:
  /// **'Choose another file'**
  String get backupChooseAnother;

  /// No description provided for @backupCreatedAt.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get backupCreatedAt;

  /// No description provided for @backupAppVersion.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get backupAppVersion;

  /// No description provided for @backupDevice.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get backupDevice;

  /// No description provided for @backupAccounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get backupAccounts;

  /// No description provided for @backupSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get backupSize;

  /// No description provided for @backupEncrypted.
  ///
  /// In en, this message translates to:
  /// **'Password protected'**
  String get backupEncrypted;

  /// No description provided for @backupUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get backupUnlock;

  /// No description provided for @backupWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Could not read this file. Check the password'**
  String get backupWrongPassword;

  /// No description provided for @backupRestoreSelected.
  ///
  /// In en, this message translates to:
  /// **'Restore selected'**
  String get backupRestoreSelected;

  /// No description provided for @backupRestoreConfirm.
  ///
  /// In en, this message translates to:
  /// **'Restore {count} settings? Existing values in these categories are overwritten.'**
  String backupRestoreConfirm(Object count);

  /// No description provided for @backupRestored.
  ///
  /// In en, this message translates to:
  /// **'Restored. Restart the app to apply everything'**
  String get backupRestored;

  /// No description provided for @backupRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Restore failed: {error}'**
  String backupRestoreFailed(Object error);

  /// No description provided for @backupSelectOne.
  ///
  /// In en, this message translates to:
  /// **'Select at least one category'**
  String get backupSelectOne;

  /// No description provided for @backupCatTheme.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get backupCatTheme;

  /// No description provided for @backupCatThemeDesc.
  ///
  /// In en, this message translates to:
  /// **'Theme, colors, glass, fonts and card style'**
  String get backupCatThemeDesc;

  /// No description provided for @backupCatCommon.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get backupCatCommon;

  /// No description provided for @backupCatCommonDesc.
  ///
  /// In en, this message translates to:
  /// **'Language, storage, network and extension options'**
  String get backupCatCommonDesc;

  /// No description provided for @backupCatPlayer.
  ///
  /// In en, this message translates to:
  /// **'Player'**
  String get backupCatPlayer;

  /// No description provided for @backupCatPlayerDesc.
  ///
  /// In en, this message translates to:
  /// **'Player preferences'**
  String get backupCatPlayerDesc;

  /// No description provided for @backupCatReader.
  ///
  /// In en, this message translates to:
  /// **'Reader'**
  String get backupCatReader;

  /// No description provided for @backupCatReaderDesc.
  ///
  /// In en, this message translates to:
  /// **'Reader preferences'**
  String get backupCatReaderDesc;

  /// No description provided for @backupCatProtected.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get backupCatProtected;

  /// No description provided for @backupCatProtectedDesc.
  ///
  /// In en, this message translates to:
  /// **'Login tokens and sign-in data'**
  String get backupCatProtectedDesc;

  /// No description provided for @backupCatOther.
  ///
  /// In en, this message translates to:
  /// **'Services and feeds'**
  String get backupCatOther;

  /// No description provided for @backupCatOtherDesc.
  ///
  /// In en, this message translates to:
  /// **'Feed layouts, lists and service options'**
  String get backupCatOtherDesc;

  /// No description provided for @logFile.
  ///
  /// In en, this message translates to:
  /// **'Log file'**
  String get logFile;

  /// No description provided for @logFileDesc.
  ///
  /// In en, this message translates to:
  /// **'Share the app log, or copy its path on Linux'**
  String get logFileDesc;

  /// No description provided for @logFileCopied.
  ///
  /// In en, this message translates to:
  /// **'Log path copied'**
  String get logFileCopied;

  /// No description provided for @donateSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Enjoying Dartotsu?'**
  String get donateSheetTitle;

  /// No description provided for @donateSheetMessage.
  ///
  /// In en, this message translates to:
  /// **'Dartotsu is built and maintained by one person. If it is useful to you, consider supporting development.'**
  String get donateSheetMessage;

  /// No description provided for @donateLater.
  ///
  /// In en, this message translates to:
  /// **'Maybe later'**
  String get donateLater;

  /// No description provided for @glassBackground.
  ///
  /// In en, this message translates to:
  /// **'Glass background'**
  String get glassBackground;

  /// No description provided for @glassBackgroundDesc.
  ///
  /// In en, this message translates to:
  /// **'Your profile banner unless you set an image link'**
  String get glassBackgroundDesc;

  /// No description provided for @glassBackgroundHint.
  ///
  /// In en, this message translates to:
  /// **'Image link (leave empty for your banner)'**
  String get glassBackgroundHint;

  /// No description provided for @followCover.
  ///
  /// In en, this message translates to:
  /// **'Follow cover'**
  String get followCover;

  /// No description provided for @followCoverDesc.
  ///
  /// In en, this message translates to:
  /// **'Colors follow the background, and the cover on detail pages'**
  String get followCoverDesc;

  /// No description provided for @cardStyle.
  ///
  /// In en, this message translates to:
  /// **'Card style'**
  String get cardStyle;

  /// No description provided for @cardStyleDesc.
  ///
  /// In en, this message translates to:
  /// **'Title placement, size, progress and badges'**
  String get cardStyleDesc;

  /// No description provided for @customFont.
  ///
  /// In en, this message translates to:
  /// **'Font'**
  String get customFont;

  /// No description provided for @customFontDesc.
  ///
  /// In en, this message translates to:
  /// **'Default, a file from your device, or Google Fonts'**
  String get customFontDesc;

  /// No description provided for @customFontError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load that font file'**
  String get customFontError;

  /// No description provided for @googleFontError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t download that font'**
  String get googleFontError;

  /// No description provided for @yourFonts.
  ///
  /// In en, this message translates to:
  /// **'Your fonts'**
  String get yourFonts;

  /// No description provided for @addFontFile.
  ///
  /// In en, this message translates to:
  /// **'Add font file…'**
  String get addFontFile;

  /// No description provided for @browseGoogleFonts.
  ///
  /// In en, this message translates to:
  /// **'Browse Google Fonts…'**
  String get browseGoogleFonts;

  /// No description provided for @searchGoogleFonts.
  ///
  /// In en, this message translates to:
  /// **'Search Google Fonts'**
  String get searchGoogleFonts;

  /// No description provided for @defaultFont.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultFont;

  /// No description provided for @materialYou.
  ///
  /// In en, this message translates to:
  /// **'Material You'**
  String get materialYou;

  /// No description provided for @materialYouDesc.
  ///
  /// In en, this message translates to:
  /// **'Dynamic colour from the system'**
  String get materialYouDesc;

  /// No description provided for @customAccent.
  ///
  /// In en, this message translates to:
  /// **'Custom accent colour'**
  String get customAccent;

  /// No description provided for @customAccentDesc.
  ///
  /// In en, this message translates to:
  /// **'Pick your own primary colour'**
  String get customAccentDesc;

  /// No description provided for @jsonTheme.
  ///
  /// In en, this message translates to:
  /// **'Custom theme file'**
  String get jsonTheme;

  /// No description provided for @jsonThemeDesc.
  ///
  /// In en, this message translates to:
  /// **'Live colours from ~/.config/dartotsu/theme.json (a custom script, or your own edits)'**
  String get jsonThemeDesc;

  /// No description provided for @customAccentDisabledDesc.
  ///
  /// In en, this message translates to:
  /// **'Turn off Material You to use a custom colour'**
  String get customAccentDisabledDesc;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme mode'**
  String get themeMode;

  /// No description provided for @mode.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get mode;

  /// No description provided for @trackingService.
  ///
  /// In en, this message translates to:
  /// **'Tracking service'**
  String get trackingService;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @notSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Not signed in'**
  String get notSignedIn;

  /// No description provided for @signOutOf.
  ///
  /// In en, this message translates to:
  /// **'Sign out of {service}?'**
  String signOutOf(String service);

  /// No description provided for @checkForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get checkForUpdates;

  /// No description provided for @checkForUpdatesDesc.
  ///
  /// In en, this message translates to:
  /// **'Notify on a new GitHub release'**
  String get checkForUpdatesDesc;

  /// No description provided for @updateChannel.
  ///
  /// In en, this message translates to:
  /// **'Update channel'**
  String get updateChannel;

  /// No description provided for @channel.
  ///
  /// In en, this message translates to:
  /// **'Channel'**
  String get channel;

  /// No description provided for @stable.
  ///
  /// In en, this message translates to:
  /// **'Stable'**
  String get stable;

  /// No description provided for @preRelease.
  ///
  /// In en, this message translates to:
  /// **'Pre-release'**
  String get preRelease;

  /// No description provided for @alpha.
  ///
  /// In en, this message translates to:
  /// **'Alpha'**
  String get alpha;

  /// No description provided for @checkNow.
  ///
  /// In en, this message translates to:
  /// **'Check now'**
  String get checkNow;

  /// No description provided for @userAgent.
  ///
  /// In en, this message translates to:
  /// **'User-Agent'**
  String get userAgent;

  /// No description provided for @settingDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get settingDefault;

  /// No description provided for @currentlyUsing.
  ///
  /// In en, this message translates to:
  /// **'Currently: {value}'**
  String currentlyUsing(String value);

  /// No description provided for @dnsOverHttps.
  ///
  /// In en, this message translates to:
  /// **'DNS-over-HTTPS'**
  String get dnsOverHttps;

  /// No description provided for @dnsDefault.
  ///
  /// In en, this message translates to:
  /// **'Default (Cloudflare)'**
  String get dnsDefault;

  /// No description provided for @proxy.
  ///
  /// In en, this message translates to:
  /// **'Proxy'**
  String get proxy;

  /// No description provided for @proxyProtocol.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get proxyProtocol;

  /// No description provided for @proxyHost.
  ///
  /// In en, this message translates to:
  /// **'Host'**
  String get proxyHost;

  /// No description provided for @proxyPort.
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get proxyPort;

  /// No description provided for @proxyUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get proxyUsername;

  /// No description provided for @proxyPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get proxyPassword;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @clearCookies.
  ///
  /// In en, this message translates to:
  /// **'Clear cookies'**
  String get clearCookies;

  /// No description provided for @clearCookiesDesc.
  ///
  /// In en, this message translates to:
  /// **'Remove every stored cookie'**
  String get clearCookiesDesc;

  /// No description provided for @clearCookiesConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove all stored cookies? This may sign you out of some sources.'**
  String get clearCookiesConfirm;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @gitHub.
  ///
  /// In en, this message translates to:
  /// **'GitHub'**
  String get gitHub;

  /// No description provided for @gitHubDesc.
  ///
  /// In en, this message translates to:
  /// **'Source, issues and releases'**
  String get gitHubDesc;

  /// No description provided for @discordDesc.
  ///
  /// In en, this message translates to:
  /// **'Community and support'**
  String get discordDesc;

  /// No description provided for @donate.
  ///
  /// In en, this message translates to:
  /// **'Buy me a coffee'**
  String get donate;

  /// No description provided for @donateDesc.
  ///
  /// In en, this message translates to:
  /// **'Support development'**
  String get donateDesc;

  /// No description provided for @contributors.
  ///
  /// In en, this message translates to:
  /// **'Contributors'**
  String get contributors;

  /// No description provided for @contributorsDesc.
  ///
  /// In en, this message translates to:
  /// **'The people who built Dartotsu'**
  String get contributorsDesc;

  /// No description provided for @contributorsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load contributors'**
  String get contributorsLoadFailed;

  /// No description provided for @forks.
  ///
  /// In en, this message translates to:
  /// **'Forks'**
  String get forks;

  /// No description provided for @forksDesc.
  ///
  /// In en, this message translates to:
  /// **'Projects built on top of Dartotsu'**
  String get forksDesc;

  /// No description provided for @forksEmpty.
  ///
  /// In en, this message translates to:
  /// **'No forks found'**
  String get forksEmpty;

  /// No description provided for @sectionColors.
  ///
  /// In en, this message translates to:
  /// **'Colors'**
  String get sectionColors;

  /// No description provided for @sectionDisplay.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get sectionDisplay;

  /// No description provided for @sectionStyle.
  ///
  /// In en, this message translates to:
  /// **'Style'**
  String get sectionStyle;

  /// No description provided for @sectionCommunity.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get sectionCommunity;

  /// No description provided for @sectionAppInfo.
  ///
  /// In en, this message translates to:
  /// **'App Info'**
  String get sectionAppInfo;

  /// No description provided for @sectionCache.
  ///
  /// In en, this message translates to:
  /// **'Cache'**
  String get sectionCache;

  /// No description provided for @sectionRequests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get sectionRequests;

  /// No description provided for @sectionDnsProxy.
  ///
  /// In en, this message translates to:
  /// **'DNS & Proxy'**
  String get sectionDnsProxy;

  /// No description provided for @onboardingBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get onboardingBack;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingPaletteTitle.
  ///
  /// In en, this message translates to:
  /// **'Make it yours'**
  String get onboardingPaletteTitle;

  /// No description provided for @onboardingPaletteBody.
  ///
  /// In en, this message translates to:
  /// **'Pick a palette. Every accent, from cards to the player, follows it.'**
  String get onboardingPaletteBody;

  /// No description provided for @themeModeAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get themeModeAuto;

  /// No description provided for @themeModeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeModeLight;

  /// No description provided for @themeModeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeModeDark;

  /// No description provided for @onboardingSyncTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync your library'**
  String get onboardingSyncTitle;

  /// No description provided for @onboardingSyncBody.
  ///
  /// In en, this message translates to:
  /// **'Sign in with AniList to bring your lists, progress and scores with you. Or skip and browse as a guest.'**
  String get onboardingSyncBody;

  /// No description provided for @onboardingOpenLinks.
  ///
  /// In en, this message translates to:
  /// **'Open AniList and repo links in Dartotsu'**
  String get onboardingOpenLinks;

  /// No description provided for @linkOpenInApp.
  ///
  /// In en, this message translates to:
  /// **'Open links in Dartotsu'**
  String get linkOpenInApp;

  /// No description provided for @linkOpenInAppDesc.
  ///
  /// In en, this message translates to:
  /// **'Let AniList and repo links open the app'**
  String get linkOpenInAppDesc;

  /// No description provided for @reviewsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviewsTitle;

  /// No description provided for @reviewsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get reviewsEmpty;

  /// No description provided for @reviewsFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load reviews'**
  String get reviewsFailed;

  /// No description provided for @reviewHelpfulQuestion.
  ///
  /// In en, this message translates to:
  /// **'Was this review helpful?'**
  String get reviewHelpfulQuestion;

  /// No description provided for @reviewVoteFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save your vote'**
  String get reviewVoteFailed;

  /// No description provided for @reviewHelpful.
  ///
  /// In en, this message translates to:
  /// **'{n} of {total} found this helpful'**
  String reviewHelpful(int n, int total);

  /// No description provided for @calendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Airing schedule'**
  String get calendarTitle;

  /// No description provided for @calendarToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get calendarToday;

  /// No description provided for @calendarEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing airs this day'**
  String get calendarEmpty;

  /// No description provided for @calendarFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the schedule'**
  String get calendarFailed;

  /// No description provided for @calendarEpisode.
  ///
  /// In en, this message translates to:
  /// **'Episode {n}'**
  String calendarEpisode(int n);

  /// No description provided for @shareAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Share anonymous usage data'**
  String get shareAnalytics;

  /// No description provided for @shareAnalyticsDesc.
  ///
  /// In en, this message translates to:
  /// **'Anonymous user counts and crash reports. No account or personal data'**
  String get shareAnalyticsDesc;

  /// No description provided for @linkOpenAnilist.
  ///
  /// In en, this message translates to:
  /// **'Open AniList links in Dartotsu'**
  String get linkOpenAnilist;

  /// No description provided for @linkOpenAnilistDesc.
  ///
  /// In en, this message translates to:
  /// **'Turn on link handling so anilist.co links open the app'**
  String get linkOpenAnilistDesc;

  /// No description provided for @linkSettingsFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the system settings'**
  String get linkSettingsFailed;

  /// No description provided for @discordRichPresence.
  ///
  /// In en, this message translates to:
  /// **'Rich Presence'**
  String get discordRichPresence;

  /// No description provided for @discordRichPresenceTokenDesc.
  ///
  /// In en, this message translates to:
  /// **'Show what you are doing on your Discord profile. Needs your Discord token.'**
  String get discordRichPresenceTokenDesc;

  /// No description provided for @discordRichPresenceDesktopDesc.
  ///
  /// In en, this message translates to:
  /// **'Show what you are doing on your Discord profile. Needs the Discord desktop app running.'**
  String get discordRichPresenceDesktopDesc;

  /// No description provided for @discordBrowsing.
  ///
  /// In en, this message translates to:
  /// **'Show browsing activity'**
  String get discordBrowsing;

  /// No description provided for @discordBrowsingDesc.
  ///
  /// In en, this message translates to:
  /// **'Also show the tab, page or profile you are looking at, not only what you watch or read.'**
  String get discordBrowsingDesc;

  /// No description provided for @discordLookHeader.
  ///
  /// In en, this message translates to:
  /// **'Presence look'**
  String get discordLookHeader;

  /// No description provided for @discordActivityType.
  ///
  /// In en, this message translates to:
  /// **'Activity type'**
  String get discordActivityType;

  /// No description provided for @discordActivityTypeDesc.
  ///
  /// In en, this message translates to:
  /// **'How Discord words it: \"Watching …\" or \"Playing …\". Auto uses Watching for anime and Playing for everything else.'**
  String get discordActivityTypeDesc;

  /// No description provided for @discordWatching.
  ///
  /// In en, this message translates to:
  /// **'Watching'**
  String get discordWatching;

  /// No description provided for @discordPlaying.
  ///
  /// In en, this message translates to:
  /// **'Playing'**
  String get discordPlaying;

  /// No description provided for @discordCovers.
  ///
  /// In en, this message translates to:
  /// **'Show covers'**
  String get discordCovers;

  /// No description provided for @discordCoversDesc.
  ///
  /// In en, this message translates to:
  /// **'Cover art and the Dartotsu icon on the card.'**
  String get discordCoversDesc;

  /// No description provided for @discordTimer.
  ///
  /// In en, this message translates to:
  /// **'Show timer'**
  String get discordTimer;

  /// No description provided for @discordTimerDesc.
  ///
  /// In en, this message translates to:
  /// **'Elapsed or remaining time under the title.'**
  String get discordTimerDesc;

  /// No description provided for @discordButtons.
  ///
  /// In en, this message translates to:
  /// **'Show buttons'**
  String get discordButtons;

  /// No description provided for @discordButtonsDesc.
  ///
  /// In en, this message translates to:
  /// **'\"View anime / manga\" and \"Open Dartotsu\" buttons.'**
  String get discordButtonsDesc;

  /// No description provided for @discordHideTitles.
  ///
  /// In en, this message translates to:
  /// **'Hide titles'**
  String get discordHideTitles;

  /// No description provided for @discordHideTitlesDesc.
  ///
  /// In en, this message translates to:
  /// **'Replace anime and manga names (and their cover and link) with \"Something private\".'**
  String get discordHideTitlesDesc;

  /// No description provided for @discordConnectionHeader.
  ///
  /// In en, this message translates to:
  /// **'Connection'**
  String get discordConnectionHeader;

  /// No description provided for @discordToken.
  ///
  /// In en, this message translates to:
  /// **'Discord token'**
  String get discordToken;

  /// No description provided for @discordTokenSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved. Tap to replace, long press to remove.'**
  String get discordTokenSaved;

  /// No description provided for @discordTokenNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set. Tap to add.'**
  String get discordTokenNotSet;

  /// No description provided for @discordTokenPrompt.
  ///
  /// In en, this message translates to:
  /// **'Paste the token of the Discord account to show the presence on. It stays on this device.'**
  String get discordTokenPrompt;

  /// No description provided for @discordTokenHint.
  ///
  /// In en, this message translates to:
  /// **'Token'**
  String get discordTokenHint;

  /// No description provided for @discordTokenSavedSnack.
  ///
  /// In en, this message translates to:
  /// **'Discord token saved'**
  String get discordTokenSavedSnack;

  /// No description provided for @discordTokenRemovedSnack.
  ///
  /// In en, this message translates to:
  /// **'Discord token removed'**
  String get discordTokenRemovedSnack;

  /// No description provided for @discordRichPresenceRow.
  ///
  /// In en, this message translates to:
  /// **'Discord Rich Presence'**
  String get discordRichPresenceRow;

  /// No description provided for @discordRichPresenceRowOn.
  ///
  /// In en, this message translates to:
  /// **'On · tap to change how it looks'**
  String get discordRichPresenceRowOn;

  /// No description provided for @discordRichPresenceRowOff.
  ///
  /// In en, this message translates to:
  /// **'Show what you are doing on your Discord profile'**
  String get discordRichPresenceRowOff;

  /// No description provided for @loginCancelled.
  ///
  /// In en, this message translates to:
  /// **'Login cancelled'**
  String get loginCancelled;

  /// No description provided for @invalidToken.
  ///
  /// In en, this message translates to:
  /// **'Invalid token'**
  String get invalidToken;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed: {error}'**
  String loginFailed(String error);

  /// No description provided for @malLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'MyAnimeList login failed'**
  String get malLoginFailed;

  /// No description provided for @simklReadOnly.
  ///
  /// In en, this message translates to:
  /// **'Simkl granted read-only access'**
  String get simklReadOnly;

  /// No description provided for @incognitoEditsBlocked.
  ///
  /// In en, this message translates to:
  /// **'Incognito: list edits are blocked'**
  String get incognitoEditsBlocked;

  /// No description provided for @serviceError.
  ///
  /// In en, this message translates to:
  /// **'{service}: {error}'**
  String serviceError(String service, String error);

  /// No description provided for @incognitoProgressNotSaved.
  ///
  /// In en, this message translates to:
  /// **'Incognito: progress not saved'**
  String get incognitoProgressNotSaved;

  /// No description provided for @progressSet.
  ///
  /// In en, this message translates to:
  /// **'Progress set to {progress}'**
  String progressSet(int progress);

  /// No description provided for @removedFromList.
  ///
  /// In en, this message translates to:
  /// **'Removed {title} from your list'**
  String removedFromList(String title);

  /// No description provided for @following.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get following;

  /// No description provided for @homeSections.
  ///
  /// In en, this message translates to:
  /// **'Home sections'**
  String get homeSections;

  /// No description provided for @homeSectionsHint.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder. Hidden sections are never fetched.'**
  String get homeSectionsHint;

  /// No description provided for @customListDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete custom list'**
  String get customListDeleteFailed;

  /// No description provided for @customListsSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save custom lists'**
  String get customListsSaveFailed;

  /// No description provided for @customListsSaved.
  ///
  /// In en, this message translates to:
  /// **'Custom lists saved'**
  String get customListsSaved;

  /// No description provided for @listName.
  ///
  /// In en, this message translates to:
  /// **'List name'**
  String get listName;

  /// No description provided for @addList.
  ///
  /// In en, this message translates to:
  /// **'Add list'**
  String get addList;

  /// No description provided for @voiceActorsIn.
  ///
  /// In en, this message translates to:
  /// **'Voice actors · {name}'**
  String voiceActorsIn(String name);

  /// No description provided for @animeAppearances.
  ///
  /// In en, this message translates to:
  /// **'Anime appearances'**
  String get animeAppearances;

  /// No description provided for @mangaAppearances.
  ///
  /// In en, this message translates to:
  /// **'Manga appearances'**
  String get mangaAppearances;

  /// No description provided for @voicedCharacters.
  ///
  /// In en, this message translates to:
  /// **'Voiced characters'**
  String get voicedCharacters;

  /// No description provided for @animeCredits.
  ///
  /// In en, this message translates to:
  /// **'Anime credits'**
  String get animeCredits;

  /// No description provided for @mangaCredits.
  ///
  /// In en, this message translates to:
  /// **'Manga credits'**
  String get mangaCredits;

  /// No description provided for @mainProductions.
  ///
  /// In en, this message translates to:
  /// **'Main productions'**
  String get mainProductions;

  /// No description provided for @otherWorks.
  ///
  /// In en, this message translates to:
  /// **'Other works'**
  String get otherWorks;

  /// No description provided for @prequelSequel.
  ///
  /// In en, this message translates to:
  /// **'Prequel & Sequel'**
  String get prequelSequel;

  /// No description provided for @previousSeason.
  ///
  /// In en, this message translates to:
  /// **'Previous season'**
  String get previousSeason;

  /// No description provided for @thisSeason.
  ///
  /// In en, this message translates to:
  /// **'This season'**
  String get thisSeason;

  /// No description provided for @nextSeason.
  ///
  /// In en, this message translates to:
  /// **'Next season'**
  String get nextSeason;

  /// No description provided for @voiceRoles.
  ///
  /// In en, this message translates to:
  /// **'Voice roles'**
  String get voiceRoles;

  /// No description provided for @staffPositions.
  ///
  /// In en, this message translates to:
  /// **'Staff positions'**
  String get staffPositions;

  /// No description provided for @mangaWorks.
  ///
  /// In en, this message translates to:
  /// **'Manga works'**
  String get mangaWorks;

  /// No description provided for @malProfile.
  ///
  /// In en, this message translates to:
  /// **'MyAnimeList profile'**
  String get malProfile;

  /// No description provided for @refreshFromMal.
  ///
  /// In en, this message translates to:
  /// **'Refresh from MyAnimeList'**
  String get refreshFromMal;

  /// No description provided for @repullProfileCounts.
  ///
  /// In en, this message translates to:
  /// **'Re-pull your profile and counts'**
  String get repullProfileCounts;

  /// No description provided for @refreshed.
  ///
  /// In en, this message translates to:
  /// **'Refreshed'**
  String get refreshed;

  /// No description provided for @simklProfile.
  ///
  /// In en, this message translates to:
  /// **'Simkl profile'**
  String get simklProfile;

  /// No description provided for @refreshFromSimkl.
  ///
  /// In en, this message translates to:
  /// **'Refresh from Simkl'**
  String get refreshFromSimkl;

  /// No description provided for @repullProfileLibrary.
  ///
  /// In en, this message translates to:
  /// **'Re-pull your profile and library'**
  String get repullProfileLibrary;

  /// No description provided for @simklSignInToSearch.
  ///
  /// In en, this message translates to:
  /// **'Sign in to Simkl to search'**
  String get simklSignInToSearch;

  /// No description provided for @dropRate.
  ///
  /// In en, this message translates to:
  /// **'Drop rate'**
  String get dropRate;

  /// No description provided for @latestEpisodes.
  ///
  /// In en, this message translates to:
  /// **'Latest episodes'**
  String get latestEpisodes;

  /// No description provided for @simklAttribution.
  ///
  /// In en, this message translates to:
  /// **'Data and artwork provided by Simkl. View on Simkl'**
  String get simklAttribution;

  /// No description provided for @onHold.
  ///
  /// In en, this message translates to:
  /// **'On hold'**
  String get onHold;

  /// No description provided for @scoredBy.
  ///
  /// In en, this message translates to:
  /// **'Scored by'**
  String get scoredBy;

  /// No description provided for @planToWatch.
  ///
  /// In en, this message translates to:
  /// **'Plan to watch'**
  String get planToWatch;

  /// No description provided for @planToRead.
  ///
  /// In en, this message translates to:
  /// **'Plan to read'**
  String get planToRead;

  /// No description provided for @timesRewatched.
  ///
  /// In en, this message translates to:
  /// **'Times rewatched'**
  String get timesRewatched;

  /// No description provided for @timesReread.
  ///
  /// In en, this message translates to:
  /// **'Times reread'**
  String get timesReread;

  /// No description provided for @comments.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get comments;

  /// No description provided for @moviesAndSeries.
  ///
  /// In en, this message translates to:
  /// **'Movies & Series'**
  String get moviesAndSeries;

  /// No description provided for @trackingOnly.
  ///
  /// In en, this message translates to:
  /// **'Tracking only'**
  String get trackingOnly;

  /// No description provided for @signedIn.
  ///
  /// In en, this message translates to:
  /// **'Signed in'**
  String get signedIn;

  /// No description provided for @searchLanguage.
  ///
  /// In en, this message translates to:
  /// **'Search language'**
  String get searchLanguage;

  /// No description provided for @savedToList.
  ///
  /// In en, this message translates to:
  /// **'Saved to your list'**
  String get savedToList;

  /// No description provided for @removedFromYourList.
  ///
  /// In en, this message translates to:
  /// **'Removed from your list'**
  String get removedFromYourList;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @synopsis.
  ///
  /// In en, this message translates to:
  /// **'Synopsis'**
  String get synopsis;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @addToList.
  ///
  /// In en, this message translates to:
  /// **'Add to List'**
  String get addToList;

  /// No description provided for @trailer.
  ///
  /// In en, this message translates to:
  /// **'Trailer'**
  String get trailer;

  /// No description provided for @titleCopied.
  ///
  /// In en, this message translates to:
  /// **'Title copied'**
  String get titleCopied;

  /// No description provided for @linkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get linkCopied;

  /// No description provided for @watchTrailer.
  ///
  /// In en, this message translates to:
  /// **'Watch trailer'**
  String get watchTrailer;

  /// No description provided for @copyTitle.
  ///
  /// In en, this message translates to:
  /// **'Copy title'**
  String get copyTitle;

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get copyLink;

  /// No description provided for @openInBrowser.
  ///
  /// In en, this message translates to:
  /// **'Open in browser'**
  String get openInBrowser;

  /// No description provided for @viewOnSource.
  ///
  /// In en, this message translates to:
  /// **'View on {source}'**
  String viewOnSource(String source);

  /// No description provided for @episodeAirsIn.
  ///
  /// In en, this message translates to:
  /// **'Episode {ep} airs in {time}'**
  String episodeAirsIn(int ep, String time);

  /// No description provided for @nextEpisodeIn.
  ///
  /// In en, this message translates to:
  /// **'Next episode in {time}'**
  String nextEpisodeIn(String time);

  /// No description provided for @logPathCopied.
  ///
  /// In en, this message translates to:
  /// **'Log file path copied to clipboard'**
  String get logPathCopied;

  /// No description provided for @animeSource.
  ///
  /// In en, this message translates to:
  /// **'Anime source'**
  String get animeSource;

  /// No description provided for @mangaSource.
  ///
  /// In en, this message translates to:
  /// **'Manga source'**
  String get mangaSource;

  /// No description provided for @popular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get popular;

  /// No description provided for @latest.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get latest;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @nothingMatched.
  ///
  /// In en, this message translates to:
  /// **'Nothing matched'**
  String get nothingMatched;

  /// No description provided for @nothingSavedFromSource.
  ///
  /// In en, this message translates to:
  /// **'Nothing saved from this source yet'**
  String get nothingSavedFromSource;

  /// No description provided for @sourceReturnedNothing.
  ///
  /// In en, this message translates to:
  /// **'This source returned nothing'**
  String get sourceReturnedNothing;

  /// No description provided for @checkConnectionOrSource.
  ///
  /// In en, this message translates to:
  /// **'Check your connection or try another source.'**
  String get checkConnectionOrSource;

  /// No description provided for @tryDifferentSearch.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term.'**
  String get tryDifferentSearch;

  /// No description provided for @savedTitlesAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Titles you add to your list appear here.'**
  String get savedTitlesAppearHere;

  /// No description provided for @tryOtherFeed.
  ///
  /// In en, this message translates to:
  /// **'Try the other feed or search instead.'**
  String get tryOtherFeed;

  /// No description provided for @searchSource.
  ///
  /// In en, this message translates to:
  /// **'Search {source}'**
  String searchSource(String source);

  /// No description provided for @animeExtensions.
  ///
  /// In en, this message translates to:
  /// **'Anime Extensions'**
  String get animeExtensions;

  /// No description provided for @mangaExtensions.
  ///
  /// In en, this message translates to:
  /// **'Manga Extensions'**
  String get mangaExtensions;

  /// No description provided for @nothingHereYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get nothingHereYet;

  /// No description provided for @savedOnDeviceUntilLogin.
  ///
  /// In en, this message translates to:
  /// **'Everything below is saved on this device until you do.'**
  String get savedOnDeviceUntilLogin;

  /// No description provided for @yourProfile.
  ///
  /// In en, this message translates to:
  /// **'Your profile'**
  String get yourProfile;

  /// No description provided for @activity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activity;

  /// No description provided for @extensions.
  ///
  /// In en, this message translates to:
  /// **'Extensions'**
  String get extensions;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get logIn;

  /// No description provided for @logOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logOutConfirm;

  /// No description provided for @incognitoMode.
  ///
  /// In en, this message translates to:
  /// **'Incognito mode'**
  String get incognitoMode;

  /// No description provided for @alsoBlockListEdits.
  ///
  /// In en, this message translates to:
  /// **'Also block list edits'**
  String get alsoBlockListEdits;

  /// No description provided for @offlineMode.
  ///
  /// In en, this message translates to:
  /// **'Offline mode'**
  String get offlineMode;

  /// No description provided for @switchService.
  ///
  /// In en, this message translates to:
  /// **'Switch service'**
  String get switchService;

  /// No description provided for @logOutOf.
  ///
  /// In en, this message translates to:
  /// **'Log out of {name}'**
  String logOutOf(String name);

  /// No description provided for @loggedIn.
  ///
  /// In en, this message translates to:
  /// **'Logged in'**
  String get loggedIn;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @nothingNew.
  ///
  /// In en, this message translates to:
  /// **'Nothing new'**
  String get nothingNew;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeek;

  /// No description provided for @listOnly.
  ///
  /// In en, this message translates to:
  /// **'List Only'**
  String get listOnly;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @searchResults.
  ///
  /// In en, this message translates to:
  /// **'Search Results'**
  String get searchResults;

  /// No description provided for @recentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get recentSearches;

  /// No description provided for @searchOrSetFilter.
  ///
  /// In en, this message translates to:
  /// **'Search or set a filter'**
  String get searchOrSetFilter;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get showLess;

  /// No description provided for @showAll.
  ///
  /// In en, this message translates to:
  /// **'Show all'**
  String get showAll;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @preset.
  ///
  /// In en, this message translates to:
  /// **'Preset'**
  String get preset;

  /// No description provided for @cardNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get cardNormal;

  /// No description provided for @cardOnCard.
  ///
  /// In en, this message translates to:
  /// **'On card'**
  String get cardOnCard;

  /// No description provided for @cardInCard.
  ///
  /// In en, this message translates to:
  /// **'In card'**
  String get cardInCard;

  /// No description provided for @size.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get size;

  /// No description provided for @cardWidth.
  ///
  /// In en, this message translates to:
  /// **'Card width'**
  String get cardWidth;

  /// No description provided for @compact.
  ///
  /// In en, this message translates to:
  /// **'Compact'**
  String get compact;

  /// No description provided for @coverAndTitleOnly.
  ///
  /// In en, this message translates to:
  /// **'Cover and title only'**
  String get coverAndTitleOnly;

  /// No description provided for @titleLines.
  ///
  /// In en, this message translates to:
  /// **'Title lines'**
  String get titleLines;

  /// No description provided for @shape.
  ///
  /// In en, this message translates to:
  /// **'Shape'**
  String get shape;

  /// No description provided for @posterShape.
  ///
  /// In en, this message translates to:
  /// **'Poster shape'**
  String get posterShape;

  /// No description provided for @cornerRadius.
  ///
  /// In en, this message translates to:
  /// **'Corner radius'**
  String get cornerRadius;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @topLeft.
  ///
  /// In en, this message translates to:
  /// **'Top left'**
  String get topLeft;

  /// No description provided for @topRight.
  ///
  /// In en, this message translates to:
  /// **'Top right'**
  String get topRight;

  /// No description provided for @bottomLeft.
  ///
  /// In en, this message translates to:
  /// **'Bottom left'**
  String get bottomLeft;

  /// No description provided for @bottomRight.
  ///
  /// In en, this message translates to:
  /// **'Bottom right'**
  String get bottomRight;

  /// No description provided for @overlays.
  ///
  /// In en, this message translates to:
  /// **'Overlays'**
  String get overlays;

  /// No description provided for @progressCount.
  ///
  /// In en, this message translates to:
  /// **'Progress / count'**
  String get progressCount;

  /// No description provided for @pill.
  ///
  /// In en, this message translates to:
  /// **'Pill'**
  String get pill;

  /// No description provided for @bar.
  ///
  /// In en, this message translates to:
  /// **'Bar'**
  String get bar;

  /// No description provided for @outside.
  ///
  /// In en, this message translates to:
  /// **'Outside'**
  String get outside;

  /// No description provided for @scoreBadge.
  ///
  /// In en, this message translates to:
  /// **'Score badge'**
  String get scoreBadge;

  /// No description provided for @airingDot.
  ///
  /// In en, this message translates to:
  /// **'Airing dot'**
  String get airingDot;

  /// No description provided for @updateAvailable.
  ///
  /// In en, this message translates to:
  /// **'Update available'**
  String get updateAvailable;

  /// No description provided for @notInstalled.
  ///
  /// In en, this message translates to:
  /// **'Not installed'**
  String get notInstalled;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @searchOrEnterUrl.
  ///
  /// In en, this message translates to:
  /// **'Search or enter URL'**
  String get searchOrEnterUrl;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @characters.
  ///
  /// In en, this message translates to:
  /// **'Characters'**
  String get characters;

  /// No description provided for @staff.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get staff;

  /// No description provided for @readMore.
  ///
  /// In en, this message translates to:
  /// **'Read more'**
  String get readMore;

  /// No description provided for @couldNotLoadList.
  ///
  /// In en, this message translates to:
  /// **'Could not load the list'**
  String get couldNotLoadList;

  /// No description provided for @logInToFavourite.
  ///
  /// In en, this message translates to:
  /// **'Log in to add favourites'**
  String get logInToFavourite;

  /// No description provided for @alsoKnownAs.
  ///
  /// In en, this message translates to:
  /// **'Also known as'**
  String get alsoKnownAs;

  /// No description provided for @hideSpoilerNames.
  ///
  /// In en, this message translates to:
  /// **'Hide spoiler names'**
  String get hideSpoilerNames;

  /// No description provided for @showSpoilerNames.
  ///
  /// In en, this message translates to:
  /// **'Show spoiler names'**
  String get showSpoilerNames;

  /// No description provided for @favourited.
  ///
  /// In en, this message translates to:
  /// **'Favourited'**
  String get favourited;

  /// No description provided for @favourite.
  ///
  /// In en, this message translates to:
  /// **'Favourite'**
  String get favourite;

  /// No description provided for @couldNotOpenTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not open this title'**
  String get couldNotOpenTitle;

  /// No description provided for @nobodyHereYet.
  ///
  /// In en, this message translates to:
  /// **'Nobody here yet'**
  String get nobodyHereYet;

  /// No description provided for @noMatches.
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get noMatches;

  /// No description provided for @gridView.
  ///
  /// In en, this message translates to:
  /// **'Grid view'**
  String get gridView;

  /// No description provided for @fullWidth.
  ///
  /// In en, this message translates to:
  /// **'Full width'**
  String get fullWidth;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get userNotFound;

  /// No description provided for @couldNotUpdateFollow.
  ///
  /// In en, this message translates to:
  /// **'Could not update follow'**
  String get couldNotUpdateFollow;

  /// No description provided for @followedUser.
  ///
  /// In en, this message translates to:
  /// **'Followed {name}'**
  String followedUser(String name);

  /// No description provided for @unfollowedUser.
  ///
  /// In en, this message translates to:
  /// **'Unfollowed {name}'**
  String unfollowedUser(String name);

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @logInToSeeMessages.
  ///
  /// In en, this message translates to:
  /// **'Log in to see your messages'**
  String get logInToSeeMessages;

  /// No description provided for @editActivity.
  ///
  /// In en, this message translates to:
  /// **'Edit activity'**
  String get editActivity;

  /// No description provided for @newActivity.
  ///
  /// In en, this message translates to:
  /// **'New activity'**
  String get newActivity;

  /// No description provided for @editMessage.
  ///
  /// In en, this message translates to:
  /// **'Edit message'**
  String get editMessage;

  /// No description provided for @writeMessage.
  ///
  /// In en, this message translates to:
  /// **'Write a message'**
  String get writeMessage;

  /// No description provided for @editReply.
  ///
  /// In en, this message translates to:
  /// **'Edit reply'**
  String get editReply;

  /// No description provided for @posted.
  ///
  /// In en, this message translates to:
  /// **'Posted'**
  String get posted;

  /// No description provided for @couldNotPost.
  ///
  /// In en, this message translates to:
  /// **'Could not post'**
  String get couldNotPost;

  /// No description provided for @nothingToPreview.
  ///
  /// In en, this message translates to:
  /// **'Nothing to preview'**
  String get nothingToPreview;

  /// No description provided for @writeSomethingHint.
  ///
  /// In en, this message translates to:
  /// **'Write something… AniList markdown works here'**
  String get writeSomethingHint;

  /// No description provided for @privateMessage.
  ///
  /// In en, this message translates to:
  /// **'Private message'**
  String get privateMessage;

  /// No description provided for @post.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get post;

  /// No description provided for @nothingHere.
  ///
  /// In en, this message translates to:
  /// **'Nothing here'**
  String get nothingHere;

  /// No description provided for @noAnimeProgress.
  ///
  /// In en, this message translates to:
  /// **'No anime progress'**
  String get noAnimeProgress;

  /// No description provided for @noMangaProgress.
  ///
  /// In en, this message translates to:
  /// **'No manga progress'**
  String get noMangaProgress;

  /// No description provided for @noMessages.
  ///
  /// In en, this message translates to:
  /// **'No messages'**
  String get noMessages;

  /// No description provided for @writeMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Write a message…'**
  String get writeMessageHint;

  /// No description provided for @shareSomethingHint.
  ///
  /// In en, this message translates to:
  /// **'Share something…'**
  String get shareSomethingHint;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @anime.
  ///
  /// In en, this message translates to:
  /// **'Anime'**
  String get anime;

  /// No description provided for @manga.
  ///
  /// In en, this message translates to:
  /// **'Manga'**
  String get manga;

  /// No description provided for @count.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get count;

  /// No description provided for @hoursWatched.
  ///
  /// In en, this message translates to:
  /// **'Hours watched'**
  String get hoursWatched;

  /// No description provided for @chaptersRead.
  ///
  /// In en, this message translates to:
  /// **'Chapters read'**
  String get chaptersRead;

  /// No description provided for @meanScore.
  ///
  /// In en, this message translates to:
  /// **'Mean score'**
  String get meanScore;

  /// No description provided for @noStatsYet.
  ///
  /// In en, this message translates to:
  /// **'No stats yet'**
  String get noStatsYet;

  /// No description provided for @totalEntries.
  ///
  /// In en, this message translates to:
  /// **'Total entries'**
  String get totalEntries;

  /// No description provided for @episodesWatched.
  ///
  /// In en, this message translates to:
  /// **'Episodes watched'**
  String get episodesWatched;

  /// No description provided for @daysWatched.
  ///
  /// In en, this message translates to:
  /// **'Days watched'**
  String get daysWatched;

  /// No description provided for @volumesRead.
  ///
  /// In en, this message translates to:
  /// **'Volumes read'**
  String get volumesRead;

  /// No description provided for @standardDeviation.
  ///
  /// In en, this message translates to:
  /// **'Standard deviation'**
  String get standardDeviation;

  /// No description provided for @showMore.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get showMore;

  /// No description provided for @followsYou.
  ///
  /// In en, this message translates to:
  /// **'Follows you'**
  String get followsYou;

  /// No description provided for @nobodyYet.
  ///
  /// In en, this message translates to:
  /// **'Nobody yet'**
  String get nobodyYet;

  /// No description provided for @logInToLike.
  ///
  /// In en, this message translates to:
  /// **'Log in to like'**
  String get logInToLike;

  /// No description provided for @failedToLikeActivity.
  ///
  /// In en, this message translates to:
  /// **'Failed to like activity'**
  String get failedToLikeActivity;

  /// No description provided for @deleteActivityConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete activity?'**
  String get deleteActivityConfirm;

  /// No description provided for @deletedActivity.
  ///
  /// In en, this message translates to:
  /// **'Deleted activity'**
  String get deletedActivity;

  /// No description provided for @failedToDeleteActivity.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete activity'**
  String get failedToDeleteActivity;

  /// No description provided for @subscribed.
  ///
  /// In en, this message translates to:
  /// **'Subscribed'**
  String get subscribed;

  /// No description provided for @unsubscribed.
  ///
  /// In en, this message translates to:
  /// **'Unsubscribed'**
  String get unsubscribed;

  /// No description provided for @failedToUpdateSubscription.
  ///
  /// In en, this message translates to:
  /// **'Failed to update subscription'**
  String get failedToUpdateSubscription;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @likedBy.
  ///
  /// In en, this message translates to:
  /// **'Liked by'**
  String get likedBy;

  /// No description provided for @follow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get follow;

  /// No description provided for @nameCopied.
  ///
  /// In en, this message translates to:
  /// **'Name copied'**
  String get nameCopied;

  /// No description provided for @followsEachOther.
  ///
  /// In en, this message translates to:
  /// **'Follows each other'**
  String get followsEachOther;

  /// No description provided for @unfollow.
  ///
  /// In en, this message translates to:
  /// **'Unfollow'**
  String get unfollow;

  /// No description provided for @userIdCopied.
  ///
  /// In en, this message translates to:
  /// **'User id copied'**
  String get userIdCopied;

  /// No description provided for @shareProfile.
  ///
  /// In en, this message translates to:
  /// **'Share profile'**
  String get shareProfile;

  /// No description provided for @copyUserId.
  ///
  /// In en, this message translates to:
  /// **'Copy user id'**
  String get copyUserId;

  /// No description provided for @failedToDelete.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete'**
  String get failedToDelete;

  /// No description provided for @failedToLike.
  ///
  /// In en, this message translates to:
  /// **'Failed to like'**
  String get failedToLike;

  /// No description provided for @replies.
  ///
  /// In en, this message translates to:
  /// **'Replies'**
  String get replies;

  /// No description provided for @reply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get reply;

  /// No description provided for @noRepliesYet.
  ///
  /// In en, this message translates to:
  /// **'No replies yet'**
  String get noRepliesYet;

  /// No description provided for @favouriteAnime.
  ///
  /// In en, this message translates to:
  /// **'Favourite anime'**
  String get favouriteAnime;

  /// No description provided for @favouriteManga.
  ///
  /// In en, this message translates to:
  /// **'Favourite manga'**
  String get favouriteManga;

  /// No description provided for @favouriteCharacters.
  ///
  /// In en, this message translates to:
  /// **'Favourite characters'**
  String get favouriteCharacters;

  /// No description provided for @favouriteStaff.
  ///
  /// In en, this message translates to:
  /// **'Favourite staff'**
  String get favouriteStaff;

  /// No description provided for @favouriteStudios.
  ///
  /// In en, this message translates to:
  /// **'Favourite studios'**
  String get favouriteStudios;

  /// No description provided for @noFavouritesYet.
  ///
  /// In en, this message translates to:
  /// **'No favourites yet'**
  String get noFavouritesYet;

  /// No description provided for @yourStory.
  ///
  /// In en, this message translates to:
  /// **'Your story'**
  String get yourStory;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @openImage.
  ///
  /// In en, this message translates to:
  /// **'Open image'**
  String get openImage;

  /// No description provided for @hideSpoiler.
  ///
  /// In en, this message translates to:
  /// **'Hide spoiler'**
  String get hideSpoiler;

  /// No description provided for @showSpoiler.
  ///
  /// In en, this message translates to:
  /// **'Show spoiler'**
  String get showSpoiler;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  /// No description provided for @started.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get started;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @private.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get private;

  /// No description provided for @hideFromStatusLists.
  ///
  /// In en, this message translates to:
  /// **'Hide from status lists'**
  String get hideFromStatusLists;

  /// No description provided for @totalRepeats.
  ///
  /// In en, this message translates to:
  /// **'Total repeats'**
  String get totalRepeats;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @customLists.
  ///
  /// In en, this message translates to:
  /// **'Custom lists'**
  String get customLists;

  /// No description provided for @activeDays.
  ///
  /// In en, this message translates to:
  /// **'Active days'**
  String get activeDays;

  /// No description provided for @longestStreak.
  ///
  /// In en, this message translates to:
  /// **'Longest streak'**
  String get longestStreak;

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current streak'**
  String get currentStreak;

  /// No description provided for @tapOrHoverDay.
  ///
  /// In en, this message translates to:
  /// **'Tap or hover a day'**
  String get tapOrHoverDay;

  /// No description provided for @less.
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get less;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @epIn.
  ///
  /// In en, this message translates to:
  /// **'Ep {ep} in {time}'**
  String epIn(int ep, String time);

  /// No description provided for @sectionLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get sectionLoading;

  /// No description provided for @querySize.
  ///
  /// In en, this message translates to:
  /// **'Query size'**
  String get querySize;

  /// No description provided for @querySizeDesc.
  ///
  /// In en, this message translates to:
  /// **'One big query loads every row (and a whole profile) in a single request. Split queries send a small request per row or per profile part: each is quick and parts appear as they arrive.'**
  String get querySizeDesc;

  /// No description provided for @oneBig.
  ///
  /// In en, this message translates to:
  /// **'One big'**
  String get oneBig;

  /// No description provided for @split.
  ///
  /// In en, this message translates to:
  /// **'Split'**
  String get split;

  /// No description provided for @sectionSocial.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get sectionSocial;

  /// No description provided for @systemNotifications.
  ///
  /// In en, this message translates to:
  /// **'System notifications'**
  String get systemNotifications;

  /// No description provided for @systemNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Show a notification for each unread AniList notification while the app is running. Opening the notifications page marks them read.'**
  String get systemNotificationsDesc;

  /// No description provided for @feedLayout.
  ///
  /// In en, this message translates to:
  /// **'Feed layout'**
  String get feedLayout;

  /// No description provided for @sectionsShown.
  ///
  /// In en, this message translates to:
  /// **'{shown} of {total} shown — tap to pick and reorder'**
  String sectionsShown(int shown, int total);

  /// No description provided for @labelSections.
  ///
  /// In en, this message translates to:
  /// **'{label} sections'**
  String labelSections(String label);

  /// No description provided for @accountOptions.
  ///
  /// In en, this message translates to:
  /// **'Account options'**
  String get accountOptions;

  /// No description provided for @accountOptionsDesc.
  ///
  /// In en, this message translates to:
  /// **'Names, score format, list order, notifications and more'**
  String get accountOptionsDesc;

  /// No description provided for @anilistAccountOptions.
  ///
  /// In en, this message translates to:
  /// **'AniList account options'**
  String get anilistAccountOptions;

  /// No description provided for @sectionPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get sectionPrivacy;

  /// No description provided for @hidePrivateEntries.
  ///
  /// In en, this message translates to:
  /// **'Hide private entries'**
  String get hidePrivateEntries;

  /// No description provided for @hidePrivateEntriesDesc.
  ///
  /// In en, this message translates to:
  /// **'Keep entries marked private on AniList out of the feed'**
  String get hidePrivateEntriesDesc;

  /// No description provided for @anilistProfile.
  ///
  /// In en, this message translates to:
  /// **'AniList profile'**
  String get anilistProfile;

  /// No description provided for @refreshFromAnilist.
  ///
  /// In en, this message translates to:
  /// **'Refresh from AniList'**
  String get refreshFromAnilist;

  /// No description provided for @couldNotUpdateAnilistSettings.
  ///
  /// In en, this message translates to:
  /// **'Could not update AniList settings'**
  String get couldNotUpdateAnilistSettings;

  /// No description provided for @sectionNames.
  ///
  /// In en, this message translates to:
  /// **'Names'**
  String get sectionNames;

  /// No description provided for @titleLanguage.
  ///
  /// In en, this message translates to:
  /// **'Title language'**
  String get titleLanguage;

  /// No description provided for @titleLanguageDesc.
  ///
  /// In en, this message translates to:
  /// **'How titles are written everywhere, e.g. Attack on Titan / Shingeki no Kyojin / 進撃の巨人.'**
  String get titleLanguageDesc;

  /// No description provided for @staffCharacterNames.
  ///
  /// In en, this message translates to:
  /// **'Staff and character names'**
  String get staffCharacterNames;

  /// No description provided for @sectionLists.
  ///
  /// In en, this message translates to:
  /// **'Lists'**
  String get sectionLists;

  /// No description provided for @scoreFormat.
  ///
  /// In en, this message translates to:
  /// **'Score format'**
  String get scoreFormat;

  /// No description provided for @sortListsBy.
  ///
  /// In en, this message translates to:
  /// **'Sort lists by'**
  String get sortListsBy;

  /// No description provided for @labelCustomLists.
  ///
  /// In en, this message translates to:
  /// **'{label} custom lists'**
  String labelCustomLists(String label);

  /// No description provided for @customListsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} lists — tap to add or remove'**
  String customListsCount(int count);

  /// No description provided for @mergeActivities.
  ///
  /// In en, this message translates to:
  /// **'Merge activities'**
  String get mergeActivities;

  /// No description provided for @minutesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} mins'**
  String minutesCount(int count);

  /// No description provided for @timezone.
  ///
  /// In en, this message translates to:
  /// **'Timezone'**
  String get timezone;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @airingNotifications.
  ///
  /// In en, this message translates to:
  /// **'Airing notifications'**
  String get airingNotifications;

  /// No description provided for @airingNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Get notified when an episode of a followed show airs'**
  String get airingNotificationsDesc;

  /// No description provided for @displayAdultContent.
  ///
  /// In en, this message translates to:
  /// **'Display adult content'**
  String get displayAdultContent;

  /// No description provided for @displayAdultContentDesc.
  ///
  /// In en, this message translates to:
  /// **'Include 18+ titles in browse, search and feeds'**
  String get displayAdultContentDesc;

  /// No description provided for @restrictMessages.
  ///
  /// In en, this message translates to:
  /// **'Restrict messages to following'**
  String get restrictMessages;

  /// No description provided for @restrictMessagesDesc.
  ///
  /// In en, this message translates to:
  /// **'Only people you follow can message you'**
  String get restrictMessagesDesc;

  /// No description provided for @sectionServices.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get sectionServices;

  /// No description provided for @novel.
  ///
  /// In en, this message translates to:
  /// **'Novel'**
  String get novel;

  /// No description provided for @labelService.
  ///
  /// In en, this message translates to:
  /// **'{label} service'**
  String labelService(String label);

  /// No description provided for @nameSettings.
  ///
  /// In en, this message translates to:
  /// **'{name} settings'**
  String nameSettings(String name);

  /// No description provided for @extensionBridgeOptions.
  ///
  /// In en, this message translates to:
  /// **'Options from the {name} extension bridge'**
  String extensionBridgeOptions(String name);

  /// No description provided for @importLists.
  ///
  /// In en, this message translates to:
  /// **'Import lists'**
  String get importLists;

  /// No description provided for @importListsDesc.
  ///
  /// In en, this message translates to:
  /// **'From Aniyomi, Mihon / Tachiyomi or Kotatsu backups'**
  String get importListsDesc;

  /// No description provided for @exportLists.
  ///
  /// In en, this message translates to:
  /// **'Export lists'**
  String get exportLists;

  /// No description provided for @exportListsDesc.
  ///
  /// In en, this message translates to:
  /// **'To an Aniyomi, Mihon or Kotatsu backup'**
  String get exportListsDesc;

  /// No description provided for @sectionBrowse.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get sectionBrowse;

  /// No description provided for @readingTab.
  ///
  /// In en, this message translates to:
  /// **'Reading tab'**
  String get readingTab;

  /// No description provided for @readingTabDesc.
  ///
  /// In en, this message translates to:
  /// **'Which extensions the third tab shows'**
  String get readingTabDesc;

  /// No description provided for @defaultFeed.
  ///
  /// In en, this message translates to:
  /// **'Default feed'**
  String get defaultFeed;

  /// No description provided for @defaultFeedDesc.
  ///
  /// In en, this message translates to:
  /// **'Which list a source opens with'**
  String get defaultFeedDesc;

  /// No description provided for @noServiceSupports.
  ///
  /// In en, this message translates to:
  /// **'No service supports {type}'**
  String noServiceSupports(String type);

  /// No description provided for @sourcesLoading.
  ///
  /// In en, this message translates to:
  /// **'{name} · {loaded} of {installed} sources loading'**
  String sourcesLoading(String name, int loaded, int installed);

  /// No description provided for @noExtensionServiceSupportsHere.
  ///
  /// In en, this message translates to:
  /// **'No extension service supports {type} here.'**
  String noExtensionServiceSupportsHere(String type);

  /// No description provided for @loadDataFrom.
  ///
  /// In en, this message translates to:
  /// **'Load data from'**
  String get loadDataFrom;

  /// No description provided for @noInstalledSourcesYet.
  ///
  /// In en, this message translates to:
  /// **'No installed {type} sources yet.'**
  String noInstalledSourcesYet(String type);

  /// No description provided for @extensionNotInstalled.
  ///
  /// In en, this message translates to:
  /// **'The extension for {name} is not installed'**
  String extensionNotInstalled(String name);

  /// No description provided for @thisSource.
  ///
  /// In en, this message translates to:
  /// **'this source'**
  String get thisSource;

  /// No description provided for @failedToAddRepository.
  ///
  /// In en, this message translates to:
  /// **'Failed to add repository: {error}'**
  String failedToAddRepository(String error);

  /// No description provided for @installedType.
  ///
  /// In en, this message translates to:
  /// **'Installed {type}'**
  String installedType(String type);

  /// No description provided for @availableType.
  ///
  /// In en, this message translates to:
  /// **'Available {type}'**
  String availableType(String type);

  /// No description provided for @noInstalledExtensions.
  ///
  /// In en, this message translates to:
  /// **'No installed {type} extensions'**
  String noInstalledExtensions(String type);

  /// No description provided for @noAvailableExtensions.
  ///
  /// In en, this message translates to:
  /// **'No available {type} extensions'**
  String noAvailableExtensions(String type);

  /// No description provided for @nothingToShowYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing to show yet'**
  String get nothingToShowYet;

  /// No description provided for @addTitlesHint.
  ///
  /// In en, this message translates to:
  /// **'Add some titles to your list and they\'ll appear here.'**
  String get addTitlesHint;

  /// No description provided for @couldntLoad.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load'**
  String get couldntLoad;

  /// No description provided for @progressStyleHint.
  ///
  /// In en, this message translates to:
  /// **'Pill and bar overlay the poster; outside shows the same count as plain text instead — pick one.'**
  String get progressStyleHint;

  /// No description provided for @nixManagedUpdate.
  ///
  /// In en, this message translates to:
  /// **'This build is managed by Nix — run \"nix flake update\" on your flake and rebuild instead of updating from here'**
  String get nixManagedUpdate;

  /// No description provided for @autoUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Automatic update failed ({error}) — opening the download page instead'**
  String autoUpdateFailed(String error);

  /// No description provided for @unknownPreference.
  ///
  /// In en, this message translates to:
  /// **'Unknown preference'**
  String get unknownPreference;

  /// No description provided for @unsupportedPreferenceType.
  ///
  /// In en, this message translates to:
  /// **'Unsupported preference type {type}'**
  String unsupportedPreferenceType(String type);

  /// No description provided for @notYetReleased.
  ///
  /// In en, this message translates to:
  /// **'Not Yet Released'**
  String get notYetReleased;

  /// No description provided for @notStarted.
  ///
  /// In en, this message translates to:
  /// **'Not Started'**
  String get notStarted;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @chooseBackupDialog.
  ///
  /// In en, this message translates to:
  /// **'Choose an Aniyomi, Mihon or Kotatsu backup'**
  String get chooseBackupDialog;

  /// No description provided for @importListsHint.
  ///
  /// In en, this message translates to:
  /// **'Bring a library over from Aniyomi, Mihon / Tachiyomi or Kotatsu. Titles, covers, progress and categories are kept.'**
  String get importListsHint;

  /// No description provided for @chooseBackupFile.
  ///
  /// In en, this message translates to:
  /// **'Choose backup file'**
  String get chooseBackupFile;

  /// No description provided for @importAnimeCount.
  ///
  /// In en, this message translates to:
  /// **'Import {count} anime'**
  String importAnimeCount(int count);

  /// No description provided for @importMangaCount.
  ///
  /// In en, this message translates to:
  /// **'Import {count} manga'**
  String importMangaCount(int count);

  /// No description provided for @mergeWithExisting.
  ///
  /// In en, this message translates to:
  /// **'Merge with existing lists'**
  String get mergeWithExisting;

  /// No description provided for @mergeWithExistingDesc.
  ///
  /// In en, this message translates to:
  /// **'Keeps what you already have; off replaces matching titles'**
  String get mergeWithExistingDesc;

  /// No description provided for @chooseAnother.
  ///
  /// In en, this message translates to:
  /// **'Choose another'**
  String get chooseAnother;

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @animeCount.
  ///
  /// In en, this message translates to:
  /// **'{count} anime'**
  String animeCount(int count);

  /// No description provided for @mangaCount.
  ///
  /// In en, this message translates to:
  /// **'{count} manga'**
  String mangaCount(int count);

  /// No description provided for @chooseSaveLocation.
  ///
  /// In en, this message translates to:
  /// **'Choose where to save the backup'**
  String get chooseSaveLocation;

  /// No description provided for @savedPath.
  ///
  /// In en, this message translates to:
  /// **'Saved {path}'**
  String savedPath(String path);

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String exportFailed(String error);

  /// No description provided for @nothingInLocalLists.
  ///
  /// In en, this message translates to:
  /// **'Nothing in your local lists yet.'**
  String get nothingInLocalLists;

  /// No description provided for @exportsSummary.
  ///
  /// In en, this message translates to:
  /// **'Exports {anime} anime and {manga} manga from your local lists. Kotatsu only supports manga.'**
  String exportsSummary(int anime, int manga);

  /// No description provided for @saveToFolder.
  ///
  /// In en, this message translates to:
  /// **'Save to folder'**
  String get saveToFolder;

  /// No description provided for @formatAnimeManga.
  ///
  /// In en, this message translates to:
  /// **'Anime and manga · .tachibk'**
  String get formatAnimeManga;

  /// No description provided for @formatMangaTachibk.
  ///
  /// In en, this message translates to:
  /// **'Manga only · .tachibk'**
  String get formatMangaTachibk;

  /// No description provided for @formatMangaZip.
  ///
  /// In en, this message translates to:
  /// **'Manga only · .zip'**
  String get formatMangaZip;

  /// No description provided for @genres.
  ///
  /// In en, this message translates to:
  /// **'Genres'**
  String get genres;

  /// No description provided for @relations.
  ///
  /// In en, this message translates to:
  /// **'Relations'**
  String get relations;

  /// No description provided for @recommendations.
  ///
  /// In en, this message translates to:
  /// **'Recommendations'**
  String get recommendations;

  /// No description provided for @openings.
  ///
  /// In en, this message translates to:
  /// **'Openings'**
  String get openings;

  /// No description provided for @endings.
  ///
  /// In en, this message translates to:
  /// **'Endings'**
  String get endings;

  /// No description provided for @background.
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get background;

  /// No description provided for @links.
  ///
  /// In en, this message translates to:
  /// **'Links'**
  String get links;

  /// No description provided for @rank.
  ///
  /// In en, this message translates to:
  /// **'Rank'**
  String get rank;

  /// No description provided for @members.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get members;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @episodes.
  ///
  /// In en, this message translates to:
  /// **'Episodes'**
  String get episodes;

  /// No description provided for @chapters.
  ///
  /// In en, this message translates to:
  /// **'Chapters'**
  String get chapters;

  /// No description provided for @volumes.
  ///
  /// In en, this message translates to:
  /// **'Volumes'**
  String get volumes;

  /// No description provided for @format.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get format;

  /// No description provided for @source.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get source;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @minutesPerEpisode.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min per ep'**
  String minutesPerEpisode(int minutes);

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @studio.
  ///
  /// In en, this message translates to:
  /// **'Studio'**
  String get studio;

  /// No description provided for @serialization.
  ///
  /// In en, this message translates to:
  /// **'Serialization'**
  String get serialization;

  /// No description provided for @season.
  ///
  /// In en, this message translates to:
  /// **'Season'**
  String get season;

  /// No description provided for @broadcast.
  ///
  /// In en, this message translates to:
  /// **'Broadcast'**
  String get broadcast;

  /// No description provided for @aired.
  ///
  /// In en, this message translates to:
  /// **'Aired'**
  String get aired;

  /// No description provided for @published.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get published;

  /// No description provided for @popularity.
  ///
  /// In en, this message translates to:
  /// **'Popularity'**
  String get popularity;

  /// No description provided for @community.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get community;

  /// No description provided for @watching.
  ///
  /// In en, this message translates to:
  /// **'Watching'**
  String get watching;

  /// No description provided for @reading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get reading;

  /// No description provided for @dropped.
  ///
  /// In en, this message translates to:
  /// **'Dropped'**
  String get dropped;

  /// No description provided for @planned.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get planned;

  /// No description provided for @trailers.
  ///
  /// In en, this message translates to:
  /// **'Trailers'**
  String get trailers;

  /// No description provided for @ratings.
  ///
  /// In en, this message translates to:
  /// **'Ratings'**
  String get ratings;

  /// No description provided for @originalTitle.
  ///
  /// In en, this message translates to:
  /// **'Original'**
  String get originalTitle;

  /// No description provided for @titleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleLabel;

  /// No description provided for @votes.
  ///
  /// In en, this message translates to:
  /// **'Votes'**
  String get votes;

  /// No description provided for @watchedStat.
  ///
  /// In en, this message translates to:
  /// **'Watched'**
  String get watchedStat;

  /// No description provided for @runtime.
  ///
  /// In en, this message translates to:
  /// **'Runtime'**
  String get runtime;

  /// No description provided for @director.
  ///
  /// In en, this message translates to:
  /// **'Director'**
  String get director;

  /// No description provided for @network.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get network;

  /// No description provided for @certification.
  ///
  /// In en, this message translates to:
  /// **'Certification'**
  String get certification;

  /// No description provided for @airs.
  ///
  /// In en, this message translates to:
  /// **'Airs'**
  String get airs;

  /// No description provided for @budget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budget;

  /// No description provided for @revenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get revenue;

  /// No description provided for @released.
  ///
  /// In en, this message translates to:
  /// **'Released'**
  String get released;

  /// No description provided for @tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// No description provided for @author.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get author;

  /// No description provided for @born.
  ///
  /// In en, this message translates to:
  /// **'Born'**
  String get born;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @established.
  ///
  /// In en, this message translates to:
  /// **'Established'**
  String get established;

  /// No description provided for @manhwa.
  ///
  /// In en, this message translates to:
  /// **'Manhwa'**
  String get manhwa;

  /// No description provided for @manhua.
  ///
  /// In en, this message translates to:
  /// **'Manhua'**
  String get manhua;

  /// No description provided for @novels.
  ///
  /// In en, this message translates to:
  /// **'Novels'**
  String get novels;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// No description provided for @movies.
  ///
  /// In en, this message translates to:
  /// **'Movies'**
  String get movies;

  /// No description provided for @shows.
  ///
  /// In en, this message translates to:
  /// **'Shows'**
  String get shows;

  /// No description provided for @rewatching.
  ///
  /// In en, this message translates to:
  /// **'Rewatching'**
  String get rewatching;

  /// No description provided for @rereading.
  ///
  /// In en, this message translates to:
  /// **'Rereading'**
  String get rereading;

  /// No description provided for @watchedStatus.
  ///
  /// In en, this message translates to:
  /// **'Watched'**
  String get watchedStatus;

  /// No description provided for @planning.
  ///
  /// In en, this message translates to:
  /// **'Planning'**
  String get planning;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// No description provided for @watch.
  ///
  /// In en, this message translates to:
  /// **'Watch'**
  String get watch;

  /// No description provided for @read.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get read;

  /// No description provided for @finished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get finished;

  /// No description provided for @releasing.
  ///
  /// In en, this message translates to:
  /// **'Releasing'**
  String get releasing;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @hiatus.
  ///
  /// In en, this message translates to:
  /// **'Hiatus'**
  String get hiatus;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @cardPresetPoster.
  ///
  /// In en, this message translates to:
  /// **'Poster'**
  String get cardPresetPoster;

  /// No description provided for @cardPresetCard.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get cardPresetCard;

  /// No description provided for @cardPresetCozy.
  ///
  /// In en, this message translates to:
  /// **'Cozy'**
  String get cardPresetCozy;

  /// No description provided for @sortTopRated.
  ///
  /// In en, this message translates to:
  /// **'Top rated'**
  String get sortTopRated;

  /// No description provided for @sortMostPopular.
  ///
  /// In en, this message translates to:
  /// **'Most popular'**
  String get sortMostPopular;

  /// No description provided for @sortTrending.
  ///
  /// In en, this message translates to:
  /// **'Trending'**
  String get sortTrending;

  /// No description provided for @sortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get sortNewest;

  /// No description provided for @sortAz.
  ///
  /// In en, this message translates to:
  /// **'A–Z'**
  String get sortAz;

  /// No description provided for @sortMostFavourited.
  ///
  /// In en, this message translates to:
  /// **'Most favourited'**
  String get sortMostFavourited;

  /// No description provided for @anyCountry.
  ///
  /// In en, this message translates to:
  /// **'Any country'**
  String get anyCountry;

  /// No description provided for @orderScore.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get orderScore;

  /// No description provided for @orderTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get orderTitle;

  /// No description provided for @orderLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last Updated'**
  String get orderLastUpdated;

  /// No description provided for @orderLastAdded.
  ///
  /// In en, this message translates to:
  /// **'Last Added'**
  String get orderLastAdded;

  /// No description provided for @never.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get never;

  /// No description provided for @always.
  ///
  /// In en, this message translates to:
  /// **'Always'**
  String get always;

  /// No description provided for @scorePoint100.
  ///
  /// In en, this message translates to:
  /// **'100 Point'**
  String get scorePoint100;

  /// No description provided for @scorePoint10Decimal.
  ///
  /// In en, this message translates to:
  /// **'10 Point Decimal'**
  String get scorePoint10Decimal;

  /// No description provided for @scorePoint10.
  ///
  /// In en, this message translates to:
  /// **'10 Point'**
  String get scorePoint10;

  /// No description provided for @scorePoint5.
  ///
  /// In en, this message translates to:
  /// **'5 Star'**
  String get scorePoint5;

  /// No description provided for @scorePoint3.
  ///
  /// In en, this message translates to:
  /// **'3 Point Smiley'**
  String get scorePoint3;

  /// No description provided for @hoursCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hour} other{{count} hours}}'**
  String hoursCount(int count);

  /// No description provided for @daysCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String daysCount(int count);

  /// No description provided for @weeksCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 week} other{{count} weeks}}'**
  String weeksCount(int count);

  /// No description provided for @continueWatching.
  ///
  /// In en, this message translates to:
  /// **'Continue Watching'**
  String get continueWatching;

  /// No description provided for @continueReading.
  ///
  /// In en, this message translates to:
  /// **'Continue Reading'**
  String get continueReading;

  /// No description provided for @favouriteAnimeSection.
  ///
  /// In en, this message translates to:
  /// **'Favourite Anime'**
  String get favouriteAnimeSection;

  /// No description provided for @favouriteMangaSection.
  ///
  /// In en, this message translates to:
  /// **'Favourite Manga'**
  String get favouriteMangaSection;

  /// No description provided for @plannedAnime.
  ///
  /// In en, this message translates to:
  /// **'Planned Anime'**
  String get plannedAnime;

  /// No description provided for @plannedManga.
  ///
  /// In en, this message translates to:
  /// **'Planned Manga'**
  String get plannedManga;

  /// No description provided for @completedAnime.
  ///
  /// In en, this message translates to:
  /// **'Completed Anime'**
  String get completedAnime;

  /// No description provided for @completedManga.
  ///
  /// In en, this message translates to:
  /// **'Completed Manga'**
  String get completedManga;

  /// No description provided for @hiddenMedia.
  ///
  /// In en, this message translates to:
  /// **'Hidden Media'**
  String get hiddenMedia;

  /// No description provided for @recentUpdates.
  ///
  /// In en, this message translates to:
  /// **'Recent Updates'**
  String get recentUpdates;

  /// No description provided for @trendingNow.
  ///
  /// In en, this message translates to:
  /// **'Trending Now'**
  String get trendingNow;

  /// No description provided for @popularThisSeason.
  ///
  /// In en, this message translates to:
  /// **'Popular This Season'**
  String get popularThisSeason;

  /// No description provided for @trendingMovies.
  ///
  /// In en, this message translates to:
  /// **'Trending Movies'**
  String get trendingMovies;

  /// No description provided for @topRatedSeries.
  ///
  /// In en, this message translates to:
  /// **'Top Rated Series'**
  String get topRatedSeries;

  /// No description provided for @mostFavouriteSeries.
  ///
  /// In en, this message translates to:
  /// **'Most Favourite Series'**
  String get mostFavouriteSeries;

  /// No description provided for @popularAnime.
  ///
  /// In en, this message translates to:
  /// **'Popular Anime'**
  String get popularAnime;

  /// No description provided for @trendingManhwa.
  ///
  /// In en, this message translates to:
  /// **'Trending Manhwa'**
  String get trendingManhwa;

  /// No description provided for @trendingNovels.
  ///
  /// In en, this message translates to:
  /// **'Trending Novels'**
  String get trendingNovels;

  /// No description provided for @topRatedManga.
  ///
  /// In en, this message translates to:
  /// **'Top Rated Manga'**
  String get topRatedManga;

  /// No description provided for @mostFavouriteManga.
  ///
  /// In en, this message translates to:
  /// **'Most Favourite Manga'**
  String get mostFavouriteManga;

  /// No description provided for @popularManga.
  ///
  /// In en, this message translates to:
  /// **'Popular Manga'**
  String get popularManga;

  /// No description provided for @topMovies.
  ///
  /// In en, this message translates to:
  /// **'Top Movies'**
  String get topMovies;

  /// No description provided for @topOna.
  ///
  /// In en, this message translates to:
  /// **'Top ONA'**
  String get topOna;

  /// No description provided for @topOva.
  ///
  /// In en, this message translates to:
  /// **'Top OVA'**
  String get topOva;

  /// No description provided for @mostPopular.
  ///
  /// In en, this message translates to:
  /// **'Most Popular'**
  String get mostPopular;

  /// No description provided for @mostFavourite.
  ///
  /// In en, this message translates to:
  /// **'Most Favourite'**
  String get mostFavourite;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @topManga.
  ///
  /// In en, this message translates to:
  /// **'Top Manga'**
  String get topManga;

  /// No description provided for @topManhwa.
  ///
  /// In en, this message translates to:
  /// **'Top Manhwa'**
  String get topManhwa;

  /// No description provided for @topManhua.
  ///
  /// In en, this message translates to:
  /// **'Top Manhua'**
  String get topManhua;

  /// No description provided for @topNovels.
  ///
  /// In en, this message translates to:
  /// **'Top Novels'**
  String get topNovels;

  /// No description provided for @topOneShots.
  ///
  /// In en, this message translates to:
  /// **'Top One-shots'**
  String get topOneShots;

  /// No description provided for @trendingMoviesToday.
  ///
  /// In en, this message translates to:
  /// **'Trending Movies Today'**
  String get trendingMoviesToday;

  /// No description provided for @trendingShowsToday.
  ///
  /// In en, this message translates to:
  /// **'Trending Shows Today'**
  String get trendingShowsToday;

  /// No description provided for @trendingMoviesWeek.
  ///
  /// In en, this message translates to:
  /// **'Trending Movies This Week'**
  String get trendingMoviesWeek;

  /// No description provided for @trendingShowsWeek.
  ///
  /// In en, this message translates to:
  /// **'Trending Shows This Week'**
  String get trendingShowsWeek;

  /// No description provided for @mostWatchedMoviesMonth.
  ///
  /// In en, this message translates to:
  /// **'Most Watched Movies This Month'**
  String get mostWatchedMoviesMonth;

  /// No description provided for @mostWatchedShowsMonth.
  ///
  /// In en, this message translates to:
  /// **'Most Watched Shows This Month'**
  String get mostWatchedShowsMonth;

  /// No description provided for @trendingThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Trending This Week'**
  String get trendingThisWeek;

  /// No description provided for @mostWatchedThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Most Watched This Month'**
  String get mostWatchedThisMonth;

  /// No description provided for @repoLinksAdded.
  ///
  /// In en, this message translates to:
  /// **'Added Repo Links Successfully!'**
  String get repoLinksAdded;

  /// No description provided for @errorGettingAnilistData.
  ///
  /// In en, this message translates to:
  /// **'Error getting data from AniList.'**
  String get errorGettingAnilistData;

  /// No description provided for @navInfo.
  ///
  /// In en, this message translates to:
  /// **'INFO'**
  String get navInfo;

  /// No description provided for @navComments.
  ///
  /// In en, this message translates to:
  /// **'COMMENTS'**
  String get navComments;

  /// No description provided for @playerNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'The player is not available yet'**
  String get playerNotAvailable;

  /// No description provided for @deepLinkInitialError.
  ///
  /// In en, this message translates to:
  /// **'Error getting initial deep link: {error}'**
  String deepLinkInitialError(String error);

  /// No description provided for @deepLinkOpenError.
  ///
  /// In en, this message translates to:
  /// **'Error Opening link: {error}'**
  String deepLinkOpenError(String error);

  /// No description provided for @linkCantBeOpened.
  ///
  /// In en, this message translates to:
  /// **'This link can\'t be opened: {link}'**
  String linkCantBeOpened(String link);

  /// No description provided for @linkOpenError.
  ///
  /// In en, this message translates to:
  /// **'Error opening link: {error}'**
  String linkOpenError(String error);

  /// No description provided for @forReleasingTitles.
  ///
  /// In en, this message translates to:
  /// **'for currently releasing titles'**
  String get forReleasingTitles;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @serviceNotFound.
  ///
  /// In en, this message translates to:
  /// **'Service \"{id}\" not found'**
  String serviceNotFound(String id);

  /// No description provided for @glassEffectEnabled.
  ///
  /// In en, this message translates to:
  /// **'Glass effect enabled'**
  String get glassEffectEnabled;

  /// No description provided for @glassEffectDisabled.
  ///
  /// In en, this message translates to:
  /// **'Glass effect disabled'**
  String get glassEffectDisabled;

  /// No description provided for @materialYouEnabled.
  ///
  /// In en, this message translates to:
  /// **'Material You enabled'**
  String get materialYouEnabled;

  /// No description provided for @materialYouDisabled.
  ///
  /// In en, this message translates to:
  /// **'Material You disabled'**
  String get materialYouDisabled;

  /// No description provided for @darkModeEnabled.
  ///
  /// In en, this message translates to:
  /// **'Dark mode enabled'**
  String get darkModeEnabled;

  /// No description provided for @darkModeDisabled.
  ///
  /// In en, this message translates to:
  /// **'Dark mode disabled'**
  String get darkModeDisabled;

  /// No description provided for @animeList.
  ///
  /// In en, this message translates to:
  /// **'Anime list'**
  String get animeList;

  /// No description provided for @mangaList.
  ///
  /// In en, this message translates to:
  /// **'Manga list'**
  String get mangaList;

  /// No description provided for @ownerAnimeList.
  ///
  /// In en, this message translates to:
  /// **'{owner}\'s anime list'**
  String ownerAnimeList(String owner);

  /// No description provided for @ownerMangaList.
  ///
  /// In en, this message translates to:
  /// **'{owner}\'s manga list'**
  String ownerMangaList(String owner);

  /// No description provided for @loadingList.
  ///
  /// In en, this message translates to:
  /// **'Loading list'**
  String get loadingList;

  /// No description provided for @earlier.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get earlier;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day ago} other{{count} days ago}}'**
  String daysAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hour ago} other{{count} hours ago}}'**
  String hoursAgo(int count);

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 minute ago} other{{count} minutes ago}}'**
  String minutesAgo(int count);

  /// No description provided for @minutesAgoShort.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String minutesAgoShort(int count);

  /// No description provided for @hoursAgoShort.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String hoursAgoShort(int count);

  /// No description provided for @daysAgoShort.
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String daysAgoShort(int count);

  /// No description provided for @weeksAgoShort.
  ///
  /// In en, this message translates to:
  /// **'{count}w ago'**
  String weeksAgoShort(int count);

  /// No description provided for @couldntLoadSource.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load this source'**
  String get couldntLoadSource;

  /// No description provided for @followers.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get followers;

  /// No description provided for @couldntLoadTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load {title}'**
  String couldntLoadTitle(String title);

  /// No description provided for @userTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} · {title}'**
  String userTitle(String name, String title);

  /// No description provided for @couldntLoadProfile.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load this profile'**
  String get couldntLoadProfile;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @feed.
  ///
  /// In en, this message translates to:
  /// **'Feed'**
  String get feed;

  /// No description provided for @stats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get stats;

  /// No description provided for @received.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get received;

  /// No description provided for @sent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get sent;

  /// No description provided for @global.
  ///
  /// In en, this message translates to:
  /// **'Global'**
  String get global;

  /// No description provided for @couldntLoadPage.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load this page'**
  String get couldntLoadPage;

  /// No description provided for @couldntLoadAllDetails.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load all details'**
  String get couldntLoadAllDetails;

  /// No description provided for @series.
  ///
  /// In en, this message translates to:
  /// **'Series'**
  String get series;

  /// No description provided for @studios.
  ///
  /// In en, this message translates to:
  /// **'Studios'**
  String get studios;

  /// No description provided for @users.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;

  /// No description provided for @repositoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'{type} Repositories'**
  String repositoriesTitle(String type);

  /// No description provided for @repositoryUrl.
  ///
  /// In en, this message translates to:
  /// **'Repository URL'**
  String get repositoryUrl;

  /// No description provided for @downloadingRepository.
  ///
  /// In en, this message translates to:
  /// **'Downloading repository…'**
  String get downloadingRepository;

  /// No description provided for @noRepositories.
  ///
  /// In en, this message translates to:
  /// **'No repositories added'**
  String get noRepositories;

  /// No description provided for @repoExtensionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} extensions'**
  String repoExtensionsCount(String count);

  /// No description provided for @searchExtensions.
  ///
  /// In en, this message translates to:
  /// **'Search extensions...'**
  String get searchExtensions;

  /// No description provided for @deletePluginTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String deletePluginTitle(String name);

  /// No description provided for @deletePluginMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this plugin?'**
  String get deletePluginMessage;

  /// No description provided for @pluginDeleted.
  ///
  /// In en, this message translates to:
  /// **'{name} deleted'**
  String pluginDeleted(String name);

  /// No description provided for @pluginNotInRepo.
  ///
  /// In en, this message translates to:
  /// **'{name} is not available in the configured repo'**
  String pluginNotInRepo(String name);

  /// No description provided for @pluginFetchFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch plugin info'**
  String get pluginFetchFailed;

  /// No description provided for @installPluginTitle.
  ///
  /// In en, this message translates to:
  /// **'Install {name}'**
  String installPluginTitle(String name);

  /// No description provided for @sizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Size: {size}'**
  String sizeLabel(String size);

  /// No description provided for @installedState.
  ///
  /// In en, this message translates to:
  /// **'Installed'**
  String get installedState;

  /// No description provided for @errorLabel.
  ///
  /// In en, this message translates to:
  /// **'Error:'**
  String get errorLabel;

  /// No description provided for @stackTraceDetails.
  ///
  /// In en, this message translates to:
  /// **'Details (Stack Trace)'**
  String get stackTraceDetails;

  /// No description provided for @shareLogFile.
  ///
  /// In en, this message translates to:
  /// **'Share log file'**
  String get shareLogFile;

  /// No description provided for @copyLogs.
  ///
  /// In en, this message translates to:
  /// **'Copy Logs'**
  String get copyLogs;

  /// No description provided for @noListToEdit.
  ///
  /// In en, this message translates to:
  /// **'{service} has no list to edit'**
  String noListToEdit(String service);

  /// No description provided for @couldNotReadFile.
  ///
  /// In en, this message translates to:
  /// **'Could not read that file'**
  String get couldNotReadFile;

  /// No description provided for @importedSummary.
  ///
  /// In en, this message translates to:
  /// **'Imported {anime} anime and {manga} manga'**
  String importedSummary(int anime, int manga);

  /// No description provided for @alreadyThere.
  ///
  /// In en, this message translates to:
  /// **' · {count} already there'**
  String alreadyThere(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'am',
    'ar',
    'as',
    'bn',
    'da',
    'de',
    'el',
    'en',
    'es',
    'fa',
    'fil',
    'fr',
    'ha',
    'he',
    'hi',
    'hr',
    'id',
    'it',
    'ja',
    'kn',
    'ko',
    'ml',
    'mr',
    'ms',
    'ne',
    'nl',
    'or',
    'pl',
    'ps',
    'pt',
    'ru',
    'sa',
    'si',
    'so',
    'sw',
    'ta',
    'te',
    'th',
    'tr',
    'uk',
    'vi',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return AppLocalizationsPtBr();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'am':
      return AppLocalizationsAm();
    case 'ar':
      return AppLocalizationsAr();
    case 'as':
      return AppLocalizationsAs();
    case 'bn':
      return AppLocalizationsBn();
    case 'da':
      return AppLocalizationsDa();
    case 'de':
      return AppLocalizationsDe();
    case 'el':
      return AppLocalizationsEl();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fa':
      return AppLocalizationsFa();
    case 'fil':
      return AppLocalizationsFil();
    case 'fr':
      return AppLocalizationsFr();
    case 'ha':
      return AppLocalizationsHa();
    case 'he':
      return AppLocalizationsHe();
    case 'hi':
      return AppLocalizationsHi();
    case 'hr':
      return AppLocalizationsHr();
    case 'id':
      return AppLocalizationsId();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'kn':
      return AppLocalizationsKn();
    case 'ko':
      return AppLocalizationsKo();
    case 'ml':
      return AppLocalizationsMl();
    case 'mr':
      return AppLocalizationsMr();
    case 'ms':
      return AppLocalizationsMs();
    case 'ne':
      return AppLocalizationsNe();
    case 'nl':
      return AppLocalizationsNl();
    case 'or':
      return AppLocalizationsOr();
    case 'pl':
      return AppLocalizationsPl();
    case 'ps':
      return AppLocalizationsPs();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'sa':
      return AppLocalizationsSa();
    case 'si':
      return AppLocalizationsSi();
    case 'so':
      return AppLocalizationsSo();
    case 'sw':
      return AppLocalizationsSw();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
    case 'th':
      return AppLocalizationsTh();
    case 'tr':
      return AppLocalizationsTr();
    case 'uk':
      return AppLocalizationsUk();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
