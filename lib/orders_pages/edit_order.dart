import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class AddOrderScreen extends StatefulWidget {
  @override
  _AddOrderScreenState createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends State<AddOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  String? clientId;
  String? adresseId;
  String? methodePaiement = 'ESPECE';
  List<Map<String, dynamic>> produits = [];

  // Fonction pour créer la commande
  Future<void> creerCommande() async {
    final String mutation = """
      mutation MyMutation {
        creerCommande(
          adresseId: "$adresseId"
          clientId: "$clientId"
          methodePaiement: $methodePaiement
          produits: ${produits.map((produit) => "{produitId: \"${produit['produitId']}\", quantite: ${produit['quantite']}}").toList()}
          statut: NONCONFIRMEE
        ) {
          commande {
            id
            dateCreation
            montantTotal
            statut
            methodePaiement
            adresseLivraison {
              rue
              ville
              codePostal
              pays
            }
            produits {
              produit {
                id
                nom
                prix
              }
              quantite
            }
          }
        }
      }
    """;

    // Appel à la mutation GraphQL
    final client = GraphQLProvider.of(context).value;
    final result = await client.mutate(MutationOptions(
      document: gql(mutation),
    ));

    if (result.hasException) {
      print('Error: ${result.exception.toString()}');
    } else {
      print('Commande créée: ${result.data}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter une Commande'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Client ID'),
                onSaved: (value) => clientId = value,
                validator: (value) => value!.isEmpty ? 'Client ID est requis' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Adresse ID'),
                onSaved: (value) => adresseId = value,
                validator: (value) => value!.isEmpty ? 'Adresse ID est requise' : null,
              ),
              DropdownButtonFormField<String>(
                value: methodePaiement,
                decoration: InputDecoration(labelText: 'Méthode de Paiement'),
                onChanged: (value) {
                  setState(() {
                    methodePaiement = value;
                  });
                },
                items: ['ESPECE', 'CARTE']
                    .map((item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        ))
                    .toList(),
              ),
              // Ajouter des champs pour les produits
              // Exemple de bouton pour ajouter un produit
              ElevatedButton(
                onPressed: () {
                  // Exemple d'ajout d'un produit
                  setState(() {
                    produits.add({
                      'produitId': '1',
                      'quantite': 2,
                    });
                  });
                },
                child: Text('Ajouter un produit'),
              ),
              // Formulaire d'envoi de la commande
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    creerCommande();
                  }
                },
                child: Text('Créer Commande'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
