import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/aira_theme.dart';
import '../services/chat_service.dart';
import '../services/voice_service.dart';
import '../widgets/message_bubble.dart';
import 'voice_settings_screen.dart';

/// Aira Chat Screen
/// 
/// A calm, supportive chat interface with:
/// - Voice input (microphone)
/// - Voice output (speaker)
/// - Soft background and animations
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final VoiceService _voiceService = VoiceService();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  
  final List<Message> _messages = [];
  bool _isLoading = false;
  bool _isConnected = true;
  bool _isListening = false;
  bool _isSpeaking = false;
  bool _voiceEnabled = false;
  bool _autoSpeak = true; // Auto-speak Aira's responses
  AiraLanguage _currentLanguage = AiraLanguage.english;
  
  @override
  void initState() {
    super.initState();
    _checkConnection();
    _addWelcomeMessage();
    _initVoice();
  }
  
  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _chatService.dispose();
    _voiceService.dispose();
    super.dispose();
  }
  
  /// Initialize voice services
  Future<void> _initVoice() async {
    _voiceService.onResult = (text) {
      setState(() {
        _textController.text = text;
      });
      // Auto-send after voice input
      _sendMessage();
    };
    
    _voiceService.onListeningChanged = (isListening) {
      if (mounted) {
        setState(() => _isListening = isListening);
      }
    };
    
    _voiceService.onSpeakingChanged = (isSpeaking) {
      if (mounted) {
        setState(() => _isSpeaking = isSpeaking);
      }
    };
    
    _voiceService.onError = (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error, style: GoogleFonts.nunito()),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    };
    
    final enabled = await _voiceService.initialize();
    if (mounted) {
      setState(() => _voiceEnabled = enabled);
    }
  }
  
  /// Check API connection on startup
  Future<void> _checkConnection() async {
    final isHealthy = await _chatService.checkHealth();
    if (mounted) {
      setState(() => _isConnected = isHealthy);
    }
  }
  
  /// Add Aira's welcome message
  void _addWelcomeMessage() {
    _messages.add(Message(
      text: "Hi, I'm here with you. Take your time — there's no rush. How are you feeling right now?",
      isUser: false,
    ));
  }
  
  /// Send a message to Aira
  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isLoading) return;
    
    _textController.clear();
    _focusNode.unfocus();
    
    setState(() {
      _messages.add(Message(text: text, isUser: true));
      _isLoading = true;
    });
    
    _scrollToBottom();
    
    try {
      final response = await _chatService.sendMessage(
        text,
        language: _currentLanguage.code,
      );
      
      if (mounted) {
        setState(() {
          _messages.add(Message(
            text: response.message,
            isUser: false,
            isCrisis: response.isCrisis,
          ));
          _isLoading = false;
        });
        _scrollToBottom();
        
        // Auto-speak Aira's response
        if (_autoSpeak && _voiceEnabled) {
          await _voiceService.speak(response.message);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(Message(
            text: "I'm having trouble connecting right now. Please try again in a moment.",
            isUser: false,
          ));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }
  
  /// Toggle voice input
  Future<void> _toggleVoiceInput() async {
    if (_isListening) {
      await _voiceService.stopListening();
    } else {
      await _voiceService.startListening();
    }
  }
  
  /// Speak the last message
  Future<void> _speakLastMessage() async {
    if (_messages.isNotEmpty) {
      final lastAiraMessage = _messages.lastWhere(
        (m) => !m.isUser,
        orElse: () => _messages.last,
      );
      await _voiceService.speak(lastAiraMessage.text);
    }
  }
  
  /// Scroll to the bottom of the chat
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AiraTheme.background,
      appBar: AppBar(
        backgroundColor: AiraTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          color: AiraTheme.textSecondary,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AiraTheme.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.eco_outlined,
                size: 18,
                color: AiraTheme.primary,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              "Aira",
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AiraTheme.textPrimary,
              ),
            ),
            if (_isSpeaking) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.volume_up,
                size: 16,
                color: AiraTheme.primary,
              )
              .animate(onComplete: (c) => c.repeat())
              .fadeIn()
              .then()
              .fadeOut(),
            ],
          ],
        ),
        centerTitle: true,
        actions: [
          // Language selector
          PopupMenuButton<AiraLanguage>(
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.language,
                  size: 18,
                  color: AiraTheme.primary,
                ),
                const SizedBox(width: 2),
                Text(
                  _currentLanguage.code.toUpperCase(),
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AiraTheme.primary,
                  ),
                ),
              ],
            ),
            tooltip: 'Change language',
            onSelected: (language) {
              setState(() => _currentLanguage = language);
              _voiceService.setLanguage(language);
            },
            itemBuilder: (context) => AiraLanguage.all.map((lang) => 
              PopupMenuItem<AiraLanguage>(
                value: lang,
                child: Row(
                  children: [
                    if (lang == _currentLanguage)
                      Icon(Icons.check, size: 16, color: AiraTheme.primary)
                    else
                      const SizedBox(width: 16),
                    const SizedBox(width: 8),
                    Text(lang.name, style: GoogleFonts.nunito()),
                  ],
                ),
              ),
            ).toList(),
          ),
          // Toggle auto-speak
          IconButton(
            icon: Icon(
              _autoSpeak ? Icons.volume_up : Icons.volume_off,
              size: 20,
              color: _autoSpeak ? AiraTheme.primary : AiraTheme.textSecondary,
            ),
            onPressed: () => setState(() => _autoSpeak = !_autoSpeak),
            tooltip: _autoSpeak ? 'Voice on' : 'Voice off',
          ),
          // Voice settings
          IconButton(
            icon: Icon(
              Icons.settings,
              size: 20,
              color: AiraTheme.textSecondary,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => VoiceSettingsScreen(
                    voiceService: _voiceService,
                  ),
                ),
              );
            },
            tooltip: 'Voice settings',
          ),
        ],
      ),
      body: Column(
        children: [
          // Connection warning
          if (!_isConnected)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.amber.shade100,
              child: Row(
                children: [
                  Icon(Icons.wifi_off, size: 16, color: Colors.amber.shade800),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Connection issues. Responses may be delayed.",
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: Colors.amber.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading) {
                  return _buildTypingIndicator();
                }
                
                final message = _messages[index];
                return GestureDetector(
                  onLongPress: !message.isUser && _voiceEnabled
                      ? () => _voiceService.speak(message.text)
                      : null,
                  child: MessageBubble(
                    message: message,
                    showTimestamp: false,
                  ),
                )
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.1, end: 0, duration: 400.ms);
              },
            ),
          ),
          
          // Listening indicator
          if (_isListening)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.mic,
                    color: AiraTheme.primary,
                    size: 20,
                  )
                  .animate(onComplete: (c) => c.repeat(reverse: true))
                  .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2)),
                  const SizedBox(width: 8),
                  Text(
                    "Listening...",
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: AiraTheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
            .animate()
            .fadeIn(),
          
          // Input area
          _buildInputArea(),
        ],
      ),
    );
  }
  
  /// Build the typing indicator
  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 8, right: 80),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AiraTheme.airaBubble,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(0),
            const SizedBox(width: 4),
            _buildDot(200),
            const SizedBox(width: 4),
            _buildDot(400),
          ],
        ),
      ),
    )
    .animate()
    .fadeIn(duration: 300.ms);
  }
  
  /// Build animated dot for typing indicator
  Widget _buildDot(int delayMs) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: AiraTheme.textSecondary.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
    )
    .animate(onComplete: (controller) => controller.repeat())
    .fadeIn(delay: Duration(milliseconds: delayMs))
    .then()
    .scale(
      begin: const Offset(1, 1),
      end: const Offset(1.3, 1.3),
      duration: 400.ms,
    )
    .then()
    .scale(
      begin: const Offset(1.3, 1.3),
      end: const Offset(1, 1),
      duration: 400.ms,
    );
  }
  
  /// Build the input area with voice button
  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: AiraTheme.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Microphone button
          if (_voiceEnabled)
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: _isListening ? AiraTheme.primary : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: _isListening ? AiraTheme.primary : AiraTheme.textSecondary.withOpacity(0.2),
                ),
              ),
              child: IconButton(
                icon: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  color: _isListening ? Colors.white : AiraTheme.textSecondary,
                  size: 22,
                ),
                onPressed: _toggleVoiceInput,
              ),
            ),
          
          // Text input
          Expanded(
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 4,
              minLines: 1,
              style: GoogleFonts.nunito(
                fontSize: 15,
                color: AiraTheme.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: _voiceEnabled 
                    ? "Type or tap mic to speak..." 
                    : "Share what's on your mind...",
                hintStyle: GoogleFonts.nunito(
                  fontSize: 15,
                  color: AiraTheme.textSecondary.withOpacity(0.6),
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          
          // Send button
          Container(
            decoration: BoxDecoration(
              color: AiraTheme.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AiraTheme.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                _isLoading ? Icons.hourglass_empty : Icons.arrow_upward,
                color: Colors.white,
                size: 22,
              ),
              onPressed: _isLoading ? null : _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
