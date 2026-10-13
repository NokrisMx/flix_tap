import 'package:flix_tap/infrastructure/models/moviedb/movie_moviedb.dart';

class MovieDiscover {
  final int page;
  final List<MovieMovieDb> results;
  final int totalPages;
  final int totalResults;

  MovieDiscover({
    required this.page,
    required this.results,
    required this.totalPages,
    required this.totalResults,
  });

  factory MovieDiscover.fromJson(Map<String, dynamic> json) => MovieDiscover(
    page: json["page"],
    results: List<MovieMovieDb>.from(
      json["results"].map((x) => MovieMovieDb.fromJson(x)),
    ),
    totalPages: json["total_pages"],
    totalResults: json["total_results"],
  );

  Map<String, dynamic> toJson() => {
    "page": page,
    "results": List<dynamic>.from(results.map((x) => x.toJson())),
    "total_pages": totalPages,
    "total_results": totalResults,
  };
}
