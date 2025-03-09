import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'SM_local_config.dart';
import 'auth/auth_provider.dart';
import 'menu.dart';
import 'auth/login_screen.dart';
import 'auth/signup_screen.dart';
import 'orders_pages/home_page.dart';
import 'auth/password_screen.dart';
import 'auth/reset_password_screen.dart';


void main() async {
  await initHiveForFlutter();
  final HttpLink httpLink = HttpLink(Config.backendUrl); // Utilise l'URL de config.dart
  final GraphQLClient client = GraphQLClient(
    cache: GraphQLCache(store: HiveStore()),
    link: httpLink,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
      ],
      child: MyApp(client: client),
    ),
  );
}

class MyApp extends StatelessWidget {
  final GraphQLClient client;
  const MyApp({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: ValueNotifier(client), // Utilisez ValueNotifier pour le client
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => const HomePage(),
          '/login': (context) => LoginScreen(),
          '/signup': (context) => SignUpScreen(),
          '/menu': (context) => const MenuPage(),
          '/forgot-password': (context) => ForgotPasswordScreen(),
          '/reset-password': (context) => ResetPasswordScreen(email: '', code: '',),
        },
      ),
    );
  }
}

