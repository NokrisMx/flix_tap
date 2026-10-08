import 'package:flix_tap/domain/entities/person.dart';
import 'package:flix_tap/infrastructure/models/moviedb/person_response.dart';

class PersonMapper {
  static Person personResponseToEntity(PersonResponse pr) => Person(
    adult: pr.adult,
    alsoKnownAs: pr.alsoKnownAs,
    biography: pr.biography,
    birthday: pr.birthday!,
    deathday: pr.deathday,
    gender: pr.gender,
    homepage: pr.homepage,
    id: pr.id,
    imdbId: pr.imdbId,
    knownForDepartment: pr.knownForDepartment,
    name: pr.name,
    placeOfBirth: pr.placeOfBirth,
    popularity: pr.popularity,
    profilePath: pr.profilePath.isNotEmpty
        ? 'https://image.tmdb.org/t/p/w500${pr.profilePath}'
        : '',
  );
}
