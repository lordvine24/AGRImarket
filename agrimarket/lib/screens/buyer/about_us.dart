import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'About AgriMarket',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'AgriMarket is a revolutionary platform designed to connect farmers directly with buyers, '
              'ensuring fresh produce reaches consumers efficiently while empowering farmers to grow their business. '
              'Through our platform, farmers can list their products, manage orders, and build relationships with buyers, '
              'while buyers gain access to high-quality farm products at competitive prices.\n\n'
              'Our mission is to support sustainable agriculture, enhance the livelihoods of farmers, and make fresh, '
              'locally sourced produce accessible to everyone. AgriMarket bridges the gap between farm and table, '
              'bringing transparency, convenience, and trust to the agricultural marketplace.\n\n'
              'Join AgriMarket today and be a part of a growing community that values quality, freshness, and fair trade.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
