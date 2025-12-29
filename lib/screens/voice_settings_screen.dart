import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../theme/aira_theme.dart';
import '../services/voice_service.dart';

/// Voice settings screen for customizing Aira's voice
class VoiceSettingsScreen extends StatefulWidget {
  final VoiceService voiceService;
  
  const VoiceSettingsScreen({super.key, required this.voiceService});

  @override
  State<VoiceSettingsScreen> createState() => _VoiceSettingsScreenState();
}

class _VoiceSettingsScreenState extends State<VoiceSettingsScreen> {
  List<Map<String, String>> _availableVoices = [];
  Map<String, String>? _selectedVoice;
  double _pitch = 1.15;
  double _speed = 0.65;
  bool _isLoading = true;
  bool _isPlaying = false;
  
  final FlutterTts _tts = FlutterTts();
  
  @override
  void initState() {
    super.initState();
    _loadVoices();
    _loadCurrentSettings();
  }
  
  Future<void> _loadCurrentSettings() async {
    _pitch = widget.voiceService.currentPitch;
    _speed = widget.voiceService.currentSpeed;
    _selectedVoice = widget.voiceService.currentVoice;
    setState(() {});
  }
  
  Future<void> _loadVoices() async {
    try {
      final voices = await _tts.getVoices;
      if (voices != null) {
        final voiceList = (voices as List).map((v) => {
          'name': v['name']?.toString() ?? '',
          'locale': v['locale']?.toString() ?? '',
        }).where((v) => v['name']!.isNotEmpty).toList();
        
        // Sort by locale
        voiceList.sort((a, b) => a['locale']!.compareTo(b['locale']!));
        
        setState(() {
          _availableVoices = voiceList;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _playDemo() async {
    if (_isPlaying) {
      await _tts.stop();
      setState(() => _isPlaying = false);
      return;
    }
    
    setState(() => _isPlaying = true);
    
    await _tts.setSpeechRate(_speed);
    await _tts.setPitch(_pitch);
    
    if (_selectedVoice != null) {
      await _tts.setVoice(_selectedVoice!);
    }
    
    String demoText = "Hey! I'm Aira, your friendly emotional support companion. How are you feeling today?";
    
    // Use language-specific demo
    final lang = widget.voiceService.currentLanguage;
    if (lang.code == 'hi') {
      demoText = "नमस्ते! मैं ऐरा हूं, आपकी दोस्त। आज आप कैसा महसूस कर रहे हैं?";
    } else if (lang.code == 'te') {
      demoText = "హాయ్! నేను ఐరా, మీ స్నేహితురాలిని. మీరు ఈ రోజు ఎలా ఫీల్ అవుతున్నారు?";
    } else if (lang.code == 'ta') {
      demoText = "வணக்கம்! நான் ஐரா, உங்கள் நண்பர். இன்று நீங்கள் எப்படி உணர்கிறீர்கள்?";
    } else if (lang.code == 'kn') {
      demoText = "ಹಾಯ್! ನಾನು ಐರಾ, ನಿಮ್ಮ ಸ್ನೇಹಿತ. ಇಂದು ನೀವು ಹೇಗೆ ಅನುಭವಿಸುತ್ತಿದ್ದೀರಿ?";
    }
    
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _isPlaying = false);
    });
    
    await _tts.speak(demoText);
  }
  
  void _saveSettings() {
    widget.voiceService.updateSettings(
      voice: _selectedVoice,
      pitch: _pitch,
      speed: _speed,
    );
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Voice settings saved!', style: GoogleFonts.nunito()),
        backgroundColor: AiraTheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
  
  String _getVoiceDisplayName(Map<String, String> voice) {
    final name = voice['name'] ?? '';
    final locale = voice['locale'] ?? '';
    
    // Extract readable name
    String displayName = name;
    if (name.contains('#')) {
      displayName = name.split('#').first;
    }
    
    // Detect gender
    final lowerName = name.toLowerCase();
    String gender = '';
    if (lowerName.contains('female') || lowerName.contains('woman') ||
        lowerName.contains('lekha') || lowerName.contains('aditi') ||
        lowerName.contains('samantha') || lowerName.contains('victoria') ||
        lowerName.contains('zira') || lowerName.contains('heera')) {
      gender = ' 👩';
    } else if (lowerName.contains('male') || lowerName.contains('man') ||
               lowerName.contains('ravi') || lowerName.contains('david')) {
      gender = ' 👨';
    }
    
    return '$displayName ($locale)$gender';
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
        title: Text(
          "Voice Settings",
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AiraTheme.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: Text(
              "Save",
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w600,
                color: AiraTheme.primary,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Demo button
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _playDemo,
                      icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
                      label: Text(
                        _isPlaying ? "Stop Demo" : "Play Demo Voice",
                        style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isPlaying ? Colors.red.shade400 : AiraTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Speed slider
                  _buildSectionTitle("Speed"),
                  _buildSliderRow(
                    value: _speed,
                    min: 0.3,
                    max: 1.0,
                    leftLabel: "Slow",
                    rightLabel: "Fast",
                    onChanged: (v) => setState(() => _speed = v),
                  ),
                  const SizedBox(height: 24),
                  
                  // Pitch slider
                  _buildSectionTitle("Pitch"),
                  _buildSliderRow(
                    value: _pitch,
                    min: 0.5,
                    max: 2.0,
                    leftLabel: "Low",
                    rightLabel: "High",
                    onChanged: (v) => setState(() => _pitch = v),
                  ),
                  const SizedBox(height: 32),
                  
                  // Voice selection
                  _buildSectionTitle("Voice"),
                  const SizedBox(height: 12),
                  
                  if (_availableVoices.isEmpty)
                    Center(
                      child: Text(
                        "No voices available",
                        style: GoogleFonts.nunito(color: AiraTheme.textSecondary),
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _availableVoices.length > 20 
                            ? 20 
                            : _availableVoices.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          color: AiraTheme.textSecondary.withOpacity(0.1),
                        ),
                        itemBuilder: (context, index) {
                          final voice = _availableVoices[index];
                          final isSelected = _selectedVoice?['name'] == voice['name'];
                          
                          return ListTile(
                            title: Text(
                              _getVoiceDisplayName(voice),
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                color: isSelected ? AiraTheme.primary : AiraTheme.textPrimary,
                              ),
                            ),
                            trailing: isSelected
                                ? Icon(Icons.check_circle, color: AiraTheme.primary)
                                : null,
                            onTap: () {
                              setState(() => _selectedVoice = voice);
                            },
                          );
                        },
                      ),
                    ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AiraTheme.textPrimary,
      ),
    );
  }
  
  Widget _buildSliderRow({
    required double value,
    required double min,
    required double max,
    required String leftLabel,
    required String rightLabel,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      children: [
        Text(
          leftLabel,
          style: GoogleFonts.nunito(
            fontSize: 12,
            color: AiraTheme.textSecondary,
          ),
        ),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            activeColor: AiraTheme.primary,
            inactiveColor: AiraTheme.primaryLight,
            onChanged: onChanged,
          ),
        ),
        Text(
          rightLabel,
          style: GoogleFonts.nunito(
            fontSize: 12,
            color: AiraTheme.textSecondary,
          ),
        ),
      ],
    );
  }
  
  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}
