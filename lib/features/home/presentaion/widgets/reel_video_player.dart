import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/services/native_video_service.dart';
import '../../data/models/reel_model.dart';

class ReelVideoPlayer extends StatelessWidget {
  final ReelModel reel;
  final bool isCurrentReel;

  const ReelVideoPlayer({
    super.key,
    required this.reel,
    required this.isCurrentReel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.black,
      child: isCurrentReel && reel.videoUrl.isNotEmpty
          ? NativeVideoWidget(
              videoUrl: reel.videoUrl,
              width: 1.sw,
              height: 1.sh,
              muted: false,
              loop: true,
            )
          : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.gray.withOpacity(0.2),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library,
              color: AppColors.white,
              size: 64.sp,
            ),
            SizedBox(height: 16.h),
            Text(
              reel.title,
              style: TextStyle(
                color: AppColors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}