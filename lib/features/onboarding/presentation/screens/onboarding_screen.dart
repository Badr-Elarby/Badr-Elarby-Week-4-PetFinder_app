import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:petfinder_app/core/utils/app_colors.dart';
import 'package:petfinder_app/core/utils/app_styles.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              // Top section with image
              Expanded(
                flex: 5,
                child: Center(
                  child: Image.asset(
                    'assets/images/Onboarding.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // Middle section with text content
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Heading text
                    Text(
                      'Find Your Best Companion With Us',
                      style: AppTextStyles.HeadingBlack24Bold,
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 16.h),

                    // Description text
                    Text(
                      'Join us now as the best suitable pets ids will be found for you to you rescue',
                      style: AppTextStyles.SubTextGrey16Regular,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Bottom section with button
              Expanded(
                flex: 1,
                child: Center(
                  child: SizedBox(
                    width: 300.w,
                    height: 56.h,
                    child: ElevatedButton(
                      onPressed: () {
                        context.go('/home');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.MintGreen,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Paw print icon
                          Icon(Icons.pets, size: 20.w, color: AppColors.white),
                          SizedBox(width: 8.w),
                          Text(
                            'Get Started',
                            style: AppTextStyles.white18Medium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }
}
