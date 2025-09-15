import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/services/native_video_service.dart';
import '../../../../core/services/locator_service.dart' as di;
import '../manager/reel_cubit.dart';
import '../widgets/reels_screen_content.dart';

class ReelsScreen extends StatelessWidget {
  final int? initialReelId;
  
  const ReelsScreen({
    super.key,
    this.initialReelId,
  });

  @override
  Widget build(BuildContext context) {
    final PageController pageController = PageController();
    
    return BlocProvider(
      create: (_) => di.sl<ReelCubit>()..loadReels(),
      child: WillPopScope(
        onWillPop: () async {
          // Clean up video resources before navigating back
          await NativeVideoService.dispose();
          return true;
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: ReelsScreenContent(
            pageController: pageController,
            initialReelId: initialReelId,
          ),
        ),
      ),
    );
  }
}