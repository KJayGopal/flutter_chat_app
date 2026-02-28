import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;

  // Check if logged in
  bool get isLoggedIn => currentUser != null;

  // User metadata helpers
  String? get userId => currentUser?.id;
  String? get userName => currentUser?.userMetadata?['full_name'];
  String? get email => currentUser?.email;
  String? get avatarUrl => currentUser?.userMetadata?['avatar_url'];

  // Listen to auth state changes
  void onAuthStateChange(void Function(Session? session) callback) {
    _supabase.auth.onAuthStateChange.listen((data) {
      callback(data.session);
    });
  }

  // Refresh session (if needed)
  Future<void> refreshSession() async {
    final session = _supabase.auth.currentSession;
    if (session != null) {
      await _supabase.auth.refreshSession();
    }
  }

  // Sign In with email and password
  Future<AuthResponse> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign In with Google OAuth
  Future<void> signInWithGoogle() async {
    await _supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: kIsWeb
          ? "http://localhost:3334"
          : 'io.supabase.flutter://login-callback',
    );
  }

  // Sign up with email and password
  Future<AuthResponse> signUpWithEmailPassword(
    String email,
    String password,
  ) async {
    return await _supabase.auth.signUp(email: email, password: password);
  }

  // Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  //Get user email, username, session
  String? getCurrentUserEmail() {
    final session = _supabase.auth.currentSession;
    final user = session?.user;
    return user?.email;
  }
}
