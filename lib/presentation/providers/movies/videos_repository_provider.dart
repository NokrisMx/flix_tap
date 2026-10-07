import 'package:flix_tap/infrastructure/datasources/video_datasource.dart';
import 'package:flix_tap/infrastructure/repositories/video_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final videosRepositoryProvider = Provider(
  (ref) => VideoRepositoryImpl(VideoDatasource()),
);
