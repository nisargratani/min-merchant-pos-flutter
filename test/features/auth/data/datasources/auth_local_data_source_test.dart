import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mini_merchant_pos_flutter/features/auth/data/datasources/auth_local_data_source.dart';

import '../../../../helpers/test_mocks.dart';

void main() {
  late AuthLocalDataSource dataSource;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSource = AuthLocalDataSource(mockSharedPreferences);
  });

  // Note: testing FlutterSecureStorage within pure unit tests requires some specific 
  // mocking because it relies on platform channels, or we can mock it by injecting it 
  // into AuthLocalDataSource. In our current implementation, FlutterSecureStorage is instantiated
  // directly inside AuthLocalDataSource, so unit testing it without integration test environments
  // might be limited, but we can test the SharedPreferences cache interactions.
  
  final tUserJson = {
    'userId': 1,
    'name': 'admin',
    'role': 'ADMIN',
    'token': 'test_token',
  };

  test('should call SharedPreferences to cache user data', () async {
    // arrange
    when(() => mockSharedPreferences.setString(any(), any()))
        .thenAnswer((_) async => true);

    // act
    await dataSource.cacheUser(tUserJson);

    // assert
    verify(() => mockSharedPreferences.setString('cached_user', jsonEncode(tUserJson)));
  });

  test('should retrieve cached user data from SharedPreferences', () {
    // arrange
    when(() => mockSharedPreferences.getString('cached_user'))
        .thenReturn(jsonEncode(tUserJson));

    // act
    final result = dataSource.getCachedUser();

    // assert
    expect(result, equals(tUserJson));
    verify(() => mockSharedPreferences.getString('cached_user'));
  });

  test('should return null when there is no cached user data', () {
    // arrange
    when(() => mockSharedPreferences.getString('cached_user'))
        .thenReturn(null);

    // act
    final result = dataSource.getCachedUser();

    // assert
    expect(result, isNull);
  });
}
