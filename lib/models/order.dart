import 'package:ec_app/models/product.dart';

class Order {
  final String id;
  final String status;
  final String clientId;
  final String clientNom;
  final double totalAmount;
  final List<Product> products;

  Order({
    required this.id,
    required this.status,
    required this.clientId,
    required this.clientNom,
    required this.totalAmount,
    required this.products,
  });
}


