import 'package:flutter/foundation.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/session/auth_session.dart';
import 'auth_state.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository;
  final AuthSession _session;

  AuthState _state = const AuthState();
  AuthState get state => _state;

  AuthViewModel(this._repository, this._session);

  Future<void> login(String username, String password) async {
    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    try {
      final user = await _repository.login(username, password);
      await _session.saveSession(user);
      _state = _state.copyWith(isLoading: false);
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await _session.logout();
    _state = const AuthState();
    notifyListeners();
  }
}
