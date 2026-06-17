import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/domain/entities/user.dart';
import 'core/database/shared_prefs_service.dart';
import 'core/router/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences before the app starts
  await SharedPrefsService.init();

  runApp(const ProviderScope(child: MiniMerchantApp()));
}

class MiniMerchantApp extends ConsumerWidget {
  const MiniMerchantApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    // Global listener to route on auth status changes
    ref.listen<AsyncValue<User?>>(authProvider, (previous, next) {
      if (!next.isLoading) {
        final user = next.valueOrNull;
        if (user == null) {
          router.go(AppRoutes.login);
        } else if (previous?.valueOrNull == null) {
          router.go(AppRoutes.products);
        }
      }
    });

    return MaterialApp.router(
      title: 'Mini Merchant POS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 2),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
