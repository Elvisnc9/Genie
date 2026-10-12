import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/theme.dart';
import 'router.dart';

class GenieApp extends ConsumerWidget {
  const GenieApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Genie',
      debugShowCheckedModeBanner: false,
      theme: GenieTheme.light,
      themeMode: ThemeMode.light,
      routerConfig: ref.watch(routerProvider),
      builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(value: GenieTheme.systemUi, child: child!),
    );
  }
}
