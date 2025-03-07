import 'package:ec_app/auth/auth_provider.dart';
import 'package:ec_app/dashbord.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'orders_pages/orders_list.dart';
import 'products_pages/product_list.dart';
import 'clients_pages/customer_list.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  int _selectedIndex = 0;

  // Liste des pages correspondant aux onglets
  static List<Widget> _pages = <Widget>[
    DashboardPage(),
    const OrdersListPage(),
    const ProductListPage(),
    const CustomerListPage(),
  ];

  // Fonction pour gérer le changement d'onglet
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 0
          ? AppBar(
              backgroundColor: const Color.fromARGB(255, 5, 19, 152),
              automaticallyImplyLeading: false, // 🔹 Supprime la flèche de retour
              title: Row(
                children: [
                  ClipOval( // 🎯 Rend le logo circulaire
                    child: Image.asset('assets/images/logo.png', height: 40, width: 40, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "doolebBusiness",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications, color: Colors.white),
                  onPressed: () {
                    print('Notification appuyée');
                  },
                ),
              ],
            )
          : null, // ✅ Pas d'AppBar sur les autres pages

      body: _pages[_selectedIndex], // Affiche la page sélectionnée

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color.fromARGB(255, 5, 19, 152),
        unselectedItemColor: Colors.grey,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashbord',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Commandes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Produits',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Clients',
          ),
        ],
      ),

      floatingActionButton: _selectedIndex == 0 // 🔹 Afficher seulement sur Dashboard
          ? FloatingActionButton(
              onPressed: () {
                Provider.of<AuthProvider>(context, listen: false).logout();
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Icon(Icons.logout),
              backgroundColor: const Color.fromARGB(255, 5, 19, 152),
            )
          : null, // ✅ Pas de bouton sur les autres pages
    );
  }
}
