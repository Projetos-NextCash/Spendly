import 'package:flutter/material.dart';
import 'package:app_nextcash/screens/tela_login.dart';
import 'package:app_nextcash/services/usuario_service.dart';

class TelaRecsenha extends StatefulWidget {
  const TelaRecsenha({super.key});

  @override
  State<TelaRecsenha> createState() => _TelaRecsenhaState();
}

class _TelaRecsenhaState extends State<TelaRecsenha> {
  final _emailController = TextEditingController();
  final _novaSenhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  final _usuarioService = UsuarioService();

  bool _estaCarregando = false;

  @override
  void dispose() {
    _emailController.dispose();
    _novaSenhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> _alterarSenha() async {
    final email = _emailController.text.trim();
    final senha = _novaSenhaController.text.trim();
    final confirmar = _confirmarSenhaController.text.trim();

    if (email.isEmpty || senha.isEmpty || confirmar.isEmpty) {
      _mostrarSnackBar("Preencha todos os campos");
      return;
    }

    if (senha != confirmar) {
      _mostrarSnackBar("As senhas não coincidem");
      return;
    }

    setState(() => _estaCarregando = true);

    try {
      await _usuarioService.recuperarSenha(
        email: email,
        senha: senha,
      );

      if (!mounted) return;

      _mostrarSnackBar("Senha alterada com sucesso!");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } catch (e) {
      _mostrarSnackBar(e.toString());
    } finally {
      if (mounted) setState(() => _estaCarregando = false);
    }
  }

  void _mostrarSnackBar(String mensagem) {
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

      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(
          color: theme.textTheme.bodyLarge?.color,
        ),
        title: Text(
          "Recuperar senha",
          style: theme.textTheme.bodyLarge?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              Text(
                "Informe seu e-mail e a nova senha que deseja utilizar.",
                style: theme.textTheme.bodyMedium,
              ),

              const SizedBox(height: 30),

              _CampoRecuperacao(
                label: "E-mail",
                hint: "seu@email.com",
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 20),

              _CampoRecuperacao(
                label: "Nova senha",
                hint: "••••••••",
                controller: _novaSenhaController,
                obscureText: true,
              ),

              const SizedBox(height: 20),

              _CampoRecuperacao(
                label: "Confirmar senha",
                hint: "••••••••",
                controller: _confirmarSenhaController,
                obscureText: true,
              ),

              const SizedBox(height: 40),

              _BotaoAcao(
                texto: "Alterar senha",
                onPressed: _estaCarregando ? null : _alterarSenha,
                carregando: _estaCarregando,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CampoRecuperacao extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;

  const _CampoRecuperacao({
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
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}

class _BotaoAcao extends StatelessWidget {
  final String texto;
  final VoidCallback? onPressed;
  final bool carregando;

  const _BotaoAcao({
    required this.texto,
    required this.onPressed,
    required this.carregando,
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