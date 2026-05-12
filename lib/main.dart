import 'package:flutter/material.dart';

import 'screens/tela_home.dart';
import 'screens/tela_login.dart';
import 'screens/tela_criar_objetivos.dart';
import 'screens/tela_registro.dart';
import 'screens/tela_transacao.dart';
import 'screens/tela_usuario.dart';
import 'screens/tela_objetivos.dart';

import 'core/theme_controller.dart';
import 'src/app_temas.dart';
import 'core/supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseConfig.init();

  //carrega o tema salvo antes de rodar o app
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeController.loadTheme();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: ThemeController.themeMode,
      builder: (context, ThemeMode mode, _) {
        return MaterialApp(
          title: 'NextCash',
          debugShowCheckedModeBanner: false,
          theme: app_temas.claro,
          darkTheme: app_temas.escuro,
          themeMode: mode,
          initialRoute: '/login',
          routes: {
            '/login': (context) => const LoginScreen(),
            '/home': (context) => const TelaHome(),
            '/objetivos': (context) => const TelaObjetivos(),
            '/criarobjetivos': (context) => const TelaCriarObjetivos(),
            '/registro': (context) => const RegisterScreen(),
            '/transacao': (context) => const TelaTransacao(),
            '/usuario': (context) => const TelaUsuario(),
          },
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
