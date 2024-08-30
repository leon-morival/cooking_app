import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cooking_app/models/recipe_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddRecipePage extends StatefulWidget {
  const AddRecipePage({super.key});

  @override
  State<AddRecipePage> createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();
  final TextEditingController _stepsController = TextEditingController();

  File? _imageFile; // Variable to hold the selected image

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Failed to pick image: $e");
    }
  }

  void _showImageSourceSelection() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera); // Take a photo
              },
              child: const Text('Take a Photo'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery); // Pick from gallery
              },
              child: const Text('Choose from Gallery'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

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
              // Image Picker
              _imageFile == null
                  ? const Text('No image selected.')
                  : Image.file(_imageFile!),
              ElevatedButton(
                onPressed: _showImageSourceSelection,
                child: const Text('Pick Image'),
              ),
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
    if (_imageFile == null) {
      // Handle case where no image is selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image.'),
        ),
      );
      return;
    }

    final newRecipe = Recipe(
      id: '',
      name: _nameController.text,
      imageURL: _imageFile!
          .path, // Save the file path or upload the file to Firebase Storage
      description: _descriptionController.text,
      ingredients: _ingredientsController.text.split(','),
      steps: _stepsController.text.split(','),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      authorId: 'exampleAuthorId', // Replace with actual author ID
    );

    try {
      final docRef = await FirebaseFirestore.instance
          .collection('recipes')
          .add(newRecipe.toMap());

      // Optionally update the recipe with the generated ID
      await FirebaseFirestore.instance
          .collection('recipes')
          .doc(docRef.id)
          .update({'id': docRef.id});

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recipe added successfully!'),
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add recipe: $e'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
