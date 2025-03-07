class Mutations {
  // Mutation pour demander une réinitialisation de mot de passe
  static const String requestPasswordReset = '''
    mutation RequestPasswordReset(\$email: String!) {
      requestPasswordReset(email: \$email) {
        success
      }
    }
  ''';

  // Mutation pour réinitialiser le mot de passe
  static const String resetPassword = '''
    mutation ResetPassword(\$email: String!, \$token: String!, \$newPassword: String!) {
      resetPassword(email: \$email, token: \$token, newPassword: \$newPassword) {
        success
      }
    }
  ''';
}