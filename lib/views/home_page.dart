import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cooking_app/views/recipe_detail_page';
import 'package:flutter/material.dart';
import 'package:cooking_app/models/recipe_model.dart';
import 'dart:io';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Les plus populaires',
          style: TextStyle(
            fontSize: 30,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('recipes').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No recipes found.'));
          }

          final recipes = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Recipe.fromFirestore(data, doc.id);
          }).toList();

          return ListView.builder(
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200], // Light grey background color
                  borderRadius: BorderRadius.circular(12.0), // Border radius
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 4,
                      offset: const Offset(0, 2), // Shadow offset
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(8.0),
                  leading: recipe.imageURL.isNotEmpty
                      ? Image.file(
                          File(recipe.imageURL),
                          width: 100,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.image,
                                size: 50); // Fallback icon
                          },
                        )
                      : const Icon(Icons.image, size: 50),
                  title: Text(recipe.name),
                  subtitle: Text(recipe.description),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailPage(recipe: recipe),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
