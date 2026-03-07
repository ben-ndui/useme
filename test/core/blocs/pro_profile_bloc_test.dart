import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:useme/core/blocs/pro_profile/pro_profile_exports.dart';
import 'package:useme/core/models/app_user.dart';
import 'package:useme/core/models/pro_profile.dart';
import 'package:useme/core/services/pro_profile_service.dart';

class MockFirestore extends Mock implements FirebaseFirestore {}

void main() {
  group('ProProfileState', () {
    test('initial state has no profile', () {
      const state = ProProfileState();
      expect(state.hasProfile, isFalse);
      expect(state.isActive, isFalse);
      expect(state.isLoading, isFalse);
      expect(state.isSaving, isFalse);
      expect(state.errorMessage, isNull);
      expect(state.successMessage, isNull);
      expect(state.searchResults, isEmpty);
      expect(state.isSearching, isFalse);
    });

    test('hasProfile returns true when profile set', () {
      const state = ProProfileState(
        profile: ProProfile(displayName: 'Test'),
      );
      expect(state.hasProfile, isTrue);
    });

    test('isActive returns true when profile available', () {
      const state = ProProfileState(
        profile: ProProfile(displayName: 'Test', isAvailable: true),
      );
      expect(state.isActive, isTrue);
    });

    test('isActive returns false when profile unavailable', () {
      const state = ProProfileState(
        profile: ProProfile(displayName: 'Test', isAvailable: false),
      );
      expect(state.isActive, isFalse);
    });

    test('isActive returns false when no profile', () {
      const state = ProProfileState();
      expect(state.isActive, isFalse);
    });

    group('copyWith', () {
      test('updates profile', () {
        const state = ProProfileState();
        final updated = state.copyWith(
          profile: const ProProfile(displayName: 'New'),
        );
        expect(updated.hasProfile, isTrue);
        expect(updated.profile!.displayName, 'New');
      });

      test('clearProfile removes profile', () {
        const state = ProProfileState(
          profile: ProProfile(displayName: 'Old'),
        );
        final updated = state.copyWith(clearProfile: true);
        expect(updated.hasProfile, isFalse);
      });

      test('clearError removes error', () {
        const state = ProProfileState(errorMessage: 'error');
        final updated = state.copyWith(clearError: true);
        expect(updated.errorMessage, isNull);
      });

      test('clearSuccess removes success', () {
        const state = ProProfileState(successMessage: 'ok');
        final updated = state.copyWith(clearSuccess: true);
        expect(updated.successMessage, isNull);
      });

      test('preserves unmodified fields', () {
        const state = ProProfileState(
          profile: ProProfile(displayName: 'Keep'),
          isLoading: true,
          searchResults: [],
        );
        final updated = state.copyWith(isSaving: true);
        expect(updated.profile!.displayName, 'Keep');
        expect(updated.isLoading, isTrue);
        expect(updated.isSaving, isTrue);
      });

      test('updates search results', () {
        const state = ProProfileState();
        final users = [
          const AppUser(uid: 'u1', email: 'a@b.com'),
        ];
        final updated = state.copyWith(searchResults: users);
        expect(updated.searchResults.length, 1);
      });
    });

    group('equality', () {
      test('same states are equal', () {
        const a = ProProfileState(isLoading: true);
        const b = ProProfileState(isLoading: true);
        expect(a, equals(b));
      });

      test('different states are not equal', () {
        const a = ProProfileState(isLoading: true);
        const b = ProProfileState(isLoading: false);
        expect(a, isNot(equals(b)));
      });
    });
  });

  group('ProProfileEvent', () {
    test('ActivateProProfileEvent props', () {
      const event = ActivateProProfileEvent(
        userId: 'u1',
        profile: ProProfile(displayName: 'Test'),
      );
      expect(event.props, contains('u1'));
    });

    test('UpdateProProfileEvent props', () {
      const event = UpdateProProfileEvent(
        userId: 'u1',
        profile: ProProfile(displayName: 'Updated'),
      );
      expect(event.props, contains('u1'));
    });

    test('SetProAvailabilityEvent props', () {
      const event = SetProAvailabilityEvent(userId: 'u1', isAvailable: true);
      expect(event.props, contains('u1'));
      expect(event.props, contains(true));
    });

    test('DeactivateProProfileEvent props', () {
      const event = DeactivateProProfileEvent(userId: 'u1');
      expect(event.props, contains('u1'));
    });

    test('DeleteProProfileEvent props', () {
      const event = DeleteProProfileEvent(userId: 'u1');
      expect(event.props, contains('u1'));
    });

    test('LoadProProfileEvent props', () {
      const event = LoadProProfileEvent(userId: 'u1');
      expect(event.props, contains('u1'));
    });

    test('SearchProsEvent props', () {
      const event = SearchProsEvent(
        types: [ProType.musician],
        city: 'Paris',
        remoteOnly: true,
        textQuery: 'guitar',
      );
      expect(event.props, isNotEmpty);
    });

    test('ClearProProfileEvent has empty props', () {
      const event = ClearProProfileEvent();
      expect(event.props, isEmpty);
    });
  });

  group('ProProfileBloc', () {
    late ProProfileBloc bloc;

    setUp(() {
      bloc = ProProfileBloc(
        service: ProProfileService(firestore: MockFirestore()),
      );
    });

    tearDown(() => bloc.close());

    test('initial state is empty', () {
      expect(bloc.state.hasProfile, isFalse);
      expect(bloc.state.isLoading, isFalse);
    });

    test('ClearProProfileEvent resets state', () async {
      bloc.emit(const ProProfileState(
        profile: ProProfile(displayName: 'Test'),
        successMessage: 'ok',
      ));

      bloc.add(const ClearProProfileEvent());
      await Future.delayed(Duration.zero);

      expect(bloc.state.hasProfile, isFalse);
      expect(bloc.state.successMessage, isNull);
    });
  });
}
