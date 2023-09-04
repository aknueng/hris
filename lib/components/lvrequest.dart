
import 'package:flutter/material.dart';

class LVRequestScreen extends StatefulWidget {
  const LVRequestScreen({super.key});

  @override
  State<LVRequestScreen> createState() => _LVRequestScreenState();
}

class _LVRequestScreenState extends State<LVRequestScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('ร้องขอวันลา (Leave Request)'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.surface,
      ),
      
    );
  }
}
