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
            const MarketReelsSectionHeader(),
            SizedBox(height: 16.h),
            MarketReelsList(state: state),
          ],
        );
      },
    );
  }
}

class MarketReelsSectionHeader extends StatelessWidget {
  const MarketReelsSectionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Market Reels',
            style: AppTextStyles.blackS18W700,
          ),
          const MarketReelsViewAllButton(),
        ],
      ),
    );
  }
}

class MarketReelsViewAllButton extends StatelessWidget {
  const MarketReelsViewAllButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        context.go(RouteNames.reelsScreen);
      },
      child: Text(
        'View All',
        style: AppTextStyles.primaryS14W500,
      ),
    );
  }
}

class MarketReelsList extends StatelessWidget {
  final ReelState state;

  const MarketReelsList({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120.h,
      child: state.isLoading
          ? const MarketReelsLoadingState()
          : state.reels.isEmpty
              ? const MarketReelsEmptyState()
              : MarketReelsLoadedState(reels: state.reels),
    );
  }
}

class MarketReelsLoadingState extends StatelessWidget {
  const MarketReelsLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class MarketReelsEmptyState extends StatelessWidget {
  const MarketReelsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('No reels available'));
  }
}

class MarketReelsLoadedState extends StatelessWidget {
  final List<ReelModel> reels;

  const MarketReelsLoadedState({
    super.key,
    required this.reels,
  });

  @override
  Widget build(BuildContext context) {
    final displayCount = reels.length > 3 ? 3 : reels.length;
    
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      scrollDirection: Axis.horizontal,
      itemCount: displayCount,
      separatorBuilder: (context, index) => SizedBox(width: 12.w),
      itemBuilder: (context, index) => MarketReelCard(reel: reels[index]),
    );
  }
}

class MarketReelCard extends StatelessWidget {
  final ReelModel reel;

  const MarketReelCard({
    super.key,
    required this.reel,
  });

  @override
  Widget build(BuildContext context) {
    return MarketReelCardContainer(reel: reel);
  }
}

class MarketReelCardContainer extends StatelessWidget {
  final ReelModel reel;
  
  const MarketReelCardContainer({
    super.key,
    required this.reel,
  });

  @override
  Widget build(BuildContext context) {
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
      child: MarketReelCardContent(reel: reel),
    );
  }
}

class MarketReelCardContent extends StatelessWidget {
  final ReelModel reel;
  
  const MarketReelCardContent({
    super.key,
    required this.reel,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: MarketReelCardInkWell(reel: reel),
    );
  }
}

class MarketReelCardInkWell extends StatelessWidget {
  final ReelModel reel;
  
  const MarketReelCardInkWell({
    super.key,
    required this.reel,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        print('🎬 MarketReels: Navigating to reel ${reel.id}');
        context.go('${RouteNames.reelsScreen}/${reel.id}');
      },
      borderRadius: BorderRadius.circular(12.r),
      child: MarketReelCardStack(reel: reel),
    );
  }
}

class MarketReelCardStack extends StatelessWidget {
  final ReelModel reel;
  
  const MarketReelCardStack({
    super.key,
    required this.reel,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const MarketReelCardThumbnail(),
        const MarketReelCardPlayButton(),
        MarketReelCardTitle(reel: reel),
      ],
    );
  }
}

class MarketReelCardThumbnail extends StatelessWidget {
  const MarketReelCardThumbnail({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: 100.w,
        height: 120.h,
        color: Colors.black12,
        child: const MarketReelCardThumbnailContent(),
      ),
    );
  }
}

class MarketReelCardThumbnailContent extends StatelessWidget {
  const MarketReelCardThumbnailContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: const [
        MarketReelCardGradient(),
        MarketReelCardVideoIcon(),
      ],
    );
  }
}

class MarketReelCardGradient extends StatelessWidget {
  const MarketReelCardGradient({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class MarketReelCardVideoIcon extends StatelessWidget {
  const MarketReelCardVideoIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.videocam,
        color: Colors.white.withOpacity(0.8),
        size: 24.sp,
      ),
    );
  }
}

class MarketReelCardPlayButton extends StatelessWidget {
  const MarketReelCardPlayButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
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
    );
  }
}

class MarketReelCardTitle extends StatelessWidget {
  final ReelModel reel;
  
  const MarketReelCardTitle({
    super.key,
    required this.reel,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
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
    );
  }
}