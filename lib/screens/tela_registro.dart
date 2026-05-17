import 'package:flutter/material.dart';
import 'package:app_nextcash/screens/tela_home.dart';
import 'package:app_nextcash/services/usuario_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usuarioService = UsuarioService();
  final _confirmarSenhaController = TextEditingController();

  bool _estaCarregando = false;
  bool _senhaVisivel = false;
  bool _confirmarSenhaVisivel = false;
  double _forcaSenha = 0;
  String _textoForcaSenha = '';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
    _confirmarSenhaController.dispose();
  }

  Future<void> _fazerCadastro() async {
    String nome = _nameController.text.trim();
    String email = _emailController.text.trim();
    String senha = _passwordController.text.trim();

    if (nome.isEmpty || email.isEmpty || senha.isEmpty) {
      _mostrarAlerta("Preencha todos os campos");
      return;
    }

    if (senha != _confirmarSenhaController.text.trim()) {
      _mostrarAlerta("As senhas não coincidem");
      return;
    }

    setState(() => _estaCarregando = true);

    try {
      await _usuarioService.cadastrar(nome: nome, email: email, senha: senha);

      await _usuarioService.login(email: email, senha: senha);

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const TelaHome()),
        (route) => false,
      );
    } catch (e) {
      _mostrarAlerta(e.toString());
    } finally {
      if (mounted) setState(() => _estaCarregando = false);
    }
  }

  void _mostrarAlerta(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), behavior: SnackBarBehavior.floating),
    );
  }

  void _verificarForcaSenha(String senha) {
    double forca = 0;

    if (senha.isEmpty) {
      setState(() {
        _forcaSenha = 0;
        _textoForcaSenha = '';
      });
      return;
    }

    if (senha.length >= 6) forca += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(senha)) forca += 0.25;
    if (RegExp(r'[0-9]').hasMatch(senha)) forca += 0.25;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(senha)) {
      forca += 0.25;
    }

    String texto;

    if (forca <= 0.25) {
      texto = 'Senha fraca';
    } else if (forca <= 0.50) {
      texto = 'Senha média';
    } else if (forca <= 0.75) {
      texto = 'Senha boa';
    } else {
      texto = 'Senha forte';
    }

    setState(() {
      _forcaSenha = forca;
      _textoForcaSenha = texto;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.textTheme.bodyLarge?.color),
        title: Text(
          'Cadastro',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),

                Text(
                  "Crie sua conta no NextCash para começar a gerenciar suas finanças.",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),

                const SizedBox(height: 40),

                _CampoCadastro(
                  label: 'Nome completo',
                  hint: 'João Silva',
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                ),

                const SizedBox(height: 20),

                _CampoCadastro(
                  label: 'E-mail',
                  hint: 'exemplo@email.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),

                const SizedBox(height: 20),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Senha', style: theme.textTheme.bodyLarge),

                    const SizedBox(height: 8),

                    TextField(
                      controller: _passwordController,
                      obscureText: !_senhaVisivel,
                      onChanged: _verificarForcaSenha,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        filled: true,
                        fillColor: theme.cardColor,

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),

                        suffixIcon: IconButton(
                          icon: Icon(
                            _senhaVisivel
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _senhaVisivel = !_senhaVisivel;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    LinearProgressIndicator(
                      value: _forcaSenha,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(10),
                    ),

                    const SizedBox(height: 5),

                    Text(_textoForcaSenha, style: theme.textTheme.bodySmall),

                    const SizedBox(height: 15),

                    _ItemRequisitoSenha(
                      texto: 'Mínimo de 6 caracteres',
                      valido: _passwordController.text.length >= 6,
                    ),

                    _ItemRequisitoSenha(
                      texto: 'Uma letra maiúscula',
                      valido: RegExp(
                        r'[A-Z]',
                      ).hasMatch(_passwordController.text),
                    ),

                    _ItemRequisitoSenha(
                      texto: 'Um número',
                      valido: RegExp(
                        r'[0-9]',
                      ).hasMatch(_passwordController.text),
                    ),

                    _ItemRequisitoSenha(
                      texto: 'Um caractere especial',
                      valido: RegExp(
                        r'[!@#$%^&*(),.?":{}|<>]',
                      ).hasMatch(_passwordController.text),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Text('Confirmar senha', style: theme.textTheme.bodyLarge),

                const SizedBox(height: 8),

                TextField(
                  controller: _confirmarSenhaController,
                  obscureText: !_confirmarSenhaVisivel,
                  textInputAction: TextInputAction.done,

                  decoration: InputDecoration(
                    hintText: '••••••••',
                    filled: true,
                    fillColor: theme.cardColor,

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),

                    suffixIcon: IconButton(
                      icon: Icon(
                        _confirmarSenhaVisivel
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _confirmarSenhaVisivel = !_confirmarSenhaVisivel;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                if (_confirmarSenhaController.text.isNotEmpty)
                  Row(
                    children: [
                      Icon(
                        _passwordController.text ==
                                _confirmarSenhaController.text
                            ? Icons.check_circle
                            : Icons.cancel,
                        color:
                            _passwordController.text ==
                                _confirmarSenhaController.text
                            ? Colors.green
                            : Colors.red,
                        size: 18,
                      ),

                      const SizedBox(width: 8),

                      Text(
                        _passwordController.text ==
                                _confirmarSenhaController.text
                            ? 'As senhas coincidem'
                            : 'As senhas não coincidem',
                      ),
                    ],
                  ),

                const SizedBox(height: 40),

                _BotaoCadastro(
                  texto: 'Cadastrar',
                  onPressed: _estaCarregando ? null : _fazerCadastro,
                  carregando: _estaCarregando,
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CampoCadastro extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  const _CampoCadastro({
    required this.label,
    required this.hint,
    required this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
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
          textInputAction: textInputAction,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: theme.cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}

class _BotaoCadastro extends StatelessWidget {
  final String texto;
  final VoidCallback? onPressed;
  final bool carregando;

  const _BotaoCadastro({
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

class _ItemRequisitoSenha extends StatelessWidget {
  final String texto;
  final bool valido;

  const _ItemRequisitoSenha({required this.texto, required this.valido});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            valido ? Icons.check_circle : Icons.cancel,
            color: valido ? Colors.green : Colors.red,
            size: 18,
          ),

          const SizedBox(width: 8),

          Text(texto),
        ],
      ),
    );
  }
}
