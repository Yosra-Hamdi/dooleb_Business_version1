import 'package:ec_app/graphql/pasword_mutations.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mot de passe oublié'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Entrez votre adresse e-mail pour réinitialiser votre mot de passe',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'E-mail',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Mutation(
              options: MutationOptions(
                document: gql(Mutations.requestPasswordReset), // Utilisez la mutation
              ),
              builder: (runMutation, result) {
                return Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        final email = emailController.text.trim();
                        if (email.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Veuillez entrer votre adresse e-mail'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        runMutation({'email': email});
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 5, 19, 152),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text('Envoyer le lien de réinitialisation'),
                    ),
                    const SizedBox(height: 20),
                    if (result != null && result.isLoading)
                      const CircularProgressIndicator(),
                    if (result != null && result.hasException)
                      Text('Erreur : ${result.exception.toString()}'),
                    if (result != null && result.data != null)
                      const Text('Un e-mail de réinitialisation a été envoyé'),
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