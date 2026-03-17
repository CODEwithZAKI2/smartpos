import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartpos/models/product_model.dart';
import 'package:smartpos/providers/product_provider.dart';
import 'package:smartpos/screens/add_product_screen.dart';
import 'package:smartpos/screens/update_product.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryAsync = ref.watch(allProductsProvider);
    return Scaffold(
      appBar: AppBar(title: Text('Inventory List')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey.shade300,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (ctx) => AddProductScreen()),
          );
        },
        child: Icon(Icons.add, size: 28, color: Colors.black),
      ),
      body: inventoryAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return Center(child: Text('No products available'));
          }
          return ProductsList(products: products);
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class ProductsList extends StatelessWidget {
  const ProductsList({super.key, required this.products});
  final List<ProductModel> products;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ListTile(
          onTap: () {
            
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (ctx) => UpdateProduct(barcode: products[index].barcode),
              ),
            );
          },
          title: Text(products[index].name),
          subtitle: Text(products[index].barcode),
          trailing: IconButton(icon: Icon(Icons.edit), onPressed: () {}),
        );
      },
    );
  }
}
