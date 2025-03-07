class Mutations {
  static const String loginMutation = '''
    mutation Login(\$username: String!, \$password: String!) {
      login(username: \$username, password: \$password) {
        success
        errors
        auth {
          token
          user {
            id
            username
          }
        }
      }
    }
  ''';
}
