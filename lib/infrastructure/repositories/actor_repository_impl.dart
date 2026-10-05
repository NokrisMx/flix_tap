import 'package:flix_tap/domain/datasources/actors_datasource.dart';
import 'package:flix_tap/domain/entities/actor.dart';
import 'package:flix_tap/domain/repositories/actors_repository.dart';

class ActorRepositoryImpl extends ActorsRepository {
  final ActorsDatasource datasource;
  ActorRepositoryImpl(this.datasource);

  @override
  Future<List<Actor>> getActorsByMovie(String movieId) {
    return datasource.getActorsByMovie(movieId);
  }
}
