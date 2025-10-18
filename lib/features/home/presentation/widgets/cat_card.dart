import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:petfinder_app/core/utils/app_colors.dart';
import 'package:petfinder_app/core/utils/app_styles.dart';
import 'package:petfinder_app/features/home/data/models/cat_image_model.dart';

class CatCard extends StatelessWidget {
  final CatImageModel cat;

  const CatCard({super.key, required this.cat});

  @override
  Widget build(BuildContext context) {
    final breed = cat.breeds.isNotEmpty ? cat.breeds.first : null;

    return GestureDetector(
      onTap: () {
        context.push('/product-details/${cat.id}');
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Cat Image
            Container(
              width: 80.w,
              height: 90.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                color: AppColors.LightBackground,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.network(
                  cat.url,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.LightBackground,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.pets,
                        color: AppColors.MintGreen,
                        size: 32.w,
                      ),
                    );
                  },
                ),
              ),
            ),

            SizedBox(width: 16.w),

            // Cat Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Breed Name
                  Text(
                    breed?.name ?? 'Unknown Breed',
                    style: AppTextStyles.HeadingBlack18Bold,
                  ),

                  SizedBox(height: 4.h),

                  // Life Span and Origin
                  if (breed?.lifeSpan != null || breed?.origin != null) ...[
                    Text(
                      '${breed?.lifeSpan != null ? '${breed!.lifeSpan} years' : 'Unknown'} • ${breed?.origin ?? 'Unknown'}',
                      style: AppTextStyles.SubTextGrey14Regular,
                    ),
                    SizedBox(height: 4.h),
                  ],

                  // Weight
                  if (breed?.weight != null) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.scale,
                          size: 14.w,
                          color: AppColors.SubTextGrey,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          breed!.weight!,
                          style: AppTextStyles.SubTextGrey14Regular,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Favorite Icon
            GestureDetector(
              onTap: () {
                // Handle favorite functionality (placeholder)
              },
              child: Container(
                padding: EdgeInsets.all(8.w),
                child: Icon(
                  Icons.favorite_border,
                  color: AppColors.MintGreen,
                  size: 24.w,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
