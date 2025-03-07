import 'dart:convert';
import 'package:ec_app/EM_local_config.dart';
import 'package:ec_app/graphql/queries.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'customer_details.dart'; // Import de la page de détails

class CustomerListPage extends StatefulWidget {
  final bool selectMode;

  const CustomerListPage({super.key, this.selectMode = false});

  @override
  _CustomerListPageState createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  List clients = [];

  @override
  void initState() {
    super.initState();
    fetchClients();
  }

  Future<void> fetchClients() async {
    const String url = Config.backendUrl; // Utiliser l'URL depuis config.dart

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'query': getCustomersQuery}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] != null && data['data']['allCustomer'] != null) {
          setState(() {
            clients = data['data']['allCustomer'];
          });
        } else {
          setState(() {
            clients = [];
          });
        }
      } else {
        throw Exception('Failed to load clients: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load clients: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des clients'),
      ),
      body: clients.isEmpty
          ? const Center(child: Text('Aucun client trouvé'))
          : ListView.builder(
              itemCount: clients.length,
              itemBuilder: (context, index) {
                var client = clients[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text('${client['firstName']} ${client['lastName']}'),
                    onTap: () {
                      if (widget.selectMode) {
                        Navigator.pop(context, client);
                      } else {
                        // Navigation vers la page de détails
                        
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CustomerDetailsPage(client: client),
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
