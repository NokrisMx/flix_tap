import 'package:flix_tap/domain/entities/video.dart';

abstract class VideosDatasource {
  Future<Video> getVideo(String movieId);
}
