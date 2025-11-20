import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeFarmer extends StatefulWidget {
  const HomeFarmer({super.key});

  @override
  State<HomeFarmer> createState() => _HomeFarmerState();
}

class _HomeFarmerState extends State<HomeFarmer> {
  bool _loading = true;
  Map<String, dynamic>? _profile;

  final List<String> _assetImages = [
    'assets/images/product1.jpg',
    'assets/images/product2.jpg',
    'assets/images/product3.jpg',
  ];

  final List<String> _tips = [
    "Water early in the morning to reduce evaporation.",
    "Rotate crops yearly to improve soil health.",
    "Composting helps retain soil nutrients naturally.",
    "Healthy soil, healthy yield — nurture your ground.",
    "AgriMarket helps your harvest reach every home.",
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('auth')
          .doc(user.uid)
          .get();
      setState(() {
        _profile = doc.data();
        _loading = false;
      });
    } catch (e) {
      print('Failed to load profile: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/signin');
  }

  @override
  Widget build(BuildContext context) {
    final name = _profile?['name'] ?? 'Farmer';
    final farm = _profile?['farmLocation'] ?? 'Unknown farm';
    final profileImage = _profile?['profileImage'];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('AgriMarket'),
        actions: [
          IconButton(
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.green),
              accountName: Text(name),
              accountEmail: Text(farm),
              currentAccountPicture: CircleAvatar(
                backgroundImage: profileImage != null && profileImage.isNotEmpty
                    ? NetworkImage(profileImage)
                    : const AssetImage('assets/images/product1.jpg')
                          as ImageProvider,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text("My Products"),
              onTap: () => Navigator.pushNamed(context, '/my_products'),
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text("Orders"),
              onTap: () => Navigator.pushNamed(context, '/orders'),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadProfile,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(name, farm, profileImage),
                    const SizedBox(height: 24),
                    _buildQuoteAndTip(),
                    const SizedBox(height: 24),
                    _buildManageProducts(context),
                    const SizedBox(height: 24),
                    _buildGallery(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/add_product'),
        backgroundColor: Colors.green,
        icon: const Icon(Icons.add),
        label: const Text("Add Product"),
      ),
    );
  }

  Widget _buildHeader(String name, String farm, String? profileImage) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF81C784), Color(0xFF4CAF50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 44,
            backgroundColor: Colors.white.withOpacity(0.2),
            backgroundImage: (profileImage != null && profileImage.isNotEmpty)
                ? NetworkImage(profileImage)
                : null,
            child: (profileImage == null || profileImage.isEmpty)
                ? const Icon(Icons.person, color: Colors.white, size: 48)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, $name 👋',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Farm: $farm',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Verified Seller ✅',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteAndTip() {
    final randomTip = _tips[DateTime.now().second % _tips.length];
    return Column(
      children: [
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.green.shade50,
          child: const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              '"Connecting farms to families — AgriMarket brings your harvest to the world."',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.green,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.lightGreen.shade50,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                const Icon(Icons.lightbulb, color: Colors.green),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    randomTip,
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildManageProducts(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Manage Your Products',
          style: Theme.of(
            context,
          ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _dashboardButton(
              icon: Icons.add_box_rounded,
              label: 'Add Product',
              color: Colors.green.shade400,
              onTap: () => Navigator.pushNamed(context, '/add_product'),
            ),
            _dashboardButton(
              icon: Icons.inventory_2_rounded,
              label: 'My Products',
              color: Colors.orange.shade400,
              onTap: () => Navigator.pushNamed(context, '/my_products'),
            ),
            _dashboardButton(
              icon: Icons.shopping_bag_rounded,
              label: 'Orders',
              color: Colors.blue.shade400,
              onTap: () => Navigator.pushNamed(context, '/orders'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _dashboardButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 6,
                offset: const Offset(2, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 30),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGallery() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Farm Gallery',
          style: Theme.of(
            context,
          ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _assetImages.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'No images found in assets/images/\nAdd some beautiful farm photos!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _assetImages.length,
                itemBuilder: (context, index) {
                  final path = _assetImages[index];
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(2, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(path, fit: BoxFit.cover),
                    ),
                  );
                },
              ),
      ],
    );
  }
}
