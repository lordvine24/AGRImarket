import 'package:flutter/material.dart';
// ... (other imports remain the same)
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../firebase_options.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  // ... (controllers and state variables remain the same)
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // ... (Your _submit logic remains the same, correctly setting _loading = true and false)
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      // Ensure Firebase is initialized for this platform before using it.
      if (Firebase.apps.isEmpty) {
        if (kIsWeb || defaultTargetPlatform != TargetPlatform.linux) {
          await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          );
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Firebase is not available on Linux desktop. Run on Chrome or Android to test auth.',
                ),
              ),
            );
          }
          setState(() => _loading = false);
          return;
        }
      }
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = cred.user?.uid;
      if (uid == null) throw Exception('Missing uid');

      final doc = await FirebaseFirestore.instance
          .collection('auth')
          .doc(uid)
          .get();
      final data = doc.data();
      final role = data?['role'] as String? ?? 'buyer';

      if (!mounted) return;
      if (role == 'farmer') {
        Navigator.of(context).pushReplacementNamed('/home_farmer');
      } else {
        Navigator.of(context).pushReplacementNamed('/home_buyer');
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Sign in error: ${e.message}')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Main Content (The Form)
    final mainContent = Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (v) => v == null || v.isEmpty ? 'Enter email' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              validator: (v) =>
                  v == null || v.isEmpty ? 'Enter password' : null,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: const Text('Sign in'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/signup'),
              child: const Text("Don't have an account? Sign up"),
            ),
          ],
        ),
      ),
    );

    // 2. Custom Agrimarket Loader Overlay (Green theme)
    final loaderOverlay = Container(
      // Use semi-transparent white background for a clean look
      color: Colors.white.withOpacity(0.85),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.green.shade700, // Custom green color
              strokeWidth: 4.0,
            ),
            const SizedBox(height: 20),
            Text(
              'Agrimarket Loading...', // Custom text
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700, // Matching text color
              ),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: Stack(
        children: [
          // Layer 1: The main content
          mainContent,

          // Layer 2: The custom loader overlay
          if (_loading) loaderOverlay,
        ],
      ),
    );
  }
}
