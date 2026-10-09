import '../../../Core/Services/MediaService.dart';
import '../../../Core/State/State.dart';
import 'Auth.dart';
import 'Screens/Detail.dart';
import 'Screens/Feed.dart';
import 'Screens/Home.dart';
import 'Screens/Search.dart';
import 'Screens/Settings.dart';

const mangaBakaServiceId = 'mangabaka';

class MangaBakaService extends MediaService {
  @override
  String get id => mangaBakaServiceId;

  @override
  String get name => 'MangaBaka';

  @override
  String get iconPath => 'assets/svg/mangabaka.svg';

  MangaBakaAuth get _auth => find();

  @override
  Queries get getQueries => _auth.queries;

  @override
  Mutations get apiMutations => _auth.mutations;

  @override
  ServiceAuth get auth => _auth;

  @override
  List<MediaType> get feedTypes => const [MediaType.manga, MediaType.novel];

  @override
  HomeScreenView get homeView => MangaBakaHomeView(this);

  @override
  FeedScreenView get feedView => MangaBakaFeedView(this);

  @override
  SearchScreenView get searchView => MangaBakaSearchView();

  @override
  DetailScreenView get detailView => MangaBakaDetailView(this);

  @override
  SettingsScreenView get settingsView => MangaBakaSettingsView();

  @override
  Set<String> get linkHosts => const {'mangabaka.org', 'www.mangabaka.org'};

  @override
  AppLink? parseUri(Uri uri) {
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.length < 2) return super.parseUri(uri);
    final kinds = {'manga', 'novel', 'manhwa', 'manhua', 'oel', 'series'};
    if (!kinds.contains(segments[0]) || int.tryParse(segments[1]) == null) {
      return null;
    }
    return AppLink(AppLinkKind.manga, segments[1]);
  }
}
