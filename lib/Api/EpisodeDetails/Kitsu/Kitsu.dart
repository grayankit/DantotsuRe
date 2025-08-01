import 'dart:convert';

import 'package:dartotsu_extension_bridge/dartotsu_extension_bridge.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';

import '../../../DataClass/Media.dart';

part 'Kitsu.g.dart';

class Kitsu {
  static Future<Map<String, DEpisode>?> getKitsuEpisodesDetails(
      Media mediaData) async {
    if (mediaData.idAnilist == null && mediaData.idMAL == null) return {};

    final externalId = mediaData.idAnilist ?? mediaData.idMAL;
    final externalSite =
        mediaData.idAnilist != null ? 'ANILIST_ANIME' : 'MYANIMELIST_ANIME';

    final query = '''
      query {
        lookupMapping(externalId: $externalId, externalSite: $externalSite) {
          __typename
          ... on Anime {
            id
            episodes(first: 2000) {
              nodes {
                number
                titles {
                  canonicalLocale
                }
                description
                thumbnail {
                  original {
                    url
                  }
                }
              }
            }
          }
        }
      }
    ''';

    final result = (await getKitsuData(query))?.data?.lookupMapping;
    if (result == null) return null;

    mediaData.idKitsu = result.id;

    final nodes = result.episodes?.nodes;
    if (nodes == null) return {};

    return Map.fromEntries(
      nodes.map((ep) {
        final number = ep?.number?.toString() ?? '';
        return MapEntry(
          number,
          DEpisode(
            episodeNumber: number,
            name: ep?.titles?.canonical,
            description: ep?.description?.en,
            thumbnail: ep?.thumbnail?.original?.url,
          ),
        );
      }),
    );
  }

  static Future<String?> decodeToString(http.Response? res) async {
    if (res == null) return null;

    if (res.headers['content-encoding'] == 'gzip') {
      return utf8.decode(res.bodyBytes);
    } else {
      return res.body;
    }
  }

  static Future<KitsuResponse?> getKitsuData(String query) async {
    final headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
    };

    try {
      final response = await http.post(
        Uri.parse('https://kitsu.io/api/graphql'),
        headers: headers,
        body: jsonEncode({"query": query}),
      );
      final json = await decodeToString(response);
      return KitsuResponse.fromJson(jsonDecode(json!));
    } catch (e) {
      debugPrint("Error fetching Kitsu data: $e");
      return null;
    }
  }
}

@JsonSerializable()
class KitsuResponse {
  final Data? data;

  KitsuResponse({this.data});

  factory KitsuResponse.fromJson(Map<String, dynamic> json) =>
      _$KitsuResponseFromJson(json);

  Map<String, dynamic> toJson() => _$KitsuResponseToJson(this);
}

@JsonSerializable()
class Data {
  final LookupMapping? lookupMapping;

  Data({this.lookupMapping});

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);

  Map<String, dynamic> toJson() => _$DataToJson(this);
}

@JsonSerializable()
class LookupMapping {
  final String? id;
  final Episodes? episodes;

  LookupMapping({this.id, this.episodes});

  factory LookupMapping.fromJson(Map<String, dynamic> json) =>
      _$LookupMappingFromJson(json);

  Map<String, dynamic> toJson() => _$LookupMappingToJson(this);
}

@JsonSerializable()
class Episodes {
  final List<Node?>? nodes;

  Episodes({this.nodes});

  factory Episodes.fromJson(Map<String, dynamic> json) =>
      _$EpisodesFromJson(json);

  Map<String, dynamic> toJson() => _$EpisodesToJson(this);
}

@JsonSerializable()
class Node {
  final int? number;
  final Titles? titles;
  final Description? description;
  final Thumbnail? thumbnail;

  Node({this.number, this.titles, this.description, this.thumbnail});

  factory Node.fromJson(Map<String, dynamic> json) => _$NodeFromJson(json);

  Map<String, dynamic> toJson() => _$NodeToJson(this);
}

@JsonSerializable()
class Description {
  final String? en;

  Description({this.en});

  factory Description.fromJson(Map<String, dynamic> json) =>
      _$DescriptionFromJson(json);

  Map<String, dynamic> toJson() => _$DescriptionToJson(this);
}

@JsonSerializable()
class Thumbnail {
  final Original? original;

  Thumbnail({this.original});

  factory Thumbnail.fromJson(Map<String, dynamic> json) =>
      _$ThumbnailFromJson(json);

  Map<String, dynamic> toJson() => _$ThumbnailToJson(this);
}

@JsonSerializable()
class Original {
  final String? url;

  Original({this.url});

  factory Original.fromJson(Map<String, dynamic> json) =>
      _$OriginalFromJson(json);

  Map<String, dynamic> toJson() => _$OriginalToJson(this);
}

@JsonSerializable()
class Titles {
  final String? canonical;

  Titles({this.canonical});

  factory Titles.fromJson(Map<String, dynamic> json) => _$TitlesFromJson(json);

  Map<String, dynamic> toJson() => _$TitlesToJson(this);
}
