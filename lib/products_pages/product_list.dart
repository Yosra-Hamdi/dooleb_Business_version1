import 'dart:convert';

import 'package:ec_app/EM_local_config.dart';
import 'package:ec_app/graphql/queries.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'product_details.dart'; // Importez la page de détails
import 'add_product.dart'; // Importez la page d'ajout de produit
import 'package:cached_network_image/cached_network_image.dart'; // Importation pour gérer les images en cache

class ProductListPage extends StatefulWidget {
  final bool selectMode; // Ajout du paramètre selectMode

  const ProductListPage({super.key, this.selectMode = false}); // Modifiez le constructeur

  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List produits = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  // Fonction pour récupérer les produits via GraphQL
  Future<void> fetchProducts() async {
    const String url = Config.backendUrl; // Utiliser l'URL depuis config.dart

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'query': getProductsQuery}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['data'] != null && data['data']['products'] != null) {
        setState(() {
          produits = data['data']['products']; // Utilisez 'products' au lieu de 'produits'
        });
      } else {
        setState(() {
          produits = [];
        });
      }
    } else {
      throw Exception('Failed to load products');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0, // Suppression de l'ombre sous l'AppBar
        backgroundColor: Colors.transparent, // Fond transparent pour une AppBar simple
        title: const Text(
          'Tous les produits',
          style: TextStyle(
            fontWeight: FontWeight.w500, // Poids de la police plus léger
            fontSize: 22,
            color: Colors.black, // Couleur noire pour un look épuré
          ),
        ),
        actions: [
          // Bouton moderne avec effet d'élévation
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 12, 42, 179), // Couleur moderne du bouton
                foregroundColor: Colors.white, // Couleur du texte
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Coins arrondis
                ),
                elevation: 5, // Effet d'élévation
              ),
              onPressed: () {
                // Naviguer vers la page d'ajout de produit
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddProductPage(), // Page pour ajouter un produit
                  ),
                ).then((_) {
                  fetchProducts(); // Recharger la liste des produits après ajout
                });
              },
              child: const Text('Ajouter un produit'),
            ),
          ),
        ],
      ),
      body: produits.isEmpty
          ? const Center(
              child: Text(
                'Aucun produit trouvé',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: produits.length,
              itemBuilder: (context, index) {
                var produit = produits[index];
                return Card(
                  elevation: 5, // Ombre de la carte
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15), // Coins arrondis
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10),
                    leading: produit['image'] != null
                        ? CachedNetworkImage(
                            imageUrl: 'http://10.0.2.2:8000${produit['image']}',
                            placeholder: (context, url) => const CircularProgressIndicator(),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                    title: Text(
                      produit['name'] ?? 'Nom non disponible',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      'Prix: ${produit['price']} TND\nStock: ${produit['stockQuantity']} ${produit['unit']}\nCatégorie: ${produit['category']['name']}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    trailing: const Icon(Icons.description, color: Color.fromARGB(255, 36, 19, 186)),
                    onTap: () {
                      if (widget.selectMode) {
                        // Mode Sélection : Retourne le produit sélectionné
                        Navigator.pop(context, produit);
                      } else {
                        // Mode Normal : Navigue vers la page des détails
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailsPage(produit: produit),
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}