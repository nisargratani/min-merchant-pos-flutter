import '../../domain/entities/report.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_remote_data_source.dart';

/// Concrete implementation of [ReportRepository].
class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource _remoteDataSource;

  ReportRepositoryImpl({required ReportRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<TodaySalesReport> getTodaySales() async {
    final data = await _remoteDataSource.getTodaySales();
    return TodaySalesReport.fromJson(data);
  }

  @override
  Future<PendingSyncReport> getPendingSync() async {
    final data = await _remoteDataSource.getPendingSync();
    return PendingSyncReport.fromJson(data);
  }
}
