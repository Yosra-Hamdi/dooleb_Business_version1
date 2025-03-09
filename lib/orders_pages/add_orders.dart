import 'dart:convert';
import 'package:ec_app/clients_pages/customer_list.dart';
import 'package:ec_app/SM_local_config.dart';

import 'package:ec_app/graphql/mutations.dart';
import 'package:ec_app/orders_pages/delevry_address.dart';
import 'package:ec_app/products_pages/product_list.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddOrderPage extends StatefulWidget {
  const AddOrderPage({super.key, required Map commande});

  @override
  _AddOrderPageState createState() => _AddOrderPageState();
}

class _AddOrderPageState extends State<AddOrderPage> {
  dynamic selectedProduct;
  dynamic selectedClient;
  dynamic selectedDeliveryAddress;
  dynamic selectedBillingAddress;
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _deliveryAddressController = TextEditingController();
  final TextEditingController _billingAddressController = TextEditingController();

  String? selectedPaymentMethod;
  double montantTotal = 0.0;

  @override
  void initState() {
    super.initState();
    _quantityController.addListener(_updateMontantTotal);
  }

  @override
  void dispose() {
    _quantityController.removeListener(_updateMontantTotal);
    _quantityController.dispose();
    _deliveryAddressController.dispose();
    _billingAddressController.dispose();
    super.dispose();
  }

  void _updateMontantTotal() {
    if (selectedProduct != null) {
      final quantity = int.tryParse(_quantityController.text) ?? 0;
      final prix = double.tryParse(selectedProduct['price'].toString()) ?? 0.0;
      setState(() {
        montantTotal = prix * quantity;
      });
    }
  }

  String? _validateQuantity(String value) {
    if (value.isEmpty) return 'Veuillez entrer une quantité';
    final quantity = int.tryParse(value);
    if (quantity == null) return 'Nombre invalide';
    if (quantity <= 0) return 'Doit être supérieur à 0';
    if (selectedProduct != null && quantity > selectedProduct['stockQuantity']) {
      return 'Stock insuffisant (${selectedProduct['stockQuantity']})';
    }
    return null;
  }

