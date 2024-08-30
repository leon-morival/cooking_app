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
    };
  }
}
