import 'package:app_nextcash/services/usuario_service.dart';
import 'package:flutter/material.dart';

import 'tela_home.dart';
import 'tela_registro.dart';
import 'tela_rec_senha.dart';

final usuarioService = UsuarioService();

void main() {
  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: LoginScreen()),
  );
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color brandGreen = Color(0xFF00FF66);
    const Color inputGray = Color(0xFF3A3A3A);
    const Color buttonGreen = Color(0xFF00CC44);

    const double horizontalPadding = 20;
    const double logoHeight = 140; // entre 120 e 150px

    Widget labeledField({
      required String label,
      required TextEditingController controller,
      bool obscureText = false,
      TextInputType? keyboardType,
      TextInputAction? textInputAction,
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
            textInputAction: textInputAction,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            cursorColor: brandGreen,
            decoration: InputDecoration(
              filled: true,
              fillColor: inputGray,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none, // sem borda visível
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none, // sem borda visível
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

    Widget actionButton({
      required String text,
      required VoidCallback onPressed,
    }) {
      return SizedBox(
        height: 52, // boa altura (padding vertical + height)
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonGreen,
            foregroundColor: Colors.black,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    final topSection = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 8),
        Text(
          'Spendly',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: brandGreen,
            fontSize: 32, // ~32
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 28),
        SizedBox(
          height: logoHeight,
          child: Image.asset('assets/logo.png', fit: BoxFit.contain),
        ),
      ],
    );

    final formSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        labeledField(
          label: 'E-mail',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 18),
        labeledField(
          label: 'Senha',
          controller: _passwordController,
          obscureText: true,
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TelaRecsenha()),
            );
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Esqueceu a senha?',
            style: TextStyle(
              color: brandGreen,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );

    final bottomSection = Row(
      children: [
        Expanded(
          child: actionButton(
            text: 'Entrar',
            onPressed: () async {
              String email = _emailController.text;
              String senha = _passwordController.text;

              if (email.isEmpty || senha.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Preencha todos os campos")),
                );
                return;
              }

              try {
                final result = await usuarioService.login(
                  email: email,
                  senha: senha,
                );
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => TelaHome()),
                );
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: actionButton(
            text: 'Cadastrar',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RegisterScreen()),
              );
            },
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: Colors.black, // #000000
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                  ),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween, // exigido no layout
                    children: [topSection, formSection, bottomSection],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
