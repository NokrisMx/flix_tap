class VideosResponse {
  final int id;
  final List<Result> results;

  VideosResponse({required this.id, required this.results});

  factory VideosResponse.fromJson(Map<String, dynamic> json) => VideosResponse(
    id: json["id"],
    results: List<Result>.from(json["results"].map((x) => Result.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "results": List<dynamic>.from(results.map((x) => x.toJson())),
  };
}

class Result {
  final String iso6391;
  final String iso31661;
  final String name;
  final String key;
  final String site;
  final int size;
  final String type;
  final bool official;
  final String id;
  final DateTime publishedAt;

  Result({
    required this.iso6391,
    required this.iso31661,
    required this.name,
    required this.key,
    required this.site,
    required this.size,
    required this.type,
    required this.official,
    required this.id,
    required this.publishedAt,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    iso6391: json["iso_639_1"] ?? '',
    iso31661: json["iso_3166_1"] ?? '',
    name: json["name"] ?? '',
    key: json["key"] ?? '',
    site: json["site"] ?? '',
    size: json["size"] ?? 0,
    type: json["type"] ?? '',
    official: json["official"] ?? false,
    id: json["id"] ?? '',
    publishedAt: DateTime.parse(json["published_at"]),
  );

  Map<String, dynamic> toJson() => {
    "iso_639_1": iso6391,
    "iso_3166_1": iso31661,
    "name": name,
    "key": key,
    "site": site,
    "size": size,
    "type": type,
    "official": official,
    "id": id,
    "published_at": publishedAt.toIso8601String(),
  };
}
