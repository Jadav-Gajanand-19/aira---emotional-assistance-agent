import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

/// Chat service for communicating with the Aira backend API.
/// 
/// This service handles:
/// - Sending messages to the API
/// - Receiving and parsing responses
/// - Session management for conversation continuity
/// - Health checks for connection verification
class ChatService {
  /// Base URL for the Aira API
  /// ⚠️ Replace with your Railway URL after deployment
  /// Example: 'https://aira-backend-production.up.railway.app'
  static const String baseUrl = 'https://aiera-backend.onrender.com'; // Render deployed
  // static const String baseUrl = 'http://10.0.2.2:8000'; // Android emulator
  // static const String baseUrl = 'https://your-app.up.railway.app'; // Production
  
  /// Session ID for conversation continuity
  final String sessionId;
  
  /// Optional user ID for personalization
  final String? userId;
  
  /// HTTP client for making requests
  final http.Client _client;
  
  /// Create a new ChatService instance
  /// 
  /// [sessionId] - Optional existing session ID. If not provided, a new one is generated.
  /// [userId] - Optional user identifier for personalization
  ChatService({
    String? sessionId,
    this.userId,
    http.Client? client,
  }) : 
    sessionId = sessionId ?? const Uuid().v4(),
    _client = client ?? http.Client();
  
  /// Send a message to Aira and receive a response
  /// 
  /// [message] - The user's message
  /// [language] - Optional language code for response (en, hi, te, etc.)
  /// 
  /// Returns a [ChatResponse] containing Aira's reply
  /// Throws an exception if the request fails
  Future<ChatResponse> sendMessage(String message, {String? language}) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': message,
          'session_id': sessionId,
          'user_id': userId,
          'language': language ?? 'en',
        }),
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ChatResponse(
          message: data['response'] ?? '',
          sessionId: data['session_id'] ?? sessionId,
          isCrisis: data['is_crisis'] ?? false,
        );
      } else if (response.statusCode == 500) {
        throw ChatException(
          'Aira is having trouble responding. Please try again.',
          statusCode: 500,
        );
      } else {
        throw ChatException(
          'Unable to connect to Aira.',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ChatException) rethrow;
      throw ChatException(
        'Connection error. Please check your internet connection.',
      );
    }
  }
  
  /// Check if the Aira API is healthy and reachable
  /// 
  /// Returns true if the API is accessible, false otherwise
  Future<bool> checkHealth() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/health'),
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  /// Dispose of the HTTP client when done
  void dispose() {
    _client.close();
  }
}

/// Response from the Aira chat API
class ChatResponse {
  /// Aira's response message
  final String message;
  
  /// Session ID for this conversation
  final String sessionId;
  
  /// Whether crisis support was triggered
  final bool isCrisis;
  
  ChatResponse({
    required this.message,
    required this.sessionId,
    this.isCrisis = false,
  });
}

/// Exception for chat-related errors
class ChatException implements Exception {
  /// User-friendly error message
  final String message;
  
  /// HTTP status code (if applicable)
  final int? statusCode;
  
  ChatException(this.message, {this.statusCode});
  
  @override
  String toString() => message;
}

/// A message in the chat history
class Message {
  /// The message text
  final String text;
  
  /// Whether this message is from the user (true) or Aira (false)
  final bool isUser;
  
  /// Timestamp of the message
  final DateTime timestamp;
  
  /// Whether this message triggered crisis support
  final bool isCrisis;
  
  Message({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.isCrisis = false,
  }) : timestamp = timestamp ?? DateTime.now();
}
