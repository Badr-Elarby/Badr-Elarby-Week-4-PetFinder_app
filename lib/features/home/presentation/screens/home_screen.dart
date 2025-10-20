import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:petfinder_app/core/utils/app_colors.dart';
import 'package:petfinder_app/core/utils/app_styles.dart';
import 'package:petfinder_app/features/home/presentation/cubits/home_cubit/home_cubit.dart';
import 'package:petfinder_app/features/home/presentation/cubits/home_cubit/home_state.dart';
import 'package:petfinder_app/features/Favorites/presentation/cubits/favorites_cubit/favorites_cubit.dart';
import 'package:petfinder_app/features/home/presentation/widgets/cat_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().getCats();

    // Add scroll listener for pagination
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<HomeCubit>().loadMoreCats();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9); // Trigger when 90% scrolled
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
                  Flexible(
                    child: Text(
                      'Find Your Forever Pet',
                      style: AppTextStyles.HeadingBlack20Bold,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Icon(
                    Icons.notifications_outlined,
                    color: AppColors.HeadingBlack,
                    size: 30.w,
                  ),
                ],
              ),

              SizedBox(height: 15.h),

              // Search description
              Text(
                'You can search by breed name, country, or weight',
                style: AppTextStyles.SubTextGrey14Regular,
              ),

              SizedBox(height: 10.h),

              // Search Bar
              Container(
                height: 48.h,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    context.read<HomeCubit>().searchCats(value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: AppTextStyles.SubTextGrey16Regular,
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColors.SubTextGrey,
                      size: 20.w,
                    ),
                    suffixIcon: Icon(
                      Icons.tune,
                      color: AppColors.SubTextGrey,
                      size: 20.w,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 10.h),

              // Categories Section
              Text('Categories', style: AppTextStyles.HeadingBlack20Bold),

              SizedBox(height: 10.h),

              // Category Filter Buttons
              SizedBox(
                height: 40.h,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildCategoryButton(
                      'All',
                      isSelected: selectedCategory == 'All',
                    ),
                    SizedBox(width: 12.w),
                    _buildCategoryButton(
                      'Cats',
                      isSelected: selectedCategory == 'Cats',
                    ),
                    SizedBox(width: 12.w),
                    _buildCategoryButton(
                      'Dogs',
                      isSelected: selectedCategory == 'Dogs',
                    ),
                    SizedBox(width: 12.w),
                    _buildCategoryButton(
                      'Birds',
                      isSelected: selectedCategory == 'Birds',
                    ),
                    SizedBox(width: 12.w),
                    _buildCategoryButton(
                      'Fish',
                      isSelected: selectedCategory == 'Fish',
                    ),
                    SizedBox(width: 12.w),
                    _buildCategoryButton(
                      'Reptiles',
                      isSelected: selectedCategory == 'Reptiles',
                    ),
                  ],
                ),
              ),

              SizedBox(height: 15.h),

              // Cats List
              Expanded(
                child: BlocBuilder<HomeCubit, HomeState>(
                  builder: (context, state) {
                    if (state is HomeLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.MintGreen,
                        ),
                      );
                    } else if (state is HomeError) {
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
                                context.read<HomeCubit>().getCats();
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
                    } else if (state is HomeSuccess) {
                      if (state.filteredCats.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64.w,
                                color: AppColors.SubTextGrey,
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                'No cats found',
                                style: AppTextStyles.HeadingBlack18Bold,
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'Try adjusting your search',
                                style: AppTextStyles.SubTextGrey14Regular,
                              ),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          context.read<HomeCubit>().getCats();
                        },
                        color: AppColors.MintGreen,
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount:
                              state.filteredCats.length +
                              (state.isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            // Show loading indicator at the bottom
                            if (index == state.filteredCats.length) {
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.h),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.MintGreen,
                                  ),
                                ),
                              );
                            }

                            final cat = state.filteredCats[index];
                            return CatCard(cat: cat);
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

  Widget _buildCategoryButton(String category, {required bool isSelected}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = category;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.MintGreen
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          category,
          style: isSelected
              ? AppTextStyles.white14SemiBold
              : AppTextStyles.SubTextGrey14Regular,
        ),
      ),
    );
  }
}
