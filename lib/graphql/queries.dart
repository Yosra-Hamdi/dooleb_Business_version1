const String getOrdersQuery = """
      query {
         orders {
    creationDate
    customer {
      address {
        city
        country
        id
        postalCode
        street
      }
      email
      firstName
      id
      lastName
      phone
    }
    deliveryAddress {
      city
      country
      id
      postalCode
      street
    }
    billingAddress {
      city
      country
      id
      postalCode
      street
    }
    id
    paymentMethod
    status
    totalAmount
    products {
      id
      quantity
      product {
        id
        image
        name
        price
        stockQuantity
        unit
        category {
          id
          name
        }
      }
    }
  }
}
      
    """;
const String getProductsQuery = """
  query MyQuery {
  products {
    category {
    id
    name
    }
    id
    image
    name
    price
    stockQuantity
    unit
  }

}

  
""";
const String getCustomersQuery = '''
  query MyQuery {
     allCustomer {
    firstName
    id
    lastName
    phone
    email
    address {
      street
      city
      country
      id
      postalCode
    }
  }
}
''';
const String getAddressQuery ='''
query MyQuery {
  allAddresses {
  id
  street
  city
  country
  postalCode
  }
}

''';

const String getCustomersWithAddressesQuery = '''
  query GetCustomersWithAddresses {
    allCustomer {
      id
      firstName
      lastName
      address {
        id
        street
        city
        postalCode
        country
      }
    }
  }
''';
const String getOrderBillingAddressQuery = r"""
query GetOrderBillingAddress($id: ID!) {
  order(id: $id) {
    billingAddress {
      street
      city
      country
      id
      postalCode
    }
  }
}
""";
const String getBillingAddressesOrdersQuery = r"""
query MyQuery {
  orders {
    billingAddress {
      id
      city
      country
      postalCode
      street
    }
  }
}""";