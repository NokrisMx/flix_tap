import 'package:flix_tap/domain/entities/person.dart';
import 'package:flix_tap/infrastructure/datasources/person_datasource_impl.dart';
import 'package:flix_tap/infrastructure/repositories/person_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final personsRepositoryProvider = Provider((ref) {
  return PersonRepositoryImpl(PersonDatasourceImpl());
});

final personInfoProvider =
    StateNotifierProvider<PersonMapNotifier, Map<String, Person>>((ref) {
      final personsRepository = ref.watch(personsRepositoryProvider);

      return PersonMapNotifier(getPerson: personsRepository.getPersonById);
    });

typedef GetPersonCallback = Future<Person> Function(String personId);

class PersonMapNotifier extends StateNotifier<Map<String, Person>> {
  final GetPersonCallback getPerson;

  PersonMapNotifier({required this.getPerson}) : super({});

  Future<void> loadPerson(String personId) async {
    if (state[personId] != null) return;

    final person = await getPerson(personId);
    state = {...state, personId: person};
  }
}
