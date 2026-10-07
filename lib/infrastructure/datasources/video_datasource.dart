import 'package:dio/dio.dart';
import 'package:flix_tap/config/constants/environment.dart';
import 'package:flix_tap/domain/datasources/videos_datasource.dart';
import 'package:flix_tap/domain/entities/video.dart';
import 'package:flix_tap/infrastructure/mappers/video_mapper.dart';
import 'package:flix_tap/infrastructure/models/moviedb/videos_response.dart';

class VideoDatasource extends VideosDatasource {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.themoviedb.org/3',
      queryParameters: {'api_key': Environment.movieDbKey, 'language': 'es-MX'},
    ),
  );

  @override
  Future<Video> getVideo(String movieId) async {
    final response = await dio.get('/movie/$movieId/videos');

    final videoResponse = VideosResponse.fromJson(response.data);

    return VideoMapper.videoToEntity(videoResponse);
  }
}
