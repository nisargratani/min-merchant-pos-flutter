import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../providers/product_provider.dart';

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          // Cart badge
          Consumer(
            builder: (context, ref, child) {
              final cartItemCount = ref.watch(
                cartNotifierProvider.select((state) {
                  final cart = state.valueOrNull;
                  if (cart == null) return 0;
                  return cart.items.fold<int>(0, (sum, item) => sum + item.qty);
                }),
              );

              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () => context.push(AppRoutes.cart),
                  ),
                  if (cartItemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$cartItemCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          if (user?.canViewOwnOrders ?? false)
            IconButton(
              icon: const Icon(Icons.receipt_long),
              onPressed: () => context.push(AppRoutes.orders),
            ),
          if (user?.canViewReports ?? false)
            IconButton(
              icon: const Icon(Icons.analytics),
              onPressed: () => context.push(AppRoutes.reports),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: productsAsync.when(
        data: (products) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(productsProvider);
          },
          child: products.isEmpty
              ? const Center(child: Text('No products found'))
              : ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primaryContainer,
                          child: Text(
                            product.name[0].toUpperCase(),
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        title: Text(product.name),
                        subtitle: Text(
                          'Price: \$${product.price.toStringAsFixed(2)}  •  Stock: ${product.stock}',
                        ),
                        trailing: Consumer(
                          builder: (context, ref, child) {
                            final currentQty = ref.watch(
                              cartNotifierProvider.select((state) {
                                final cart = state.valueOrNull;
                                if (cart == null) return 0;
                                final item = cart.items
                                    .where((i) => i.productId == product.id)
                                    .firstOrNull;
                                return item?.qty ?? 0;
                              }),
                            );

                            if (currentQty > 0) {
                              return SizedBox(
                                width: 130, // Fixed width to keep minus aligned
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                      ),
                                      onPressed: () {
                                        if (currentQty > 1) {
                                          // Send delta -1 to API
                                          ref
                                              .read(
                                                cartNotifierProvider.notifier,
                                              )
                                              .addToCart(product.id, -1);
                                        } else {
                                          ref
                                              .read(
                                                cartNotifierProvider.notifier,
                                              )
                                              .removeFromCart(product.id);
                                        }
                                      },
                                    ),
                                    SizedBox(
                                      width: 24, // Fixed width for text
                                      child: Text(
                                        '$currentQty',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                      ),
                                      onPressed: currentQty >= product.stock
                                          ? null
                                          : () {
                                              // Send delta 1 to API
                                              ref
                                                  .read(
                                                    cartNotifierProvider
                                                        .notifier,
                                                  )
                                                  .addToCart(product.id, 1);
                                            },
                                    ),
                                  ],
                                ),
                              );
                            }

                            return SizedBox(
                              width: 130,
                              child: IconButton(
                                icon: const Icon(Icons.add_shopping_cart),
                                onPressed: product.stock <= 0
                                    ? null
                                    : () {
                                        // Add first item, delta 1
                                        ref
                                            .read(cartNotifierProvider.notifier)
                                            .addToCart(product.id, 1);
                                      },
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $err'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(productsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
