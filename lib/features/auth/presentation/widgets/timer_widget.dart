import 'dart:async';
import 'package:flutter/cupertino.dart';
import '../../../../core/constants/text_styles.dart';

class TimerWidget extends StatefulWidget {
  const TimerWidget({super.key});

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  int seconds = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (mounted) {
          setState(() {
            if (seconds > 0) {
              seconds--;
            } else {
              timer.cancel();
            }
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "00:${seconds.toString().padLeft(2, '0')}",
        style: AppTextStyles.descriptionS18W500,
      ),
    );
  }
}