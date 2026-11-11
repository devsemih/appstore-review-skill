import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _nickname = TextEditingController();
  bool _isSignUp = true;
  String? _error;

  Future<void> _submit() async {
    try {
      if (_isSignUp) {
        final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _email.text.trim(),
          password: _password.text,
        );
        await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
          'nickname': _nickname.text.trim(),
          'coins': 0,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _email.text.trim(),
          password: _password.text,
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Huddle', style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 8),
              const Text('Chat with people around you'),
              const SizedBox(height: 32),
              if (_isSignUp)
                TextField(controller: _nickname, decoration: const InputDecoration(labelText: 'Nickname')),
              TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
              TextField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
              if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              FilledButton(onPressed: _submit, child: Text(_isSignUp ? 'Create account' : 'Log in')),
              TextButton(
                onPressed: () => setState(() => _isSignUp = !_isSignUp),
                child: Text(_isSignUp ? 'I already have an account' : 'Create a new account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
