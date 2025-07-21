import 'package:flutter/material.dart';

class AccountPage extends StatelessWidget {
  static route() => MaterialPageRoute(builder: (context) => AccountPage());
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(child: Text('Account page')),
    );
  }
}

/**
 * 1. View My Created Projects in Profile
 * 2. What is added to recent and Why it should be added
 * 3. What should be added to Offline and what should not
 * 4. Setting up everything to work well
 * 5. ---
 * **/
