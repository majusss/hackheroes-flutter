import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hackheroes_flutter/screens/onboarding.dart';
import 'package:hackheroes_flutter/screens/start.dart';
import 'package:hackheroes_flutter/services/api.dart';
import 'package:provider/provider.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:async';

void main() async {
  await dotenv.load(fileName: ".env");

  runApp(MultiProvider(
    providers: [
      Provider<ApiService>(create: (_) => ApiService()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF22A45D)),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();

    _sub = uriLinkStream.listen((Uri? uri) {
      if (uri != null && uri.path == '/callback') {
        final token = uri.queryParameters['token'];
        if (token != null && mounted) {
          Provider.of<ApiService>(context, listen: false)
              .login(token, context: context);
        }
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<ApiService>(context).isAuth(),
      builder: (context, snapshot) =>
          snapshot.connectionState == ConnectionState.done
              ? snapshot.data == true
                  ? const StartScreen()
                  : const OnboardingScreen()
              : snapshot.connectionState == ConnectionState.waiting
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : Text(snapshot.error.toString()),
    );
  }
}
