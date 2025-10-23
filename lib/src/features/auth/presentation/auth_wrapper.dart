import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kipu/src/features/auth/application/auth_service.dart';
import 'package:kipu/screens/login_screen.dart';
import 'package:kipu/src/features/transactions/presentation/screens/home_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();
  bool _isCheckingRedirect = true;

  @override
  void initState() {
    super.initState();
    _checkRedirectResult();
  }

  Future<void> _checkRedirectResult() async {
    try {
      await _authService.getRedirectResult();
    } catch (e) {
      print('Error verificando redirect: $e');
    } finally {
      setState(() {
        _isCheckingRedirect = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingRedirect) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        // User is logged in
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          if (user == null) {
            return const LoginScreen();
          } 
          return const HomeScreen();
        }
        // Waiting for connection
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
