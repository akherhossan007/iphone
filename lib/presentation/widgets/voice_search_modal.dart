import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceSearchModal extends StatefulWidget {
  const VoiceSearchModal({super.key});

  static Future<String?> show(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const VoiceSearchModal(),
    );
  }

  @override
  State<VoiceSearchModal> createState() => _VoiceSearchModalState();
}

class _VoiceSearchModalState extends State<VoiceSearchModal> with SingleTickerProviderStateMixin {
  late final stt.SpeechToText _speech;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  bool _isInitialized = false;
  bool _isListening = false;
  String _spokenText = '';
  String _statusText = 'কথা বলার জন্য প্রস্তুত হচ্ছে...';
  String _selectedLocaleId = 'bn_BD';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _initSpeech();
  }

  @override
  void dispose() {
    _speech.stop();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    try {
      final available = await _speech.initialize(
        onStatus: (status) {
          if (!mounted) return;
          if (status == 'listening') {
            setState(() {
              _isListening = true;
              _statusText = 'শুনছি... আপনার পছন্দের প্রোডাক্টের নাম বলুন';
            });
          } else if (status == 'notListening' || status == 'done') {
            setState(() {
              _isListening = false;
              if (_spokenText.trim().isNotEmpty) {
                _statusText = 'শনাক্ত সম্পন্ন!';
              } else {
                _statusText = 'কথা বুঝতে পারিনি। আবার ট্যাপ করে বলুন।';
              }
            });
            if (_spokenText.trim().isNotEmpty) {
              Future.delayed(const Duration(milliseconds: 600), () {
                if (mounted) {
                  _finishWithResult(_spokenText);
                }
              });
            }
          }
        },
        onError: (errorNotification) {
          if (!mounted) return;
          setState(() {
            _isListening = false;
            _statusText = 'মাইক্রোফোন এরর বা কথা শোনা যায়নি। আবার বলুন।';
          });
        },
      );

      if (available && mounted) {
        // Detect Bengali or fallback to English / device default
        final locales = await _speech.locales();
        String locale = 'en_US';
        for (var l in locales) {
          if (l.localeId.startsWith('bn')) {
            locale = l.localeId;
            break;
          }
        }
        setState(() {
          _isInitialized = true;
          _selectedLocaleId = locale;
        });
        _startListening();
      } else if (mounted) {
        setState(() {
          _isInitialized = false;
          _statusText = 'মাইক্রোফোন বা স্পিচ সার্ভিস উপলভ্য নয়। সেটিংসে পারমিশন চেক করুন।';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitialized = false;
          _statusText = 'স্পিচ শুরু করা যায়নি: $e';
        });
      }
    }
  }

  void _startListening() async {
    if (!_isInitialized) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _spokenText = '';
      _isListening = true;
      _statusText = 'শুনছি... আপনার পছন্দের প্রোডাক্টের নাম বলুন';
    });

    try {
      await _speech.listen(
        onResult: (result) {
          if (!mounted) return;
          setState(() {
            _spokenText = result.recognizedWords;
          });
          if (result.finalResult && _spokenText.trim().isNotEmpty) {
            _finishWithResult(_spokenText);
          }
        },
        listenOptions: stt.SpeechListenOptions(
          localeId: _selectedLocaleId,
          listenFor: const Duration(seconds: 12),
          pauseFor: const Duration(seconds: 3),
          partialResults: true,
          cancelOnError: true,
          listenMode: stt.ListenMode.search,
        ),
      );
    } catch (_) {}
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
    if (_spokenText.trim().isNotEmpty) {
      _finishWithResult(_spokenText);
    }
  }

  void _finishWithResult(String raw) {
    HapticFeedback.lightImpact();
    // Clean Bengali filler words commonly spoken during search
    String cleaned = raw.trim();
    final prefixes = ['আমি ', 'একটু ', 'আমাকে ', 'search for ', 'find '];
    final suffixes = [' খুঁজছি', ' দেখান', ' চাই', ' লাগবে', ' দিন', ' দাও'];

    for (var p in prefixes) {
      if (cleaned.toLowerCase().startsWith(p.toLowerCase())) {
        cleaned = cleaned.substring(p.length).trim();
      }
    }
    for (var s in suffixes) {
      if (cleaned.toLowerCase().endsWith(s.toLowerCase())) {
        cleaned = cleaned.substring(0, cleaned.length - s.length).trim();
      }
    }

    Navigator.pop(context, cleaned.isNotEmpty ? cleaned : raw.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 30,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: 44,
            height: 4.5,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),

          // Header Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF2374).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.mic_rounded, color: Color(0xFFFF2374), size: 22),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ভয়েস সার্চ (Voice Search)',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        'Speak in Bengali or English',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8), size: 22),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Pulsing Microphone Graphic
          GestureDetector(
            onTap: () {
              if (_isListening) {
                _stopListening();
              } else {
                _startListening();
              }
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_isListening) ...[
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 96 * _pulseAnimation.value,
                        height: 96 * _pulseAnimation.value,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFFF2374).withValues(alpha: 0.15),
                        ),
                      );
                    },
                  ),
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 82 * _pulseAnimation.value,
                        height: 82 * _pulseAnimation.value,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFFF2374).withValues(alpha: 0.25),
                        ),
                      );
                    },
                  ),
                ],
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF2374), Color(0xFFFF5286)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF2374).withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Status / Guidance Text
          Text(
            _statusText,
            style: GoogleFonts.hindSiliguri(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: _isListening ? const Color(0xFFFF2374) : const Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Spoken Text Box (Real-time Preview)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _spokenText.isNotEmpty ? const Color(0xFFFF2374) : const Color(0xFFE2E8F0),
                width: _spokenText.isNotEmpty ? 1.5 : 1,
              ),
            ),
            child: Text(
              _spokenText.isNotEmpty
                  ? _spokenText
                  : 'যেমন বলুন: "CeraVe Cleanser", "সানস্ক্রিন", "Centella Toner"...',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: _spokenText.isNotEmpty ? FontWeight.w800 : FontWeight.w500,
                color: _spokenText.isNotEmpty ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 18),

          // Done Action Button if text spoken
          if (_spokenText.trim().isNotEmpty) ...[
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: () => _finishWithResult(_spokenText),
                icon: const Icon(Icons.search_rounded, color: Colors.white, size: 20),
                label: Text(
                  'এই নামে খুঁজুন',
                  style: GoogleFonts.hindSiliguri(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF2374),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
