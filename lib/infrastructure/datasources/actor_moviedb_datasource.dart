import 'package:dio/dio.dart';
import 'package:flix_tap/config/constants/environment.dart';
import 'package:flix_tap/domain/datasources/actors_datasource.dart';
import 'package:flix_tap/domain/entities/actor.dart';
import 'package:flix_tap/infrastructure/mappers/actor_mapper.dart';
import 'package:flix_tap/infrastructure/models/moviedb/credits_response.dart';

class ActorMovieDbDatasource extends ActorsDatasource {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.themoviedb.org/3',
      queryParameters: {'api_key': Environment.movieDbKey, 'language': 'es-MX'},
    ),
  );

  @override
  Future<List<Actor>> getActorsByMovie(String movieId) async {
    final response = await dio.get('/movie/$movieId/credits');

    final castResponse = CreditsResponse.fromJson(response.data);

    List<Actor> actors = castResponse.cast
        .map((cast) => ActorMapper.castToEntity(cast))
        .toList();

    return actors;
  }
}
