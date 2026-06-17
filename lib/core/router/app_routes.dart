/// Centralized class containing all application routing paths.
class AppRoutes {
  AppRoutes._();

  /// Splash / initial authentication checking screen
  static const String splash = '/';

  /// User authentication screen
  static const String login = '/login';

  /// Main POS product catalog listing screen
  static const String products = '/products';

  /// Shopping cart items summary screen
  static const String cart = '/cart';

  /// Past orders and sync status tracking screen
  static const String orders = '/orders';

  /// Admin reports dashboard analytical screen
  static const String reports = '/reports';
}
