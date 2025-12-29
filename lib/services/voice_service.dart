import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';

/// Supported languages for Aira
class AiraLanguage {
  final String code;
  final String name;
  final String ttsLocale;
  final String sttLocale;
  
  const AiraLanguage({
    required this.code,
    required this.name,
    required this.ttsLocale,
    required this.sttLocale,
  });
  
  static const english = AiraLanguage(
    code: 'en',
    name: 'English',
    ttsLocale: 'en-IN',
    sttLocale: 'en_IN',
  );
  
  static const hindi = AiraLanguage(
    code: 'hi',
    name: 'हिंदी (Hindi)',
    ttsLocale: 'hi-IN',
    sttLocale: 'hi_IN',
  );
  
  static const telugu = AiraLanguage(
    code: 'te',
    name: 'తెలుగు (Telugu)',
    ttsLocale: 'te-IN',
    sttLocale: 'te_IN',
  );
  
  static const tamil = AiraLanguage(
    code: 'ta',
    name: 'தமிழ் (Tamil)',
    ttsLocale: 'ta-IN',
    sttLocale: 'ta_IN',
  );
  
  static const kannada = AiraLanguage(
    code: 'kn',
    name: 'ಕನ್ನಡ (Kannada)',
    ttsLocale: 'kn-IN',
    sttLocale: 'kn_IN',
  );
  
  static const List<AiraLanguage> all = [
    english,
    hindi,
    telugu,
    tamil,
    kannada,
  ];
}

/// Voice service for Aira with multi-language support
class VoiceService {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  
  bool _speechEnabled = false;
  bool _isListening = false;
  bool _isSpeaking = false;
  
  AiraLanguage _currentLanguage = AiraLanguage.english;
  
  // Voice settings
  double _currentSpeed = 1.00;
  double _currentPitch = 1.15;
  Map<String, String>? _currentVoice;
  
  // Callbacks
  Function(String)? onResult;
  Function(bool)? onListeningChanged;
  Function(bool)? onSpeakingChanged;
  Function(String)? onError;
  
  /// Get current language
  AiraLanguage get currentLanguage => _currentLanguage;
  
  /// Get current speed
  double get currentSpeed => _currentSpeed;
  
  /// Get current pitch
  double get currentPitch => _currentPitch;
  
  /// Get current voice
  Map<String, String>? get currentVoice => _currentVoice;
  
  /// Update voice settings
  Future<void> updateSettings({
    Map<String, String>? voice,
    double? pitch,
    double? speed,
  }) async {
    if (speed != null) _currentSpeed = speed;
    if (pitch != null) _currentPitch = pitch;
    if (voice != null) _currentVoice = voice;
    
    await _flutterTts.setSpeechRate(_currentSpeed);
    await _flutterTts.setPitch(_currentPitch);
    
    if (_currentVoice != null) {
      await _flutterTts.setVoice(_currentVoice!);
    }
    
    debugPrint('Voice settings updated: speed=$_currentSpeed, pitch=$_currentPitch');
  }
  
