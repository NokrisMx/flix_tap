import 'package:flix_tap/domain/entities/video.dart';
import 'package:flix_tap/infrastructure/models/moviedb/videos_response.dart';

class VideoMapper {
  static Video videoToEntity(VideosResponse response) {
    return Video(
      id: response.id,
      results: response.results
          .map(
            (result) => VideoResult(
              iso6391: result.iso6391,
              iso31661: result.iso31661,
              name: result.name,
              key: result.key,
              site: result.site,
              size: result.size,
              type: result.type,
              official: result.official,
              id: result.id,
              publishedAt: result.publishedAt,
            ),
          )
          .toList(),
    );
  }
}
