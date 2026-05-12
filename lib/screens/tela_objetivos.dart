import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_nextcash/services/objetivo_service.dart';
import 'package:app_nextcash/services/usuario_service.dart';
import 'package:app_nextcash/services/transacao_service.dart';

class TelaObjetivos extends StatefulWidget {
  const TelaObjetivos({super.key});

  @override
  State<TelaObjetivos> createState() => _TelaObjetivosState();
}

class _TelaObjetivosState extends State<TelaObjetivos> {
  List<dynamic> _objetivos = [];
  double _saldoCalculado = 0.0;
  bool _carregando = true;
  String _filtroAtual = 'Todos';

  final Color corVerdeApp = const Color(0xFF00C853);

  @override
  void initState() {
    super.initState();
    _buscarDados();
  }

  Future<void> _buscarDados() async {
    setState(() => _carregando = true);
    try {
      final usuario = await UsuarioService().getUsuarioFromToken();
      if (usuario != null) {
        final uid = usuario["id"].toString();
        final objetivos = await ObjetivoService().listarObjetivos(uid);
        final transacoes = await TransacaoService().listarTransacoes(uid);
        final listaTransacoes = transacoes["transacoes"] ?? [];

        double saldo = 0;
        for (var t in listaTransacoes) {
          saldo += (t["valor"] as num).toDouble();
        }

        setState(() {
          _objetivos = objetivos["objetivos"] ?? [];
          _saldoCalculado = saldo;
        });
      }
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  List<dynamic> get _objetivosFiltrados {
    if (_filtroAtual == 'Em aberto') {
      return _objetivos.where((o) =>
          (double.tryParse(o['valor_atual'].toString()) ?? 0) <
          (double.tryParse(o['valor_meta'].toString()) ?? 0)).toList();
    }
    if (_filtroAtual == 'Concluídos') {
      return _objetivos.where((o) =>
          (double.tryParse(o['valor_atual'].toString()) ?? 0) >=
          (double.tryParse(o['valor_meta'].toString()) ?? 0)).toList();
    }
    return _objetivos;
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final isDark = tema.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Meus Objetivos", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (val) => setState(() => _filtroAtual = val),
            itemBuilder: (_) => ['Todos', 'Em aberto', 'Concluídos']
                .map((f) => PopupMenuItem(value: f, child: Text(f)))
                .toList(),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: corVerdeApp,
        onPressed: () => Navigator.pushNamed(context, '/criarobjetivos').then((_) => _buscarDados()),
        child: const Icon(Icons.add, color: Colors.black, size: 30),
      ),
      body: _carregando
          ? Center(child: CircularProgressIndicator(color: corVerdeApp))
          : Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Saldo disponível", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                          const SizedBox(height: 4),
                          Text(
                            "R\$ ${_saldoCalculado.toStringAsFixed(2).replaceAll('.', ',')}",
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      Icon(Icons.account_balance_wallet_outlined, color: corVerdeApp),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: _objetivosFiltrados.length,
                    itemBuilder: (_, i) {
                      final obj = _objetivosFiltrados[i];
                      return _CardObjetivo(
                        corVerde: corVerdeApp,
                        objetivo: obj,
                        onTap: () => showDialog(
                          context: context,
                          builder: (_) => _DialogDetalhesObjetivo(
                            corVerde: corVerdeApp,
                            objetivo: obj,
                            saldoDisponivel: _saldoCalculado,
                            onRefresh: _buscarDados,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

// --- CARD INDIVIDUAL ---
class _CardObjetivo extends StatelessWidget {
  final Map<String, dynamic> objetivo;
  final VoidCallback onTap;
  final Color corVerde;

  const _CardObjetivo({required this.objetivo, required this.onTap, required this.corVerde});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    double meta = double.tryParse(objetivo['valor_meta'].toString()) ?? 0;
    double atual = double.tryParse(objetivo['valor_atual'].toString()) ?? 0;
    bool concluido = atual >= meta;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: concluido ? Border.all(color: corVerde, width: 2) : Border.all(color: isDark ? Colors.white10 : Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: concluido ? corVerde.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
              child: Icon(concluido ? Icons.check_circle : Icons.flag_rounded, color: concluido ? corVerde : Colors.grey),
            ),
            const Spacer(),
            Text(objetivo['descricao'] ?? "", maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text("Meta: R\$ ${meta.toStringAsFixed(2).replaceAll('.', ',')}", 
              style: TextStyle(color: concluido ? corVerde : Colors.grey[600], fontSize: 12, fontWeight: concluido ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}

// --- DIÁLOGO DE DETALHES ---
class _DialogDetalhesObjetivo extends StatelessWidget {
  final Map<String, dynamic> objetivo;
  final double saldoDisponivel;
  final VoidCallback onRefresh;
  final Color corVerde;

  const _DialogDetalhesObjetivo({required this.objetivo, required this.saldoDisponivel, required this.onRefresh, required this.corVerde});

  @override
  Widget build(BuildContext context) {
    double meta = double.tryParse(objetivo['valor_meta'].toString()) ?? 0;
    double atual = double.tryParse(objetivo['valor_atual'].toString()) ?? 0;
    bool concluido = atual >= meta;
    bool podeConcluir = saldoDisponivel >= meta;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Detalhes", style: TextStyle(fontWeight: FontWeight.bold)),
          IconButton(
            icon: Icon(Icons.edit_note, color: corVerde),
            onPressed: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (_) => _DialogEdicaoObjetivo(objetivo: objetivo, corVerde: corVerde, onRefresh: onRefresh),
              );
            },
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(objetivo['descricao'] ?? "", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              minHeight: 12,
              value: (saldoDisponivel / meta).clamp(0, 1),
              color: podeConcluir ? corVerde : Colors.orange,
              backgroundColor: Colors.grey[300],
            ),
          ),
          const SizedBox(height: 16),
          Text(concluido ? "Objetivo alcançado! 🎉" : "Faltam R\$ ${(meta - saldoDisponivel).clamp(0, double.infinity).toStringAsFixed(2).replaceAll('.', ',')}",
            style: TextStyle(color: Colors.grey[600])),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: () async {
            await ObjetivoService().deletarObjetivo(objetivo['id'].toString());
            onRefresh();
            Navigator.pop(context);
          },
        ),
        const Spacer(),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: corVerde, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          onPressed: (podeConcluir || concluido) ? () async {
            await ObjetivoService().atualizarObjetivo(id: objetivo['id'].toString(), valorAtual: concluido ? 0 : meta);
            onRefresh();
            Navigator.pop(context);
          } : null,
          child: Text(concluido ? "Reabrir" : "Concluir"),
        ),
      ],
    );
  }
}

// --- ✏️ NOVO DIÁLOGO DE EDIÇÃO PADRONIZADO ---
class _DialogEdicaoObjetivo extends StatefulWidget {
  final Map<String, dynamic> objetivo;
  final Color corVerde;
  final VoidCallback onRefresh;

  const _DialogEdicaoObjetivo({required this.objetivo, required this.corVerde, required this.onRefresh});

  @override
  State<_DialogEdicaoObjetivo> createState() => _DialogEdicaoObjetivoState();
}

class _DialogEdicaoObjetivoState extends State<_DialogEdicaoObjetivo> {
  late TextEditingController _descController;
  late TextEditingController _metaController;
  double _metaNumerica = 0;

  @override
  void initState() {
    super.initState();
    _metaNumerica = double.tryParse(widget.objetivo['valor_meta'].toString()) ?? 0;
    _descController = TextEditingController(text: widget.objetivo['descricao']);
    _metaController = TextEditingController(
      text: NumberFormat.currency(symbol: "R\$", locale: "pt_BR").format(_metaNumerica)
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text("Editar Objetivo", style: TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Valor da Meta", style: TextStyle(color: Colors.grey, fontSize: 13)),
            TextField(
              controller: _metaController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              cursorColor: widget.corVerde,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: widget.corVerde),
              onChanged: (value) {
                String cleanString = value.replaceAll(RegExp(r'[^0-9]'), '');
                if (cleanString.isEmpty) cleanString = '0';
                double valor = double.parse(cleanString) / 100;
                _metaNumerica = valor;
                setState(() {
                  _metaController.value = TextEditingValue(
                    text: NumberFormat.currency(symbol: "R\$", locale: "pt_BR").format(valor),
                    selection: TextSelection.collapsed(offset: NumberFormat.currency(symbol: "R\$", locale: "pt_BR").format(valor).length),
                  );
                });
              },
              decoration: const InputDecoration(border: InputBorder.none),
            ),
            const Divider(),
            TextField(
              controller: _descController,
              cursorColor: widget.corVerde,
              decoration: InputDecoration(
                labelText: "Descrição do Objetivo",
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: widget.corVerde)),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar", style: TextStyle(color: Colors.grey))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: widget.corVerde, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          onPressed: () async {
            await ObjetivoService().atualizarObjetivo(
              id: widget.objetivo['id'].toString(),
              descricao: _descController.text,
              valorMeta: _metaNumerica,
            );
            widget.onRefresh();
            if (mounted) Navigator.pop(context);
          },
          child: const Text("Salvar"),
        ),
      ],
    );
  }
}