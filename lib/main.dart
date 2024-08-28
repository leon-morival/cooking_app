import 'package:cooking_app/views/home_page.dart';
import 'package:cooking_app/views/recipes_page.dart';
import 'package:cooking_app/views/shopping_list_page.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/shopping_item.dart'; // Assurez-vous d'importer le modèle

void main() async {
  // Initialisation de Hive
  await Hive.initFlutter();

  // Enregistrement de l'adaptateur pour ShoppingItem
  Hive.registerAdapter(ShoppingItemAdapter());

  // Ouverture de la boîte 'shopping_box'
  // await Hive.deleteBoxFromDisk('shopping_box');
  await Hive.openBox<ShoppingItem>('shopping_box');

  // Démarrer l'application
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cooking App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    ShoppingListPage(),
    RecipesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Liste Courses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Recettes',
          ),
        ],
      ),
    );
  }
}
