import 'package:dantotsu/DataClass/Media.dart';
import 'package:dantotsu/DataClass/SearchResults.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../Preferences/PrefManager.dart';
import '../../Preferences/Preferences.dart';
import '../../Services/Api/Queries.dart';
import 'Data/data.dart';
import 'Mal.dart';
import 'MalQueries/MalStrings.dart';

part 'MalQueries/GetAnimeMangaListData.dart';

class MalQueries extends Queries {
  Future<T?> Function<T>(
    String url, {
    Map<String, String>? headers,
    bool withNoHeaders,
    bool force,
    bool useToken,
    bool includeNsfw,
    bool show,
  }) externalQuery;

  MalQueries(this.externalQuery);

  @override
  Future<Map<String, List<Media>>> getAnimeList() => _getAnimeList();

  @override
  Future<List<String?>> getBannerImages() {
    // TODO: implement getBannerImages
    throw UnimplementedError();
  }

  @override
  Future<List<Media>> getCalendarData() {
    // TODO: implement getCalendarData
    throw UnimplementedError();
  }

  @override
  Future<bool>? getGenresAndTags() {
    // TODO: implement getGenresAndTags
    throw UnimplementedError();
  }

  @override
  Future<Map<String, List<Media>>> getMangaList() => _getMangaList();

  Future<List<Media>> getTrending({String? year, String? season}) => _getTrending(year: year, season: season);

  Future<List<Media>> loadNextPage(String type, int page) => _loadNextPage(type, page);

  @override
  Future<Media?>? getMedia(int id, {bool mal = true}) {
    // TODO: implement getMedia
    throw UnimplementedError();
  }

  @override
  Future<Map<String, List<Media>>> getMediaLists(
      {required bool anime, required int userId, String? sortOrder}) {
    // TODO: implement getMediaLists
    throw UnimplementedError();
  }

  @override
  Future<bool>? getUserData() {
    return null;
  }

  @override
  Future<Map<String, List<Media>>>? initHomePage() {
    // TODO: implement initHomePage
    throw UnimplementedError();
  }

  @override
  Future<Media?>? mediaDetails(Media media) {
    // TODO: implement mediaDetails
    throw UnimplementedError();
  }

  @override
  Future<SearchResults?> search(
      {required String type,
      int? page,
      int? perPage,
      String? search,
      String? sort,
      List<String>? genres,
      List<String>? tags,
      String? status,
      String? source,
      String? format,
      String? countryOfOrigin,
      bool isAdult = false,
      bool? onList,
      List<String>? excludedGenres,
      List<String>? excludedTags,
      int? startYear,
      int? seasonYear,
      String? season,
      int? id,
      bool hd = false}) {
    // TODO: implement search
    throw UnimplementedError();
  }


}
