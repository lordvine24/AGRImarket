import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'buyer/ farmers_products.dart';
import 'buyer/buyer_orders.dart';
import 'buyer/about_us.dart';
import 'buyer/contact_us.dart';

class HomeBuyer extends StatefulWidget {
  const HomeBuyer({super.key});

  @override
  State<HomeBuyer> createState() => _HomeBuyerState();
}

class _HomeBuyerState extends State<HomeBuyer> {
  String _selectedPage = "farmers";

  void _selectPage(String page) {
    setState(() => _selectedPage = page);
    Navigator.pop(context); // close drawer
  }

  Widget _getPage() {
    switch (_selectedPage) {
      case "orders":
        return const BuyerOrders();
      case "about":
        return const AboutUsPage();
      case "contact":
        return const ContactUsPage();
      case "farmers":
      default:
        return const FarmersProductPage();
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/signin');
  }

  final List<String> _quotes = [
    "Buy fresh, eat healthy!",
    "Support local farmers!",
    "Good food, good mood!",
    "Healthy choices, happy life!",
  ];

  Widget _buildQuoteCard() {
    final quote = (_quotes..shuffle()).first; // pick random quote
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        quote,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AgriMarket'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Sign out',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.green),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'AgriMarket',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Fresh from farm to table',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.store),
              title: const Text("Farmers"),
              onTap: () => _selectPage("farmers"),
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text("My Orders"),
              onTap: () => _selectPage("orders"),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text("About Us"),
              onTap: () => _selectPage("about"),
            ),
            ListTile(
              leading: const Icon(Icons.contact_mail),
              title: const Text("Contact Us"),
              onTap: () => _selectPage("contact"),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildQuoteCard(),
          Expanded(child: _getPage()),
        ],
      ),
    );
  }
}
