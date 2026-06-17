import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mini_merchant_pos_flutter/core/error/failures.dart';
import 'package:mini_merchant_pos_flutter/core/usecase/usecase.dart';
import 'package:mini_merchant_pos_flutter/core/utils/either.dart';
import 'package:mini_merchant_pos_flutter/features/products/domain/entities/product.dart';
import 'package:mini_merchant_pos_flutter/features/products/domain/usecases/get_products_usecase.dart';

import '../../../../helpers/test_mocks.dart';

void main() {
  late GetProductsUseCase usecase;
  late MockProductRepository mockProductRepository;

  setUp(() {
    mockProductRepository = MockProductRepository();
    usecase = GetProductsUseCase(mockProductRepository);
  });

  final tProducts = <Product>[
    const Product(
      id: 1,
      name: 'Coffee',
      price: 5.0,
      stock: 50,
    ),
  ];

  test('should get a list of products from the repository', () async {
    // arrange
    when(() => mockProductRepository.getProducts())
        .thenAnswer((_) async => Right(tProducts));

    // act
    final result = await usecase(const NoParams());

    // assert
    result.fold(
      (l) => fail('Expected Right but got Left'),
      (r) {
        expect(r.length, tProducts.length);
        expect(r.first, tProducts.first);
      },
    );
    verify(() => mockProductRepository.getProducts());
    verifyNoMoreInteractions(mockProductRepository);
  });

  test('should return ServerFailure when getting products fails', () async {
    // arrange
    const tFailure = ServerFailure('Failed to fetch products');
    when(() => mockProductRepository.getProducts())
        .thenAnswer((_) async => const Left<Failure, List<Product>>(tFailure));

    // act
    final result = await usecase(const NoParams());

    // assert
    expect(result, const Left<Failure, List<Product>>(tFailure));
    verify(() => mockProductRepository.getProducts());
    verifyNoMoreInteractions(mockProductRepository);
  });
}
