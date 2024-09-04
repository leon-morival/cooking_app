import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cooking_app/models/recipe_model.dart';

class RecipeDetailPage extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailPage({super.key, required this.recipe});

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours > 0 ? '$hours hours ' : ''}${minutes > 0 ? '$minutes minutes' : ''}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.name),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display recipe image
              recipe.imageURL.isNotEmpty
                  ? Image.file(
                      File(recipe.imageURL),
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.image,
                            size: 200); // Fallback icon
                      },
                    )
                  : const Icon(Icons.image, size: 200),

              const SizedBox(height: 16.0),

              // Display recipe duration
              if (recipe.duration != Duration.zero)
                Text(
                  'Temps de préparation: ${_formatDuration(recipe.duration)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),

              const SizedBox(height: 16.0),

              // Display recipe name
              Text(
                recipe.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),

              const SizedBox(height: 8.0),

              // Display recipe description
              Text(
                recipe.description,
                style: const TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 16.0),

              // Display ingredients
              const Text(
                'Ingredients',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
              ),
              ...recipe.ingredients
                  .map((ingredient) => Text('- $ingredient'))
                  ,

              const SizedBox(height: 16.0),

              // Display steps
              const Text(
                'Preparation',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
              ),

              const SizedBox(height: 10),
              ...recipe.steps.map((step) {
                final index = recipe.steps.indexOf(step) + 1;
                return Column(
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'STEP $index \n',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: step,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
