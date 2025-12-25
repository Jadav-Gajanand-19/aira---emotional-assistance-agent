import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/aira_theme.dart';
import 'auth_screen.dart';

/// Aira Splash Screen
/// 
/// A calming animated splash screen with:
/// - Breathing circle animation
/// - Gentle fade-in text
/// - Smooth transition to auth screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    
    // Breathing animation controller
    _breathingController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);
    
    // Pulse animation controller
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    // Navigate to auth screen after delay
    Future.delayed(const Duration(milliseconds: 4000), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              return const AuthScreen();
            },
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF5F2ED),
              Color(0xFFE8F0E8),
              Color(0xFFF0E8F4),
            ],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer breathing ring
            AnimatedBuilder(
              animation: _breathingController,
              builder: (context, child) {
                return Container(
                  width: 200 + (_breathingController.value * 40),
                  height: 200 + (_breathingController.value * 40),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AiraTheme.primary.withOpacity(0.1),
                      width: 2,
                    ),
                  ),
                );
              },
            ),
            
            // Middle breathing ring
            AnimatedBuilder(
              animation: _breathingController,
              builder: (context, child) {
                return Container(
                  width: 160 + (_breathingController.value * 30),
                  height: 160 + (_breathingController.value * 30),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AiraTheme.primary.withOpacity(0.15),
                      width: 2,
                    ),
                  ),
                );
              },
            ),
            
            // Inner pulsing circle with glow
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AiraTheme.primaryLight,
                    boxShadow: [
                      BoxShadow(
                        color: AiraTheme.primary.withOpacity(
                          0.2 + (_pulseController.value * 0.15),
                        ),
                        blurRadius: 30 + (_pulseController.value * 20),
                        spreadRadius: 5 + (_pulseController.value * 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.eco_outlined,
                    size: 50,
                    color: AiraTheme.primary,
                  ),
                );
              },
            ),
            
            // Text content at bottom
            Positioned(
              bottom: 120,
              child: Column(
                children: [
                  // App name
                  Text(
                    "Aira",
                    style: GoogleFonts.nunito(
                      fontSize: 42,
                      fontWeight: FontWeight.w700,
                      color: AiraTheme.textPrimary,
                      letterSpacing: 2,
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 800.ms)
                  .slideY(begin: 0.3, end: 0, duration: 800.ms),
                  
                  const SizedBox(height: 12),
                  
                  // Tagline
                  Text(
                    "breathe · feel · be",
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AiraTheme.textSecondary,
                      letterSpacing: 4,
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 1000.ms, duration: 800.ms)
                  .slideY(begin: 0.3, end: 0, duration: 800.ms),
                ],
              ),
            ),
            
            // Loading indicator at very bottom
            Positioned(
              bottom: 50,
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AiraTheme.primary.withOpacity(0.5),
                  ),
                ),
              )
              .animate()
              .fadeIn(delay: 1500.ms, duration: 600.ms),
            ),
          ],
        ),
      ),
    );
  }
}
