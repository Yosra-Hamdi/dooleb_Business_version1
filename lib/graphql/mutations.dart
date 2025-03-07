const String createOrderMutation = r"""
  mutation MyMutation(
    $customerId: ID!, 
    $products: [ProductInput!]!, 
    $deliveryAddressId: ID!, 
    $billingAddressId: ID!, 
    $paymentMethod: PaymentMethodEnum!, 
    $status: StatusEnum = UNCONFIRMED
  ) {
    createOrder(
      customerId: $customerId,
      products: $products,
      deliveryAddressId: $deliveryAddressId,
      billingAddressId: $billingAddressId,
      paymentMethod: $paymentMethod,
      status: $status
    ) {
      order {
        id
        creationDate
        totalAmount
        status
        paymentMethod
        customer {
          id
          firstName
          lastName
          phone
          email
          address {
            city
            street
            country
            postalCode
          }
        }
        deliveryAddress {
          id
          street
          postalCode
          country
          city
        }
        billingAddress {
          id
          street
          postalCode
          country
          city
        }
        products {
          id
          product {
            id
            name
            price
          }
          quantity
        }
      }
    }
  }
""";



// Mutation pour supprimer une commande
const String deleteOrderMutation = r'''
  mutation deleteOrder($orderId: ID!) {
    deleteOrder(orderId: $orderId) {
      success
    }
  }
''';



// Mutation pour modifier le statut d'une commande
const String updateOrderStatus = r'''
  mutation updateOrderStatus($orderId: ID!, $status: StatusEnum!) {
    updateOrderStatus(orderId: $orderId, status: $status) {
      order {
        status
        id
      }
    }
  }
''';

const String createProductMutation = """
  mutation CreateProduct(
    \$nom: String!, 
    \$prix: String!, 
    \$quantiteStock: Int!, 
    \$categoryId: Int!, 
    \$unit: String!
  ) {
    createProduit(
      nom: \$nom
      prix: \$prix
      quantiteStock: \$quantiteStock
      categoryId: \$categoryId
      unit: \$unit
    ) {
      produit {
        id
        nom
        prix
        quantiteStock
        unit
        category {
          nom
        }
      }
    }
  }
""";
const String createAddressMutation = """
  mutation CreateAddress(
    \$street: String!,
    \$city: String!,
    \$postalCode: String!,
    \$country: CountryEnum!
  ) {
    createAddress(
      street: \$street,
      city: \$city,
      postalCode: \$postalCode,
      country: \$country
    ) {
      address {
        id
        street
        city
        postalCode
        country
      }
    }
  }
""";


const String updateOrderMutation = '''
  mutation UpdateOrder(\$orderId: ID!, \$products: [ProductInput!]!) {
    updateOrder(orderId: \$orderId, products: \$products) {
      order {
        id
        status
        totalAmount
        products {
          product {
            id
            name
            price
          }
          quantity
        }
      }
    }
  }
''';

const String updateProductStockMutation = '''
  mutation UpdateProductStock(\$id: Int!, \$quantity: Int!) {
    updateProductStock(id: \$id, quantity: \$quantity) {
      product {
        id
        stockQuantity
      }
    }
  }
''';