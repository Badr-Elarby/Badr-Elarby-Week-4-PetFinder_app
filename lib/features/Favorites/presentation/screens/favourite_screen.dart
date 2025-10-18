import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:petfinder_app/core/utils/app_colors.dart';
import 'package:petfinder_app/core/utils/app_styles.dart';
import 'package:petfinder_app/features/Favorites/presentation/cubits/favorites_cubit/favorites_cubit.dart';
import 'package:petfinder_app/features/Favorites/presentation/cubits/favorites_cubit/favorites_state.dart';
import 'package:petfinder_app/features/Favorites/presentation/widgets/favorite_product_card.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({super.key});

  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  @override
  void initState() {
    super.initState();
    context.read<FavoritesCubit>().getFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40.h),

              // Header Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('My Favorites', style: AppTextStyles.HeadingBlack20Bold),
                  Icon(
                    Icons.heart_broken_outlined,
                    color: AppColors.HeadingBlack,
                    size: 30.w,
                  ),
                ],
              ),

              SizedBox(height: 15.h),

              // Description
              Text(
                'Your favorite cats are here for easy access',
                style: AppTextStyles.SubTextGrey14Regular,
              ),

              SizedBox(height: 20.h),

              // Favorites List
              Expanded(
                child: BlocBuilder<FavoritesCubit, FavoritesState>(
                  builder: (context, state) {
                    if (state is FavoritesLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.MintGreen,
                        ),
                      );
                    } else if (state is FavoritesError) {
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
                                context.read<FavoritesCubit>().getFavorites();
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
                    } else if (state is FavoritesSuccess) {
                      if (state.favorites.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.favorite_border,
                                size: 64.w,
                                color: AppColors.SubTextGrey,
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                'No favorites yet',
                                style: AppTextStyles.HeadingBlack18Bold,
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'Add some cats to your favorites to see them here',
                                style: AppTextStyles.SubTextGrey14Regular,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          context.read<FavoritesCubit>().getFavorites();
                        },
                        color: AppColors.MintGreen,
                        child: ListView.builder(
                          itemCount: state.favorites.length,
                          itemBuilder: (context, index) {
                            final cat = state.favorites[index];
                            return FavoriteProductCard(cat: cat);
                          },
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
