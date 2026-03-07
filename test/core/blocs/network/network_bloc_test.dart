import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:useme/core/blocs/network/network_bloc.dart';
import 'package:useme/core/blocs/network/network_event.dart';
import 'package:useme/core/blocs/network/network_state.dart';
import 'package:useme/core/models/user_contact.dart';
import 'package:useme/core/services/network_service.dart';

class MockNetworkService extends Mock implements NetworkService {}

void main() {
  late MockNetworkService mockService;

  setUp(() {
    mockService = MockNetworkService();
  });

  group('NetworkBloc', () {
    test('initial state is empty NetworkState', () {
      final bloc = NetworkBloc(networkService: mockService);
      addTearDown(bloc.close);

      expect(bloc.state, const NetworkState());
      expect(bloc.state.contacts, isEmpty);
      expect(bloc.state.searchResults, isEmpty);
      expect(bloc.state.isLoading, false);
      expect(bloc.state.isSearching, false);
    });

    blocTest<NetworkBloc, NetworkState>(
      'ContactsUpdatedEvent updates contacts',
      build: () => NetworkBloc(networkService: mockService),
      act: (bloc) => bloc.add(ContactsUpdatedEvent(contacts: [
        UserContact(
          id: 'c1',
          ownerId: 'o1',
          contactName: 'Test',
          category: ContactCategory.artist,
          createdAt: DateTime(2024),
        ),
      ])),
      expect: () => [
        isA<NetworkState>()
            .having((s) => s.contacts.length, 'contacts length', 1)
            .having((s) => s.contacts.first.contactName, 'name', 'Test'),
      ],
    );

    blocTest<NetworkBloc, NetworkState>(
      'ClearNetworkEvent resets state',
      build: () => NetworkBloc(networkService: mockService),
      seed: () => NetworkState(contacts: [
        UserContact(
          id: 'c1',
          ownerId: 'o1',
          contactName: 'Test',
          category: ContactCategory.artist,
          createdAt: DateTime(2024),
        ),
      ]),
      act: (bloc) => bloc.add(const ClearNetworkEvent()),
      expect: () => [const NetworkState()],
    );

    blocTest<NetworkBloc, NetworkState>(
      'SearchUsersEvent with short query clears results',
      build: () => NetworkBloc(networkService: mockService),
      act: (bloc) => bloc.add(const SearchUsersEvent(query: 'a')),
      expect: () => [
        isA<NetworkState>()
            .having((s) => s.searchResults, 'results', isEmpty)
            .having((s) => s.isSearching, 'isSearching', false),
      ],
    );

    blocTest<NetworkBloc, NetworkState>(
      'SearchUsersEvent with valid query searches users',
      build: () {
        when(() => mockService.searchUsers('test'))
            .thenAnswer((_) async => []);
        return NetworkBloc(networkService: mockService);
      },
      act: (bloc) => bloc.add(const SearchUsersEvent(query: 'test')),
      expect: () => [
        isA<NetworkState>()
            .having((s) => s.isSearching, 'isSearching', true),
        isA<NetworkState>()
            .having((s) => s.isSearching, 'isSearching', false)
            .having((s) => s.searchResults, 'results', isEmpty),
      ],
    );
  });

  group('NetworkState', () {
    test('getByCategory filters correctly', () {
      final state = NetworkState(contacts: [
        UserContact(
          id: '1',
          ownerId: 'o',
          contactName: 'A',
          category: ContactCategory.artist,
          createdAt: DateTime(2024),
        ),
        UserContact(
          id: '2',
          ownerId: 'o',
          contactName: 'E',
          category: ContactCategory.engineer,
          createdAt: DateTime(2024),
        ),
        UserContact(
          id: '3',
          ownerId: 'o',
          contactName: 'A2',
          category: ContactCategory.artist,
          createdAt: DateTime(2024),
        ),
      ]);

      expect(state.getByCategory(ContactCategory.artist).length, 2);
      expect(state.getByCategory(ContactCategory.engineer).length, 1);
      expect(state.getByCategory(ContactCategory.studio).length, 0);
    });

    test('onPlatform and offPlatform filter correctly', () {
      final state = NetworkState(contacts: [
        UserContact(
          id: '1',
          ownerId: 'o',
          contactName: 'A',
          category: ContactCategory.artist,
          isOnPlatform: true,
          createdAt: DateTime(2024),
        ),
        UserContact(
          id: '2',
          ownerId: 'o',
          contactName: 'B',
          category: ContactCategory.artist,
          isOnPlatform: false,
          createdAt: DateTime(2024),
        ),
      ]);

      expect(state.onPlatform.length, 1);
      expect(state.offPlatform.length, 1);
      expect(state.onPlatform.first.contactName, 'A');
      expect(state.offPlatform.first.contactName, 'B');
    });

    test('copyWith creates modified copy', () {
      const state = NetworkState(isLoading: true);
      final updated = state.copyWith(isLoading: false, isSearching: true);

      expect(updated.isLoading, false);
      expect(updated.isSearching, true);
    });
  });
}
