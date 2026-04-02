import 'package:app_nextcash/screens/tela_login.dart';
import 'package:flutter/material.dart';


class TelaRecsenha extends StatefulWidget {
  const TelaRecsenha({super.key});

  @override
  State<TelaRecsenha> createState() => _TelaRecsenhaState();
}

class _TelaRecsenhaState extends State<TelaRecsenha> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _novaSenhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _novaSenhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color backgroundBlack = Color(0xFF000000);
    const Color brandGreen = Color(0xFF00CC44);
    const Color inputGray = Color(0xFF3A3A3A);

    Widget labeledField({
      required String label,
      required TextEditingController controller,
      bool obscureText = false,
      TextInputType? keyboardType,
    }) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: const TextStyle(color: Colors.white),
            cursorColor: brandGreen,
            decoration: InputDecoration(
              filled: true,
              fillColor: inputGray,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      );
    }

    Widget button() {
      return SizedBox(
        width: 220,
        height: 52,
        child: ElevatedButton(
          onPressed: () async{
            final email = _emailController.text;
            final senha = _novaSenhaController.text;
            final confirmar = _confirmarSenhaController.text;

            if (senha != confirmar) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("As senhas não coincidem"),
                ),
              );
              return;
            }

            try {
                final result = await usuarioService.recuperarSenha(
                  email: email,
                  senha: senha,
                );
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(e.toString())));
              }

            // lógica recuperar senha aqui
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: brandGreen,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: const Text("Alterar senha"),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundBlack,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [

              /// topo
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    "Recuperar senha",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                ],
              ),

              const SizedBox(height: 40),

              labeledField(
                label: "E-mail",
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 18),

              labeledField(
                label: "Nova senha",
                controller: _novaSenhaController,
                obscureText: true,
              ),

              const SizedBox(height: 18),

              labeledField(
                label: "Confirmar senha",
                controller: _confirmarSenhaController,
                obscureText: true,
              ),

              const SizedBox(height: 30),

              Center(child: button()),
            ],
          ),
        ),
      ),
    );
  }
}