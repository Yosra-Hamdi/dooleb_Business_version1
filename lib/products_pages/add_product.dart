import 'dart:convert';
import 'package:ec_app/SM_local_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ec_app/graphql/mutations.dart'; // Importez la mutation

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prixController = TextEditingController();
  final TextEditingController _quantiteController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  int? _categoryId;

  // Fonction pour ajouter un produit via GraphQL
  Future<void> addProduct() async {
    const String url = Config.backendUrl; // Utiliser l'URL depuis config.dart

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'query': createProductMutation,
        'variables': {
          'nom': _nomController.text,
          'prix': _prixController.text,
          'quantiteStock': int.tryParse(_quantiteController.text) ?? 0,
          'categoryId': _categoryId,
          'unit': _unitController.text,
        }
      }),
    );

    if (response.statusCode == 200) {
      Navigator.pop(context, true); // Retourne à la page de liste des produits
    } else {
      throw Exception('Failed to add product');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un produit'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(labelText: 'Nom du produit'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom de produit';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _prixController,
                decoration: const InputDecoration(labelText: 'Prix'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un prix';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _quantiteController,
                decoration: const InputDecoration(labelText: 'Quantité en stock'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une quantité';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _unitController,
                decoration: const InputDecoration(labelText: 'Unité'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une unité';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    addProduct();
                  }
                },
                child: const Text('Ajouter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
