import 'package:flutter/material.dart';
import 'package:hackheroes_flutter/services/api.dart';
import 'package:provider/provider.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Start Screen'),
      ),
      body: Center(
          child: Column(
        children: [
          const Text('Welcome to the Start Screen!'),
          Text(Provider.of<ApiService>(context).user.email),
          FilledButton(
              onPressed: () {
                Provider.of<ApiService>(context, listen: false)
                    .logout(context: context);
              },
              child: const Text("Wyloguj sie"))
        ],
      )),
    );
  }
}
