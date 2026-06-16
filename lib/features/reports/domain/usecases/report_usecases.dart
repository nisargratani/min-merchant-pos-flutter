import '../../../../core/usecase/usecase.dart';
import '../entities/report.dart';
import '../repositories/report_repository.dart';

/// Fetches today's sales summary (Admin only).
class GetTodaySalesUseCase implements UseCase<TodaySalesReport, NoParams> {
  final ReportRepository _repository;
  GetTodaySalesUseCase(this._repository);

  @override
  Future<TodaySalesReport> call(NoParams params) => _repository.getTodaySales();
}

/// Fetches pending sync count.
class GetPendingSyncUseCase implements UseCase<PendingSyncReport, NoParams> {
  final ReportRepository _repository;
  GetPendingSyncUseCase(this._repository);

  @override
  Future<PendingSyncReport> call(NoParams params) => _repository.getPendingSync();
}
