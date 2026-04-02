import 'package:flutter/material.dart';

import 'tela_objetivos.dart';
import 'tela_transacao.dart';
import 'tela_usuario.dart';
import 'package:app_nextcash/services/usuario_service.dart';

/// Tela de dashboard financeiro em tema escuro.
///
/// Este arquivo pode ser usado diretamente como `home` no MaterialApp:
/// `home: const TelaHome(),`
class TelaHome extends StatefulWidget {
  const TelaHome({super.key});

  @override
  State<TelaHome> createState() => _TelaHomeState();
}

class _TelaHomeState extends State<TelaHome> {
  String nomeUsuario = "Carregando...";

  @override
  void initState() {
    super.initState();
    carregarUsuario();
  }

  void carregarUsuario() async {
    final usuarioService = UsuarioService();

    final tokenData = await usuarioService.getUsuarioFromToken();

    if (tokenData != null) {
      final response = await usuarioService.buscarPorId(tokenData["id"]);

      setState(() {
        nomeUsuario = response["usuario"]["nome"] ?? "Usuário";
      });
    }
  }

  // Valores em variáveis para facilitar manutenção.
  static const double saldoTotal = 1000.00;
  static const double despesaTotal = 560.00;

  static const List<_DespesaRecente> despesasRecentes = <_DespesaRecente>[
    _DespesaRecente(nome: 'Mercado', valor: 350.00, data: 'Hoje'),
    _DespesaRecente(nome: 'Transporte', valor: 120.00, data: 'Ontem'),
    _DespesaRecente(nome: 'Academia', valor: 90.00, data: '24/Fev'),
  ];

  String _formatarReal(double valor) {
    final String comDuasCasas = valor.toStringAsFixed(2).replaceAll('.', ',');
    return 'R\$ $comDuasCasas';
  }

  @override
  Widget build(BuildContext context) {
    const Color fundo = Color(0xFF0B0B0B);
    const Color textoPrincipal = Colors.white;
    const Color textoSecundario = Color(0xFFBDBDBD);
    const Color cinzaCard = Color(0xFF2B2B2B);
    const Color vermelhoDespesa = Color(0xFFD64545);
    const Color verde = Color(0xFF00CC44);
    const Color azul = Color(0xFF2D7FF9);
    const Color amarelo = Color(0xFFF2C94C);
    const Color verdeEscuro = Color(0xFF005200);

    return Scaffold(
      backgroundColor: fundo,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Olá, $nomeUsuario',
                      style: const TextStyle(
                        color: textoPrincipal,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TelaUsuario(),
                          ),
                        );
                      },
                      child: const CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, color: Colors.black),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                CardSaldo(
                  saldoTexto: _formatarReal(saldoTotal),
                  corFundo: cinzaCard,
                ),
                const SizedBox(height: 12),
                CardDespesa(
                  despesaTexto: 'Despesa - ${_formatarReal(despesaTotal)}',
                  corFundo: vermelhoDespesa,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Despesas Recentes',
                  style: TextStyle(
                    color: textoPrincipal,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ...despesasRecentes.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ItemDespesa(
                      nome: item.nome,
                      valorTexto: '-${_formatarReal(item.valor)}',
                      data: item.data,
                      corNome: textoPrincipal,
                      corMeta: textoSecundario,
                      corValor: vermelhoDespesa,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    BotaoAcao(
                      icone: Icons.add,
                      texto: 'Novo',
                      corCirculo: verde,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TelaTransacao(),
                          ),
                        );
                      },
                    ),
                    SizedBox(width: 18),
                    BotaoAcao(
                      icone: Icons.flag,
                      texto: 'Objetivos',
                      corCirculo: azul,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TelaObjetivos(),
                          ),
                        );
                      },
                    ),
                    SizedBox(width: 18),
                    BotaoAcao(
                      icone: Icons.receipt_long,
                      texto: 'Extrato',
                      corCirculo: amarelo,
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                const Text(
                  'Gráfico Mensal',
                  style: TextStyle(
                    color: textoPrincipal,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: cinzaCard,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Placeholder do gráfico',
                    style: TextStyle(color: textoSecundario, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CardSaldo extends StatelessWidget {
  const CardSaldo({
    super.key,
    required this.saldoTexto,
    required this.corFundo,
  });

  final String saldoTexto;
  final Color corFundo;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: corFundo,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Saldo Total',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            saldoTexto,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class CardDespesa extends StatelessWidget {
  const CardDespesa({
    super.key,
    required this.despesaTexto,
    required this.corFundo,
  });

  final String despesaTexto;
  final Color corFundo;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: corFundo,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        despesaTexto,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class ItemDespesa extends StatelessWidget {
  const ItemDespesa({
    super.key,
    required this.nome,
    required this.valorTexto,
    required this.data,
    required this.corNome,
    required this.corMeta,
    required this.corValor,
  });

  final String nome;
  final String valorTexto;
  final String data;
  final Color corNome;
  final Color corMeta;
  final Color corValor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF171717),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              nome,
              style: TextStyle(
                color: corNome,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                valorTexto,
                style: TextStyle(
                  color: corValor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(data, style: TextStyle(color: corMeta, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class BotaoAcao extends StatelessWidget {
  const BotaoAcao({
    super.key,
    required this.icone,
    required this.texto,
    required this.corCirculo,
    this.onTap,
  });

  final IconData icone;
  final String texto;
  final Color corCirculo;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: corCirculo,
              shape: BoxShape.circle,
            ),
            child: Center(child: Icon(icone, color: Colors.black, size: 28)),
          ),
          const SizedBox(height: 8),
          Text(
            texto,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _DespesaRecente {
  const _DespesaRecente({
    required this.nome,
    required this.valor,
    required this.data,
  });

  final String nome;
  final double valor;
  final String data;
}
