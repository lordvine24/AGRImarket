import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FarmersList extends StatefulWidget {
  const FarmersList({super.key});

  @override
  State<FarmersList> createState() => _FarmersListState();
}

class _FarmersListState extends State<FarmersList> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _placeOrder(
    String farmerId,
    String productId,
    String productName,
    double price,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('orders').add({
        'buyerId': user.uid,
        'farmerId': farmerId,
        'productId': productId,
        'productName': productName,
        'price': price,
        'status': 'Pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Order placed for $productName')));
    } catch (e) {
      print('Failed to place order: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to place order')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('auth')
          .where('role', isEqualTo: 'farmer')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No farmers available'));
        }

        final farmers = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: farmers.length,
          itemBuilder: (context, index) {
            final farmer = farmers[index];
            final farmerId = farmer.id;
            final farmerName = farmer['name'] ?? 'Farmer';
            final farmLocation = farmer['farmLocation'] ?? 'Unknown Location';
            final farmerEmail = farmer['email'] ?? 'No Email';
            final farmerPhone = farmer['phone'] ?? 'No Phone';

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      farmerName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('Location: $farmLocation'),
                    const SizedBox(height: 4),
                    Text('Email: $farmerEmail'),
                    const SizedBox(height: 4),
                    Text('Phone: $farmerPhone'),
                    const SizedBox(height: 12),
                    StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection('products')
                          .where('farmerId', isEqualTo: farmerId)
                          .snapshots(),
                      builder: (context, productSnapshot) {
                        if (!productSnapshot.hasData ||
                            productSnapshot.data!.docs.isEmpty) {
                          return const Text('No products available');
                        }

                        final products = productSnapshot.data!.docs;

                        return Column(
                          children: products.map((product) {
                            final productId = product.id;
                            final productName = product['name'] ?? 'Product';
                            final productPrice = (product['price'] ?? 0)
                                .toDouble();

                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(productName),
                              subtitle: Text(
                                'Price: \$${productPrice.toStringAsFixed(2)}',
                              ),
                              trailing: ElevatedButton(
                                onPressed: () => _placeOrder(
                                  farmerId,
                                  productId,
                                  productName,
                                  productPrice,
                                ),
                                child: const Text('Order'),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
