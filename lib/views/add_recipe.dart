import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cooking_app/models/recipe_model.dart';
import 'package:flutter/material.dart';

class AddRecipePage extends StatefulWidget {
  const AddRecipePage({super.key});

  @override
  State<AddRecipePage> createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _imageURLController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();
  final TextEditingController _stepsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a Recipe'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Recipe Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the recipe name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _imageURLController,
                decoration: const InputDecoration(labelText: 'Image URL'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the image URL';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _ingredientsController,
                decoration: const InputDecoration(
                    labelText: 'Ingredients (comma-separated)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter ingredients';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _stepsController,
                decoration:
                    const InputDecoration(labelText: 'Steps (comma-separated)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter steps';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _addRecipe();
                  }
                },
                child: const Text('Add Recipe'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addRecipe() async {
    final newRecipe = Recipe(
      id: '',
      name: _nameController.text,
      imageURL: _imageURLController.text,
      description: _descriptionController.text,
      ingredients: _ingredientsController.text.split(','),
      steps: _stepsController.text.split(','),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      authorId: 'exampleAuthorId', // Replace with actual author ID
    );

    final docRef = await FirebaseFirestore.instance
        .collection('recipes')
        .add(newRecipe.toMap());

    // Optionally update the recipe with the generated ID
    await FirebaseFirestore.instance
        .collection('recipes')
        .doc(docRef.id)
        .update({'id': docRef.id});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("La recette à bien été ajoutée!"),
        duration: Duration(seconds: 2),
      ),
    );

    Navigator.pop(context);
  }
}
