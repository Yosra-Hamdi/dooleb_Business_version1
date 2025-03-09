class Mutations {
  static const String loginMutation = '''
    mutation Login(\$email: String!, \$password: String!) {
      login(email: \$email, password: \$password) {
        token
        user {
          id
          email
          firstName
          lastName
        }
      }
    }
  ''';
}
