import 'dart:convert';
import 'package:ec_app/EM_local_config.dart';

import 'package:ec_app/graphql/queries.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class BillingAddressListPage extends StatefulWidget {
  const BillingAddressListPage({super.key});

  @override
  _BillingAddressListPageState createState() => _BillingAddressListPageState();
}

class _BillingAddressListPageState extends State<BillingAddressListPage> {
  Map<String, dynamic>? order;

  @override
  void initState() {
    super.initState();
    fetchBillingAddress('66'); // Passer l'ID de la commande ici
  }

  // Fonction pour récupérer l'adresse de facturation via GraphQL
  Future<void> fetchBillingAddress(String orderId) async {
    const String url = Config.backendUrl; // Utiliser l'URL depuis config.dart

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'query': getOrderBillingAddressQuery,
        'variables': {'id': orderId},
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['data'] != null && data['data']['order'] != null) {
        setState(() {
          order = data['data']['order'];
        });
      } else {
        setState(() {
          order = null;
        });
      }
    } else {
      throw Exception('Failed to load billing address');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Adresse de Facturation',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 22,
            color: Colors.black,
          ),
        ),
      ),
      body: order == null
          ? const Center(
              child: Text(
                'Aucune adresse de facturation trouvée',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : Card(
              elevation: 5,
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(10),
                title: Text(
                  'Commande #${order!['id']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                subtitle: Text(
                  'Ville: ${order!['billingAddress']['city'] ?? 'Non spécifié'}\n'
                  'Pays: ${order!['billingAddress']['country'] ?? 'Non spécifié'}\n'
                  'Code Postal: ${order!['billingAddress']['postalCode'] ?? 'Non spécifié'}\n'
                  'Rue: ${order!['billingAddress']['street'] ?? 'Non spécifié'}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ),
            ),
    );
  }
}