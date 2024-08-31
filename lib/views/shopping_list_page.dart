import 'package:cooking_app/models/shopping_item.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ShoppingListPage extends StatefulWidget {
  const ShoppingListPage({super.key});

  @override
  _ShoppingListPageState createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  final Box<ShoppingItem> shoppingBox = Hive.box<ShoppingItem>('shopping_box');
  String selectedCategory = 'Légumes';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Liste de courses',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: ValueListenableBuilder(
          valueListenable: shoppingBox.listenable(),
          builder: (context, Box<ShoppingItem> box, _) {
            if (box.values.isEmpty) {
              return const Center(
                child: Text('La liste de courses est vide'),
              );
            }

            // Convert the box values to a list
            List<ShoppingItem> items = box.values.toList().cast<ShoppingItem>();

            // Group items by category
            Map<String, List<ShoppingItem>> categorizedItems = {};
            for (var item in items) {
              String category = item.category ?? 'Uncategorized';
              categorizedItems[category] = categorizedItems[category] ?? [];
              categorizedItems[category]!.add(item);
            }

            // Sort items within each category: non-bought items first, then bought items
            categorizedItems.forEach((key, value) {
              value.sort((a, b) {
                // Compare `isBought` status using integer values
                return (a.isBought ? 1 : 0).compareTo(b.isBought ? 1 : 0);
              });
            });
            // Generate list sections
            List<Widget> listSections = [];
            categorizedItems.forEach((category, items) {
              listSections.add(
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    category,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              );

              for (var item in items) {
                listSections.add(
                  Dismissible(
                      key: Key(item.id), // Use the unique ID as the key
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Confirmer la suppression'),
                              content: const Text(
                                  'Voulez-vous vraiment supprimer cet aliment ?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                  child: const Text('Annuler'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                  },
                                  child: const Text('Supprimer'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      onDismissed: (direction) {
                        item.delete();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${item.name} supprimé'),
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 1.0, horizontal: 16.0),
                          title: Text(
                            item.name,
                            style: TextStyle(
                              decoration: item.isBought
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          trailing: Checkbox(
                            value: item.isBought,
                            onChanged: (value) {
                              setState(() {
                                item.isBought = value ?? false;
                                item.save();
                              });
                            },
                          ),
                        ),
                      )),
                );
              }
            });

            return ListView(
              children: listSections,
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddItemDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddItemDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ajouter un aliment'),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration:
                        const InputDecoration(hintText: 'Nom de l\'aliment'),
                  ),
                  const SizedBox(height: 20),
                  DropdownButton<String>(
                    value: selectedCategory,
                    items: <String>[
                      'Légumes',
                      'Fruits',
                      'Produits laitiers',
                      'Viandes',
                      'Boissons',
                      'Autres'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setDialogState(() {
                          selectedCategory = newValue;
                        });
                      }
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  final newItem = ShoppingItem(
                    id: DateTime.now().toString(), // Or use a UUID library
                    name: controller.text,
                    category: selectedCategory,
                  );
                  shoppingBox.add(newItem);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }
}
