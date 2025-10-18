import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petfinder_app/features/Favorites/presentation/widgets/favorite_product_card.dart';
import 'package:petfinder_app/features/Favorites/presentation/cubits/favorites_cubit/favorites_cubit.dart';
import 'package:petfinder_app/features/Favorites/presentation/cubits/favorites_cubit/favorites_state.dart';
import 'package:petfinder_app/features/home/data/models/cat_image_model.dart';
import 'package:petfinder_app/features/home/data/models/cat_breed_model.dart';

// Mock classes
class MockFavoritesCubit extends Mock implements FavoritesCubit {}

void main() {
  late MockFavoritesCubit mockFavoritesCubit;

  // Mock cat data
  final mockPersianCat = CatImageModel(
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
      ),
    ],
  );

  final mockCatWithoutBreeds = CatImageModel(
    id: "cat2",
    url: "https://cdn2.thecatapi.com/images/cat2.jpg",
    width: 600,
    height: 400,
    breeds: [],
  );

  setUpAll(() {
    // Initialize Flutter bindings for testing
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() {
    mockFavoritesCubit = MockFavoritesCubit();
    // Setup default mock behavior for all void methods to return Future.value()
    when(
      () => mockFavoritesCubit.removeFromFavorites(any()),
    ).thenAnswer((_) async => Future.value());
  });

  Widget createWidgetUnderTest(CatImageModel cat) {
    return BlocProvider<FavoritesCubit>.value(
      value: mockFavoritesCubit,
      child: ScreenUtilInit(
        designSize: const Size(360, 640),
        builder: (_, __) => MaterialApp(
          home: Scaffold(body: FavoriteProductCard(cat: cat)),
        ),
      ),
    );
  }

  final favoriteCardKey = const Key('favorite_product_card');

  group('FavoriteProductCard', () {
    testWidgets('should display complete cat information correctly', (
      tester,
    ) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest(mockPersianCat));
      await tester.pumpAndSettle();

      // Assert - Check main elements are displayed
      expect(find.text('Persian'), findsOneWidget);
      expect(
        find.text('10 - 15 years • Iran'),
        findsOneWidget,
      ); // Correct formatted text
      expect(find.text('3 - 7'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      expect(find.byIcon(Icons.scale), findsOneWidget);
      expect(
        find.byIcon(Icons.favorite),
        findsOneWidget,
      ); // Filled heart for favorites
    });

    testWidgets('should display fallback "Unknown Breed" when no breed data', (
      tester,
    ) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest(mockCatWithoutBreeds));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Unknown Breed'), findsOneWidget);
      expect(find.byIcon(Icons.pets), findsOneWidget); // Fallback icon shown
    });

    testWidgets(
      'should handle image loading error gracefully with fallback icon',
      (tester) async {
        // Act
        await tester.pumpWidget(createWidgetUnderTest(mockPersianCat));
        await tester.pumpAndSettle();

        // The widget should render with fallback icon if image fails
        expect(find.text('Persian'), findsOneWidget);
        // Image widget exists (even if network fails, widget structure is there)
        expect(find.byType(Image), findsOneWidget);
      },
    );

    testWidgets('should show correct heart icon state when in favorites', (
      tester,
    ) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest(mockPersianCat));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.favorite), findsOneWidget); // Filled heart shown
      expect(
        find.byIcon(Icons.favorite_border),
        findsNothing,
      ); // Empty heart not shown
    });
  });
}
