import 'package:ec_app/SM_local_config.dart';

import 'package:ec_app/graphql/mutations.dart';
import 'package:ec_app/products_pages/product_list.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';

class OrderDetailsPage extends StatefulWidget {
  final Map<String, dynamic> commande;

  const OrderDetailsPage({super.key, required this.commande});

  @override
  _OrderDetailsPageState createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  String? selectedStatut;
  double totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    selectedStatut = widget.commande['status'] ?? 'UNCONFIRMED';
    calculateTotal();
  }

  void calculateTotal() {
    final products = widget.commande['products'] ?? [];
    double newTotal = 0.0;

    for (var productData in products) {
      final product = productData['product'] ?? {};
      int quantity = productData['quantity'] ?? 0;
      double price = double.tryParse(product['price'].toString()) ?? 0.0;
      newTotal += quantity * price;
    }

    setState(() {
      totalAmount = newTotal;
    });
  }

  void removeProduct(int index) async {
    TextEditingController confirmationController = TextEditingController();

    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation de suppression', style: TextStyle(fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Êtes-vous sûr de vouloir supprimer ce produit de la commande ?',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmationController,
                decoration: const InputDecoration(
                  hintText: 'Tapez "Confirmer" pour confirmer',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                if (confirmationController.text.trim() == 'Confirmer') {
                  Navigator.of(context).pop(true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Veuillez taper "Confirmer" pour confirmer la suppression')),
                  );
                }
              },
              child: const Text('Confirmer', style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      setState(() {
        widget.commande['products'].removeAt(index);
        calculateTotal();
      });
    }
  }

  Future<void> saveChanges() async {
    const String url = Config.backendUrl;

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'query': updateOrderMutation,
        'variables': {
          'orderId': widget.commande['id'],
          'products': widget.commande['products'].map((productData) {
            return {
              'productId': productData['product']['id'],
              'quantity': productData['quantity'],
            };
          }).toList(),
        },
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['data']['updateOrder'] != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Modifications enregistrées avec succès!')),
        );
        Navigator.pop(context, true);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de l\'enregistrement des modifications')),
        );
      }
    }
  }

  Future<void> deleteCommande(BuildContext context, String id) async {
    if (widget.commande['status'] == 'DELIVERED') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Une commande livrée ne peut pas être supprimée')),
      );
      return;
    }

    TextEditingController confirmationController = TextEditingController();

    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation de suppression', style: TextStyle(fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Vous souhaitez supprimer la commande avec  ?\n'
                'L\'historique des statuts et les détails de la commande seront également supprimés.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmationController,
                decoration: const InputDecoration(
                  hintText: 'Tapez "Confirmer" pour confirmer',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                if (confirmationController.text.trim() == 'Confirmer') {
                  Navigator.of(context).pop(true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Veuillez taper "Confirmer" pour confirmer la suppression')),
                  );
                }
              },
              child: const Text('Confirmer', style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );

    if (!confirmDelete) return;

    const String url = Config.backendUrl;

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'query': deleteOrderMutation,
        'variables': {'orderId': id},
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (data['errors'] != null) {
        final errorMessage = data['errors'][0]['message'];
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur GraphQL: $errorMessage')),
          );
        }
        return;
      }

      if (data['data'] != null && data['data']['deleteOrder'] != null) {
        final success = data['data']['deleteOrder']['success'];

        if (success == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Commande supprimée avec succès!')),
            );
            Navigator.pop(context, true);
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('La suppression a échoué')),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Réponse inattendue de l\'API')),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la suppression')),
        );
      }
    }
  }
  Future<void> updateStatutCommande(BuildContext context, String id, String newStatut) async {
    const String url = Config.backendUrl;

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'query': updateOrderStatus,
        'variables': {'orderId': id, 'status': newStatut},
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['data']['updateOrderStatus']['order'] != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Statut mis à jour avec succès!')),
        );
        setState(() {
          selectedStatut = newStatut;
        });
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la mise à jour du statut')),
        );
      }
    }
  }
