import 'package:ec_app/graphql/pasword_mutations.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'code_verification_screen.dart'; // Page pour saisir le code

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
              'Entrez votre adresse email et nous vous enverrons un code pour réinitialiser votre mot de passe.',
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
                document: gql(Mutations.requestPasswordReset),
                onCompleted: (dynamic resultData) {
                  if (resultData != null && resultData['requestPasswordReset']['success']) {
                    // Rediriger vers la page de saisie du code
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CodeVerificationScreen(email: emailController.text),
                      ),
                    );
                  }
                },
                onError: (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur : ${error.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
              ),
              builder: (runMutation, result) {
                return Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        final email = emailController.text.trim();
                        if (email.isEmpty || !email.contains('@')) {
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
                      child: const Text('Envoyer le code'),
                    ),
                    const SizedBox(height: 20),
                    if (result != null && result.isLoading)
                      const CircularProgressIndicator(),
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