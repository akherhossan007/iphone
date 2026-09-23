import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CountdownTimerWidget extends StatefulWidget {
  final int endTimestamp;
  final Color badgeColor;

  const CountdownTimerWidget({
    super.key,
    required this.endTimestamp,
    this.badgeColor = const Color(0xFF1E293B),
  });

  @override
  State<CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget> {
  late Timer _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _calculateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _calculateRemaining();
        });
      }
    });
  }

  void _calculateRemaining() {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final diff = widget.endTimestamp - now;
    if (diff > 0) {
      _remaining = Duration(seconds: diff);
    } else {
      _remaining = Duration.zero; // Graceful zero end
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Widget _buildTimeBox(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      decoration: BoxDecoration(
        color: widget.badgeColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        value.padLeft(2, '0'),
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final days = _remaining.inDays;
    final hours = _remaining.inHours.remainder(24);
    final minutes = _remaining.inMinutes.remainder(60);
    final seconds = _remaining.inSeconds.remainder(60);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (days > 0) ...[
          _buildTimeBox('${days}d'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 2),
            child: Text(':', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
          ),
        ],
        _buildTimeBox(hours.toString()),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 2),
          child: Text(':', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
        ),
        _buildTimeBox(minutes.toString()),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 2),
          child: Text(':', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
        ),
        _buildTimeBox(seconds.toString()),
      ],
    );
  }
}