@override
Widget build(BuildContext context) {
  final customer = widget.commande['customer'] ?? {};
  final deliveryAddress = widget.commande['deliveryAddress'] ?? {};
  final billingAddress = widget.commande['billingAddress'] ?? {};
  final products = widget.commande['products'] ?? [];

  return Scaffold(
    appBar: AppBar(
      title: Text('Détails de la Commande #${widget.commande['id']}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
      
     
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statut de la commande
          Container(
            width: double.infinity, // Occupe toute la largeur de l'écran
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(255, 255, 243, 243).withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Statut de la Commande',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                DropdownButton<String>(
                  value: selectedStatut,
                  isExpanded: true, // Pour que le DropdownButton occupe toute la largeur
                  onChanged: (String? newValue) {
                    if (newValue != null && widget.commande['id'] != null) {
                      updateStatutCommande(context, widget.commande['id'].toString(), newValue);
                    }
                  },
                  items: ['UNCONFIRMED', 'CONFIRMED', 'CANCELLED', 'PAID', 'DELIVERED']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
            const SizedBox(height: 16),

            
              // Montant Total
          Container(
            width: double.infinity, // Occupe toute la largeur de l'écran
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Montant Total : ${totalAmount.toStringAsFixed(2)} TND',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Date de Création : ${widget.commande['creationDate'] ?? 'Non spécifiée'}',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  'Méthode de Paiement : ${widget.commande['paymentMethod'] ?? 'Non spécifiée'}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        

          // Informations du client
Container(
  width: double.infinity, // Occupe toute la largeur de l'écran
  margin: const EdgeInsets.symmetric(vertical: 8),
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.2),
        spreadRadius: 1,
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ],
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Informations Client',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      const SizedBox(height: 8),
      Text(
        'Nom : ${customer['firstName'] ?? ''} ${customer['lastName'] ?? ''}',
        style: const TextStyle(fontSize: 14),
      ),
      const SizedBox(height: 4),
      Text(
        'Téléphone : ${customer['phone'] ?? 'Non spécifié'}',
        style: const TextStyle(fontSize: 14),
      ),
      const SizedBox(height: 4),
      Text(
        'Email : ${customer['email'] ?? 'Non spécifié'}',
        style: const TextStyle(fontSize: 14),
      ),
    ],
  ),
),
const SizedBox(height: 16),

// Adresse de livraison
Container(
  width: double.infinity, // Occupe toute la largeur de l'écran
  margin: const EdgeInsets.symmetric(vertical: 8),
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.2),
        spreadRadius: 1,
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ],
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Adresse de Livraison',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '${deliveryAddress['street'] ?? ''} '
              '${deliveryAddress['city'] ?? ''} '
              '${deliveryAddress['postalCode'] ?? ''} '
              '${deliveryAddress['country'] ?? ''}'.trim().isEmpty 
                ? 'Non spécifiée' 
                : '${deliveryAddress['street'] ?? ''}, '
                  '${deliveryAddress['city'] ?? ''}, '
                  '${deliveryAddress['postalCode'] ?? ''}, '
                  '${deliveryAddress['country'] ?? ''}',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
      IconButton(
        icon: const Icon(Icons.edit,  color: Color.fromARGB(255, 40, 34, 213)),
        onPressed: () {
          // Action de modification ici
        },
      ),
    ],
  ),
),
const SizedBox(height: 16),
Container(
  width: double.infinity, // Occupe toute la largeur de l'écran
  margin: const EdgeInsets.symmetric(vertical: 8),
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.2),
        spreadRadius: 1,
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ],
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Adresse de Facturation',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '${billingAddress['street'] ?? ''} '
              '${billingAddress['city'] ?? ''} '
              '${billingAddress['postalCode'] ?? ''} '
              '${billingAddress['country'] ?? ''}'.trim().isEmpty 
                ? 'Non spécifiée' 
                : '${billingAddress['street'] ?? ''}, '
                  '${billingAddress['city'] ?? ''}, '
                  '${billingAddress['postalCode'] ?? ''}, '
                  '${billingAddress['country'] ?? ''}',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
      IconButton(
        icon: const Icon(Icons.edit, color: Color.fromARGB(255, 40, 34, 213)),
        onPressed: () {
          // Action de modification ici
        },
      ),
    ],
  ),
),
const SizedBox(height: 16),


          Container(
            width: double.infinity, // Occupe toute la largeur de l'écran
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
            color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.2),
        spreadRadius: 1,
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ],
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // En-tête : Titre + Bouton Ajouter
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Produits Commandés',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          ElevatedButton(
            onPressed: () async {
              final selectedProduct = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProductListPage(selectMode: true),
                ),
              );

              if (selectedProduct != null) {
                setState(() {
                  widget.commande['products'].add({
                    'product': selectedProduct,
                    'quantity': 1,
                  });
                  calculateTotal();
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 16, 24, 179),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Icon(
              Icons.add, 
              size: 20, 
              color: Colors.white,
            ),
          ),
          
        ],
      ),
      const SizedBox(height: 16),

      // Liste des produits
      ...products.asMap().entries.map<Widget>((entry) {
        final index = entry.key;
        final productData = entry.value;
        final product = productData['product'] ?? {};
        int quantity = productData['quantity'] ?? 0;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
            leading: product['image'] != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: 'http://10.0.2.2:8000${product['image']}',
                      placeholder: (context, url) => const CircularProgressIndicator(),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  )
                : Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.image_not_supported, size: 30, color: Colors.grey),
                  ),
            title: Text(
              product['name'] ?? 'Nom non disponible',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Prix: ${product['price']} TND',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                
                Row(
                  children: [
                    const Text('Quantité: ', style: TextStyle(fontSize: 12)),
                    IconButton(
                      icon: const Icon(Icons.remove, size: 18),
                      onPressed: () {
                        if (quantity > 1) {
                          setState(() {
                            quantity--;
                            productData['quantity'] = quantity;
                            calculateTotal();
                          });
                        }
                      },
                    ),
                    Container(
                      width: 40,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Text(
                        quantity.toString(),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 16),
                      onPressed: () {
                        setState(() {
                          quantity++;
                          productData['quantity'] = quantity;
                          calculateTotal();
                        });
                      },
                    ),
                 
                  ],
                ),
                  IconButton(
                      icon: const Icon(Icons.delete, size: 25, color: Colors.red),
                      onPressed: () {
                        removeProduct(index);
                      },
                    ),
              ],
            ),
          ),
        );
      }).toList(),
    ],
  ),
),

            // Bouton de suppression de la commande
          Row(
            mainAxisAlignment: MainAxisAlignment.center, // Centrer les boutons horizontalement
            children: [
              // Bouton "Enregistrer les modifications"
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Couleur verte pour indiquer une action positive
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Bordures arrondies
                  ),
                  elevation: 2, // Ombre légère pour un effet de profondeur
                ),
                onPressed: saveChanges,
                child: const Text('Enregistrer',
                  style: TextStyle(fontSize: 16,
                  color: Colors.white, 
                  fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16), // Espacement entre les boutons

    // Bouton "Supprimer la commande"
    ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red, // Couleur rouge pour indiquer une action critique
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Bordures arrondies
        ),
        elevation: 2, // Ombre légère pour un effet de profondeur
      ),
      onPressed: () => deleteCommande(context, widget.commande['id']?.toString() ?? ''),
      child: const Text(
        'Supprimer',
        style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
      ),
    ),
  ],
),
          ],
        ),
      ),
    );
  }
}