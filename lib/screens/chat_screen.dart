import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/aira_theme.dart';
import '../services/chat_service.dart';
import '../widgets/message_bubble.dart';

/// Aira Chat Screen
/// 
/// A calm, supportive chat interface with:
/// - Soft background
/// - Rounded message bubbles
/// - Gentle typing indicator
/// - Slow fade-in animations
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  
  final List<Message> _messages = [];
  bool _isLoading = false;
  bool _isConnected = true;
  
  @override
  void initState() {
    super.initState();
    _checkConnection();
    _addWelcomeMessage();
  }
  
  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _chatService.dispose();
    super.dispose();
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
    
    setState(() {
      _messages.add(Message(text: text, isUser: true));
      _isLoading = true;
    });
    
    _scrollToBottom();
    
    try {
      final response = await _chatService.sendMessage(text);
      
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
          ],
        ),
        centerTitle: true,
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
                return MessageBubble(
                  message: message,
                  showTimestamp: false,
                )
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.1, end: 0, duration: 400.ms);
              },
            ),
          ),
          
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
  
  /// Build the input area
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
                hintText: "Share what's on your mind...",
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
