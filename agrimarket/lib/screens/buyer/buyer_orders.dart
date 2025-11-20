import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class BuyerOrders extends StatefulWidget {
  const BuyerOrders({super.key});

  @override
  State<BuyerOrders> createState() => _BuyerOrdersState();
}

class _BuyerOrdersState extends State<BuyerOrders> {
  User? _user;

  @override
  void initState() {
    super.initState();
    _initFirebase();
  }

  Future<void> _initFirebase() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "YOUR_API_KEY",
          appId: "YOUR_APP_ID",
          messagingSenderId: "YOUR_SENDER_ID",
          projectId: "YOUR_PROJECT_ID",
        ),
      );
    }
    _user = FirebaseAuth.instance.currentUser;
    setState(() {});
  }

  // --------------------------
  // FETCH ORDERS
  // --------------------------
  Stream<QuerySnapshot> _getUserOrders() {
    if (_user == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('orders')
        .where('buyerId', isEqualTo: _user!.uid)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  String _formatTimestamp(Timestamp? ts) {
    if (ts == null) return '';
    final date = ts.toDate();
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }

  Future<String> _getFarmerName(String farmerId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(farmerId)
          .get();
      if (doc.exists) {
        final data = doc.data();
        return data?['name'] ?? 'Unknown Farmer';
      }
    } catch (e) {
      debugPrint('Error fetching farmer: $e');
    }
    return 'Unknown Farmer';
  }

  // --------------------------
  // UI
  // --------------------------
  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _getUserOrders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No orders found.'));
        }

        final orders = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index].data() as Map<String, dynamic>;
            final productName = order['productName'] ?? 'Unknown';
            final quantity = order['quantity'] ?? 1;
            final timestamp = _formatTimestamp(order['timestamp']);
            final farmerId = order['farmerId'] ?? '';

            return FutureBuilder<String>(
              future: _getFarmerName(farmerId),
              builder: (context, farmerSnapshot) {
                final farmerName =
                    farmerSnapshot.connectionState == ConnectionState.waiting
                    ? 'Loading...'
                    : farmerSnapshot.data ?? 'Unknown Farmer';

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
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
                        Text('Quantity: $quantity'),
                        const SizedBox(height: 4),
                        Text('Farmer: $farmerName'),
                        const SizedBox(height: 4),
                        Text('Ordered on: $timestamp'),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
