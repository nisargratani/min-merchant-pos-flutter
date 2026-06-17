import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mini_merchant_pos_flutter/core/error/failures.dart';
import 'package:mini_merchant_pos_flutter/core/utils/either.dart';
import 'package:mini_merchant_pos_flutter/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:mini_merchant_pos_flutter/features/cart/domain/entities/cart_item.dart';

import '../../../../helpers/test_mocks.dart';

void main() {
  late CartRepositoryImpl repository;
  late MockCartRemoteDataSource mockRemoteDataSource;
  late MockCartLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUpAll(() {
    registerFallbackValue(const Cart(items: [], totalAmount: 0));
  });

  setUp(() {
    mockRemoteDataSource = MockCartRemoteDataSource();
    mockLocalDataSource = MockCartLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = CartRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  const tCartItem = CartItem(productId: 1, name: 'Coffee', price: 5.0, qty: 2);
  const tLocalCart = Cart(items: [tCartItem], totalAmount: 10.0);
  final tRemoteCartJson = {
    'items': [
      {'productId': 1, 'name': 'Coffee', 'price': 5.0, 'qty': 2}
    ],
    'totalAmount': 10.0
  };

  group('getCart', () {
    test('should return remote cart and sync when online', () async {
      // arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockLocalDataSource.getCart()).thenAnswer((_) async => tLocalCart);
      when(() => mockRemoteDataSource.getCart()).thenAnswer((_) async => tRemoteCartJson);
      when(() => mockLocalDataSource.saveCart(any())).thenAnswer((_) async => {});

      // act
      final result = await repository.getCart();

      // assert
      result.fold(
        (l) => fail('Expected Right but got Left'),
        (r) {
          expect(r.items.length, 1);
          expect(r.items.first.productId, tCartItem.productId);
        },
      );
      verify(() => mockNetworkInfo.isConnected);
      verify(() => mockLocalDataSource.getCart()); // From _syncLocalToRemote
      verify(() => mockRemoteDataSource.getCart());
      verify(() => mockLocalDataSource.saveCart(any()));
    });

    test('should return local cart when offline', () async {
      // arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(() => mockLocalDataSource.getCart()).thenAnswer((_) async => tLocalCart);

      // act
      final result = await repository.getCart();

      // assert
      result.fold(
        (l) => fail('Expected Right but got Left'),
        (r) {
          expect(r.items.length, 1);
          expect(r.items.first.productId, tCartItem.productId);
        },
      );
      verify(() => mockNetworkInfo.isConnected);
      verify(() => mockLocalDataSource.getCart());
      verifyNever(() => mockRemoteDataSource.getCart());
    });
  });

  group('addToCart', () {
    const tProductId = 1;
    const tQty = 2;

    test('should update local and remote when online', () async {
      // arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockLocalDataSource.addToCart(tProductId, tQty)).thenAnswer((_) async => {});
      when(() => mockRemoteDataSource.addToCart(tProductId, tQty)).thenAnswer((_) async => {});

      // act
      final result = await repository.addToCart(tProductId, tQty);

      // assert
      expect(result, const Right<Failure, void>(null));
      verify(() => mockLocalDataSource.addToCart(tProductId, tQty));
      verify(() => mockRemoteDataSource.addToCart(tProductId, tQty));
    });

    test('should only update local when offline', () async {
      // arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(() => mockLocalDataSource.addToCart(tProductId, tQty)).thenAnswer((_) async => {});

      // act
      final result = await repository.addToCart(tProductId, tQty);

      // assert
      expect(result, const Right<Failure, void>(null));
      verify(() => mockLocalDataSource.addToCart(tProductId, tQty));
      verifyNever(() => mockRemoteDataSource.addToCart(any(), any()));
    });
  });

  group('removeFromCart', () {
    const tProductId = 1;

    test('should update local and remote when online', () async {
      // arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockLocalDataSource.removeFromCart(tProductId)).thenAnswer((_) async => {});
      when(() => mockRemoteDataSource.removeFromCart(tProductId)).thenAnswer((_) async => {});

      // act
      final result = await repository.removeFromCart(tProductId);

      // assert
      expect(result, const Right<Failure, void>(null));
      verify(() => mockLocalDataSource.removeFromCart(tProductId));
      verify(() => mockRemoteDataSource.removeFromCart(tProductId));
    });

    test('should only update local when offline', () async {
      // arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(() => mockLocalDataSource.removeFromCart(tProductId)).thenAnswer((_) async => {});

      // act
      final result = await repository.removeFromCart(tProductId);

      // assert
      expect(result, const Right<Failure, void>(null));
      verify(() => mockLocalDataSource.removeFromCart(tProductId));
      verifyNever(() => mockRemoteDataSource.removeFromCart(any()));
    });
  });

  group('clearCart', () {
    test('should clear local and remote when online', () async {
      // arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockLocalDataSource.clearCart()).thenAnswer((_) async => {});
      when(() => mockRemoteDataSource.clearCart()).thenAnswer((_) async => {});

      // act
      final result = await repository.clearCart();

      // assert
      expect(result, const Right<Failure, void>(null));
      verify(() => mockLocalDataSource.clearCart());
      verify(() => mockRemoteDataSource.clearCart());
    });
  });
}
