import 'package:flix_tap/domain/entities/person.dart';

abstract class PersonsDatasource {
  Future<Person> getPersonById(String personId);
}
