import 'package:flutter/material.dart';
import 'package:app_nextcash/services/usuario_service.dart';

final usuarioService = UsuarioService();

class TelaEditarUsuario extends StatefulWidget {
  const TelaEditarUsuario({super.key});

  @override
  State<TelaEditarUsuario> createState() => _TelaEditarUsuarioState();
}

class _TelaEditarUsuarioState extends State<TelaEditarUsuario> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    carregarUsuario();
  }
  //carrega os 
  void carregarUsuario() async {
    final usuario = await usuarioService.getUsuarioFromToken();

    if (usuario != null) {
      _nomeController.text = usuario["nome"] ?? "";
      _emailController.text = usuario["email"] ?? "";
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color fundo = Color(0xFF0B0B0B);
    const Color verde = Color(0xFF00CC44);
    const Color inputGray = Color(0xFF3A3A3A);

    Widget campo({
      required String label,
      required TextEditingController controller,
      bool obscure = false,
      TextInputType? keyboard,
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
            obscureText: obscure,
            keyboardType: keyboard,
            style: const TextStyle(color: Colors.white),
            cursorColor: verde,
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

    return Scaffold(
      backgroundColor: fundo,
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
                    "Editar usuário",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              campo(label: "Nome", controller: _nomeController),

              const SizedBox(height: 18),

              campo(
                label: "Email",
                controller: _emailController,
                keyboard: TextInputType.emailAddress,
              ),

              const SizedBox(height: 18),

              campo(
                label: "Nova senha",
                controller: _senhaController,
                obscure: true,
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: 220,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    final nome = _nomeController.text;
                    final email = _emailController.text;
                    final senha = _senhaController.text;

                    try {
                      // pega usuário logado
                      final usuario = await usuarioService
                          .getUsuarioFromToken();

                      if (usuario == null) {
                        throw Exception("Usuário não autenticado");
                      }

                      await usuarioService.atualizar(
                        id: usuario["id"],
                        nome: nome.isEmpty ? null : nome,
                        email: email.isEmpty ? null : email,
                        senha: senha.isEmpty ? null : senha,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Usuário atualizado com sucesso"),
                        ),
                      );

                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: verde,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    "Salvar alterações",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
