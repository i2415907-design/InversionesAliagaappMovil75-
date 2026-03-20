import 'package:flutter/material.dart';
import 'package:rutasinversionesaliaga/utils/app_theme.dart';
import 'package:rutasinversionesaliaga/routes/app_router.dart';
import 'package:overlay_support/overlay_support.dart'; // 1. Importa la librería

void main() {
  runApp(
    const OverlaySupport.global( // 2. Envuelve MyApp aquí
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: AppTheme.themeData,
    );
  }
}