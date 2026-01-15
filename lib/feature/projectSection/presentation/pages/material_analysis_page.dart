import 'package:flutter/material.dart';

class MaterialAnalysisPage extends StatelessWidget {
  const MaterialAnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Material Analysis')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Material Analysis\nComing Soon',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
