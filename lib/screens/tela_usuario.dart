import 'package:flutter/material.dart';

//import 'tela_RecSenha.dart';
import 'tela_up_usuario.dart';

class TelaUsuario extends StatelessWidget {
  const TelaUsuario({super.key});

  @override
  Widget build(BuildContext context) {
    const Color fundo = Color(0xFF0B0B0B);
    const Color textoPrincipal = Colors.white;
    const Color textoSecundario = Color(0xFFBDBDBD);
    const Color verde = Color(0xFF00CC44);

    return Scaffold(
      backgroundColor: fundo,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// botão voltar
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
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
                        border: Border.all(color: verde, width: 2),
                      ),
                      child: const Icon(Icons.person, size: 40, color: verde),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Nome",
                      style: TextStyle(
                        color: textoPrincipal,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              /// opções
              ItemUsuario(
                icone: Icons.person_outline,
                titulo: "Dados Cadastrais",
                subtitulo: "Informações Pessoais.",
                onTap:() {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TelaEditarUsuario()),
                  );
                },
              ),

              ItemUsuario(
                icone: Icons.shield_outlined,
                titulo: "Segurança",
                subtitulo: "Senhas, Acessos.",
              ),

              ItemUsuario(
                icone: Icons.help_outline,
                titulo: "Sobre o Aplicativo",
                subtitulo: "Quem somos.",
              ),

              const SizedBox(height: 10),

              ItemUsuario(
                icone: Icons.logout,
                titulo: "Sair da Conta",
                subtitulo: "",
                mostrarSeta: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
    const Color textoPrincipal = Colors.white;
    const Color textoSecundario = Color(0xFFBDBDBD);
    const Color verde = Color(0xFF00CC44);

    return GestureDetector(
      onTap: onTap, // aqui é onde você conecta o clique
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icone, color: textoSecundario, size: 26),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      color: textoPrincipal,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitulo,
                    style: const TextStyle(color: textoSecundario, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (mostrarSeta)
              const Icon(Icons.arrow_forward_ios, color: verde, size: 16),
          ],
        ),
      ),
    );
  }
}
