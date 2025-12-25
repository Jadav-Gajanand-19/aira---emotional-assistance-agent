import 'dart:convert';
import 'package:http/http.dart' as http;

/// Authentication service for user signup/login
/// 
/// For now, this uses simple local storage simulation.
/// In production, connect to a real authentication backend.
class AuthService {
  // Backend URL (same as chat service)
  static const String baseUrl = 'https://aira-api.onrender.com';
  
  // Current user data (in-memory for demo)
  static Map<String, dynamic>? _currentUser;
  
  // Simulated user database (for demo - replace with real auth)
  static final Map<String, Map<String, dynamic>> _users = {};
  
  /// Register a new user
  Future<bool> register(String name, String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Check if user exists
    if (_users.containsKey(email.toLowerCase())) {
      return false; // User already exists
    }
    
    // Create new user
    _users[email.toLowerCase()] = {
      'name': name,
      'email': email.toLowerCase(),
      'password': password, // In production, hash this!
      'createdAt': DateTime.now().toIso8601String(),
    };
    
    _currentUser = _users[email.toLowerCase()];
    return true;
  }
  
  /// Login existing user
  Future<bool> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    final user = _users[email.toLowerCase()];
    
    if (user == null || user['password'] != password) {
      return false; // Invalid credentials
    }
    
    _currentUser = user;
    return true;
  }
  
  /// Check if user is logged in
  bool get isLoggedIn => _currentUser != null;
  
  /// Get current user
  Map<String, dynamic>? get currentUser => _currentUser;
  
  /// Get current user's name
  String? get userName => _currentUser?['name'];
  
  /// Get current user's email (used as user_id for chat)
  String? get userEmail => _currentUser?['email'];
  
  /// Logout
  void logout() {
    _currentUser = null;
  }
}
