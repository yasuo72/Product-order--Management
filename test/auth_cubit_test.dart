import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:product_order_app/core/network/network_exceptions.dart';
import 'package:product_order_app/features/auth/data/auth_repository.dart';
import 'package:product_order_app/features/auth/data/models/user_model.dart';
import 'package:product_order_app/features/auth/logic/auth_cubit.dart';
import 'package:product_order_app/features/auth/logic/auth_state.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late AuthRepository mockAuthRepository;
  late AuthCubit authCubit;

  const sampleUser = UserModel(
    id: 1,
    username: 'emilys',
    email: 'emily@example.com',
    firstName: 'Emily',
    lastName: 'Johnson',
    token: 'fake-jwt-token',
  );

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    authCubit = AuthCubit(mockAuthRepository);
  });

  tearDown(() {
    authCubit.close();
  });

  group('AuthCubit Tests', () {
    test('initial state is AuthInitial', () {
      expect(authCubit.state, const AuthInitial());
    });

    test('checkAuthStatus emits AuthAuthenticated when cached user exists', () {
      when(() => mockAuthRepository.getCachedUser()).thenReturn(sampleUser);

      authCubit.checkAuthStatus();

      expect(authCubit.state, const AuthAuthenticated(sampleUser));
    });

    test('checkAuthStatus emits AuthUnauthenticated when cached user does not exist', () {
      when(() => mockAuthRepository.getCachedUser()).thenReturn(null);

      authCubit.checkAuthStatus();

      expect(authCubit.state, const AuthUnauthenticated());
    });

    test('login emits [AuthLoading, AuthAuthenticated] on success', () async {
      when(() => mockAuthRepository.login(
            username: 'emilys',
            password: 'emilyspass',
          )).thenAnswer((_) async => sampleUser);

      final expectedStates = [
        const AuthLoading(),
        const AuthAuthenticated(sampleUser),
      ];

      expectLater(authCubit.stream, emitsInOrder(expectedStates));

      await authCubit.login(username: 'emilys', password: 'emilyspass');
    });

    test('login emits [AuthLoading, AuthError, AuthUnauthenticated] on failure', () async {
      when(() => mockAuthRepository.login(
            username: 'wrong',
            password: 'wrong',
          )).thenThrow(AppException('Invalid credentials or session expired.', 401));

      final expectedStates = [
        const AuthLoading(),
        const AuthError('Invalid credentials or session expired.'),
        const AuthUnauthenticated(),
      ];

      expectLater(authCubit.stream, emitsInOrder(expectedStates));

      await authCubit.login(username: 'wrong', password: 'wrong');
    });

    test('logout calls repository logout and emits AuthUnauthenticated', () async {
      when(() => mockAuthRepository.logout()).thenAnswer((_) async {});

      await authCubit.logout();

      expect(authCubit.state, const AuthUnauthenticated());
      verify(() => mockAuthRepository.logout()).called(1);
    });
  });
}
