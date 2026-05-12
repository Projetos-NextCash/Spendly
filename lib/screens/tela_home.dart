import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'tela_objetivos.dart';
import 'tela_transacao.dart';
import 'tela_usuario.dart';
import 'package:app_nextcash/services/usuario_service.dart';
import 'package:app_nextcash/services/transacao_service.dart';
import 'tela_extrato.dart';

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
  }

  Future<void> _inicializarDados() async {
    setState(() => carregando = true);
    await Future.wait([carregarUsuario(), carregarTransacoes()]);
    if (mounted) setState(() => carregando = false);
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
    final usuario = await UsuarioService().getUsuarioFromToken();
    if (usuario != null && mounted) {
      setState(() => nomeUsuario = usuario["nome"]);
    }
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

    final recentes = transacoes.reversed.take(5).toList();
    for (var t in recentes) {
      final dataApi = DateTime.parse(t["data_transacao"]).toLocal();
      lista.add(
        DespesaRecente(
          id: t["id"].toString(),
          nome: t["categoria"],
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

  // --- LÓGICA DE APAGAR ATUALIZADA ---
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
        // Chamando seu método apagarTransacao exatamente como você enviou
        final resultado = await TransacaoService().apagarTransacao(id);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(resultado["message"] ?? "Sucesso!")),
          );
          carregarTransacoes(); // Recarrega os dados da tela
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Erro ao apagar transação.")),
          );
        }
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
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const meses = ['Jan','Fev','Mar','Abr','Mai','Jun','Jul','Ago','Set','Out','Nov','Dez'];
                  int idx = value.toInt() - 1;
                  if (idx < 0 || idx >= 12) return const SizedBox();
                  return Text(meses[idx], style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontSize: 10));
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
                BarChartRodData(toY: receitasPorMes[mes] ?? 0, color: theme.primaryColor, width: 7),
                BarChartRodData(toY: despesasPorMes[mes] ?? 0, color: Colors.redAccent, width: 7),
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
                  CardDespesa(despesaTexto: 'Total de saídas: ${_formatarReal(despesaTotal)}'),
                  const SizedBox(height: 28),
                  Text(
                    'Movimentações recentes',
                    style: theme.textTheme.bodyLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
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
                    style: theme.textTheme.bodyLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
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
              _abreviarNome(nomeUsuario),
              style: theme.textTheme.bodyLarge?.copyWith(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TelaUsuario())),
          child: CircleAvatar(
            backgroundColor: theme.cardColor,
            child: Icon(Icons.person_outline, color: theme.primaryColor),
          ),
        ),
      ],
    );
  }

  Widget _buildAcoesRapidas(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        BotaoAcao(
          icone: Icons.add,
          texto: 'Novo',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TelaTransacao())).then((_) => carregarTransacoes()),
        ),
        BotaoAcao(
          icone: Icons.flag_outlined,
          texto: 'Metas',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TelaObjetivos())),
        ),
        BotaoAcao(
          icone: Icons.bar_chart,
          texto: 'Extrato',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TelaExtrato())).then((_) => carregarTransacoes()),
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

  DespesaRecente({required this.id, required this.nome, required this.valor, required this.data});
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
            backgroundColor: (isDespesa ? Colors.red : Colors.green).withOpacity(0.1),
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
                Text(item.nome, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 15)),
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
                child: const Icon(Icons.delete_outline, size: 18, color: Colors.grey),
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
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dinheiro disponível', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text(saldoTexto, style: theme.textTheme.bodyLarge?.copyWith(fontSize: 28, fontWeight: FontWeight.bold)),
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
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(12)),
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

  const BotaoAcao({super.key, required this.icone, required this.texto, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(color: theme.primaryColor, shape: BoxShape.circle),
            child: Icon(icone, color: Colors.black),
          ),
          const SizedBox(height: 8),
          Text(texto, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}