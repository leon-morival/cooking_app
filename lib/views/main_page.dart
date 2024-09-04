import 'package:cooking_app/views/meal_prep_page.dart';
import 'package:flutter/material.dart';
import 'package:cooking_app/views/home_page.dart';
import 'package:cooking_app/views/recipes_page.dart';
import 'package:cooking_app/views/shopping_list_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const ShoppingListPage(),
    const MealPrepPage(),
    const RecipesPage(),
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
            icon: Icon(Icons.event_note),
            label: 'Meal Prep',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Recettes',
          ),
        ],
        // Explicitly set colors
        selectedItemColor: Colors.blue, // Color for selected item
        unselectedItemColor: Colors.grey, // Color for unselected items
        backgroundColor: Colors.white, // Background color of the bar
      ),
    );
  }
}
