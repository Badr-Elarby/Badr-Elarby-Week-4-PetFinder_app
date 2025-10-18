import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:petfinder_app/core/utils/app_colors.dart';
import 'package:petfinder_app/core/utils/app_styles.dart';
import 'package:petfinder_app/features/ProductDetails/presentation/cubit/product_details_cubit.dart';
import 'package:petfinder_app/features/ProductDetails/presentation/cubit/product_details_state.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String catId;

  const ProductDetailsScreen({super.key, required this.catId});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen>
    with TickerProviderStateMixin {
  late AnimationController _buttonAnimationController;
  late Animation<double> _buttonScaleAnimation;

  @override
  void initState() {
    super.initState();
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _buttonAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Fetch cat details when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductDetailsCubit>().getCatDetails(widget.catId);
    });
  }

  @override
  void dispose() {
    _buttonAnimationController.dispose();
    super.dispose();
  }

  void _onAdoptMePressed() {
    _buttonAnimationController.forward().then((_) {
      _buttonAnimationController.reverse();
    });
    // TODO: Add adoption functionality later
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.HeadingBlack,
            size: 20.w,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: Text('Details', style: AppTextStyles.HeadingBlack20Bold),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.favorite_border,
              color: AppColors.MintGreen,
              size: 24.w,
            ),
            onPressed: () {
              // TODO: Add to favorites functionality
            },
          ),
        ],
      ),
      body: BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
        builder: (context, state) {
          if (state is ProductDetailsLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.MintGreen),
            );
          } else if (state is ProductDetailsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64.w,
                    color: AppColors.SubTextGrey,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Something went wrong',
                    style: AppTextStyles.HeadingBlack18Bold,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    state.message,
                    style: AppTextStyles.SubTextGrey14Regular,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProductDetailsCubit>().getCatDetails(
                        widget.catId,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.MintGreen,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'Try Again',
                      style: AppTextStyles.white14SemiBold,
                    ),
                  ),
                ],
              ),
            );
          } else if (state is ProductDetailsSuccess) {
            final cat = state.cat;
            final breed = cat.breeds.isNotEmpty ? cat.breeds.first : null;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cat Image
                  Container(
                    width: double.infinity,
                    height: 300.h,
                    decoration: BoxDecoration(
                      color: AppColors.LightBackground,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(24.r),
                        bottomRight: Radius.circular(24.r),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(24.r),
                        bottomRight: Radius.circular(24.r),
                      ),
                      child: Image.network(
                        cat.url,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              color: AppColors.LightBackground,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(24.r),
                                bottomRight: Radius.circular(24.r),
                              ),
                            ),
                            child: Icon(
                              Icons.pets,
                              color: AppColors.MintGreen,
                              size: 64.w,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Cat Name
                        Text(
                          breed?.name ?? 'Unknown Breed',
                          style: AppTextStyles.HeadingBlack24Bold,
                        ),

                        SizedBox(height: 8.h),

                        // Location
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16.w,
                              color: AppColors.CoralRed,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '2.7 km away', // Mock location
                              style: AppTextStyles.SubTextGrey14Regular,
                            ),
                          ],
                        ),

                        SizedBox(height: 24.h),

                        // Attributes Row
                        Row(
                          children: [
                            Expanded(
                              child: _buildAttributeCard(
                                'Origin',
                                breed?.origin ?? 'Unknown', // Use breed origin
                                Icons.location_on,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: _buildAttributeCard(
                                'Life Span',
                                breed?.lifeSpan ??
                                    'Unknown', // Use breed life span
                                Icons.cake,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: _buildAttributeCard(
                                'Weight',
                                breed?.weight ??
                                    '10 kg', // Use breed weight or mock
                                Icons.scale,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 24.h),

                        // About Section
                        Text('About:', style: AppTextStyles.HeadingBlack18Bold),
                        SizedBox(height: 8.h),
                        Text(
                          breed?.description ??
                              'This is a wonderful pet that would make a great addition to any family. They are friendly, playful, and love being around people. Perfect for both experienced and first-time pet owners.',
                          style: AppTextStyles.SubTextGrey16Regular,
                        ),

                        SizedBox(height: 40.h),

                        // Adopt Me Button
                        AnimatedBuilder(
                          animation: _buttonScaleAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _buttonScaleAnimation.value,
                              child: SizedBox(
                                width: double.infinity,
                                height: 56.h,
                                child: ElevatedButton(
                                  onPressed: _onAdoptMePressed,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.MintGreen,
                                    foregroundColor: AppColors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16.r),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    'Adopt Me',
                                    style: AppTextStyles.white18Medium,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildAttributeCard(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: AppColors.LightBackground,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20.w, color: AppColors.MintGreen),
          SizedBox(height: 4.h),
          Text(label, style: AppTextStyles.SubTextGrey10Regular),
          SizedBox(height: 2.h),
          Text(
            value,
            style: AppTextStyles.HeadingBlack14SemiBold,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
