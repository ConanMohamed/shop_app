import 'package:flutter/material.dart';
import 'widgets/grocery_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 255, 215, 213),
        brightness: Brightness.light,
        surface: const Color.fromARGB(255, 223, 255, 214),
        ),
        scaffoldBackgroundColor: const Color.fromARGB(255, 232, 215, 255),
        useMaterial3: true,
      ),
      home: const GroceryList(),
    );
  }
}
