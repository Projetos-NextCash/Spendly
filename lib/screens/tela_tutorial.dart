import 'package:flutter/material.dart';
import '/core/theme_controller.dart'; // Ajuste o caminho do seu ThemeController se necessário

class TelaTutorial extends StatelessWidget {
  const TelaTutorial({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, currentTheme, child) {
        final isDark = currentTheme == ThemeMode.dark ||
            (currentTheme == ThemeMode.system &&
                MediaQuery.of(context).platformBrightness == Brightness.dark);

        // Cores idênticas à tela anterior e à imagem do perfil
        final backgroundColor = isDark ? const Color(0xFF0F0F0F) : Colors.grey[50]!;
        final primaryColor = const Color(0xFF00C853); // Verde neon
        final textColor = isDark ? Colors.white : Colors.black87;
        final subtitleColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
        final cardColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
        final dividerColor = isDark ? Colors.white10 : Colors.grey[200]!;

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
              'Central de Dúvidas',
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
                // Boas-vindas
                Text(
                  'Bem-vindo(a)!',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Aqui você encontrará uma introdução e algumas explicações sobre como este aplicativo funciona e como ter uma melhor experiência durante o uso.',
                  style: TextStyle(color: textColor, fontSize: 15, height: 1.5),
                ),
                const SizedBox(height: 8),
                Text(
                  'Apresentaremos um tutorial sobre nossas funcionalidades para que você, usuário, não se confunda e consiga tirar possíveis dúvidas.',
                  style: TextStyle(color: subtitleColor, fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 32),

                Text(
                  'Guias por Tela',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // 1. Tela Inicial
                _buildTutorialSection(
                  title: 'Tela Inicial',
                  icon: Icons.home_outlined,
                  cardColor: cardColor,
                  textColor: textColor,
                  primaryColor: primaryColor,
                  dividerColor: dividerColor,
                  children: [
                    const Text(
                      'Esta tela representa o ponto central do aplicativo, ou seja, o espaço onde você passará boa parte do tempo durante a navegação. Aqui está a porta de acesso para as principais funcionalidades do app, além de um resumo das suas informações financeiras.',
                    ),
                    const SizedBox(height: 12),
                    const Text('Nesta tela, você poderá visualizar:', style: TextStyle(fontWeight: FontWeight.bold)),
                    _buildBulletItem('Seu saldo (dinheiro disponível);'),
                    _buildBulletItem('Seus gastos (total de saídas);'),
                    _buildBulletItem('Transações recentes (movimentações mais recentes);'),
                    _buildBulletItem('Um gráfico na parte inferior da tela, que apresenta um retorno visual das suas movimentações durante o mês.'),
                    const SizedBox(height: 12),
                    const Text('Há também três botões em destaque:', style: TextStyle(fontWeight: FontWeight.bold)),
                    _buildInlineBadge(['Nova Movimentação', 'Metas', 'Movimentações'], primaryColor),
                    const Text('Esses botões levam você para páginas onde poderá realizar diferentes operações.'),
                  ],
                ),

                // 2. Tela de Nova Movimentação
                _buildTutorialSection(
                  title: 'Tela de Nova Movimentação',
                  icon: Icons.add_circle_outline,
                  cardColor: cardColor,
                  textColor: textColor,
                  primaryColor: primaryColor,
                  dividerColor: dividerColor,
                  children: [
                    const Text(
                      'Nesta tela, você encontrará um formulário com os seguintes campos:',
                    ),
                    _buildBulletItem('Valor\n• Descrição\n• Tipo\n• Categoria'),
                    const Text(
                      'Esses campos são responsáveis por registrar suas movimentações financeiras, tanto de entrada (lucro) quanto de saída (gasto).',
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: primaryColor.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Exemplo Prático:',
                            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Imagine que você fez uma compra no supermercado no valor de 568,73 reais. Você deverá preencher:\n\n'
                            '1. O valor da compra;\n'
                            '2. O tipo, que será Saída(no caso deste exemplo);\n'
                            '3. A categoria, escolhendo uma opção existente ou criando uma nova ao selecionar “Outros”;\n'
                            '4. Uma descrição, caso queira identificar melhor a movimentação.',
                            style: TextStyle(fontSize: 13, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('Após preencher as informações, basta adicionar a movimentação. Ela será registrada no sistema e exibida nas telas do aplicativo.'),
                  ],
                ),

                // 3. Tela de Extrato
                _buildTutorialSection(
                  title: 'Tela de Extrato (Movimentações)',
                  icon: Icons.receipt_long_outlined,
                  cardColor: cardColor,
                  textColor: textColor,
                  primaryColor: primaryColor,
                  dividerColor: dividerColor,
                  children: [
                    const Text(
                      'Após realizar movimentações, esta tela ficará responsável por exibir todas as transações feitas por você, organizadas em ordem de registro.',
                    ),
                    const SizedBox(height: 12),
                    const Text('Ao lado de cada transação, haverá um botão com três pontos, onde você encontrará duas opções:', style: TextStyle(fontWeight: FontWeight.bold)),
                    _buildBulletItem('Editar a transação, caso tenha cometido algum erro;'),
                    _buildBulletItem('Excluir a transação, se necessário.'),
                    const SizedBox(height: 12),
                    const Text('Além disso, as transações podem ser filtradas utilizando os filtros disponíveis na parte superior da tela, facilitando a busca pelas informações desejadas.'),
                  ],
                ),

                // 4. Tela de Metas
                _buildTutorialSection(
                  title: 'Tela de Metas',
                  icon: Icons.track_changes,
                  cardColor: cardColor,
                  textColor: textColor,
                  primaryColor: primaryColor,
                  dividerColor: dividerColor,
                  children: [
                    const Text(
                      'Depois de registrar suas movimentações, você poderá criar metas financeiras dentro do aplicativo.\n\n'
                      'Ao acessar a tela pelo botão “Metas”, você verá:',
                    ),
                    _buildBulletItem('As metas já cadastradas;'),
                    _buildBulletItem('Seu saldo disponível;'),
                    _buildBulletItem('O progresso das metas.'),
                    const SizedBox(height: 12),
                    const Text(
                      'Ao clicar em uma meta, será exibido um pop-up, onde você poderá acompanhar seu progresso. Nesse mesmo espaço, será possível:',
                    ),
                    _buildBulletItem('Editar a meta (ícone de lápis);'),
                    _buildBulletItem('Excluir a meta (ícone de lixeira).'),
                    const SizedBox(height: 12),
                    const Text(
                      'Para criar uma nova meta, basta clicar no botão “+” verde, localizado no canto inferior direito da tela.\n\n'
                      'Ao pressioná-lo, será aberto um formulário onde você deverá informar:',
                    ),
                    _buildBulletItem('Valor da meta;\n• Descrição;\n• Data de início (quando começará a economizar);\n• Data limite (até quando a meta ficará ativa).'),
                    const SizedBox(height: 12),
                    const Text('Depois disso, basta clicar em “Criar Objetivo”, e a meta será adicionada à lista da tela anterior.'),
                  ],
                ),

                // 5. Tela de Usuário
                _buildTutorialSection(
                  title: 'Tela de Usuário',
                  icon: Icons.person_outline,
                  cardColor: cardColor,
                  textColor: textColor,
                  primaryColor: primaryColor,
                  dividerColor: dividerColor,
                  children: [
                    const Text('Nesta tela, você encontrará tudo relacionado à sua conta. Aqui será possível:'),
                    _buildBulletItem('Visualizar e editar seus dados cadastrados (as alterações só serão salvas caso os campos sejam modificados e confirmados);'),
                    _buildBulletItem('Alterar sua senha, na área de segurança;'),
                    _buildBulletItem('Acessar a seção Sobre o Aplicativo, onde você poderá conhecer mais sobre a NextCash;'),
                    _buildBulletItem('Consultar a seção de Dúvidas, onde este tutorial estará disponível para ajudar você a entender melhor o funcionamento do aplicativo.'),
                    const SizedBox(height: 12),
                    const Text('Ao final da tela, também estarão disponíveis as opções para:', style: TextStyle(fontWeight: FontWeight.bold)),
                    _buildBulletItem('Sair da conta;'),
                    _buildBulletItem('Apagar a conta, caso deseje.'),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget estrutural para cada Menu Sanfona (ExpansionTile) do Tutorial
  Widget _buildTutorialSection({
    required String title,
    required IconData icon,
    required Color cardColor,
    required Color textColor,
    required Color primaryColor,
    required Color dividerColor,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: dividerColor),
      ),
      child: Theme(
        // Remove as linhas de divisão nativas que o ExpansionTile coloca no topo/fundo ao abrir
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(icon, color: primaryColor, size: 24),
          title: Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconColor: primaryColor,
          collapsedIconColor: textColor.withOpacity(0.6),
          childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: children.map((widget) {
            if (widget is Text) {
              return DefaultTextStyle.merge(
                style: TextStyle(color: textColor.withOpacity(0.9), fontSize: 14, height: 1.5),
                child: widget,
              );
            }
            return widget;
          }).toList(),
        ),
      ),
    );
  }

  // Helper para criar listas com marcadores personalizados
  Widget _buildBulletItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  // Helper visual para destacar botões citados no texto
  Widget _buildInlineBadge(List<String> labels, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: labels.map((label) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: primaryColor.withOpacity(0.3)),
            ),
            child: Text(
              label,
              style: TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          );
        }).toList(),
      ),
    );
  }
}