/// Today's sales report entity.
class TodaySalesReport {
  final int totalOrders;
  final double totalAmount;

  const TodaySalesReport({
    required this.totalOrders,
    required this.totalAmount,
  });

  factory TodaySalesReport.fromJson(Map<String, dynamic> json) {
    return TodaySalesReport(
      totalOrders: json['totalOrders'] as int? ?? 0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Pending sync report entity.
class PendingSyncReport {
  final int pendingOrders;

  const PendingSyncReport({required this.pendingOrders});

  factory PendingSyncReport.fromJson(Map<String, dynamic> json) {
    return PendingSyncReport(
      pendingOrders: json['pendingOrders'] as int? ?? 0,
    );
  }
}
