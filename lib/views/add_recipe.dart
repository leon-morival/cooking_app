import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cooking_app/models/recipe_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/cupertino.dart'; // Import Cupertino package

class AddRecipePage extends StatefulWidget {
  const AddRecipePage({super.key});

  @override
  State<AddRecipePage> createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  final _formKey = GlobalKey<FormState>();
  final User? user = FirebaseAuth.instance.currentUser;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();
  final TextEditingController _stepsController = TextEditingController();

  File? _imageFile; // Variable to hold the selected image
  Duration _duration = Duration.zero; // New field for duration

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

  void _showDurationPicker() {
    // Initial selected values
    int selectedHours = _duration.inHours;
    int selectedMinutes = _duration.inMinutes.remainder(60);

    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          title: const Text('Choisir la durée'),
          message: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 32,
                  scrollController:
                      FixedExtentScrollController(initialItem: selectedHours),
                  onSelectedItemChanged: (index) {
                    selectedHours = index;
                  },
                  children: List<Widget>.generate(24, (index) {
                    return Center(child: Text('$index heures'));
                  }),
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 32,
                  scrollController:
                      FixedExtentScrollController(initialItem: selectedMinutes),
                  onSelectedItemChanged: (index) {
                    selectedMinutes = index;
                  },
                  children: List<Widget>.generate(60, (index) {
                    return Center(child: Text('$index minutes'));
                  }),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            CupertinoActionSheetAction(
              child: const Text('Valider'),
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _duration = Duration(
                    hours: selectedHours,
                    minutes: selectedMinutes,
                  );
                });
              },
            ),
            CupertinoActionSheetAction(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.pop(context);
              },
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
        title: const Text('Créer une recette'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Image Picker
              _imageFile == null
                  ? const Text("Pas d'image sélectionné.")
                  : Image.file(_imageFile!),
              ElevatedButton(
                onPressed: _showImageSourceSelection,
                child: const Text('Choisir une image'),
              ),
              TextFormField(
                controller: _nameController,
                decoration:
                    const InputDecoration(labelText: 'Nom de la recette'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez rentrer le nom de la recette';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une description';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _ingredientsController,
                decoration: const InputDecoration(
                    labelText: 'Ingredients (séparé par des virgules)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Merci de rentrer des ingrédients';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _stepsController,
                decoration: const InputDecoration(
                    labelText: 'Etapes (séparé par des virgules)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez rentrer les différentes étapes';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _showDurationPicker,
                child: Text(
                  'Choisir la durée de la recette: ${_duration.inHours}h ${_duration.inMinutes.remainder(60)}m',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _addRecipe();
                  }
                },
                child: const Text('Ajouté la recette'),
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
          content: Text('Merci de selectionner une image.'),
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
      authorId: user!.uid, // Replace with actual author ID
      duration: _duration,
      published: false,
      validated: false, // Add the duration
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
          content: Text('La recette à bien été ajoutée!'),
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("erreur lors de l'ajout de la recette: $e"),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
