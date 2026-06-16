import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/report_provider.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    // RBAC: Admin only
    if (user == null || !user.canViewReports) {
      return Scaffold(
        appBar: AppBar(title: const Text('Reports')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Access Denied: Admins Only',
                  style: TextStyle(fontSize: 18, color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    final salesAsync = ref.watch(todaySalesProvider);
    final syncAsync = ref.watch(pendingSyncProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(todaySalesProvider);
              ref.invalidate(pendingSyncProvider);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Today's Sales Card
            salesAsync.when(
              data: (report) => Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.attach_money,
                              color: Colors.green, size: 28),
                          const SizedBox(width: 8),
                          Text("Today's Sales",
                              style: Theme.of(context).textTheme.titleLarge),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _statColumn(
                            context,
                            'Total Orders',
                            report.totalOrders.toString(),
                            Icons.shopping_bag,
                          ),
                          _statColumn(
                            context,
                            'Total Revenue',
                            '\$${report.totalAmount.toStringAsFixed(2)}',
                            Icons.account_balance_wallet,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              loading: () => const Card(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (err, _) => Card(
                child: ListTile(
                  leading: const Icon(Icons.error, color: Colors.red),
                  title: Text('Error: $err'),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Pending Sync Card
            syncAsync.when(
              data: (report) => Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.sync_problem,
                              color: Colors.orange, size: 28),
                          const SizedBox(width: 8),
                          Text('Pending Sync',
                              style: Theme.of(context).textTheme.titleLarge),
                        ],
                      ),
                      const Divider(),
                      _statColumn(
                        context,
                        'Orders Waiting to Sync',
                        report.pendingOrders.toString(),
                        Icons.cloud_upload,
                      ),
                    ],
                  ),
                ),
              ),
              loading: () => const Card(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (err, _) => Card(
                child: ListTile(
                  leading: const Icon(Icons.error, color: Colors.red),
                  title: Text('Error: $err'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statColumn(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
