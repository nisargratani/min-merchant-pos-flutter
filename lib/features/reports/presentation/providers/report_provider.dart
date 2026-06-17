import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/usecase/usecase.dart';
import '../../data/datasources/report_remote_data_source.dart';
import '../../data/repositories/report_repository_impl.dart';
import '../../domain/entities/report.dart';
import '../../domain/repositories/report_repository.dart';
import '../../domain/usecases/report_usecases.dart';

// ── Data Sources ──
final reportRemoteDataSourceProvider = Provider<ReportRemoteDataSource>((ref) {
  return ReportRemoteDataSource(ref.watch(dioProvider));
});

// ── Repository ──
final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepositoryImpl(
    remoteDataSource: ref.watch(reportRemoteDataSourceProvider),
  );
});

// ── Use Cases ──
final getTodaySalesUseCaseProvider = Provider<GetTodaySalesUseCase>((ref) {
  return GetTodaySalesUseCase(ref.watch(reportRepositoryProvider));
});

final getPendingSyncUseCaseProvider = Provider<GetPendingSyncUseCase>((ref) {
  return GetPendingSyncUseCase(ref.watch(reportRepositoryProvider));
});

// ── State ──

final todaySalesProvider = FutureProvider<TodaySalesReport>((ref) async {
  final useCase = ref.watch(getTodaySalesUseCaseProvider);
  final result = await useCase(const NoParams());
  return result.fold(
    (failure) => throw failure,
    (report) => report,
  );
});

final pendingSyncProvider = FutureProvider<PendingSyncReport>((ref) async {
  final useCase = ref.watch(getPendingSyncUseCaseProvider);
  final result = await useCase(const NoParams());
  return result.fold(
    (failure) => throw failure,
    (report) => report,
  );
});
