import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petfinder_app/features/Favorites/presentation/screens/favourite_screen.dart';
import 'package:petfinder_app/features/Favorites/presentation/cubits/favorites_cubit/favorites_cubit.dart';
import 'package:petfinder_app/features/Favorites/presentation/cubits/favorites_cubit/favorites_state.dart';
import 'package:petfinder_app/features/home/data/models/cat_image_model.dart';
import 'package:petfinder_app/features/home/data/models/cat_breed_model.dart';

// Mock classes using bloc_test's MockCubit
class MockFavoritesCubit extends MockCubit<FavoritesState>
    implements FavoritesCubit {}

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

  final mockSiameseCat = CatImageModel(
    id: "cat2",
    url: "https://cdn2.thecatapi.com/images/cat2.jpg",
    width: 600,
    height: 400,
    breeds: [
      CatBreedModel(
        id: "siamese",
        name: "Siamese",
        origin: "Thailand",
        lifeSpan: "12 - 15",
        weight: "2 - 6",
      ),
    ],
  );

  final mockCats = [mockPersianCat, mockSiameseCat];

  setUpAll(() {
    // Initialize Flutter bindings
    TestWidgetsFlutterBinding.ensureInitialized();
    // Register fallback for CatImageModel
    registerFallbackValue(mockPersianCat);
  });

  setUp(() {
    mockFavoritesCubit = MockFavoritesCubit();
    // Setup default mocks for all async methods - these can be overridden in individual tests
    when(() => mockFavoritesCubit.getFavorites()).thenAnswer((_) async {});
    when(
      () => mockFavoritesCubit.addToFavorites(any()),
    ).thenAnswer((_) async {});
    when(
      () => mockFavoritesCubit.removeFromFavorites(any()),
    ).thenAnswer((_) async {});
    when(() => mockFavoritesCubit.clearFavorites()).thenAnswer((_) async {});
    when(() => mockFavoritesCubit.isFavorite(any())).thenReturn(false);
  });

  tearDown(() {
    mockFavoritesCubit.close();
  });

  Widget createWidgetUnderTest() {
    return BlocProvider<FavoritesCubit>.value(
      value: mockFavoritesCubit,
      child: ScreenUtilInit(
        designSize: const Size(360, 640),
        builder: (_, __) => const MaterialApp(home: FavouriteScreen()),
      ),
    );
  }

  group('FavouriteScreen', () {
    testWidgets(
      'should show loading indicator when state is FavoritesLoading',
      (tester) async {
        // Arrange
        when(() => mockFavoritesCubit.state).thenReturn(FavoritesLoading());

        // Act
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('My Favorites'), findsOneWidget);
        expect(
          find.text('Your favorite cats are here for easy access'),
          findsOneWidget,
        );
      },
    );

    testWidgets('should display empty state when no favorites', (tester) async {
      // Arrange
      when(
        () => mockFavoritesCubit.state,
      ).thenReturn(const FavoritesSuccess(favorites: []));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Assert
      expect(find.text('No favorites yet'), findsOneWidget);
      expect(
        find.text('Add some cats to your favorites to see them here'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('should display list of favorites when data exists', (
      tester,
    ) async {
      // Arrange
      when(
        () => mockFavoritesCubit.state,
      ).thenReturn(FavoritesSuccess(favorites: mockCats));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Persian'), findsOneWidget);
      expect(find.text('Siamese'), findsOneWidget);
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('should call getFavorites on init', (tester) async {
      // Arrange
      when(() => mockFavoritesCubit.state).thenReturn(FavoritesInitial());
      clearInteractions(mockFavoritesCubit);

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Assert
      verify(() => mockFavoritesCubit.getFavorites()).called(1);
    });

    testWidgets('should have proper header and icon', (tester) async {
      // Arrange
      when(() => mockFavoritesCubit.state).thenReturn(FavoritesLoading());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Assert
      expect(find.text('My Favorites'), findsOneWidget);
      expect(find.byIcon(Icons.heart_broken_outlined), findsOneWidget);
      expect(find.byType(SafeArea), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
    });

    testWidgets('should display header subtitle correctly', (tester) async {
      // Arrange
      when(() => mockFavoritesCubit.state).thenReturn(FavoritesLoading());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Assert header text presence
      expect(
        find.text('Your favorite cats are here for easy access'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.heart_broken_outlined), findsOneWidget);
    });
  });
}
