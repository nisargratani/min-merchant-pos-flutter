import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/order_provider.dart';

class OrderListScreen extends ConsumerWidget {
  const OrderListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(orderNotifierProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Sync Pending Orders',
            onPressed: () {
              ref.read(orderNotifierProvider.notifier).syncPendingOrders();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Syncing pending orders...')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(orderNotifierProvider.notifier).fetchOrders(),
          ),
        ],
      ),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No orders yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: ExpansionTile(
                  leading: _buildSyncStatusIcon(order.syncStatus),
                  title: Text(
                    'Order ${order.localOrderId.substring(0, 8)}...',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '\$${order.totalAmount.toStringAsFixed(2)}  •  ${order.paymentMode}',
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildSyncBadge(order.syncStatus),
                          const SizedBox(width: 6),
                          _buildPaymentBadge(order.paymentStatus),
                        ],
                      ),
                    ],
                  ),
                  children: [
                    // Order items
                    if (order.items.isNotEmpty)
                      ...order.items.map(
                        (item) => ListTile(
                          dense: true,
                          title: Text(
                            item.productName ?? 'Product #${item.productId}',
                          ),
                          trailing: Text(
                            '${item.qty} × \$${item.price.toStringAsFixed(2)}',
                          ),
                        ),
                      ),

                    const Divider(),

                    // Payment info section
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 4.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payment Details',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          _infoRow('Payment Status', order.paymentStatus),
                          _infoRow('Payment Mode', order.paymentMode),
                          if (order.paymentRef != null)
                            _infoRow('Transaction ID', order.paymentRef!),
                          if (order.paymentId != null)
                            _infoRow('Payment ID', '#${order.paymentId}'),
                          _infoRow(
                            'Created',
                            DateTime.fromMillisecondsSinceEpoch(
                              order.createdAt,
                            ).toString().substring(0, 19),
                          ),
                        ],
                      ),
                    ),

                    // Action buttons
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // "Pay Now" button — shows for synced but unpaid orders
                          if (order.syncStatus == 'SYNCED' &&
                              order.paymentStatus == 'PENDING' &&
                              order.serverOrderId != null &&
                              (user?.canMakePayment ?? false))
                            ElevatedButton.icon(
                              onPressed: () {
                                ref
                                    .read(orderNotifierProvider.notifier)
                                    .simulatePayment(order);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Processing payment...'),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.payment, size: 18),
                              label: const Text('Pay Now'),
                            ),

                          // "Retry Payment" for failed payments
                          if (order.paymentStatus == 'FAILED' &&
                              order.serverOrderId != null &&
                              (user?.canMakePayment ?? false))
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                              ),
                              onPressed: () {
                                ref
                                    .read(orderNotifierProvider.notifier)
                                    .simulatePayment(order);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Retrying payment...'),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.replay, size: 18),
                              label: const Text('Retry Payment'),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $err'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.read(orderNotifierProvider.notifier).fetchOrders(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncStatusIcon(String status) {
    switch (status) {
      case 'SYNCED':
        return const Icon(Icons.cloud_done, color: Colors.green);
      case 'PAID':
        return const Icon(Icons.check_circle, color: Colors.blue);
      case 'FAILED':
        return const Icon(Icons.error, color: Colors.red);
      case 'PENDING':
      default:
        return const Icon(Icons.hourglass_bottom, color: Colors.orange);
    }
  }

  Widget _buildSyncBadge(String status) {
    Color color;
    switch (status) {
      case 'PENDING':
        color = Colors.orange;
        break;
      case 'PAID':
        color = Colors.blue;
        break;
      case 'SYNCED':
        color = Colors.green;
        break;
      case 'FAILED':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    return _badge('Sync: $status', color);
  }

  Widget _buildPaymentBadge(String status) {
    Color color;
    IconData icon;
    switch (status) {
      case 'SUCCESS':
        color = Colors.green;
        icon = Icons.check;
        break;
      case 'FAILED':
        color = Colors.red;
        icon = Icons.close;
        break;
      case 'PENDING':
      default:
        color = Colors.orange;
        icon = Icons.hourglass_empty;
    }
    return _badge('Pay: $status', color, icon: icon);
  }

  Widget _badge(String text, Color color, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 3),
          ],
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
