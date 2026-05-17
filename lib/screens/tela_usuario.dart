import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'tela_rec_senha.dart';
import 'tela_up_usuario.dart';
import 'package:app_nextcash/services/usuario_service.dart';
import '../core/theme_controller.dart';

class TelaUsuario extends StatefulWidget {
  const TelaUsuario({super.key});

  @override
  State<TelaUsuario> createState() => _TelaUsuarioState();
}

class _TelaUsuarioState extends State<TelaUsuario> {
  final usuarioService = UsuarioService();

  String nome = "Carregando...";
  String email = "";

  Future<Map<String, dynamic>?> getUsuarioById(int id) async {
  try {
    final response = await http.get(
      Uri.parse("SEU_ENDPOINT_AQUI/usuarios/$id"),
      headers: {
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return null;
  } catch (e) {
    throw Exception("Erro ao buscar usuário: $e");
  }
}

  Future<void> carregarUsuario() async {
  final usuarioLocal = await usuarioService.getUsuarioFromToken();

  if (usuarioLocal == null) return;

  final resposta =
      await usuarioService.buscarPorId(usuarioLocal["id"]);

  final usuario = resposta["usuario"];

  if (!mounted) return;

  setState(() {
    nome = usuario["nome"] ?? "";
    email = usuario["email"] ?? "";
  });
}

  @override
  void initState() {
    super.initState();
    carregarUsuario();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// botão voltar
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),

              const SizedBox(height: 10),

              /// avatar + nome
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.primaryColor, width: 2),
                      ),
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: theme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      nome,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      email,
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 16),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              /// 🔥 SWITCH DE TEMA
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text("Modo escuro", style: theme.textTheme.bodyLarge),
                activeColor: const Color(0xFF00C853),
                activeTrackColor: const Color(0xFF00C853).withOpacity(0.5),
                value: theme.brightness == Brightness.dark,
                onChanged: (value) {
                  ThemeController.toggleTheme(value);
                },
              ),

              const SizedBox(height: 10),

              /// opções (Todos agora possuem efeito InkWell nativamente)
              ItemUsuario(
                icone: Icons.person_outline,
                titulo: "Dados cadastrados",
                subtitulo: "Informações pessoais",
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TelaEditarUsuario(),
                    ),
                  );

                  if (mounted) {
                    setState(() {
                      nome = "Carregando...";
                      email = "";
                    });
                    await carregarUsuario();
                  }
                },
              ),

              ItemUsuario(
                icone: Icons.shield_outlined,
                titulo: "Segurança",
                subtitulo: "Senhas e acessos",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TelaRecsenha(),
                    ),
                  );
                },
              ),

              ItemUsuario(
                icone: Icons.help_outline,
                titulo: "Sobre o aplicativo",
                subtitulo: "Quem somos",
                onTap: () {
                  Navigator.pushNamed(context, '/sobrenos');
                },
              ),

              ItemUsuario(
                icone: Icons.help_outline,
                titulo: "Tutorial",
                subtitulo: "Como usar o aplicativo",
                onTap: () {
                  Navigator.pushNamed(context, '/tutorial');
                },
              ),

              const SizedBox(height: 10),

              ItemUsuario(
                icone: Icons.logout,
                titulo: "Sair da conta",
                subtitulo: "",
                mostrarSeta: false,
                onTap: () async {
                  await usuarioService.logout();

                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                },
              ),

              ItemUsuario(
                icone: Icons.delete_outline,
                titulo: "Apagar conta",
                subtitulo: "Remover permanentemente",
                mostrarSeta: false,
                onTap: () async {
                  final confirmar = await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: theme.cardColor,
                      title: Text(
                        "Deletar conta",
                        style: theme.textTheme.bodyLarge,
                      ),
                      content: Text(
                        "Essa ação não pode ser desfeita. Deseja continuar?",
                        style: theme.textTheme.bodyMedium,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Cancelar"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            "Deletar",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirmar == true) {
                    final tokenData = await usuarioService
                        .getUsuarioFromToken();
                    await usuarioService.deletar(tokenData!["id"]);

                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 🔥 COMPONENTE ITEM REFATORADO COM INKWELL
class ItemUsuario extends StatelessWidget {
  const ItemUsuario({
    super.key,
    required this.icone,
    required this.titulo,
    required this.subtitulo,
    this.mostrarSeta = true,
    this.onTap,
  });

  final IconData icone;
  final String titulo;
  final String subtitulo;
  final bool mostrarSeta;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      splashColor: theme.brightness == Brightness.dark
          ? Colors.white10
          : Colors.black12, // Adapta o brilho do clique conforme o tema ativo
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 8,
        ), // Adicionado um pequeno padding horizontal para o efeito não grudar nas bordas
        child: Row(
          children: [
            Icon(icone, color: theme.textTheme.bodyMedium?.color, size: 26),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitulo.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitulo,
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
            if (mostrarSeta)
              Icon(
                Icons.arrow_forward_ios,
                color: theme.primaryColor,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}
