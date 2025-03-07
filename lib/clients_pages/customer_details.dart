import 'package:flutter/material.dart';

class CustomerDetailsPage extends StatelessWidget {
  final dynamic client;

  const CustomerDetailsPage({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Fond clair pour un look moderne
      appBar: AppBar(
        title: Text(
          '${client['firstName']} ${client['lastName']}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        foregroundColor: Colors.black,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar centré
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.purple,
              child: Icon(
                Icons.person,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // Carte des informations personnelles
            _buildCard(
              title: "Informations Client",
              children: [
                _buildInfoRow(Icons.person, "Prénom", client['firstName']),
                _buildInfoRow(Icons.person_outline, "Nom", client['lastName']),
                _buildInfoRow(Icons.email, "Email", client['email']),
                _buildInfoRow(Icons.phone, "Téléphone", client['phone']),
              ],
            ),

            const SizedBox(height: 16),

            // Carte de l'adresse
            if (client['address'] != null)
              _buildCard(
                title: "Adresse",
                children: [
                  _buildInfoRow(Icons.home, "Rue", client['address']['street']),
                  _buildInfoRow(Icons.location_city, "Ville", client['address']['city']),
                  _buildInfoRow(Icons.flag, "Pays", client['address']['country']),
                  _buildInfoRow(Icons.markunread_mailbox, "Code Postal", client['address']['postalCode']),
                ],
              )
            else
              _buildCard(
                title: "Adresse",
                children: [
                  const Text(
                    'Aucune adresse enregistrée',
                    style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // Widget pour créer une carte avec un titre
  Widget _buildCard({required String title, required List<Widget> children}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  // Widget pour afficher une ligne d'information avec une icône
  Widget _buildInfoRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.purple, size: 24),
          const SizedBox(width: 12),
          Text(
            "$label : ",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value ?? 'Non spécifié',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
