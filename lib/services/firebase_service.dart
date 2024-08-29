import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addRecipe({
    required String name,
    required String imageURL,
    required double rating,
    required String description,
    required List<String> ingredients,
    required List<String> steps,
    required String authorId,
  }) async {
    try {
      await _firestore.collection('recipes').add({
        'name': name,
        'imageURL': imageURL,
        'rating': rating,
        'description': description,
        'ingredients': ingredients,
        'steps': steps,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
        'authorId': authorId,
      });
      print("Recipe added successfully");
    } catch (e) {
      print("Error adding recipe: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getRecipes() async {
    List<Map<String, dynamic>> recipes = [];
    try {
      QuerySnapshot snapshot = await _firestore.collection('recipes').get();
      for (var doc in snapshot.docs) {
        recipes.add(doc.data() as Map<String, dynamic>);
      }
      return recipes;
    } catch (e) {
      print("Error getting recipes: $e");
      return [];
    }
  }

  Future<void> removeRecipe(String recipeId, String currentUserId) async {
    try {
      DocumentSnapshot recipeDoc =
          await _firestore.collection('recipes').doc(recipeId).get();

      if (recipeDoc.exists) {
        Map<String, dynamic> data = recipeDoc.data() as Map<String, dynamic>;
        String authorId = data['authorId'];

        if (authorId == currentUserId) {
          await _firestore.collection('recipes').doc(recipeId).delete();
          print("Recipe removed successfully");
        } else {
          print("You do not have permission to remove this recipe.");
        }
      } else {
        print("Recipe not found");
      }
    } catch (e) {
      print("Error removing recipe: $e");
    }
  }

  Future<void> editRecipe({
    required String recipeId,
    required String currentUserId,
    String? name,
    String? imageURL,
    double? rating,
    String? description,
    List<String>? ingredients,
    List<String>? steps,
  }) async {
    try {
      DocumentSnapshot recipeDoc =
          await _firestore.collection('recipes').doc(recipeId).get();

      if (recipeDoc.exists) {
        Map<String, dynamic> data = recipeDoc.data() as Map<String, dynamic>;
        String authorId = data['authorId'];

        if (authorId == currentUserId) {
          await _firestore.collection('recipes').doc(recipeId).update({
            if (name != null) 'name': name,
            if (imageURL != null) 'imageURL': imageURL,
            if (rating != null) 'rating': rating,
            if (description != null) 'description': description,
            if (ingredients != null) 'ingredients': ingredients,
            if (steps != null) 'steps': steps,
            'updatedAt': Timestamp.now(),
          });
          print("Recipe updated successfully");
        } else {
          print("You do not have permission to edit this recipe.");
        }
      } else {
        print("Recipe not found");
      }
    } catch (e) {
      print("Error updating recipe: $e");
    }
  }
}
