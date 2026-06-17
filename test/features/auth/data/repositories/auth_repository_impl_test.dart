import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mini_merchant_pos_flutter/core/error/failures.dart';
import 'package:mini_merchant_pos_flutter/core/utils/either.dart';
import 'package:mini_merchant_pos_flutter/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mini_merchant_pos_flutter/features/auth/domain/entities/user.dart';

import '../../../../helpers/test_mocks.dart';

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockAuthLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockLocalDataSource = MockAuthLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  const tUsername = 'admin';
  const tPassword = 'password123';
  final tUserModelData = {
    'userId': 1,
    'name': tUsername,
    'role': 'ADMIN',
    'token': 'test_token',
  };
  final tUser = User.fromJson(tUserModelData);

  group('login', () {
    test('should return NetworkFailure when device is offline', () async {
      // arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      // act
      final result = await repository.login(tUsername, tPassword);

      // assert
      expect(result, const Left<Failure, User>(NetworkFailure()));
      verify(() => mockNetworkInfo.isConnected);
      verifyZeroInteractions(mockRemoteDataSource);
    });

    test('should return User and cache token/user when online and remote call succeeds', () async {
      // arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.login(tUsername, tPassword))
          .thenAnswer((_) async => tUserModelData);
      when(() => mockLocalDataSource.saveToken(any())).thenAnswer((_) async => {});
      when(() => mockLocalDataSource.cacheUser(any())).thenAnswer((_) async => {});

      // act
      final result = await repository.login(tUsername, tPassword);

      // assert
      expect(result, Right<Failure, User>(tUser));
      verify(() => mockRemoteDataSource.login(tUsername, tPassword));
      verify(() => mockLocalDataSource.saveToken('test_token'));
      verify(() => mockLocalDataSource.cacheUser(tUserModelData));
    });

    test('should return ServerFailure when remote call throws an exception', () async {
      // arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.login(tUsername, tPassword))
          .thenThrow(Exception('Server error'));

      // act
      final result = await repository.login(tUsername, tPassword);

      // assert
      expect(result, const Left<Failure, User>(ServerFailure('Exception: Server error')));
    });
  });

  group('getCurrentUser', () {
    test('should return right null if not authenticated', () async {
      // arrange
      when(() => mockLocalDataSource.hasToken()).thenAnswer((_) async => false);

      // act
      final result = await repository.getCurrentUser();

      // assert
      expect(result, const Right<Failure, User?>(null));
      verify(() => mockLocalDataSource.hasToken());
      verifyZeroInteractions(mockRemoteDataSource);
    });

    test('should return cached user if remote call fails (offline-first fallback)', () async {
      // arrange
      when(() => mockLocalDataSource.hasToken()).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.getMe()).thenThrow(Exception('Network error'));
      when(() => mockLocalDataSource.getCachedUser()).thenReturn(tUserModelData);

      // act
      final result = await repository.getCurrentUser();

      // assert
      expect(result, Right<Failure, User?>(tUser));
      verify(() => mockRemoteDataSource.getMe());
      verify(() => mockLocalDataSource.getCachedUser());
    });
  });
}