  bool _validateAllFields() {
    if (selectedProduct == null ||
        selectedClient == null ||
        _quantityController.text.isEmpty ||
        _deliveryAddressController.text.isEmpty ||
        _billingAddressController.text.isEmpty ||
        selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs correctement.')),
      );
      return false;
    }
    return true;
  }

  void _showAddAddressDialog(bool isDeliveryAddress) {
    final TextEditingController streetController = TextEditingController();
    final TextEditingController cityController = TextEditingController();
    final TextEditingController postalCodeController = TextEditingController();
    String selectedCountry = "Tunisie"; // Valeur par défaut
    // Liste des pays autorisés (doit correspondre à l'Enum dans Django)
    final List<String> countryList = [
    "Tunisie",
    "France",
    "Allemagne",
    "Italie",
    "Espagne",
    "États-Unis",
    "Canada",
    "Royaume-Uni"
  ];
  


    // Fonction de validation des champs de l'adresse
    String? _validateAddressFields() {
      if (streetController.text.isEmpty) return 'Veuillez entrer la rue';
      if (cityController.text.isEmpty) return 'Veuillez entrer la ville';
      if (postalCodeController.text.isEmpty) return 'Veuillez entrer le code postal';
      return null;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ajouter une adresse'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: streetController,
                  decoration: const InputDecoration(labelText: 'Rue'),
                ),
                TextField(
                  controller: cityController,
                  decoration: const InputDecoration(labelText: 'Ville'),
                ),
                TextField(
                  controller: postalCodeController,
                  decoration: const InputDecoration(labelText: 'Code Postal'),
                ),
                 DropdownButtonFormField<String>(
                value: selectedCountry,
                items: countryList.map((String country) {
                  return DropdownMenuItem<String>(
                    value: country,
                    child: Text(country),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCountry = newValue!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Pays'),
              ),
            ],
          ),
        ),
               
             
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Validation des champs avant de soumettre
                final validationError = _validateAddressFields();
                if (validationError != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(validationError)),
                  );
                  return;
                }
                const String url = Config.backendUrl;
                final response = await http.post(
                  Uri.parse(url),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({
                    'query': createAddressMutation,
                    'variables': {
                      'city': cityController.text,
                      'country': selectedCountry.toUpperCase().replaceAll('-', '_'),
                      'postalCode': postalCodeController.text,
                      'street': streetController.text,
                    },
                  }),
                );

                final responseData = jsonDecode(response.body);
                if(response.statusCode == 200 && responseData['data'] != null && 
    responseData['data']['createAddress'] != null && 
    responseData['data']['createAddress']['address'] != null) {
                  final addressId = responseData['data']['createAddress']['address']['id'];
                  final newAddress = {
                    'id': addressId,
                    'street': streetController.text,
                    'city': cityController.text,
                    'postalCode': postalCodeController.text,
                    'country': selectedCountry,
                  };

                     setState(() {
                  if (isDeliveryAddress) {
                    _deliveryAddressController.text = '${streetController.text}, ${cityController.text}, ${postalCodeController.text}, $selectedCountry';
                    selectedDeliveryAddress = newAddress;
                  } else {
                    _billingAddressController.text = '${streetController.text}, ${cityController.text}, ${postalCodeController.text}, $selectedCountry';
                    selectedBillingAddress = newAddress;
                  }
                });
                  Navigator.pop(context);
                } else {
                  print('Erreur GraphQL: ${response.body}');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Erreur lors de l\'ajout de l\'adresse.')),
                  );
                }
              },
              child: const Text('Enregistrer'),
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
        title: const Text(
          'Ajouter une commande',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 4,
        backgroundColor: Colors.white.withOpacity(0.9),
        shadowColor: Colors.grey.withOpacity(0.3),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sélection de produit avec champ de quantité intégré
            Card(
              
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (selectedProduct != null && selectedProduct['image'] != null)
                      Image.network(
                        'http://10.0.2.2:8000${selectedProduct['image']}',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    const SizedBox(height: 8),
                    Text(
                      selectedProduct != null
                          ? "Produit : ${selectedProduct['name']}"
                          : "Aucun produit sélectionné",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    if (selectedProduct != null) ...[
                      const SizedBox(height: 8),
                      Text("Prix : ${selectedProduct['price']} TND"),
                      Text("Stock : ${selectedProduct['stockQuantity']}"),
                      Text("Catégorie : ${selectedProduct['category']['name']}"),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _quantityController,
                        decoration: InputDecoration(
                          labelText: 'Quantité',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          errorText: _validateQuantity(_quantityController.text),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: _validateQuantity(_quantityController.text) != null
                                  ? Colors.red
                                  : Colors.grey,
                              width: 1.5,
                            ),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Montant Total: ${montantTotal.toStringAsFixed(2)} TND',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProductListPage(selectMode: true),
                          ),
                        );
                        if (result != null) {
                          setState(() {
                            selectedProduct = result;
                            _updateMontantTotal();
                          });
                        }
                      },
                      child: const Text('Sélectionner un produit'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Sélection de client
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                title: Text(selectedClient != null
                    ? "Client : ${selectedClient['firstName']} ${selectedClient['lastName']}"
                    : "Aucun client sélectionné"),
                subtitle: selectedClient != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Email : ${selectedClient['email']}"),
                          Text("Téléphone : ${selectedClient['phone']}"),
                          Text("Adresse : ${selectedClient['address']['street']}, ${selectedClient['address']['city']}"),
                        ],
                      )
                    : null,
                trailing: ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CustomerListPage(selectMode: true),
                      ),
                    );
                    if (result != null) {
                      setState(() {
                        selectedClient = result;
                      });
                    }
                  },
                  child: const Text('Sélectionner'),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Adresse de livraison avec bouton pour ajouter une nouvelle adresse
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _deliveryAddressController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Adresse de livraison',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.list ,  color: Color.fromARGB(255, 58, 18, 188)), 
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddressListPage(selectMode: true),
                      ),
                    );
                    if (result != null) {
                      setState(() {
                        selectedDeliveryAddress = result;
                        _deliveryAddressController.text = '${result['street']}, ${result['city']}, ${result['postalCode']}, ${result['country']}';
                      });
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.add_location  ,color: Color.fromARGB(255, 30, 17, 171)),
                  onPressed: () => _showAddAddressDialog(true),
                ),
              ],
            ),

            const SizedBox(height: 16),
              // Adresse de facturation avec bouton pour ajouter une nouvelle adresse
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _billingAddressController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Adresse de facturation',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
             
                IconButton(
                  icon: const Icon(Icons.add_location ,  color: Color.fromARGB(255, 15, 33, 169)), 
                 onPressed: () => _showAddAddressDialog(false),
                ),
              ],
            ),
             const SizedBox(height: 16),

            // Méthode de paiement
            DropdownButtonFormField<String>(
              value: selectedPaymentMethod,
              decoration: InputDecoration(
                labelText: 'Méthode de paiement',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              items: ['CARD', 'CASH'].map((method) {
                return DropdownMenuItem<String>(value: method, child: Text(method));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedPaymentMethod = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Bouton pour valider la commande
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (!_validateAllFields()) return;

                  const String url = Config.backendUrl;
                  final response = await http.post(
                    Uri.parse(url),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({
                      'query': createOrderMutation,
                      'variables': {
                        'customerId': selectedClient['id'],
                        'paymentMethod': selectedPaymentMethod,
                        'products': [
                          {
                            'productId': selectedProduct['id'],
                            'quantity': int.parse(_quantityController.text),
                          },
                        ],
                        'deliveryAddressId': selectedDeliveryAddress['id'],
                        'billingAddressId': selectedBillingAddress['id'],
                        'status': 'UNCONFIRMED',
                      },
                    }),
                  );

                  final responseData = jsonDecode(response.body);

                  if (response.statusCode == 200 && responseData['data'] != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Commande ajoutée avec succès!')),
                    );
                    Navigator.pop(context);
                  } else {
                    print('Erreur GraphQL: ${response.body}');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Erreur lors de l'ajout de la commande.")),
                    );
                  }
                },
                child: const Text('Valider la commande',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold , color: Color.fromARGB(255, 38, 76, 214)), 
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}