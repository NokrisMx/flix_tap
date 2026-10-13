class Genres {
  final List<Genre> genres;

  Genres({required this.genres});

  factory Genres.fromJson(Map<String, dynamic> json) => Genres(
    genres: List<Genre>.from(json["genres"].map((x) => Genre.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "genres": List<dynamic>.from(genres.map((x) => x.toJson())),
  };
}

class Genre {
  final int id;
  final String name;

  Genre({required this.id, required this.name});

  factory Genre.fromJson(Map<String, dynamic> json) =>
      Genre(id: json["id"] ?? 0, name: json["name"] ?? '');

  Map<String, dynamic> toJson() => {"id": id, "name": name};
}
