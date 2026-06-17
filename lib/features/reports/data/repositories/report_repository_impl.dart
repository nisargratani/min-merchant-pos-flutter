import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/report.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_remote_data_source.dart';

/// Concrete implementation of [ReportRepository].
class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource _remoteDataSource;

  ReportRepositoryImpl({required ReportRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, TodaySalesReport>> getTodaySales() async {
    try {
      final data = await _remoteDataSource.getTodaySales();
      return Right(TodaySalesReport.fromJson(data));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
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
