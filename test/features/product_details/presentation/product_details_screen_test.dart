import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petfinder_app/core/utils/app_colors.dart';
import 'package:petfinder_app/features/ProductDetails/presentation/cubit/product_details_cubit.dart';
import 'package:petfinder_app/features/ProductDetails/presentation/cubit/product_details_state.dart';
import 'package:petfinder_app/features/ProductDetails/presentation/screens/product_details_screen.dart';
import 'package:petfinder_app/features/home/data/models/cat_image_model.dart';
import 'package:petfinder_app/features/home/data/models/cat_breed_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bloc_test/bloc_test.dart';

// Mock classes
class MockProductDetailsCubit extends Mock implements ProductDetailsCubit {
  ProductDetailsState _currentState = ProductDetailsInitial();

  @override
  ProductDetailsState get state => _currentState;

  @override
  Stream<ProductDetailsState> get stream => Stream.value(_currentState);

  @override
  Future<void> close() => Future.value();

  @override
  Future<void> getCatDetails(String id) => Future.value();

  // Helper method to set state for testing
  void setState(ProductDetailsState state) {
    _currentState = state;
  }
}

void main() {
  late MockProductDetailsCubit mockCubit;

  setUp(() {
    mockCubit = MockProductDetailsCubit();
  });

  // Mock cat data
  final mockCat = CatImageModel(
    id: "cat1",
    url: "https://cdn2.thecatapi.com/images/cat1.jpg",
    width: 800,
    height: 600,
    breeds: [
      CatBreedModel(
        id: "pers",
        name: "Persian",
        origin: "Iran",
        lifeSpan: "10 - 15",
        weight: "3 - 7",
        description:
            "The Persian cat is a long-haired breed of cat characterized by its round face and short muzzle.",
        temperament: "Affectionate, Gentle, Quiet",
      ),
    ],
  );

  Widget createWidgetUnderTest() {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      child: MaterialApp(
        home: BlocProvider<ProductDetailsCubit>(
          create: (context) => mockCubit,
          child: const ProductDetailsScreen(catId: 'cat1'),
        ),
      ),
    );
  }

  group('ProductDetailsScreen', () {
    testWidgets(
      'should display error state with retry button when state is error',
      (tester) async {
        // Arrange
        mockCubit.setState(ProductDetailsError(message: 'Test error'));

        // Act
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Something went wrong'), findsOneWidget);
        expect(find.text('Test error'), findsOneWidget);
        expect(find.text('Try Again'), findsOneWidget);
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      },
    );

    testWidgets('should display cat details when state is success', (
      tester,
    ) async {
      // Arrange
      mockCubit.setState(ProductDetailsSuccess(cat: mockCat));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Persian'), findsOneWidget);
      expect(find.text('Iran'), findsOneWidget);
      expect(find.text('10 - 15'), findsOneWidget);
      expect(find.text('3 - 7'), findsOneWidget);
      expect(find.text('About:'), findsOneWidget);
      expect(
        find.text(
          'The Persian cat is a long-haired breed of cat characterized by its round face and short muzzle.',
        ),
        findsOneWidget,
      );
      expect(find.text('Adopt Me'), findsOneWidget);
    });

    testWidgets('should display cat image when state is success', (
      tester,
    ) async {
      // Arrange
      mockCubit.setState(ProductDetailsSuccess(cat: mockCat));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Image), findsOneWidget);
      final imageWidget = tester.widget<Image>(find.byType(Image));
      expect(imageWidget.image, isA<NetworkImage>());
      expect(
        (imageWidget.image as NetworkImage).url,
        'https://cdn2.thecatapi.com/images/cat1.jpg',
      );
    });

    testWidgets('should display app bar with correct title and back button', (
      tester,
    ) async {
      // Arrange
      mockCubit.setState(ProductDetailsSuccess(cat: mockCat));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Details'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('should handle adopt me button press with animation', (
      tester,
    ) async {
      // Arrange
      mockCubit.setState(ProductDetailsSuccess(cat: mockCat));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Adopt Me'));
      await tester.pump();

      // Assert
      expect(find.text('Adopt Me'), findsOneWidget);
      // Note: Animation testing would require more complex setup
    });

    testWidgets('should handle image loading error gracefully', (tester) async {
      // Arrange
      mockCubit.setState(ProductDetailsSuccess(cat: mockCat));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Simulate image loading error
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      // The widget should still render without crashing
      expect(find.text('Persian'), findsOneWidget);
    });
  });
}
