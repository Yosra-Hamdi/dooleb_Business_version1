import 'package:ec_app/graphql/queries.dart';
import 'package:ec_app/orders_pages/add_orders.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'order_details.dart';
import 'package:ec_app/SM_local_config.dart';


class OrdersListPage extends StatefulWidget {
  const OrdersListPage({super.key});

  @override
  _OrdersListPageState createState() => _OrdersListPageState();
}

class _OrdersListPageState extends State<OrdersListPage> {
  List commandes = [];

  @override
  void initState() {
    super.initState();
    fetchCommandes();
  }

  Future<void> fetchCommandes() async {
    const String url = Config.backendUrl;

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'query': getOrdersQuery}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['data'] != null && data['data']['orders'] != null) {
        List sortedCommandes = (data['data']['orders'] as List)
            .where((commande) => commande['creationDate'] != null)
            .toList()
            .cast<Map<String, dynamic>>();

        sortedCommandes.sort((a, b) {
          DateTime dateA = DateTime.parse(a['creationDate']);
          DateTime dateB = DateTime.parse(b['creationDate']);
          return dateB.compareTo(dateA);
        });

        setState(() {
          commandes = sortedCommandes;
        });
      } else {
        setState(() {
          commandes = [];
        });
      }
    } else {
      throw Exception('Échec du chargement des commandes');
    }
  }

  String formatDate(String dateStr) {
    try {
      DateTime date = DateTime.parse(dateStr);
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    } catch (e) {
      return 'Date inconnue';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Toutes les Commandes',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 57, 41, 236),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddOrderPage(commande: {}),
                  ),
                ).then((_) {
                  fetchCommandes();
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Ajouter'),
            ),
          ),
        ],
      ),
      body: commandes.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 80, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    'Aucune commande trouvée',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: commandes.length,
              itemBuilder: (context, index) {
                var commande = commandes[index];
                var creationDate = formatDate(commande['creationDate'] ?? '');
                var status = commande['status'] ?? 'Inconnu';
                var totalAmount = commande['totalAmount']?.toString() ?? '0';

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      creationDate,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Statut : $status'),
                          Text(
                            'Montant total : ${totalAmount}TND',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailing: const Icon(Icons.description, color: Color.fromARGB(255, 54, 41, 239)),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderDetailsPage(commande: commande),
                        ),
                      ).then((_) {
                        fetchCommandes();
                      });
                    },
                  ),
                );
              },
            ),
    );
  }
}
