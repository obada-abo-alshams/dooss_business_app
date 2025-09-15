import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/text_styles.dart';
import '../manager/reel_cubit.dart';
import '../manager/reel_state.dart';
import '../pages/reels_viewer_screen.dart';
import '../../data/models/reel_model.dart';
import 'reel_preview_player.dart';

/// Simple reels section for home screen - just previews with exact 120x156 dimensions
/// Tapping launches full-screen Instagram-style reels experience
class SimpleReelsSection extends StatefulWidget {
  const SimpleReelsSection({super.key});

  @override
  State<SimpleReelsSection> createState() => _SimpleReelsSectionState();
}

class _SimpleReelsSectionState extends State<SimpleReelsSection> {
  @override
  void initState() {
    super.initState();
    
    // Load reels when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReelCubit>().loadReels();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            'Market Reels',
            style: AppTextStyles.blackS18W700,
          ),
        ),
        SizedBox(height: 16.h),
        
        // Horizontal reels list
        SizedBox(
          height: 200.h, // 156h for card + 44h for title and spacing
          child: BlocBuilder<ReelCubit, ReelState>(
            buildWhen: (previous, current) =>
                previous.reels != current.reels ||
                previous.isLoading != current.isLoading ||
                previous.error != current.error,
            builder: (context, state) {
              if (state.isLoading && state.reels.isEmpty) {
                return _buildLoadingState();
              }

              if (state.error != null && state.reels.isEmpty) {
                return _buildErrorState(state.error!);
              }

              if (state.reels.isEmpty) {
                return _buildEmptyState();
              }

              return _buildReelsList(state.reels);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReelsList(List<ReelModel> reels) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: reels.length,
      itemBuilder: (context, index) {
        final reel = reels[index];
        
        return Container(
          margin: EdgeInsets.only(right: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Reel preview card with exact dimensions
              GestureDetector(
                onTap: () => _onReelTap(context, reels, index),
                child: ReelPreviewPlayer(
                  reelUrl: reel.videoUrl,
                  thumbnailUrl: reel.thumbnail,
                ),
              ),
              
              SizedBox(height: 8.h),
              
              // Reel title (under the card)
              SizedBox(
                width: 120.w,
                child: Text(
                  reel.title,
                  style: AppTextStyles.blackS12W600,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16.h),
          Text(
            'Loading reels...',
            style: AppTextStyles.grayS14W400,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.gray,
            size: 48.sp,
          ),
          SizedBox(height: 16.h),
          Text(
            'Failed to load reels',
            style: AppTextStyles.grayS16W600,
          ),
          SizedBox(height: 8.h),
          Text(
            error,
            style: AppTextStyles.grayS12W400,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () => context.read<ReelCubit>().loadReels(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library_outlined,
            color: AppColors.gray,
            size: 48.sp,
          ),
          SizedBox(height: 16.h),
          Text(
            'No reels available',
            style: AppTextStyles.grayS16W600,
          ),
          SizedBox(height: 8.h),
          Text(
            'Check back later for new content',
            style: AppTextStyles.grayS12W400,
          ),
        ],
      ),
    );
  }

  void _onReelTap(BuildContext context, List<ReelModel> reels, int index) {
    print('🎬 SimpleReelsSection: Tapped reel ${reels[index].title} at index $index');
    
    // Navigate to full-screen reels viewer, passing the entire list and index
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReelsViewerScreen(
          reelsList: reels,
          initialIndex: index,
        ),
      ),
    );
  }
}