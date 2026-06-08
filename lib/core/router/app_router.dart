import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/portero_scanner/presentation/pages/scanner_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/portero',
      builder: (context, state) => const ScannerPage(),
    ),
    GoRoute(
      path: '/tutor',
      builder: (context, state) => const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.construction, size: 64, color: Colors.orange),
              SizedBox(height: 16),
              Text(
                'Panel del Tutor',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('En construcción', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    ),
  ],
);
