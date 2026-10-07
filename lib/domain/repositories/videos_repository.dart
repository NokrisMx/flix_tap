import 'package:flix_tap/domain/entities/video.dart';

abstract class VideosRepository {
  Future<Video> getVideo(String movieId);
}
