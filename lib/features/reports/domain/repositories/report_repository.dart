import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/report.dart';

/// Abstract report repository — domain layer contract.
abstract class ReportRepository {
  Future<Either<Failure, TodaySalesReport>> getTodaySales();
  Future<Either<Failure, PendingSyncReport>> getPendingSync();
}
