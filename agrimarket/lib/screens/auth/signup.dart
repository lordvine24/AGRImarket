import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../firebase_options.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _farmController = TextEditingController();
  String _role = 'farmer'; // 'farmer' or 'buyer'

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _farmController.dispose();
    super.dispose();
  }

  bool _loading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      // Ensure Firebase is initialized for this platform before using it.
      if (Firebase.apps.isEmpty) {
        if (kIsWeb || defaultTargetPlatform != TargetPlatform.linux) {
          await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          );
          // Debug: report initialized app
          // ignore: avoid_print
          print('Firebase.apps after init: ${Firebase.apps.length}');
          try {
            // ignore: avoid_print
            print(
              'Firebase current projectId: ${Firebase.app().options.projectId}',
            );
          } catch (e) {
            // ignore: avoid_print
            print('Could not read Firebase.app() options: $e');
          }
        } else {
          // On Linux desktop we may not have native Firebase plugins available.
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
      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim();
      final farm = _farmController.text.trim();

      // Debug: log intent to create user
      // ignore: avoid_print
      print('Signup: creating user with email=$email role=$_role');

      // Create Firebase user
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = cred.user?.uid;
      if (uid == null) throw Exception('Failed to get user id');

      // Debug: created user
      // ignore: avoid_print
      print('Signup: created user uid=$uid');

      // Save profile to Firestore auth collection
      // Use a direct write and log progress so we can debug failures
      // ignore: avoid_print
      print('Signup: saving user profile to auth collection for uid=$uid');
      await FirebaseFirestore.instance.collection('auth').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'phone': phone,
        'role': _role,
        'farmLocation': farm,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Debug: saved
      // ignore: avoid_print
      print('Signup: user profile saved to auth collection for uid=$uid');

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Signup successful')));

      // Navigate to appropriate home
      if (_role == 'farmer') {
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/home_farmer');
      } else {
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/home_buyer');
      }
    } on FirebaseAuthException catch (e, s) {
      // Log error + stack for debugging
      // ignore: avoid_print
      print('Signup FirebaseAuthException: ${e.code} ${e.message}');
      // ignore: avoid_print
      print(s);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Signup error: ${e.message}')));
    } catch (e, s) {
      // General error
      // ignore: avoid_print
      print('Signup error: $e');
      // ignore: avoid_print
      print(s);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String? _validateEmail(String? v) {
    if (v == null || v.isEmpty) return 'Please enter an email';
    final emailReg = RegExp(r"^[\w-.]+@([\w-]+\.)+[\w-]{2,4}");
    if (!emailReg.hasMatch(v)) return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Please enter a password';
    if (v.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top image/logo
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: ClipOval(
                    child: Image.network(
                      'https://images.unsplash.com/photo-1501004318641-b39e6451bec6?auto=format&fit=crop&w=400&q=80',
                      width: 92,
                      height: 92,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) => const Icon(
                        Icons.person,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full name',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Please enter name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                validator: _validateEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Please enter phone' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _farmController,
                decoration: InputDecoration(
                  labelText: 'Farm location (optional)',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Account type selector: Farmer or Buyer
              const Text(
                'Account type',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Card(
                color: Colors.white,
                child: Column(
                  children: [
                    RadioListTile<String>(
                      title: const Text('Farmer'),
                      value: 'farmer',
                      groupValue: _role,
                      activeColor: Theme.of(context).colorScheme.primary,
                      onChanged: (v) => setState(() => _role = v ?? 'farmer'),
                    ),
                    RadioListTile<String>(
                      title: const Text('Buyer'),
                      value: 'buyer',
                      groupValue: _role,
                      activeColor: Theme.of(context).colorScheme.primary,
                      onChanged: (v) => setState(() => _role = v ?? 'buyer'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: _validatePassword,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmController,
                decoration: const InputDecoration(
                  labelText: 'Confirm password',
                ),
                obscureText: true,
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Please confirm password';
                  }
                  if (v != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Text('Sign up', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
