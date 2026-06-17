import '../../../../core/usecase/usecase.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/report.dart';
import '../repositories/report_repository.dart';

/// Fetches today's sales summary (Admin only).
class GetTodaySalesUseCase implements UseCase<TodaySalesReport, NoParams> {
  final ReportRepository _repository;
  GetTodaySalesUseCase(this._repository);

  @override
  Future<Either<Failure, TodaySalesReport>> call(NoParams params) => _repository.getTodaySales();
}

/// Fetches pending sync count.
class GetPendingSyncUseCase implements UseCase<PendingSyncReport, NoParams> {
  final ReportRepository _repository;
  GetPendingSyncUseCase(this._repository);

  @override
  Future<Either<Failure, PendingSyncReport>> call(NoParams params) => _repository.getPendingSync();
}
