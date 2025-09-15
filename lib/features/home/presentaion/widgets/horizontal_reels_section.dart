import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/text_styles.dart';
import '../manager/reel_cubit.dart';
import '../manager/reel_state.dart';
import '../../data/models/reel_model.dart';
import 'reel_card_player.dart';

/// Horizontal reels section for home screen
/// Keeps the card-like UI but uses ReelCardPlayer internally
class HorizontalReelsSection extends StatefulWidget {
  final VoidCallback? onViewAllPressed;

  const HorizontalReelsSection({
    super.key,
    this.onViewAllPressed,
  });

  @override
  State<HorizontalReelsSection> createState() => _HorizontalReelsSectionState();
}

class _HorizontalReelsSectionState extends State<HorizontalReelsSection> {
  final ScrollController _scrollController = ScrollController();
  int _currentVisibleIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Load reels when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReelCubit>().loadReels();
    });
  }

  void _onScroll() {
    // Determine which reel is currently in viewport
    final itemWidth = 216.w; // Card width + margin
    final scrollOffset = _scrollController.offset;
    final newVisibleIndex = (scrollOffset / itemWidth).round();
    
    if (newVisibleIndex != _currentVisibleIndex && newVisibleIndex >= 0) {
      setState(() {
        _currentVisibleIndex = newVisibleIndex;
      });
      
      // Update focused reel in cubit
      context.read<ReelsCubit>().setFocusedReel(newVisibleIndex);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Market Reels',
                style: AppTextStyles.blackS18W700,
              ),
              if (widget.onViewAllPressed != null)
                GestureDetector(
                  onTap: widget.onViewAllPressed,
                  child: Text(
                    'View All',
                    style: AppTextStyles.primaryS16W600,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        
        // Horizontal reels list
        SizedBox(
          height: 300.h,
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
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: reels.length,
      itemBuilder: (context, index) {
        final reel = reels[index];
        final isInViewport = index == _currentVisibleIndex;
        
        return Container(
          margin: EdgeInsets.only(right: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Reel video card
              ReelCardPlayer(
                reelUrl: reel.videoUrl,
                reelId: reel.id,
                thumbnailUrl: reel.thumbnail,
                isInViewport: isInViewport,
                onTap: () => _onReelTap(context, reel, index),
              ),
              
              SizedBox(height: 8.h),
              
              // Reel info
              SizedBox(
                width: 200.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reel.title,
                      style: AppTextStyles.blackS14W600,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          color: AppColors.gray,
                          size: 14.sp,
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            reel.dealerUsername ?? 'Unknown',
                            style: AppTextStyles.grayS12W400,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
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

  void _onReelTap(BuildContext context, ReelModel reel, int index) {
    print('🎬 HorizontalReelsSection: Reel tapped - ${reel.title}');
    
    // Update focused reel
    context.read<ReelsCubit>().setFocusedReel(reel.id);
    
    // Enable auto-play for this reel
    context.read<ReelsCubit>().enableAutoPlay();
    
    // TODO: Navigate to full-screen viewer if needed
    // context.push('/reels/${reel.id}');
  }
}