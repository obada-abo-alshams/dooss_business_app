import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/text_styles.dart';
import '../../data/models/reel_model.dart';

class ReelInfoOverlay extends StatelessWidget {
  final ReelModel reel;

  const ReelInfoOverlay({
    super.key,
    required this.reel,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 16.w,
      right: 80.w, // Leave space for actions
      bottom: 100.h,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dealer info
          Row(
            children: [
              CircleAvatar(
                radius: 16.r,
                backgroundColor: AppColors.primary,
                child: Text(
                  (reel.dealerUsername?.isNotEmpty == true)
                      ? reel.dealerUsername![0].toUpperCase()
                      : 'U',
                  style: AppTextStyles.whiteS14W600,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                reel.dealerUsername ?? 'Unknown User',
                style: AppTextStyles.whiteS14W600,
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  'Follow',
                  style: AppTextStyles.whiteS12W600,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // Reel title and description
          Text(
            reel.title,
            style: AppTextStyles.whiteS16W600,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (reel.description?.isNotEmpty == true) ...[
            SizedBox(height: 8.h),
            Text(
              reel.description!,
              style: AppTextStyles.whiteS14W400,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          SizedBox(height: 8.h),
          // Tags or metadata
          Row(
            children: [
              Icon(
                Icons.visibility,
                color: AppColors.white.withOpacity(0.7),
                size: 16.sp,
              ),
              SizedBox(width: 4.w),
              Text(
                _formatCount(reel.viewsCount),
                style: AppTextStyles.whiteS12W400.copyWith(
                  color: AppColors.white.withOpacity(0.7),
                ),
              ),
              SizedBox(width: 16.w),
              Icon(
                Icons.schedule,
                color: AppColors.white.withOpacity(0.7),
                size: 16.sp,
              ),
              SizedBox(width: 4.w),
              Text(
                _formatDate(reel.createdAt),
                style: AppTextStyles.whiteS12W400.copyWith(
                  color: AppColors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M views';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K views';
    } else {
      return '$count views';
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Recently';
    }
  }
}