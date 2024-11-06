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

  final apiService = ApiService();
  await apiService.setup();
  // await apiService.login(
  //     "eyJhbGciOiJSUzI1NiIsImNhdCI6ImNsX0I3ZDRQRDIyMkFBQSIsImtpZCI6Imluc18yb09YQ09ESUIwblR4RXhUVDBFQnpDa3ZEVmkiLCJ0eXAiOiJKV1QifQ.eyJleHAiOjE3Mzg2ODU1ODcsImlhdCI6MTczMDkwOTU4NywiaXNzIjoiaHR0cHM6Ly9zdXJlLWh1bXBiYWNrLTIwLmNsZXJrLmFjY291bnRzLmRldiIsImp0aSI6ImY2ZTY0MDk4NGJiNjlhMzg2YWU3IiwibmJmIjoxNzMwOTA5NTgyLCJzdWIiOiJ1c2VyXzJvT2V0Y1FjSEliaU5vcEZpNjBuYlBPTkQ4RiJ9.S0_USEbcIkEUXBVj5YTjyjwZUQSNPrTNN4PKeXCnE-k9B44WYXVmj9uP0SNf_ujXED9rxQAw0rYvLAe0oqjISAGWnvugs3JiEV56wr7j8RLB-sXJNaKziJWVOte6BjIjBTKNPTaO_jz7WRon83kb2nxpneM6_f7o0tXYRWlS_7wrSMDgFo7a5ujQyjnB5k8migwkwH4YB7zUsNGMSHKHKKTUBMSdxOK7Lhm3qziDtYE17jyXJSA-khmSAZPuGEjwtjg7MtbQo6JNLQ12Yu4hXO0en0vQF9poNHMLbVWeOMEfKONm3OAXm5CzU4q8uK-vmN_oFknFQmhPISzrNhtajA");

  runApp(MultiProvider(
    providers: [
      Provider<ApiService>(create: (_) => apiService),
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
    debugPrint(Provider.of<ApiService>(context).isAuth.toString());
    return Provider.of<ApiService>(context).isAuth
        ? const StartScreen()
        : const OnboardingScreen();
  }
}
