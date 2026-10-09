import '../../../Core/Preferences/PrefManager.dart';
import '../../../Core/Services/LayoutPref.dart';

const kSimklHomeSections = <String, bool>{
  'Continue Watching': true,
  'Plan to Watch': true,
  'On Hold': true,
  'Dropped': true,
};

const kSimklAnimeSections = <String, bool>{
  'Trending Now': true,
  'Trending This Week': true,
  'Most Watched This Month': true,
  'Airing Now': true,
  'Top Rated Series': true,
  'Top Movies': true,
  'Top ONA': true,
  'Most Popular': true,
};

const kSimklMovieSections = <String, bool>{
  'Trending Movies Today': true,
  'Trending Shows Today': true,
  'Trending Movies This Week': true,
  'Trending Shows This Week': true,
  'Most Watched Movies This Month': true,
  'Most Watched Shows This Month': true,
  'Top Rated Movies': true,
  'Top Rated Shows': true,
};

class SimklPref {
  SimklPref._();

  static const token = Pref('simklToken', '', PrefLocation.PROTECTED);
  static const refresh = Pref('simklRefreshToken', '', PrefLocation.PROTECTED);
  static const expiresAt = Pref<int>(
    'simklTokenExpires',
    0,
    PrefLocation.PROTECTED,
  );

  static final homeLayout = layoutPref('simklHomeLayout', kSimklHomeSections);
  static final animeLayout = layoutPref(
    'simklAnimeLayout',
    kSimklAnimeSections,
  );
  static final movieLayout = layoutPref(
    'simklMovieLayout',
    kSimklMovieSections,
  );
}
