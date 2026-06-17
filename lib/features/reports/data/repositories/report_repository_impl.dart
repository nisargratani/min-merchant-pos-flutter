import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/report.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_local_data_source.dart';
import '../datasources/report_remote_data_source.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource _remoteDataSource;
  final ReportLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  ReportRepositoryImpl({
    required ReportRemoteDataSource remoteDataSource,
    required ReportLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, TodaySalesReport>> getTodaySales() async {
    final isOnline = await _networkInfo.isConnected;
    if (isOnline) {
      try {
        final data = await _remoteDataSource.getTodaySales();
        // Save to local storage for offline use
        await _localDataSource.saveTodaySales(data);
        return Right(TodaySalesReport.fromJson(data));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      try {
        final data = await _localDataSource.getTodaySales();
        return Right(TodaySalesReport.fromJson(data));
      } catch (e) {
        return Left(CacheFailure('No offline sales report available.'));
      }
    }
  }

  @override
  Future<Either<Failure, PendingSyncReport>> getPendingSync() async {
    try {
      final data = await _remoteDataSource.getPendingSync();
      return Right(PendingSyncReport.fromJson(data));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
