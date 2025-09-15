import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/colors.dart';
import '../../data/models/reel_model.dart';
import '../widgets/full_screen_reel_player.dart';

/// Full-screen Instagram-style reels viewer
/// Vertical PageView with proper video lifecycle management
class ReelsViewerScreen extends StatefulWidget {
  final List<ReelModel> reelsList;
  final int initialIndex;

  const ReelsViewerScreen({
    super.key,
    required this.reelsList,
    required this.initialIndex,
  });

  @override
  State<ReelsViewerScreen> createState() => _ReelsViewerScreenState();
}

class _ReelsViewerScreenState extends State<ReelsViewerScreen> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    
    // Set full-screen immersive mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    
    print('🎬 ReelsViewerScreen: Initialized with ${widget.reelsList.length} reels, starting at index ${widget.initialIndex}');
  }

  @override
  void dispose() {
    print('🗑️ ReelsViewerScreen: Disposing page controller and restoring UI');
    
    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    print('📄 ReelsViewerScreen: Page changed from $_currentIndex to $index');
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        children: [
          // Main vertical PageView
          PageView.builder(
            scrollDirection: Axis.vertical,
            controller: _pageController,
            itemCount: widget.reelsList.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              final reel = widget.reelsList[index];
              final isCurrentReel = index == _currentIndex;
              
              return FullScreenReelPlayer(
                key: Key('reel_${reel.id}'), // Important for disposal when scrolling
                reel: reel,
                isCurrentReel: isCurrentReel,
                onTap: () => print('Tapped reel ${reel.id}'),
              );
            },
          ),

          // Back button (top left)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16.h,
            left: 16.w,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: AppColors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: AppColors.white,
                  size: 24.sp,
                ),
              ),
            ),
          ),

          // Reel counter (top right)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16.h,
            right: 16.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                '${_currentIndex + 1} / ${widget.reelsList.length}',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // Scroll indicator (right edge)
          Positioned(
            right: 8.w,
            top: MediaQuery.of(context).padding.top + 80.h,
            bottom: 80.h,
            child: _buildScrollIndicator(),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollIndicator() {
    if (widget.reelsList.length <= 1) return const SizedBox.shrink();

    return Container(
      width: 4.w,
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(2.r),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final indicatorHeight = constraints.maxHeight / widget.reelsList.length;
          final currentPosition = _currentIndex * indicatorHeight;
          
          return Stack(
            children: [
              Positioned(
                top: currentPosition,
                child: Container(
                  width: 4.w,
                  height: indicatorHeight,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}