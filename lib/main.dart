import 'package:decorar_admin/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'splash_screen.dart';
import 'login_adm.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:decorar_admin/product_adm.dart';
import 'package:decorar_admin/blog.dart';
import 'package:decorar_admin/upload_blog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter bindings are initialized first
  await Firebase.initializeApp(); // Initialize Firebase
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeModel(prefs),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
      builder: (context, theme, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'DecorAR Admin',
          theme: theme.currentTheme, // Use the current theme from ThemeModel
          initialRoute: '/',
          routes: {
            '/': (context) => SplashScreen(),
            'login': (context) => LoginPage(),
            '/product': (context) => ProductPage(),
        '/blog': (context) => BlogPage(),
          },
        );
      },
    );
  }
}
