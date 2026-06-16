class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://pos-test.equilym.com/api';

  // Auth
  static const String login = '/login';
  static const String logout = '/logout';
  static const String me = '/users/me';

  // Products
  static const String products = '/products';

  // Cart
  static const String cart = '/cart';
  static const String cartItems = '/cart/items';
  static String cartItem(int productId) => '/cart/items/$productId';
  static const String cartClear = '/cart/clear';

  // Orders
  static const String orders = '/orders';
  static String orderDetail(int orderId) => '/orders/$orderId';

  // Payments
  static const String payments = '/payments';

  // Sync
  static const String syncOrders = '/sync/orders';
  static const String syncPayments = '/sync/payments';

  // Reports
  static const String todaySales = '/reports/today-sales';
  static const String pendingSync = '/reports/pending-sync';
}
