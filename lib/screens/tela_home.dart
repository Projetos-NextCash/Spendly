import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'tela_objetivos.dart';
import 'tela_transacao.dart';
import 'tela_usuario.dart';
import 'package:app_nextcash/services/usuario_service.dart';
import 'package:app_nextcash/services/transacao_service.dart';
import 'tela_extrato.dart';
import '../storage/local_storage.dart' as local;

class TelaHome extends StatefulWidget {
  const TelaHome({super.key});

  @override
  State<TelaHome> createState() => _TelaHomeState();
}

class _TelaHomeState extends State<TelaHome> {
  String nomeUsuario = "Carregando...";
  Map<int, double> receitasPorMes = {};
  Map<int, double> despesasPorMes = {};
  double saldoTotal = 0;
  double despesaTotal = 0;
  List<DespesaRecente> despesasRecentes = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();

    _inicializarDados();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      verificarPrimeiroAcesso();
    });
  }

  // 👇 NOVA NOTIFICAÇÃO PREMIUM DE META ALCANÇADA
  void _mostrarPopupMetaAlcancada({required String nomeMeta}) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              // Um degradê moderno simulando conquista/ouro
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF00C853),
                  Color(0xFF00E676),
                  Color(0xFFFFD700),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00C853).withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                // Ícone de troféu animado/destacado
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Parabéns! Meta Alcançada! 🎉",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Você conquistou o objetivo: \"$nomeMeta\".",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "Cada centavo poupado é um passo rumo à sua liberdade financeira. Continue com essa disciplina incrível!",
                        style: TextStyle(
                          color: Color.fromRGBO(255, 255, 255, 0.94),
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Fica visível por 5 segundos para dar tempo do usuário ler a mensagem bonita
    Future.delayed(const Duration(seconds: 5), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  void _mostrarNotificacaoTopo({
    required bool sucesso,
    required String mensagem,
  }) {
    final overlay = Overlay.of(context);

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: sucesso ? const Color(0xFF00C853) : Colors.redAccent,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  sucesso ? Icons.check_circle : Icons.error_outline,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    mensagem,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  Future<void> verificarPrimeiroAcesso() async {
    final mostrar = await local.LocalStorage.deveMostrarBoasVindas();

    if (!mostrar || !mounted) return;

    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: const [
              Icon(Icons.waving_hand, color: Color(0xFF00C853)),
              SizedBox(width: 8),
              Text("Bem-vindo(a)!"),
            ],
          ),
          content: const Text(
            "Seu cadastro foi realizado com sucesso.\n\n"
            "Você pode acessar seu perfil para conhecer "
            "o tutorial do aplicativo e saber mais sobre nós.",
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await local.LocalStorage.marcarBoasVindasComoVista();

                if (!mounted) return;

                Navigator.pop(context);
              },
              child: const Text("Agora não"),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C853),
                foregroundColor: Colors.black,
              ),
              onPressed: () async {
                await local.LocalStorage.marcarBoasVindasComoVista();

                if (!mounted) return;

                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TelaUsuario()),
                );
              },
              child: const Text("Ver perfil"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _inicializarDados() async {
    setState(() => carregando = true);
    await Future.wait([carregarUsuario(), carregarTransacoes()]);
    if (mounted) setState(() => carregando = false);
  }

  Future<void> atualizarUsuario() async {
    final tokenData = await UsuarioService().getUsuarioFromToken();

    if (tokenData == null) return;

    final id = tokenData["id"];

    final usuario = await UsuarioService().buscarPorId(id);

    if (!mounted) return;

    setState(() {
      nomeUsuario = usuario["usuario"]["nome"] ?? "Usuário";
    });
  }

  String _abreviarNome(String nome) {
    List<String> partes = nome.trim().split(' ');
    if (partes.length <= 1) return nome;
    String primeiroNome = partes[0];
    String sobrenomesAbreviados = partes
        .skip(1)
        .where((p) => p.length > 2)
        .map((p) => "${p[0].toUpperCase()}.")
        .join(' ');
    return "$primeiroNome $sobrenomesAbreviados";
  }

  Future<void> carregarUsuario() async {
    final tokenData = await UsuarioService().getUsuarioFromToken();
    if (tokenData == null) return;

    final usuario = await UsuarioService().buscarPorId(tokenData["id"]);

    if (!mounted) return;

    setState(() {
      nomeUsuario = usuario["usuario"]["nome"] ?? "";
    });
  }

  Future<void> carregarTransacoes() async {
    final tokenData = await UsuarioService().getUsuarioFromToken();
    if (tokenData == null) return;

    final idUsuario = tokenData["id"];
    final response = await TransacaoService().listarTransacoes(idUsuario);
    final transacoes = response["transacoes"] ?? [];

    double saldo = 0;
    double despesas = 0;
    Map<int, double> tempReceitas = {};
    Map<int, double> tempDespesas = {};
    List<DespesaRecente> lista = [];

    for (var t in transacoes) {
      double valor = (t["valor"] as num).toDouble();
      final data = DateTime.parse(t["data_transacao"]);
      int mes = data.month;

      saldo += valor;
      if (valor > 0) {
        tempReceitas[mes] = (tempReceitas[mes] ?? 0) + valor;
      } else {
        double valorAbs = valor.abs();
        despesas += valorAbs;
        tempDespesas[mes] = (tempDespesas[mes] ?? 0) + valorAbs;
      }
    }

    transacoes.sort((a, b) {
      return DateTime.parse(
        b["data_transacao"],
      ).compareTo(DateTime.parse(a["data_transacao"]));
    });

    final recentes = transacoes.take(5).toList();

    for (var t in recentes) {
      final dataApi = DateTime.parse(t["data_transacao"]).toLocal();

      lista.add(
        DespesaRecente(
          id: t["id"].toString(),
          nome: t["categoria"] ?? "Sem categoria",
          valor: (t["valor"] as num).toDouble(),
          data:
              "${dataApi.day.toString().padLeft(2, '0')}/${dataApi.month.toString().padLeft(2, '0')}",
        ),
      );
    }

    if (mounted) {
      setState(() {
        receitasPorMes = tempReceitas;
        despesasPorMes = tempDespesas;
        saldoTotal = saldo;
        despesaTotal = despesas;
        despesasRecentes = lista;
      });
    }
  }

  Future<void> _confirmarExclusao(String id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Excluir Movimentação"),
        content: const Text("Deseja realmente apagar este registro?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Apagar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await TransacaoService().apagarTransacao(id);
        await carregarTransacoes();

        _mostrarNotificacaoTopo(
          sucesso: true,
          mensagem: "Movimentação excluída com sucesso",
        );
      } catch (e) {
        _mostrarNotificacaoTopo(
          sucesso: false,
          mensagem: "Erro ao excluir movimentação",
        );
      }
    }
  }

  String _formatarReal(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  Widget _buildGrafico(ThemeData theme) {
    double maxValor = 500;
    for (var v in [...receitasPorMes.values, ...despesasPorMes.values]) {
      if (v > maxValor) maxValor = v;
    }

    return Container(
      height: 220,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 24, 20, 10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxValor * 1.2,
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const meses = [
                    'Jan',
                    'Fev',
                    'Mar',
                    'Abr',
                    'Mai',
                    'Jun',
                    'Jul',
                    'Ago',
                    'Set',
                    'Out',
                    'Nov',
                    'Dez',
                  ];
                  int idx = value.toInt() - 1;
                  if (idx < 0 || idx >= 12) return const SizedBox();
                  return Text(
                    meses[idx],
                    style: TextStyle(
                      color: theme.textTheme.bodyMedium?.color,
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(6, (index) {
            int mes = index + 1;
            return BarChartGroupData(
              x: mes,
              barRods: [
                BarChartRodData(
                  toY: receitasPorMes[mes] ?? 0,
                  color: theme.primaryColor,
                  width: 7,
                ),
                BarChartRodData(
                  toY: despesasPorMes[mes] ?? 0,
                  color: Colors.redAccent,
                  width: 7,
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _inicializarDados,
          color: theme.primaryColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(theme),
                  const SizedBox(height: 20),
                  CardSaldo(saldoTexto: _formatarReal(saldoTotal)),
                  const SizedBox(height: 12),
                  CardDespesa(
                    despesaTexto:
                        'Total de saídas: ${_formatarReal(despesaTotal)}',
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Movimentações recentes',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  ...despesasRecentes.map(
                    (item) => ItemDespesaWidget(
                      item: item,
                      onDelete: () => _confirmarExclusao(item.id),
                    ),
                  ),

                  const SizedBox(height: 24),
                  _buildAcoesRapidas(theme),
                  const SizedBox(height: 32),
                  Text(
                    'Visão Mensal (6 meses)',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildGrafico(theme),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Bem-vindo(a),", style: theme.textTheme.bodyMedium),
            Text(
              _viewNome(nomeUsuario),
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TelaUsuario()),
            );
            await atualizarUsuario();
          },
          child: CircleAvatar(
            backgroundColor: theme.cardColor,
            child: Icon(Icons.person_outline, color: theme.primaryColor),
          ),
        ),
      ],
    );
  }

  String _viewNome(String nome) => _abreviarNome(nome);

  Widget _buildAcoesRapidas(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        BotaoAcao(
          icone: Icons.add,
          texto: 'Nova\nMovimentação',
          onTap: () async {
            final resultado = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TelaTransacao()),
            );

            if (!mounted || resultado == null) return;

            await Future.delayed(const Duration(milliseconds: 300));
            await carregarTransacoes();

            // 👇 O FILTRO DE METAS ALCANÇADAS PODE ENTRAR AQUI
            // Se o retorno da tela de transações indicar que uma meta foi batida:
            if (resultado["metaAlcancada"] == true &&
                resultado["nomeMeta"] != null) {
              _mostrarPopupMetaAlcancada(nomeMeta: resultado["nomeMeta"]);
            } else {
              _mostrarNotificacaoTopo(
                sucesso: resultado["sucesso"],
                mensagem: resultado["mensagem"],
              );
            }
          },
          textalignment: TextAlign.center,
        ),
        BotaoAcao(
          icone: Icons.flag_outlined,
          texto: 'Metas\n',
          onTap: () =>
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TelaObjetivos()),
              ).then(
                (_) => carregarTransacoes(),
              ), // Recarrega se voltar da tela de metas
          textalignment: TextAlign.center,
        ),
        BotaoAcao(
          icone: Icons.bar_chart,
          texto: 'Hist. de\nMovimentações',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TelaExtrato()),
          ).then((_) => carregarTransacoes()),
          textalignment: TextAlign.center,
        ),
      ],
    );
  }
}

