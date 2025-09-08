import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:dooss_business_app/core/constants/colors.dart';
import 'package:dooss_business_app/core/constants/text_styles.dart';
import 'package:dooss_business_app/core/services/native_video_service.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/services/locator_service.dart' as di;
import '../manager/reel_cubit.dart';
import '../manager/reel_state.dart';
import '../../data/models/reel_model.dart';

class MarketReelsSection extends StatelessWidget {
  const MarketReelsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReelCubit, ReelState>(
      builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Market Reels',
                      style: AppTextStyles.blackS18W700,
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to Reels screen
                        context.go(RouteNames.reelsScreen);
                      },
                      child: Text(
                        'View All',
                        style: AppTextStyles.primaryS14W500,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              // Reels List
              SizedBox(
                height: 120.h,
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : state.reels.isEmpty
                        ? const Center(child: Text('No reels available'))
                        : ListView.separated(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            scrollDirection: Axis.horizontal,
                            itemCount: state.reels.length > 3 ? 3 : state.reels.length,
                            separatorBuilder: (context, index) => SizedBox(width: 12.w),
                            itemBuilder: (context, index) => _buildReelCard(state.reels[index], context),
                          ),
              ),
            ],
          );
        },
      );
  }

  Widget _buildReelCard(ReelModel reel, BuildContext context) {
    return Container(
      width: 100.w,
      height: 120.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            print('🎬 MarketReels: Navigating to reel ${reel.id}');
            // Navigate to Reels screen with specific reel
            context.go('${RouteNames.reelsScreen}/${reel.id}');
          },
          borderRadius: BorderRadius.circular(12.r),
          child: Stack(
            children: [
              // Video Thumbnail - Use lightweight thumbnail instead of full video
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  width: 100.w,
                  height: 120.h,
                  color: Colors.black12,
                  child: Stack(
                    children: [
                      // Use a placeholder or thumbnail image instead of video preview
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.3),
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                      // Video icon to indicate it's a video
                      Center(
                        child: Icon(
                          Icons.videocam,
                          color: Colors.white.withOpacity(0.8),
                          size: 24.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Play Button Overlay
              Center(
                child: Container(
                  width: 32.w,
                  height: 32.h,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              // Title
              Positioned(
                bottom: 8.h,
                left: 8.w,
                right: 8.w,
                child: Text(
                  reel.title,
                  style: AppTextStyles.s14w700.copyWith(
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        offset: const Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 