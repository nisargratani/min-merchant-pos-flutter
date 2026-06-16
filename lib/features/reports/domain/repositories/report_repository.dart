import '../entities/report.dart';

/// Abstract report repository — domain layer contract.
abstract class ReportRepository {
  Future<TodaySalesReport> getTodaySales();
  Future<PendingSyncReport> getPendingSync();
}
