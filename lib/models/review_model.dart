import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String id;
  final String recipeId; // Reference to the recipe this note belongs to
  final int score; // Rating score from 1 to 5
  final String? review; // Optional written review
  final DateTime createdAt; // Timestamp when the note was created

  Note({
    required this.id,
    required this.recipeId,
    required this.score,
    this.review, // Review is optional
    required this.createdAt,
  });

  factory Note.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Note(
      id: documentId,
      recipeId: data['recipeId'],
      score: data['score'] ?? 1, // Default to 1 if not provided
      review: data['review'], // Review can be null
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'recipeId': recipeId,
      'score': score,
      'review': review, // Review can be null
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
