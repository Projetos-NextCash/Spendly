import 'package:flutter/material.dart';
import 'package:app_nextcash/services/usuario_service.dart';

import 'tela_home.dart';
import 'tela_registro.dart';
import 'tela_rec_senha.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usuarioService = UsuarioService();

  bool _estaCarregando = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _fazerLogin() async {
    String email = _emailController.text.trim();
    String senha = _passwordController.text.trim();

    if (email.isEmpty || senha.isEmpty) {
      _mostrarAlerta("Preencha todos os campos");
      return;
    }

    setState(() => _estaCarregando = true);

    try {
      await _usuarioService.login(email: email, senha: senha);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TelaHome()),
      );
    } catch (e) {
      _mostrarAlerta(e.toString());
    } finally {
      if (mounted) setState(() => _estaCarregando = false);
    }
  }

  void _mostrarAlerta(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(minHeight: constraints.maxHeight - 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    /// TOPO
                    Column(
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          'NextCash',
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          height: 120,
                          child: Image.asset(
                            'assets/logo.png',
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.account_balance_wallet,
                              size: 80,
                              color: theme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),

                    /// FORM
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _CampoTextoCustom(
                          label: 'E-mail',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          hint: 'exemplo@email.com',
                        ),
                        const SizedBox(height: 20),
                        _CampoTextoCustom(
                          label: 'Senha',
                          controller: _passwordController,
                          obscureText: true,
                          hint: '••••••••',
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const TelaRecsenha()),
                            ),
                            child: Text(
                              'Esqueceu a senha?',
                              style: TextStyle(color: theme.primaryColor),
                            ),
                          ),
                        ),
                      ],
                    ),

                    /// BOTÕES
                    Column(
                      children: [
                        _BotaoPrincipal(
                          texto: 'Entrar',
                          onPressed:
                              _estaCarregando ? null : _fazerLogin,
                          carregando: _estaCarregando,
                        ),
                        const SizedBox(height: 15),

                        OutlinedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const RegisterScreen()),
                          ),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 52),
                            side: BorderSide(color: theme.primaryColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Criar conta',
                            style: TextStyle(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CampoTextoCustom extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;

  const _CampoTextoCustom({
    required this.label,
    required this.hint,
    required this.controller,
    this.obscureText = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodyLarge),
        const SizedBox(height: 8),

        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: theme.cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}

class _BotaoPrincipal extends StatelessWidget {
  final String texto;
  final VoidCallback? onPressed;
  final bool carregando;

  const _BotaoPrincipal({
    required this.texto,
    required this.onPressed,
    this.carregando = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: carregando
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                texto,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}