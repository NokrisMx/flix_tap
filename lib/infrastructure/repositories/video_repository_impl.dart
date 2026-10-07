import 'package:flix_tap/domain/datasources/videos_datasource.dart';
import 'package:flix_tap/domain/entities/video.dart';
import 'package:flix_tap/domain/repositories/videos_repository.dart';

class VideoRepositoryImpl extends VideosRepository {
  final VideosDatasource datasource;

  VideoRepositoryImpl(this.datasource);

  @override
  Future<Video> getVideo(String movieId) {
    return datasource.getVideo(movieId);
  }
}
