import 'dart:convert';
import 'package:ec_app/SM_local_config.dart';

import 'package:ec_app/graphql/queries.dart'; // Importez votre fichier de requêtes GraphQL
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class AddressListPage extends StatefulWidget {
  final bool selectMode; // Mode sélection pour retourner une adresse

  const AddressListPage({super.key, this.selectMode = false});

  @override
  _AddressListPageState createState() => _AddressListPageState();
}

class _AddressListPageState extends State<AddressListPage> {
  List customers = []; // Liste des clients avec leurs adresses

  @override
  void initState() {
    super.initState();
    fetchCustomersWithAddresses();
  }

  // Fonction pour récupérer les clients avec leurs adresses via GraphQL
  Future<void> fetchCustomersWithAddresses() async {
    const String url = Config.backendUrl; // Utiliser l'URL depuis config.dart

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'query': getCustomersWithAddressesQuery}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['data'] != null && data['data']['allCustomer'] != null) {
        setState(() {
          customers = data['data']['allCustomer'];
        });
      } else {
        setState(() {
          customers = [];
        });
      }
    } else {
      throw Exception('Failed to load customers with addresses');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0, // Suppression de l'ombre sous l'AppBar
        backgroundColor: Colors.transparent, // Fond transparent pour une AppBar simple
        title: const Text(
          'Adresses des clients',
          style: TextStyle(
            fontWeight: FontWeight.w500, // Poids de la police plus léger
            fontSize: 22,
            color: Colors.black, // Couleur noire pour un look épuré
          ),
        ),
      ),
      body: customers.isEmpty
          ? const Center(
              child: Text(
                'Aucun client trouvé',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: customers.length,
              itemBuilder: (context, index) {
                var customer = customers[index];
                var address = customer['address'];
                return Card(
                  elevation: 5, // Ombre de la carte
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15), // Coins arrondis
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10),
                    title: Text(
                      '${customer['firstName']} ${customer['lastName']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (address != null) ...[
                          Text(
                            '${address['street'] ?? 'Rue non disponible'}',
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                          ),
                          Text(
                            '${address['city']}, ${address['postalCode']}',
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                          ),
                          Text(
                            '${address['country']}',
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                          ),
                        ] else
                          const Text(
                            'Aucune adresse disponible',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black),
                    onTap: () {
                      if (widget.selectMode) {
                        // Mode Sélection : Retourne l'adresse sélectionnée
                        Navigator.pop(context, address);
                      } else {
                        // Mode Normal : Navigue vers une page de détails (si nécessaire)
                        // Exemple : Navigator.push(context, MaterialPageRoute(builder: (context) => AddressDetailsPage(address: address)));
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}