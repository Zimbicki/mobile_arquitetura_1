import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/product_controller.dart';
import 'controllers/favorite_controller.dart';
import 'repositories/product_repository.dart';
import 'screens/product_list_page.dart';
import 'screens/login_page.dart';
import 'services/session_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final sessionService = SessionService();
  await sessionService.loadSession();

  final favoriteController = FavoriteController();
  await favoriteController.loadFavorites();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: sessionService),
        ChangeNotifierProvider(
          create: (_) => ProductController(ProductRepository()),
        ),
        ChangeNotifierProvider.value(value: favoriteController),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionService = Provider.of<SessionService>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Catálogo Otimizado',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: sessionService.isAuthenticated ? const ProductListPage() : const LoginPage(),
    );
  }
}