class DespesaRecente {
  final String id;
  final String nome;
  final double valor;
  final String data;

  DespesaRecente({
    required this.id,
    required this.nome,
    required this.valor,
    required this.data,
  });
}

class ItemDespesaWidget extends StatelessWidget {
  final DespesaRecente item;
  final VoidCallback onDelete;

  const ItemDespesaWidget({
    super.key,
    required this.item,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDespesa = item.valor < 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: (isDespesa ? Colors.red : Colors.green)
                .withOpacity(0.1),
            child: Icon(
              isDespesa ? Icons.arrow_downward : Icons.arrow_upward,
              color: isDespesa ? Colors.red : Colors.green,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.nome,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(item.data, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isDespesa ? "- " : "+ "}R\$ ${item.valor.abs().toStringAsFixed(2)}',
                style: TextStyle(
                  color: isDespesa ? Colors.redAccent : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: onDelete,
                child: const Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- OUTROS COMPONENTES (CARD SALDO, CARD DESPESA, BOTAO ACAO) ---
class CardSaldo extends StatelessWidget {
  final String saldoTexto;
  const CardSaldo({super.key, required this.saldoTexto});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dinheiro disponível', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text(
            saldoTexto,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class CardDespesa extends StatelessWidget {
  final String despesaTexto;
  const CardDespesa({super.key, required this.despesaTexto});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.trending_down, color: Colors.redAccent),
          const SizedBox(width: 8),
          Text(despesaTexto, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class BotaoAcao extends StatelessWidget {
  final IconData icone;
  final String texto;
  final VoidCallback? onTap;
  final TextAlign textalignment;

  const BotaoAcao({
    super.key,
    required this.icone,
    required this.texto,
    this.onTap,
    this.textalignment = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: theme.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icone, color: Colors.black),
          ),
          const SizedBox(height: 8),
          Text(
            texto,
            style: theme.textTheme.bodyMedium,
            textAlign: textalignment,
          ),
        ],
      ),
    );
  }
}
