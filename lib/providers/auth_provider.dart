import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/player_model.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

// User type enum for login selection
enum UserType { player, agent, recruiter, guest }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.initial;
  UserModel? _currentUser;
  PlayerModel? _currentPlayerProfile;
  String? _errorMessage;
  UserType _selectedUserType = UserType.player;

  AuthStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  PlayerModel? get currentPlayerProfile => _currentPlayerProfile;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;
  UserType get selectedUserType => _selectedUserType;
  bool get isGuest => _selectedUserType == UserType.guest;

  void setUserType(UserType type) {
    _selectedUserType = type;
    notifyListeners();
  }

  // Demo credentials for each user type
  static const Map<String, Map<String, String>> demoCredentials = {
    'player': {'email': 'player@spora.com', 'password': 'player123', 'name': 'Lucas Martin'},
    'agent': {'email': 'agent@spora.com', 'password': 'agent123', 'name': 'Marie Dubois - Agent'},
    'recruiter': {'email': 'recruiter@spora.com', 'password': 'recruiter123', 'name': 'Jean Claude - Recruteur'},
    'guest': {'email': 'guest@spora.com', 'password': 'guest123', 'name': 'Invité'},
  };

  Future<void> login(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    // No backend yet: any valid-looking credentials are accepted.
    // The demo accounts above simply map to nicer display names/avatars.
    if (password.length < 8 || !email.contains('@')) {
      _errorMessage = 'Email ou mot de passe invalide';
      _status = AuthStatus.error;
      notifyListeners();
      return;
    }

    // Infer the role from a known demo e-mail, else keep the chosen type.
    for (final entry in demoCredentials.entries) {
      if (entry.value['email'] == email) {
        _selectedUserType = UserType.values.byName(entry.key);
      }
    }
    final creds = demoCredentials[_selectedUserType.name];
    final isDemo = creds != null && email == creds['email'];
    _currentUser = UserModel(
      id: '${_selectedUserType.name}_${DateTime.now().millisecondsSinceEpoch}',
      name: isDemo ? creds['name']! : email.split('@').first,
      email: email,
      role: _getUserRole(),
      avatarUrl: 'https://i.pravatar.cc/200?u=$email',
      subscription: _selectedUserType == UserType.guest
          ? SubscriptionType.free
          : SubscriptionType.premium,
      createdAt: DateTime(2024, 1, 15),
    );
    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  // Quick login with demo credentials for selected user type
  Future<void> loginWithDemoCredentials() async {
    final creds = demoCredentials[_selectedUserType.name];
    if (creds != null) {
      await login(creds['email']!, creds['password']!);
    }
  }

  UserRole _getUserRole() {
    switch (_selectedUserType) {
      case UserType.player:
        return UserRole.player;
      case UserType.agent:
        return UserRole.agent;
      case UserType.recruiter:
        return UserRole.recruiter;
      case UserType.guest:
        return UserRole.player; // Guest gets player role but with limited access
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    _currentUser = UserModel(
      id: 'user_new_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      role: role,
      subscription: SubscriptionType.free,
      createdAt: DateTime.now(),
    );
    _status = AuthStatus.authenticated;
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _currentUser = null;
    _currentPlayerProfile = null;
    _status = AuthStatus.unauthenticated;
    _selectedUserType = UserType.player;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
