import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Pour gérer les images en cache

class ProductDetailsPage extends StatelessWidget {
  final dynamic produit;

  const ProductDetailsPage({super.key, required this.produit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du produit'),
        backgroundColor: Colors.transparent, // Transparente pour un look moderne
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            // Image du produit dans une carte avec ombre
            Card(
              elevation: 4, // Ombre légère
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // Bordures arrondies
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: produit['image'] != null
                    ? CachedNetworkImage(
                        imageUrl: 'http://10.0.2.2:8000${produit['image']}',
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                        width: double.infinity, // Largeur maximale
                        height: 350, // Hauteur fixe pour l'image
                        fit: BoxFit.cover, // Couvrir toute la zone
                      )
                    : Container(
                        width: double.infinity,
                        height: 50,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // Nom du produit
            Text(
              produit['name'] ?? 'Nom non disponible',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Informations du produit dans une carte
            Card(
              elevation: 2, // Ombre légère
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // Bordures arrondies
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Prix du produit
                    _buildInfoRow('Prix', '${produit['price']} TND'),
                    const SizedBox(height: 12),

                    // Quantité en stock
                    _buildInfoRow('Quantité en stock', '${produit['stockQuantity']}'),
                    const SizedBox(height: 12),

                    // Catégorie du produit
                    _buildInfoRow('Catégorie', produit['category']['name'] ?? 'Non spécifiée'),
                    const SizedBox(height: 12),

                    // Unité du produit
                    _buildInfoRow('Unité', produit['unit'] ?? 'Non spécifiée'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Méthode pour construire une ligne d'information
  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label : ',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}