import 'package:flix_tap/domain/datasources/persons_datasource.dart';
import 'package:flix_tap/domain/entities/person.dart';
import 'package:flix_tap/domain/repositories/persons_repository.dart';

class PersonRepositoryImpl extends PersonsRepository {
  final PersonsDatasource datasource;
  PersonRepositoryImpl(this.datasource);

  @override
  Future<Person> getPersonById(String personId) {
    return datasource.getPersonById(personId);
  }
}
