import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mini_merchant_pos_flutter/core/error/failures.dart';
import 'package:mini_merchant_pos_flutter/core/utils/either.dart';
import 'package:mini_merchant_pos_flutter/features/auth/domain/entities/user.dart';
import 'package:mini_merchant_pos_flutter/features/auth/domain/usecases/login_usecase.dart';

import '../../../../helpers/test_mocks.dart';

void main() {
  late LoginUseCase usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = LoginUseCase(mockAuthRepository);
  });

  const tUsername = 'admin';
  const tPassword = 'password123';
  final tUser = const User(
    userId: 1,
    name: tUsername,
    role: UserRole.admin,
    token: 'test_token',
  );

  test('should return User from the repository when login is successful', () async {
    // arrange
    when(() => mockAuthRepository.login(tUsername, tPassword))
        .thenAnswer((_) async => Right(tUser));

    // act
    final result = await usecase(const LoginParams(username: tUsername, password: tPassword));

    // assert
    expect(result, Right<Failure, User>(tUser));
    verify(() => mockAuthRepository.login(tUsername, tPassword));
    verifyNoMoreInteractions(mockAuthRepository);
  });

  test('should return Failure from the repository when login fails', () async {
    // arrange
    const tFailure = ServerFailure('Invalid credentials');
    when(() => mockAuthRepository.login(tUsername, tPassword))
        .thenAnswer((_) async => const Left(tFailure));

    // act
    final result = await usecase(const LoginParams(username: tUsername, password: tPassword));

    // assert
    expect(result, Left<Failure, User>(tFailure));
    verify(() => mockAuthRepository.login(tUsername, tPassword));
    verifyNoMoreInteractions(mockAuthRepository);
  });
}
