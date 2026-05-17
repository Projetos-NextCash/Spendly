import 'package:flutter/material.dart';
import '/core/theme_controller.dart'; // Certifique-se de ajustar o caminho correto do seu ThemeController

class TelaSobreNos extends StatelessWidget {
  const TelaSobreNos({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuta as mudanças de tema do ThemeController
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, currentTheme, child) {
        // Verifica se o tema atual é escuro (seja forçado ou pelo sistema)
        final isDark = currentTheme == ThemeMode.dark ||
            (currentTheme == ThemeMode.system &&
                MediaQuery.of(context).platformBrightness == Brightness.dark);

        // Cores baseadas na imagem fornecida
        final backgroundColor = isDark ? const Color(0xFF0F0F0F) : Colors.grey[50]!;
        final primaryColor = const Color(0xFF00C853); // Verde neon da imagem
        final textColor = isDark ? Colors.white : Colors.black87;
        final subtitleColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
        final cardColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            backgroundColor: backgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: textColor),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'Sobre o aplicativo',
              style: TextStyle(
                color: textColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabeçalho com Ícone da Empresa / Nome
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.account_balance_wallet,
                          size: 60,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'NextCash',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'Soluções Financeiras Inteligentes',
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Parágrafo 1
                Text(
                  'A NextCash é uma empresa no ramo da tecnologia que foca no desenvolvimento de softwares e aplicativos financeiros. Temos como objetivo central criar soluções digitais que ajudem tanto pessoas quanto empresas a organizarem melhor suas finanças de um jeito rápido, fácil e seguro.',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 16),

                // Parágrafo 2
                Text(
                  'No mercado atual, buscamos nos destacar investindo sempre em inovação e na experiência do usuário, garantindo que nossas criações acompanhem as mudanças do setor financeiro.',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 32),

                // Seção da Equipe
                Text(
                  'Nossa Equipe',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Cards dos Integrantes da Equipe
                _buildTeamMember(
                  name: 'Daniela',
                  role: 'Líder e Especialista da Equipe de Documentação',
                  icon: Icons.description_outlined,
                  cardColor: cardColor,
                  textColor: textColor,
                  roleColor: subtitleColor,
                  iconColor: primaryColor,
                ),
                _buildTeamMember(
                  name: 'Lucas',
                  role: 'Líder da Equipe de Desenvolvimento',
                  icon: Icons.terminal,
                  cardColor: cardColor,
                  textColor: textColor,
                  roleColor: subtitleColor,
                  iconColor: primaryColor,
                ),
                _buildTeamMember(
                  name: 'Fábio',
                  role: 'Desenvolvedor Back-End',
                  icon: Icons.dns_outlined,
                  cardColor: cardColor,
                  textColor: textColor,
                  roleColor: subtitleColor,
                  iconColor: primaryColor,
                ),
                _buildTeamMember(
                  name: 'João',
                  role: 'Desenvolvedor Back-End',
                  icon: Icons.dns_outlined,
                  cardColor: cardColor,
                  textColor: textColor,
                  roleColor: subtitleColor,
                  iconColor: primaryColor,
                ),
                _buildTeamMember(
                  name: 'Vinicius',
                  role: 'Desenvolvedor Front-End',
                  icon: Icons.code,
                  cardColor: cardColor,
                  textColor: textColor,
                  roleColor: subtitleColor,
                  iconColor: primaryColor,
                ),
                _buildTeamMember(
                  name: 'Welber',
                  role: 'Desenvolvedor Front-End',
                  icon: Icons.code,
                  cardColor: cardColor,
                  textColor: textColor,
                  roleColor: subtitleColor,
                  iconColor: primaryColor,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  // Componente reutilizável para renderizar cada membro da equipe
  Widget _buildTeamMember({
    required String name,
    required String role,
    required IconData icon,
    required Color cardColor,
    required Color textColor,
    required Color roleColor,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cardColor == Colors.white ? Colors.grey[200]! : Colors.white10,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  role,
                  style: TextStyle(
                    color: roleColor,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}