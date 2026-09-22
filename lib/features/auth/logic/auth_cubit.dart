import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/network_exceptions.dart';
import '../data/auth_repository.dart';
import '../data/models/user_model.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(const AuthInitial());

  void checkAuthStatus() {
    final cachedUser = _authRepository.getCachedUser();
    if (cachedUser != null) {
      emit(AuthAuthenticated(cachedUser));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.login(
        username: username,
        password: password,
      );
      emit(AuthAuthenticated(user));
    } on AppException catch (e) {
      emit(AuthError(e.message));
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Failed to login: ${e.toString()}'));
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    emit(const AuthUnauthenticated());
  }

  void handleSessionExpired() {
    _authRepository.logout();
    emit(const AuthUnauthenticated('Session expired. Please log in again.'));
  }

  UserModel? get currentUser {
    final s = state;
    if (s is AuthAuthenticated) return s.user;
    return _authRepository.getCachedUser();
  }
}
