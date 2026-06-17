import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mini_merchant_pos_flutter/features/products/data/repositories/product_repository_impl.dart';
import 'package:mini_merchant_pos_flutter/features/products/domain/entities/product.dart';

import '../../../../helpers/test_mocks.dart';

void main() {
  late ProductRepositoryImpl repository;
  late MockProductRemoteDataSource mockRemoteDataSource;

  late MockProductLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockProductRemoteDataSource();
    mockLocalDataSource = MockProductLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = ProductRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  final tProductModelDataList = [
    {'id': 1, 'name': 'Coffee', 'price': 5.0, 'stock': 50},
  ];

  final tProducts = [
    const Product(id: 1, name: 'Coffee', price: 5.0, stock: 50),
  ];

  group('getProducts', () {
    test(
      'should return list of Products when remote data source is successful',
      () async {
        // arrange
        when(
          () => mockRemoteDataSource.getProducts(),
        ).thenAnswer((_) async => tProductModelDataList);

        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(
          () => mockLocalDataSource.cacheProducts(any()),
        ).thenAnswer((_) async => {});

        // act
        final result = await repository.getProducts();

        // assert
        result.fold((l) => fail('Expected Right but got Left'), (r) {
          expect(r.length, tProducts.length);
          expect(r.first, tProducts.first);
        });
        verify(() => mockRemoteDataSource.getProducts());
        verify(() => mockLocalDataSource.cacheProducts(tProducts));
      },
    );

    test(
      'should return ServerFailure when remote data source throws an exception',
      () async {
        // arrange
        when(
          () => mockRemoteDataSource.getProducts(),
        ).thenThrow(Exception('Server error'));

        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(
          () => mockLocalDataSource.getProducts(),
        ).thenAnswer((_) async => <Product>[]);

        // act
        final result = await repository.getProducts();

        // assert
        result.fold((l) => fail('Expected Right but got Left'), (r) {
          expect(r.isEmpty, true);
        });
        verify(() => mockRemoteDataSource.getProducts());
      },
    );
  });
}
