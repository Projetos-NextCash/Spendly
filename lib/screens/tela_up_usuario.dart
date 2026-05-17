import 'package:flutter/material.dart';
import 'package:app_nextcash/services/usuario_service.dart';

class TelaEditarUsuario extends StatefulWidget {
  const TelaEditarUsuario({super.key});

  @override
  State<TelaEditarUsuario> createState() => _TelaEditarUsuarioState();
}

class _TelaEditarUsuarioState extends State<TelaEditarUsuario> {
  final usuarioService = UsuarioService();

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool carregandoSalvar = false;
  bool carregandoInicial = true;

  final Color corVerdeApp = const Color(0xFF00C853);

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await carregarUsuario();

    if (!mounted) return;

    setState(() {
      carregandoInicial = false;
    });
  }

  Future<void> carregarUsuario() async {
  try {
    final tokenData = await usuarioService.getUsuarioFromToken();

    if (tokenData == null) return;

    final response = await usuarioService.buscarPorId(
      tokenData["id"],
    );

    final usuario = response["usuario"];

    if (!mounted || usuario == null) return;

    setState(() {
      _nomeController.text = usuario["nome"] ?? "";
      _emailController.text = usuario["email"] ?? "";
    });
  } catch (e) {
    debugPrint("Erro ao carregar usuário: $e");
  }
}

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
  setState(() => carregandoSalvar = true);

  try {
    final tokenData = await usuarioService.getUsuarioFromToken();

    if (tokenData == null) {
      throw Exception("Usuário não autenticado");
    }

    await usuarioService.atualizar(
      id: tokenData["id"],
      nome: _nomeController.text.trim(),
      email: _emailController.text.trim(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Alterações salvas com sucesso!"),
      ),
    );

    Navigator.pop(context, true);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Erro ao atualizar: $e")),
    );
  } finally {
    if (mounted) {
      setState(() => carregandoSalvar = false);
    }
  }
}

  Widget campo({
    required String label,
    required TextEditingController controller,
    bool obscure = false,
    TextInputType? keyboard,
    required ThemeData theme,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    final inputFillColor = isDark ? const Color(0xFF1E1E1E) : Colors.grey[200];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboard,
          cursorColor: corVerdeApp,
          decoration: InputDecoration(
            filled: true,
            fillColor: inputFillColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: corVerdeApp, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    if (carregandoInicial) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: tema.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Perfil",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 30),

              CircleAvatar(
                radius: 40,
                backgroundColor: corVerdeApp.withOpacity(0.1),
                child: Icon(Icons.person_outline, size: 40, color: corVerdeApp),
              ),

              const SizedBox(height: 30),

              campo(
                label: "Nome completo",
                controller: _nomeController,
                theme: tema,
              ),
              const SizedBox(height: 20),

              campo(
                label: "E-mail",
                controller: _emailController,
                keyboard: TextInputType.emailAddress,
                theme: tema,
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: carregandoSalvar ? null : _salvar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: corVerdeApp,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: carregandoSalvar
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text(
                          "Salvar Alterações",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
