import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dooss_business_app/features/home/presentaion/widgets/home_banner.dart';
import 'package:dooss_business_app/features/home/presentaion/widgets/market_reels_section.dart';
import 'package:dooss_business_app/features/home/presentaion/widgets/browse_by_type_section_wrapper.dart';
import 'package:dooss_business_app/features/home/presentaion/widgets/content_section.dart';

class HomeTabScrollView extends StatelessWidget {
  const HomeTabScrollView({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh logic will be handled by parent data loader
      },
      child: const HomeTabScrollContent(),
    );
  }
}

class HomeTabScrollContent extends StatelessWidget {
  const HomeTabScrollContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          HomeTabBannerSection(),
          const MarketReelsSection(),
          SizedBox(height: 24.h),
          const BrowseByTypeSectionWrapper(),
          SizedBox(height: 24.h),
          const ContentSection(),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}

class HomeTabBannerSection extends StatelessWidget {
  const HomeTabBannerSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: const HomeBanner(),
    );
  }
}