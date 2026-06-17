import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mini_merchant_pos_flutter/core/error/failures.dart';
import 'package:mini_merchant_pos_flutter/core/utils/either.dart';
import 'package:mini_merchant_pos_flutter/core/usecase/usecase.dart';
import 'package:mini_merchant_pos_flutter/features/cart/domain/entities/cart_item.dart';
import 'package:mini_merchant_pos_flutter/features/cart/domain/usecases/cart_usecases.dart';

import '../../../../helpers/test_mocks.dart';

void main() {
  late MockCartRepository mockCartRepository;
  late GetCartUseCase getCartUseCase;
  late AddToCartUseCase addToCartUseCase;
  late RemoveFromCartUseCase removeFromCartUseCase;
  late ClearCartUseCase clearCartUseCase;

  setUp(() {
    mockCartRepository = MockCartRepository();
    getCartUseCase = GetCartUseCase(mockCartRepository);
    addToCartUseCase = AddToCartUseCase(mockCartRepository);
    removeFromCartUseCase = RemoveFromCartUseCase(mockCartRepository);
    clearCartUseCase = ClearCartUseCase(mockCartRepository);
  });

  const tCart = Cart(
    items: [
      CartItem(productId: 1, name: 'Coffee', price: 5.0, qty: 2),
    ],
    totalAmount: 10.0,
  );

  group('GetCartUseCase', () {
    test('should get cart from repository', () async {
      // arrange
      when(() => mockCartRepository.getCart())
          .thenAnswer((_) async => const Right<Failure, Cart>(tCart));

      // act
      final result = await getCartUseCase(const NoParams());

      // assert
      result.fold(
        (l) => fail('Expected Right but got Left'),
        (r) {
          expect(r.items.length, tCart.items.length);
          expect(r.totalAmount, tCart.totalAmount);
        },
      );
      verify(() => mockCartRepository.getCart());
      verifyNoMoreInteractions(mockCartRepository);
    });
  });

  group('AddToCartUseCase', () {
    const tProductId = 1;
    const tQty = 2;

    test('should call addToCart on repository', () async {
      // arrange
      when(() => mockCartRepository.addToCart(tProductId, tQty))
          .thenAnswer((_) async => const Right<Failure, void>(null));

      // act
      final result = await addToCartUseCase(const AddToCartParams(productId: tProductId, qty: tQty));

      // assert
      expect(result, const Right<Failure, void>(null));
      verify(() => mockCartRepository.addToCart(tProductId, tQty));
      verifyNoMoreInteractions(mockCartRepository);
    });
  });

  group('RemoveFromCartUseCase', () {
    const tProductId = 1;

    test('should call removeFromCart on repository', () async {
      // arrange
      when(() => mockCartRepository.removeFromCart(tProductId))
          .thenAnswer((_) async => const Right<Failure, void>(null));

      // act
      final result = await removeFromCartUseCase(tProductId);

      // assert
      expect(result, const Right<Failure, void>(null));
      verify(() => mockCartRepository.removeFromCart(tProductId));
      verifyNoMoreInteractions(mockCartRepository);
    });
  });

  group('ClearCartUseCase', () {
    test('should call clearCart on repository', () async {
      // arrange
      when(() => mockCartRepository.clearCart())
          .thenAnswer((_) async => const Right<Failure, void>(null));

      // act
      final result = await clearCartUseCase(const NoParams());

      // assert
      expect(result, const Right<Failure, void>(null));
      verify(() => mockCartRepository.clearCart());
      verifyNoMoreInteractions(mockCartRepository);
    });
  });
}
