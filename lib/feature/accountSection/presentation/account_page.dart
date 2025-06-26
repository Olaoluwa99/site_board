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
