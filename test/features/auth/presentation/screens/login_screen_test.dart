import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mini_merchant_pos_flutter/core/error/failures.dart';
import 'package:mini_merchant_pos_flutter/core/utils/either.dart';
import 'package:mini_merchant_pos_flutter/features/auth/domain/entities/user.dart';
import 'package:mini_merchant_pos_flutter/features/auth/domain/usecases/login_usecase.dart';
import 'package:mini_merchant_pos_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:mini_merchant_pos_flutter/features/auth/presentation/screens/login_screen.dart';

import 'package:mini_merchant_pos_flutter/core/usecase/usecase.dart';
import '../../../../helpers/test_mocks.dart';

// We need a fake params class for mocktail to register fallback values
class FakeLoginParams extends Fake implements LoginParams {}

class FakeNoParams extends Fake implements NoParams {}

void main() {
  late MockLoginUseCase mockLoginUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;

  setUpAll(() {
    registerFallbackValue(FakeLoginParams());
    registerFallbackValue(FakeNoParams());
  });

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockGetCurrentUserUseCase = MockGetCurrentUserUseCase();
  });

  Widget createWidgetUnderTest() {
    return createTestApp(
      overrides: [
        loginUseCaseProvider.overrideWithValue(mockLoginUseCase),
        logoutUseCaseProvider.overrideWithValue(mockLogoutUseCase),
        getCurrentUserUseCaseProvider.overrideWithValue(
          mockGetCurrentUserUseCase,
        ),
      ],
      child: const LoginScreen(),
    );
  }

  testWidgets('should show loading indicator while logging in', (
    WidgetTester tester,
  ) async {
    // arrange
    when(
      () => mockGetCurrentUserUseCase(any()),
    ).thenAnswer((_) async => const Right(null));
    when(() => mockLoginUseCase(any())).thenAnswer((_) async {
      await Future.delayed(const Duration(milliseconds: 50));
      return Right(User(userId: 1, name: 'admin', role: UserRole.admin));
    });

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle(); // Wait for initial loads

    // act
    await tester.enterText(find.byType(TextField).first, 'admin');
    await tester.enterText(find.byType(TextField).last, 'password');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump(); // Start the future

    // assert
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle(); // Finish the future
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('should show error snackbar when login fails', (
    WidgetTester tester,
  ) async {
    // arrange
    when(
      () => mockGetCurrentUserUseCase(any()),
    ).thenAnswer((_) async => const Right(null));
    when(
      () => mockLoginUseCase(any()),
    ).thenAnswer((_) async => const Left(ServerFailure('Invalid credentials')));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // act
    await tester.enterText(find.byType(TextField).first, 'admin');
    await tester.enterText(find.byType(TextField).last, 'wrongpass');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    // assert
    expect(find.text('Invalid credentials'), findsOneWidget);
  });
}
