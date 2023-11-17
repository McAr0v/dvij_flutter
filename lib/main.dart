
import 'package:flutter/material.dart';
import 'themes/app_colors.dart';
import 'themes/light_theme.dart'; // Импортируйте вашу светлую тему
import 'themes/dark_theme.dart';  // Импортируйте вашу темную тему

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "123",
      theme: CustomTheme.darkTheme,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('123'),
      ),
      body: Container(
        alignment: Alignment.center,
        color: Theme.of(context).colorScheme.background,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Привет Dvij',
                style: Theme.of(context).textTheme.displayLarge

              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  // Действие при нажатии кнопки
                },
                child: const Text('Нажми меня'),
              ),
            ],
          ),
        ),
      )
    );
  }
}