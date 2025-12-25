import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/aira_theme.dart';
import '../services/chat_service.dart';

/// Message bubble widget for chat messages
/// 
/// Features:
/// - Different colors for user vs Aira messages
/// - Large border radius for soft appearance
/// - Optional timestamp display
/// - Special styling for crisis messages
class MessageBubble extends StatelessWidget {
  final Message message;
  final bool showTimestamp;
  
  const MessageBubble({
    super.key,
    required this.message,
    this.showTimestamp = false,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 8,
          left: isUser ? 48 : 0,
          right: isUser ? 0 : 48,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _getBubbleColor(),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isUser 
                ? const Radius.circular(20) 
                : const Radius.circular(4),
            bottomRight: isUser 
                ? const Radius.circular(4) 
                : const Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Crisis indicator
            if (message.isCrisis && !isUser)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.favorite,
                      size: 14,
                      color: AiraTheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "You're not alone",
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AiraTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            
            // Message text
            Text(
              message.text,
              style: GoogleFonts.nunito(
                fontSize: 15,
                height: 1.5,
                color: isUser 
                    ? AiraTheme.textPrimary 
                    : AiraTheme.textPrimary,
              ),
            ),
            
            // Timestamp (optional)
            if (showTimestamp)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _formatTime(message.timestamp),
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    color: AiraTheme.textSecondary.withOpacity(0.6),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  /// Get the bubble color based on message type
  Color _getBubbleColor() {
    if (message.isUser) {
      return AiraTheme.userBubble;
    } else if (message.isCrisis) {
      return AiraTheme.accent.withOpacity(0.8);
    } else {
      return AiraTheme.airaBubble;
    }
  }
  
  /// Format timestamp for display
  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
