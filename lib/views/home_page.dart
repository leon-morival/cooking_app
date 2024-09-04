import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cooking_app/views/recipe_detail_page.dart';
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            // Ajoutez ici les éléments que vous voulez au-dessus de la liste
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                "Trouvez les meilleurs recettes dès maintenant",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Rechercher des recettes...",
                  suffixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15.0, vertical: 10.0),
                ),
              ),
            ),
            // Ajoutez plus de widgets ici si nécessaire

            // Ensuite, placez le StreamBuilder dans la colonne
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('recipes')
                  .where('validated', isEqualTo: true)
                  .where('published', isEqualTo: true)
                  .snapshots(),
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
                  shrinkWrap:
                      true, // This ensures that ListView takes only as much space as needed
                  physics:
                      const NeverScrollableScrollPhysics(), // Disable scrolling inside the ListView since it's already in a ScrollView
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(
                            255, 255, 255, 255), // Light grey background color
                        borderRadius:
                            BorderRadius.circular(12.0), // Border radius
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 181, 181, 181)
                                .withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: const Offset(0, 1), // Shadow offset
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
                              builder: (context) =>
                                  RecipeDetailPage(recipe: recipe),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
