import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routing/feature_registry.dart';

void main() {
  runApp(const ProviderScope(child: ReaderApp()));
}

class ReaderApp extends StatelessWidget {
  const ReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reader',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const _Home(),
        ...FeatureRegistry.routes(),
      },
      onUnknownRoute: (settings) => MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text('Unknown route: ${settings.name}')),
          body: const Center(child: Text('Route not registered.')),
        ),
      ),
    );
  }
}

class _Home extends StatelessWidget {
  const _Home();

  @override
  Widget build(BuildContext context) {
    final features = FeatureRegistry.all;
    if (features.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Reader')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'No features registered yet.\n\n'
              'Run: dart run tool/bin/generate.dart <ModuleName>',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Reader')),
      body: ListView.separated(
        itemCount: features.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final f = features[i];
          return ListTile(
            leading: Icon(f.icon),
            title: Text(f.title),
            subtitle: Text(f.routeName),
            onTap: () => Navigator.of(context).pushNamed(f.routeName),
          );
        },
      ),
    );
  }
}
