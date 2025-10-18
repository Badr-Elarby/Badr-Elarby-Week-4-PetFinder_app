import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:petfinder_app/features/home/data/models/cat_image_model.dart';
import 'package:petfinder_app/features/home/data/models/cat_breed_model.dart';
import 'package:petfinder_app/features/home/presentation/widgets/cat_card.dart';

void main() {
  group('CatCard', () {
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
        ),
      ],
    );

    Widget createWidgetUnderTest() {
      return MaterialApp.router(
        routerConfig: GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) =>
                  Scaffold(body: CatCard(cat: mockCat)),
            ),
            GoRoute(
              path: '/product-details/:id',
              builder: (context, state) => Scaffold(
                body: Text('Product Details: ${state.pathParameters['id']}'),
              ),
            ),
          ],
        ),
      );
    }

    testWidgets('should display cat information correctly', (tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Persian'), findsOneWidget);
      expect(find.text('10 - 15 years'), findsOneWidget);
      expect(find.text('Iran'), findsOneWidget);
      expect(find.text('3 - 7'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      expect(find.byIcon(Icons.scale), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('should navigate to product details when tapped', (
      tester,
    ) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(CatCard));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Product Details: cat1'), findsOneWidget);
    });

    testWidgets('should display fallback text when breed data is missing', (
      tester,
    ) async {
      // Arrange
      final catWithoutBreeds = CatImageModel(
        id: "cat1",
        url: "https://cdn2.thecatapi.com/images/cat1.jpg",
        width: 800,
        height: 600,
        breeds: [],
      );

      final widget = MaterialApp.router(
        routerConfig: GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) =>
                  Scaffold(body: CatCard(cat: catWithoutBreeds)),
            ),
          ],
        ),
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Unknown Breed'), findsOneWidget);
    });

    testWidgets(
      'should display partial information when some breed fields are null',
      (tester) async {
        // Arrange
        final catWithPartialData = CatImageModel(
          id: "cat1",
          url: "https://cdn2.thecatapi.com/images/cat1.jpg",
          width: 800,
          height: 600,
          breeds: [
            CatBreedModel(
              id: "pers",
              name: "Persian",
              origin: null,
              lifeSpan: null,
              weight: "3 - 7",
            ),
          ],
        );

        final widget = MaterialApp.router(
          routerConfig: GoRouter(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) =>
                    Scaffold(body: CatCard(cat: catWithPartialData)),
              ),
            ],
          ),
        );

        // Act
        await tester.pumpWidget(widget);
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Persian'), findsOneWidget);
        expect(find.text('3 - 7'), findsOneWidget);
        expect(find.text('Unknown'), findsOneWidget); // For life span
        expect(find.text('Unknown'), findsOneWidget); // For origin
      },
    );

    testWidgets('should handle image loading error gracefully', (tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // The widget should still render without crashing
      expect(find.text('Persian'), findsOneWidget);
      expect(find.byIcon(Icons.pets), findsOneWidget); // Fallback icon
    });

    testWidgets('should have proper styling and layout', (tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Container), findsWidgets);
      expect(find.byType(Row), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(Expanded), findsOneWidget);
    });
  });
}
