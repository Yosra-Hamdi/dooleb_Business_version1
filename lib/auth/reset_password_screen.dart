import 'package:ec_app/graphql/pasword_mutations.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';


class ResetPasswordScreen extends StatelessWidget {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController tokenController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Réinitialiser le mot de passe'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: tokenController,
              decoration: InputDecoration(
                labelText: 'Token de réinitialisation',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Nouveau mot de passe',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirmer le mot de passe',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Mutation(
              options: MutationOptions(
                document: gql(Mutations.resetPassword), // Utilisez la mutation
              ),
              builder: (runMutation, result) {
                return Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        final newPassword = newPasswordController.text.trim();
                        final confirmPassword = confirmPasswordController.text.trim();
                        final token = tokenController.text.trim();

                        if (newPassword.isEmpty || confirmPassword.isEmpty || token.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Veuillez remplir tous les champs'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        if (newPassword != confirmPassword) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Les mots de passe ne correspondent pas'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        runMutation({
                          'email': 'hamdiyosra010@gmail.com', // Remplacez par l'e-mail de l'utilisateur
                          'token': token,
                          'newPassword': newPassword,
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 5, 19, 152),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text('Réinitialiser le mot de passe'),
                    ),
                    const SizedBox(height: 20),
                    if (result != null && result.isLoading)
                      const CircularProgressIndicator(),
                    if (result != null && result.hasException)
                      Text('Erreur : ${result.exception.toString()}'),
                    if (result != null && result.data != null)
                      const Text('Mot de passe réinitialisé avec succès'),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}