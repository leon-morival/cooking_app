import 'package:cloud_firestore/cloud_firestore.dart';

class Recipe {
  final String id;
  final String name;
  final String imageURL;
  final String description;
  final List<String> ingredients;
  final List<String> steps;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String authorId;
  final Duration duration;
  final bool validated; // New field for validation status
  final bool published; // New field for publication status

  Recipe({
    required this.id,
    required this.name,
    required this.imageURL,
    required this.description,
    required this.ingredients,
    required this.steps,
    required this.createdAt,
    required this.updatedAt,
    required this.authorId,
    required this.duration,
    required this.validated, // Initialize validated
    required this.published, // Initialize published
  });

  factory Recipe.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Recipe(
      id: documentId,
      name: data['name'],
      imageURL: data['imageURL'],
      description: data['description'],
      ingredients: List<String>.from(data['ingredients']),
      steps: List<String>.from(data['steps']),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      authorId: data['authorId'],
      duration: Duration(
        hours: data['duration']['hours'] ?? 0,
        minutes: data['duration']['minutes'] ?? 0,
      ),
      validated: data['validated'] ?? false, // Handle validated field
      published: data['published'] ?? false, // Handle published field
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageURL': imageURL,
      'description': description,
      'ingredients': ingredients,
      'steps': steps,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'authorId': authorId,
      'duration': {
        'hours': duration.inHours,
        'minutes': duration.inMinutes.remainder(60),
      },
      'validated': validated, // Include validated field
      'published': published, // Include published field
    };
  }
}
