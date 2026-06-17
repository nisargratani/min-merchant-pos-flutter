import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mini_merchant_pos_flutter/core/network/network_info.dart';
import 'package:mini_merchant_pos_flutter/features/auth/domain/repositories/auth_repository.dart';
import 'package:mini_merchant_pos_flutter/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:mini_merchant_pos_flutter/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:mini_merchant_pos_flutter/features/auth/domain/usecases/login_usecase.dart';
import 'package:mini_merchant_pos_flutter/features/auth/domain/usecases/logout_usecase.dart';
import 'package:mini_merchant_pos_flutter/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:mini_merchant_pos_flutter/features/products/domain/repositories/product_repository.dart';
import 'package:mini_merchant_pos_flutter/features/products/data/datasources/product_remote_data_source.dart';
import 'package:mini_merchant_pos_flutter/features/products/domain/usecases/get_products_usecase.dart';
import 'package:mini_merchant_pos_flutter/features/products/data/datasources/product_local_data_source.dart';
import 'package:mini_merchant_pos_flutter/features/cart/domain/repositories/cart_repository.dart';
import 'package:mini_merchant_pos_flutter/features/cart/data/datasources/cart_local_data_source.dart';
import 'package:mini_merchant_pos_flutter/features/cart/data/datasources/cart_remote_data_source.dart';

// --- Core Mocks ---
class MockNetworkInfo extends Mock implements NetworkInfo {}
class MockSharedPreferences extends Mock implements SharedPreferences {}
class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

// --- Auth Mocks ---
class MockAuthRepository extends Mock implements AuthRepository {}
class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}
class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}
class MockLoginUseCase extends Mock implements LoginUseCase {}
class MockLogoutUseCase extends Mock implements LogoutUseCase {}
class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

// --- Product Mocks ---
class MockProductRepository extends Mock implements ProductRepository {}
class MockProductRemoteDataSource extends Mock implements ProductRemoteDataSource {}
class MockProductLocalDataSource extends Mock implements ProductLocalDataSource {}
class MockGetProductsUseCase extends Mock implements GetProductsUseCase {}

// --- Cart Mocks ---
class MockCartRepository extends Mock implements CartRepository {}
class MockCartLocalDataSource extends Mock implements CartLocalDataSource {}
class MockCartRemoteDataSource extends Mock implements CartRemoteDataSource {}

// --- Widget Test Wrapper ---
Widget createTestApp({
  required Widget child,
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      home: child,
      // Suppress annoying pixel overflow errors during tests by shrinking the screen artificially,
      // or providing a standard responsive wrapping if needed.
    ),
  );
}
