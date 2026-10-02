import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flix_tap/infrastructure/datasources/moviedb_datasource.dart';
import 'package:flix_tap/infrastructure/repositories/movie_repository_impl.dart';

//Este repositorio es inmutable, por lo que no es necesario usar un StateNotifierProvider. Un Provider es suficiente para exponerlo a la aplicación.
final movieRepositoryProvider = Provider(
  (ref) => MovieRepositoryImpl(MoviedbDatasource()),
);
