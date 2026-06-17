import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_remote_data_source.dart';
import '../datasources/cart_local_data_source.dart';

/// Concrete implementation of [CartRepository].
class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource _remoteDataSource;
  final CartLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  CartRepositoryImpl({
    required CartRemoteDataSource remoteDataSource,
    required CartLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _networkInfo = networkInfo;

  /// Syncs local cart to remote backend using Delta logic.
  Future<void> _syncLocalToRemote() async {
    try {
      final localCart = await _localDataSource.getCart();
      
      // Fetch remote cart to calculate deltas
      final remoteData = await _remoteDataSource.getCart();
      final remoteCart = Cart.fromJson(remoteData);
      
      final remoteQtyMap = {
        for (var item in remoteCart.items) item.productId: item.qty
      };

      // 1. Send deltas for items present in local cart
      for (final localItem in localCart.items) {
        final remoteQty = remoteQtyMap[localItem.productId] ?? 0;
        final delta = localItem.qty - remoteQty;
        
        if (delta != 0) {
          await _remoteDataSource.addToCart(localItem.productId, delta);
        }
      }

      // 2. Remove items from remote that are completely missing in local cart
      for (final remoteItem in remoteCart.items) {
        final existsLocally = localCart.items.any((i) => i.productId == remoteItem.productId);
        if (!existsLocally) {
          await _remoteDataSource.removeFromCart(remoteItem.productId);
        }
      }
    } catch (_) {
      // Ignore sync errors here, it will retry on next fetch
    }
  }

  @override
  Future<Either<Failure, Cart>> getCart() async {
    try {
      final isOnline = await _networkInfo.isConnected;
      if (isOnline) {
        await _syncLocalToRemote();

        final data = await _remoteDataSource.getCart();
        final remoteCart = Cart.fromJson(data);

        // Save fresh remote cart to local DB
        await _localDataSource.saveCart(remoteCart);
        return Right(remoteCart);
      } else {
        final localCart = await _localDataSource.getCart();
        return Right(localCart);
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addToCart(int productId, int qty) async {
    try {
      // Update locally first (offline-first approach)
      await _localDataSource.addToCart(productId, qty);

      final isOnline = await _networkInfo.isConnected;
      if (isOnline) {
        await _remoteDataSource.addToCart(productId, qty);
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromCart(int productId) async {
    try {
      // Update locally first
      await _localDataSource.removeFromCart(productId);

      final isOnline = await _networkInfo.isConnected;
      if (isOnline) {
        await _remoteDataSource.removeFromCart(productId);
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearCart() async {
    try {
      // Update locally first
      await _localDataSource.clearCart();

      final isOnline = await _networkInfo.isConnected;
      if (isOnline) {
        await _remoteDataSource.clearCart();
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