  /// Initialize voice services
  Future<bool> initialize() async {
    try {
      // Request microphone permission
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        onError?.call('Microphone permission denied');
        return false;
      }
      
      // Initialize speech recognition
      _speechEnabled = await _speechToText.initialize(
        onError: (error) {
          debugPrint('Speech error: ${error.errorMsg}');
          onError?.call(error.errorMsg);
        },
        onStatus: (status) {
          debugPrint('Speech status: $status');
          if (status == 'done' || status == 'notListening') {
            _isListening = false;
            onListeningChanged?.call(false);
          }
        },
      );
      
      // Configure TTS for soft female voice
      await _configureTts();
      
      debugPrint('Voice service initialized: $_speechEnabled');
      return _speechEnabled;
    } catch (e) {
      debugPrint('Voice init error: $e');
      onError?.call('Failed to initialize voice: $e');
      return false;
    }
  }
  
  /// Set language for voice
  Future<void> setLanguage(AiraLanguage language) async {
    _currentLanguage = language;
    await _configureTts();
    debugPrint('Language set to: ${language.name}');
  }
  
  /// Configure text-to-speech for Aira's calm female voice
  Future<void> _configureTts() async {
    await _flutterTts.setLanguage(_currentLanguage.ttsLocale);
    await _flutterTts.setSpeechRate(0.65); // 1.25x speed
    await _flutterTts.setVolume(0.85);
    await _flutterTts.setPitch(1.15); // Slightly higher for warm feminine voice
    
    // Try to set a female voice if available
    if (!kIsWeb) {
      try {
        final voices = await _flutterTts.getVoices;
        if (voices != null) {
          final voiceList = voices as List;
          
          // Find female voice for current language
          final femaleVoice = voiceList.where((v) {
            final name = (v['name'] ?? '').toString().toLowerCase();
            final locale = (v['locale'] ?? '').toString().toLowerCase();
            
            final isRightLocale = locale.contains(_currentLanguage.code) ||
                                  locale.contains('in'); // Indian locales
            
            final isFemale = name.contains('female') || 
                            name.contains('woman') ||
                            // Common female voice names
                            name.contains('lekha') ||     // Hindi female
                            name.contains('aditi') ||     // Hindi female
                            name.contains('samantha') ||  // English female
                            name.contains('victoria') ||  // English female
                            name.contains('karen') ||     // English female
                            name.contains('zira') ||      // English female
                            name.contains('heera') ||     // Hindi female
                            name.contains('swati');       // Hindi female
            
            return isFemale || isRightLocale;
          }).firstOrNull;
          
          if (femaleVoice != null) {
            await _flutterTts.setVoice({
              'name': femaleVoice['name'],
              'locale': femaleVoice['locale'],
            });
            debugPrint('Set voice: ${femaleVoice['name']}');
          }
        }
      } catch (e) {
        debugPrint('Error setting voice: $e');
      }
    }
    
    _flutterTts.setStartHandler(() {
      _isSpeaking = true;
      onSpeakingChanged?.call(true);
    });
    
    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
      onSpeakingChanged?.call(false);
    });
    
    _flutterTts.setCancelHandler(() {
      _isSpeaking = false;
      onSpeakingChanged?.call(false);
    });
    
    _flutterTts.setErrorHandler((msg) {
      _isSpeaking = false;
      onSpeakingChanged?.call(false);
      onError?.call('TTS error: $msg');
    });
  }
  
  /// Check if speech recognition is available
  bool get isAvailable => _speechEnabled;
  
  /// Check if currently listening
  bool get isListening => _isListening;
  
  /// Check if currently speaking
  bool get isSpeaking => _isSpeaking;
  
  /// Start listening for speech (auto-detects language)
  Future<void> startListening() async {
    if (!_speechEnabled) {
      onError?.call('Speech recognition not available');
      return;
    }
    
    if (_isListening) return;
    
    // Stop any ongoing speech first
    await stopSpeaking();
    
    _isListening = true;
    onListeningChanged?.call(true);
    
    await _speechToText.listen(
      onResult: _handleSpeechResult,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      localeId: _currentLanguage.sttLocale,
      listenMode: ListenMode.confirmation,
    );
  }
  
  /// Stop listening
  Future<void> stopListening() async {
    if (!_isListening) return;
    
    await _speechToText.stop();
    _isListening = false;
    onListeningChanged?.call(false);
  }
  
  /// Handle speech recognition result
  void _handleSpeechResult(SpeechRecognitionResult result) {
    if (result.finalResult) {
      final text = result.recognizedWords;
      if (text.isNotEmpty) {
        onResult?.call(text);
      }
      _isListening = false;
      onListeningChanged?.call(false);
    }
  }
  
  /// Speak text aloud (Aira's response)
  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    
    // Stop listening while speaking
    await stopListening();
    
    // Clean text for speech
    final cleanText = _cleanTextForSpeech(text);
    
    await _flutterTts.speak(cleanText);
  }
  
  /// Stop speaking
  Future<void> stopSpeaking() async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      _isSpeaking = false;
      onSpeakingChanged?.call(false);
    }
  }
  
  /// Clean text for natural speech
  String _cleanTextForSpeech(String text) {
    return text
        // Remove markdown
        .replaceAll(RegExp(r'\*\*([^*]+)\*\*'), r'$1')
        .replaceAll(RegExp(r'\*([^*]+)\*'), r'$1')
        .replaceAll(RegExp(r'`([^`]+)`'), r'$1')
        .replaceAll(RegExp(r'#{1,6}\s'), '')
        // Remove URLs
        .replaceAll(RegExp(r'https?://\S+'), '')
        // Remove emojis
        .replaceAll(RegExp(r'[\u{1F300}-\u{1F9FF}]', unicode: true), '')
        // Clean up whitespace
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
  
  /// Toggle listening state
  Future<void> toggleListening() async {
    if (_isListening) {
      await stopListening();
    } else {
      await startListening();
    }
  }
  
  /// Dispose resources
  void dispose() {
    _speechToText.stop();
    _flutterTts.stop();
  }
}
