import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../firebase_options.dart';

class FarmersProductPage extends StatefulWidget {
  const FarmersProductPage({super.key});

  @override
  State<FarmersProductPage> createState() => _FarmersProductPageState();
}

class _FarmersProductPageState extends State<FarmersProductPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  }

  Stream<QuerySnapshot> _getProductsStream() {
    return _firestore.collection('products').snapshots();
  }

  Future<Map<String, dynamic>> _getFarmerData(String farmerId) async {
    try {
      final doc = await _firestore.collection('auth').doc(farmerId).get();
      if (doc.exists) return doc.data()!;
    } catch (e) {
      debugPrint('Error fetching farmer: $e');
    }
    return {'name': 'Unknown', 'phone': 'N/A'};
  }

  Future<void> _placeOrder({
    required String productId,
    required String productName,
    required String farmerId,
    required int quantity,
  }) async {
    try {
      // Ensure Firebase is initialized
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please login before ordering")),
        );
        return;
      }

      await _firestore.collection('orders').add({
        'buyerId': user.uid,
        'farmerId': farmerId,
        'productId': productId,
        'productName': productName,
        'quantity': quantity,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order placed successfully")),
      );
    } catch (e) {
      print("ORDER ERROR: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Order failed: $e')));
    }
  }

  void _showOrderDialog(String productId, String productName, String farmerId) {
    final quantityController = TextEditingController(text: '1');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order $productName'),
        content: TextField(
          controller: quantityController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Quantity'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final quantity = int.tryParse(quantityController.text) ?? 1;
              _placeOrder(
                productId: productId,
                productName: productName,
                farmerId: farmerId,
                quantity: quantity,
              );
              Navigator.pop(context);
            },
            child: const Text('Order'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmers & Products'),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getProductsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No products available.'));
          }

          final products = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index].data() as Map<String, dynamic>;
              final farmerId = product['farmerId'] ?? '';
              final productName = product['name'] ?? 'Unnamed Product';
              final productPrice = product['price'] ?? 'N/A';
              final productImage = product['image'];
              final productId = products[index].id;

              return FutureBuilder<Map<String, dynamic>>(
                future: _getFarmerData(farmerId),
                builder: (context, farmerSnapshot) {
                  final farmerData =
                      farmerSnapshot.data ??
                      {'name': 'Unknown', 'phone': 'N/A'};

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image:
                                    productImage != null &&
                                        productImage.isNotEmpty
                                    ? NetworkImage(productImage)
                                    : const AssetImage(
                                            'assets/images/product1.jpg',
                                          )
                                          as ImageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  productName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Price: $productPrice',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Farmer: ${farmerData['name']}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Contact: ${farmerData['phone']}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () => _showOrderDialog(
                                    productId,
                                    productName,
                                    farmerId,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                  child: const Text('Order'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
