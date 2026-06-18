import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'data/datasources/auth_remote_datasource.dart';
import 'data/datasources/product_remote_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/product_repository_impl.dart';
import 'data/session/auth_session.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/product_list_page.dart';
import 'presentation/viewmodel/auth_viewmodel.dart';
import 'presentation/viewmodel/product_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Dependências compartilhadas
  final httpClient = http.Client();

  // Datasources
  final authDatasource = AuthRemoteDatasource(httpClient);
  final productDatasource = ProductRemoteDatasource(httpClient);

  // Repositories
  final authRepository = AuthRepositoryImpl(authDatasource);
  final productRepository = ProductRepositoryImpl(productDatasource);

  // Session
  final authSession = AuthSession();
  await authSession.loadSession();

  // ViewModels
  final authViewModel = AuthViewModel(authRepository, authSession);
  final productViewModel = ProductViewModel(productRepository);
  await productViewModel.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authSession),
        ChangeNotifierProvider.value(value: authViewModel),
        ChangeNotifierProvider.value(value: productViewModel),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Provider.of<AuthSession>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Catálogo Otimizado',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: session.isAuthenticated ? const ProductListPage() : const LoginPage(),
    );
  }
}
