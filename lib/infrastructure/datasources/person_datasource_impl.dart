import 'package:dio/dio.dart';
import 'package:flix_tap/config/constants/environment.dart';
import 'package:flix_tap/domain/datasources/persons_datasource.dart';
import 'package:flix_tap/domain/entities/person.dart';
import 'package:flix_tap/infrastructure/mappers/person_mapper.dart';
import 'package:flix_tap/infrastructure/models/moviedb/person_response.dart';

class PersonDatasourceImpl extends PersonsDatasource {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.themoviedb.org/3',
      queryParameters: {'api_key': Environment.movieDbKey, 'language': 'es-MX'},
    ),
  );

  @override
  Future<Person> getPersonById(String personId) async {
    final response = await dio.get('/person/$personId');

    if (response.statusCode != 200) {
      throw Exception('Person with id $personId');
    }

    final personDetail = PersonResponse.fromJson(response.data);
    return PersonMapper.personResponseToEntity(personDetail);
  }
}
