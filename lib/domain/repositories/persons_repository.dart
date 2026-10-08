import 'package:flix_tap/domain/entities/person.dart';

abstract class PersonsRepository {
  Future<Person> getPersonById(String personId);
}
