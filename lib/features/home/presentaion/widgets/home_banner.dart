import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeBanner extends StatelessWidget {
  const HomeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final devicePixelWidth = (MediaQuery.of(context).size.width * MediaQuery.of(context).devicePixelRatio).round();
    return Container(
      height: 180.h,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Image.asset(
          'assets/images/head_image_home_screen.png', // يمكن تغييرها لصورة البانر المطلوبة
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          cacheWidth: devicePixelWidth,
        ),
      ),
    );
  }
} 