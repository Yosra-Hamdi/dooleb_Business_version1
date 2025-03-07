class Mutations {
  static const String createUser = """
    mutation CreateUser(
      \$firstName: String!,
      \$lastName: String!,
      \$email: String!,
      \$password: String!,
      \$phone: String!,
      \$storeName: String!,
    ) {
      createUser(
        firstName: \$firstName,
        lastName: \$lastName,
        email: \$email,
        password: \$password,
        phone: \$phone,
        storeName: \$storeName,
      ) {
        user {
          id
          email
        }
      }
    }
  """;

  static const String tokenAuth = """
    mutation TokenAuth(\$email: String!, \$password: String!) {
      tokenAuth(email: \$email, password: \$password) {
        token
      }
    }
  """;
}