import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:mini_merchant_pos_flutter/core/error/failures.dart';
import 'package:mini_merchant_pos_flutter/core/utils/either.dart';
import 'package:mini_merchant_pos_flutter/features/auth/domain/entities/user.dart';
import 'package:mini_merchant_pos_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:mini_merchant_pos_flutter/features/products/domain/entities/product.dart';
import 'package:mini_merchant_pos_flutter/features/products/presentation/providers/product_provider.dart';
import 'package:mini_merchant_pos_flutter/features/products/presentation/screens/product_list_screen.dart';

import 'package:mini_merchant_pos_flutter/core/usecase/usecase.dart';
import '../../../../helpers/test_mocks.dart';

class FakeNoParams extends Fake implements NoParams {}

void main() {
  late MockGetProductsUseCase mockGetProductsUseCase;

  setUpAll(() {
    registerFallbackValue(FakeNoParams());
  });

  setUp(() {
    mockGetProductsUseCase = MockGetProductsUseCase();
  });

  final tProducts = <Product>[
    const Product(id: 1, name: 'Coffee', price: 5.0, stock: 50),
  ];

  Widget createWidgetUnderTest(User currentUser) {
    return createTestApp(
      overrides: [
        getProductsUseCaseProvider.overrideWithValue(mockGetProductsUseCase),
        currentUserProvider.overrideWithValue(currentUser),
      ],
      child: const ProductListScreen(),
    );
  }

  testWidgets('should show loading indicator then display products', (
    WidgetTester tester,
  ) async {
    // arrange
    when(() => mockGetProductsUseCase(any())).thenAnswer((_) async {
      await Future.delayed(const Duration(milliseconds: 50));
      return Right<Failure, List<Product>>(tProducts);
    });

    final adminUser = const User(
      userId: 1,
      name: 'admin',
      role: UserRole.admin,
    );

    await mockNetworkImages(() async {
      await tester.pumpWidget(createWidgetUnderTest(adminUser));

      // assert loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle(); // finish loading

      // assert products displayed
      expect(find.text('Coffee'), findsOneWidget);
      expect(find.textContaining('\$5.00'), findsOneWidget);

      // assert Analytics icon is visible for Admin
      expect(find.byIcon(Icons.analytics), findsOneWidget);
    });
  });

  testWidgets('should hide FAB for Cashier role', (WidgetTester tester) async {
    // arrange
    when(
      () => mockGetProductsUseCase(any()),
    ).thenAnswer((_) async => Right<Failure, List<Product>>(tProducts));

    final cashierUser = const User(
      userId: 2,
      name: 'cashier',
      role: UserRole.employee,
    );

    await mockNetworkImages(() async {
      await tester.pumpWidget(createWidgetUnderTest(cashierUser));
      await tester.pumpAndSettle();

      // assert products displayed
      expect(find.text('Coffee'), findsOneWidget);

      // assert Analytics icon is HIDDEN for Cashier
      expect(find.byIcon(Icons.analytics), findsNothing);
    });
  });

  testWidgets('should show error text when fetching products fails', (
    WidgetTester tester,
  ) async {
    // arrange
    when(
      () => mockGetProductsUseCase(any()),
    ).thenAnswer((_) async => const Left(ServerFailure('API Error')));

    final adminUser = const User(
      userId: 1,
      name: 'admin',
      role: UserRole.admin,
    );

    await mockNetworkImages(() async {
      await tester.pumpWidget(createWidgetUnderTest(adminUser));
      await tester.pumpAndSettle();

      // assert error message
      expect(find.textContaining('API Error'), findsOneWidget);
    });
  });
}
