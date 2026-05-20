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

  void _mostrarNotificacaoTopo({
    required bool sucesso,
    required String mensagem,
  }) {
    // Garante que o widget está montado e visível antes de acessar o Overlay
    if (!mounted) return;
    
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
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  Future<void> _buscarDados() async {
    if (!mounted) return;
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

        if (mounted) {
          setState(() {
            _objetivos = objetivos["objetivos"] ?? [];
            _saldoCalculado = saldo;
          });
        }
      }
    } catch (e) {
      debugPrint("Erro ao buscar dados: $e");
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  List<dynamic> get _objetivosFiltrados {
    if (_filtroAtual == 'Em aberto') {
      return _objetivos
          .where(
            (o) =>
                (double.tryParse(o['valor_atual'].toString()) ?? 0) <
                (double.tryParse(o['valor_meta'].toString()) ?? 0),
          )
          .toList();
    }
    if (_filtroAtual == 'Concluídos') {
      return _objetivos
          .where(
            (o) =>
                (double.tryParse(o['valor_atual'].toString()) ?? 0) >=
                (double.tryParse(o['valor_meta'].toString()) ?? 0),
          )
          .toList();
    }
    return _objetivos;
  }

  // Método auxiliar para gerenciar a abertura sequencial dos diálogos sem quebrar o Context
  void _abrirDetalhesObjetivo(dynamic obj) {
    showDialog(
      context: context,
      builder: (contextPrincipal) => _DialogDetalhesObjetivo(
        corVerde: corVerdeApp,
        objective: obj,
        saldoDisponivel: _saldoCalculado,
        onRefresh: _buscarDados,
        onNotificacao: _mostrarNotificacaoTopo,
      ),
    ).then((retorno) {
      // Se o diálogo de detalhes fechar retornando a flag para editar, abrimos o de edição aqui na raiz
      if (retorno == 'abrir_edicao') {
        _abrirEdicaoObjetivo(obj);
      }
    });
  }

  void _abrirEdicaoObjetivo(dynamic obj) {
    showDialog(
      context: context,
      builder: (contextPrincipal) => _DialogEdicaoObjetivo(
        objetivo: obj,
        corVerde: corVerdeApp,
        onRefresh: _buscarDados,
        onNotificacao: _mostrarNotificacaoTopo,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final isDark = tema.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Meus Objetivos",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (val) => setState(() => _filtroAtual = val),
            itemBuilder: (_) => [
              'Todos',
              'Em aberto',
              'Concluídos',
            ].map((f) => PopupMenuItem(value: f, child: Text(f))).toList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: corVerdeApp,
        onPressed: () => Navigator.pushNamed(
          context,
          '/criarobjetivos',
        ).then((resultado) {
          _buscarDados();
          if (resultado == true) {
            _mostrarNotificacaoTopo(
              sucesso: true,
              mensagem: "Objetivo criado com sucesso!",
            );
          }
        }),
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
                          Text(
                            "Saldo disponível",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "R\$ ${_saldoCalculado.toStringAsFixed(2).replaceAll('.', ',')}",
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        color: corVerdeApp,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                        onTap: () => _abrirDetalhesObjetivo(obj), // Chamando o gerenciador seguro
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

  const _CardObjetivo({
    required this.objetivo,
    required this.onTap,
    required this.corVerde,
  });

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
          border: concluido
              ? Border.all(color: corVerde, width: 2)
              : Border.all(color: isDark ? Colors.white10 : Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: concluido
                  ? corVerde.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.1),
              child: Icon(
                concluido ? Icons.check_circle : Icons.flag_rounded,
                color: concluido ? corVerde : Colors.grey,
              ),
            ),
            const Spacer(),
            Text(
              objetivo['descricao'] ?? "",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              "Meta: R\$ ${meta.toStringAsFixed(2).replaceAll('.', ',')}",
              style: TextStyle(
                color: concluido ? corVerde : Colors.grey[600],
                fontSize: 12,
                fontWeight: concluido ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- DIÁLOGO DE DETALHES ---
class _DialogDetalhesObjetivo extends StatefulWidget {
  final Map<String, dynamic> objective;
  final double saldoDisponivel;
  final VoidCallback onRefresh;
  final Color corVerde;
  final void Function({required bool sucesso, required String mensagem}) onNotificacao;

  const _DialogDetalhesObjetivo({
    required this.objective,
    required this.saldoDisponivel,
    required this.onRefresh,
    required this.corVerde,
    required this.onNotificacao,
  });

  @override
  State<_DialogDetalhesObjetivo> createState() =>
      _DialogDetalhesObjetivoState();
}

class _DialogDetalhesObjetivoState extends State<_DialogDetalhesObjetivo> {
  String _formatarData(dynamic dataRaw) {
    if (dataRaw == null) return 'Não definida';
    try {
      final dataParsed = DateTime.tryParse(dataRaw.toString());
      if (dataParsed != null) {
        return DateFormat('dd/MM/yyyy').format(dataParsed);
      }
    } catch (_) {}
    return 'Não definida';
  }

  void _confirmarExclusao(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Excluir Objetivo?",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Tem certeza que deseja apagar este objetivo? Essa ação não poderá ser desfeita.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                "Cancelar",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                try {
                  await ObjetivoService().deletarObjetivo(
                    widget.objective['id'].toString(),
                  );

                  widget.onRefresh();

                  if (ctx.mounted) Navigator.pop(ctx);
                  if (context.mounted) Navigator.pop(context);

                  widget.onNotificacao(
                    sucesso: true,
                    mensagem: "Objetivo excluído com sucesso",
                  );
                } catch (e) {
                  if (ctx.mounted) Navigator.pop(ctx);
                  widget.onNotificacao(
                    sucesso: false,
                    mensagem: "Erro ao excluir objetivo",
                  );
                }
              },
              child: const Text("Excluir"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double meta =
        double.tryParse(widget.objective['valor_meta'].toString()) ?? 0;
    double atual =
        double.tryParse(widget.objective['valor_atual'].toString()) ?? 0;
    bool concluido = atual >= meta;
    bool podeConcluir = widget.saldoDisponivel >= meta;

    String dataInicioFmt = _formatarData(widget.objective['data_inicio']);
    String dataLimiteFmt = _formatarData(widget.objective['data_limite']);

    final moedaFmt = NumberFormat.currency(symbol: "R\$", locale: "pt_BR");

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titlePadding: const EdgeInsets.only(
        top: 8,
        left: 24,
        right: 8,
        bottom: 0,
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Detalhes", style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit_note, color: widget.corVerde),
                onPressed: () {
                  // Pop enviando a string de instrução capturada pela TelaObjetivos
                  Navigator.pop(context, 'abrir_edicao');
                },
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                widget.objective['descricao'] ?? "",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Acumulado",
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                Text(
                  "Meta",
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  moedaFmt.format(widget.saldoDisponivel),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: widget.corVerde,
                  ),
                ),
                Text(
                  moedaFmt.format(meta),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                minHeight: 12,
                value: meta > 0 ? (widget.saldoDisponivel / meta).clamp(0, 1) : 0,
                color: podeConcluir ? widget.corVerde : Colors.orange,
                backgroundColor: Colors.grey[300],
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                concluido
                    ? "Objetivo alcançado! 🎉"
                    : "Faltam ${(meta - widget.saldoDisponivel).clamp(0, double.infinity).toStringAsFixed(2).replaceAll('.', ',')}",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),

            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: widget.corVerde),
                const SizedBox(width: 8),
                const Text(
                  "Início: ",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  dataInicioFmt,
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.outlined_flag, size: 16, color: widget.corVerde),
                const SizedBox(width: 8),
                const Text(
                  "Prazo Limite: ",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  dataLimiteFmt,
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: () => _confirmarExclusao(context),
        ),
        const Spacer(),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.corVerde,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: (podeConcluir || concluido)
              ? () async {
                  try {
                    await ObjetivoService().atualizarObjetivo(
                      id: widget.objective['id'].toString(),
                      valorAtual: concluido ? 0 : meta,
                    );
                    widget.onRefresh();
                    if (context.mounted) Navigator.pop(context);
                    
                    widget.onNotificacao(
                      sucesso: true,
                      mensagem: concluido ? "Objetivo reaberto com sucesso!" : "Objetivo concluído com sucesso! 🎉",
                    );
                  } catch (e) {
                    widget.onNotificacao(
                      sucesso: false,
                      mensagem: "Erro ao atualizar objetivo",
                    );
                  }
                }
              : null,
          child: Text(concluido ? "Reabrir" : "Concluir"),
        ),
      ],
    );
  }
}

// --- DIÁLOGO DE EDIÇÃO ---
class _DialogEdicaoObjetivo extends StatefulWidget {
  final Map<String, dynamic> objetivo;
  final Color corVerde;
  final VoidCallback onRefresh;
  final void Function({required bool sucesso, required String mensagem}) onNotificacao;

  const _DialogEdicaoObjetivo({
    required this.objetivo,
    required this.corVerde,
    required this.onRefresh,
    required this.onNotificacao,
  });

  @override
  State<_DialogEdicaoObjetivo> createState() => _DialogEdicaoObjetivoState();
}

class _DialogEdicaoObjetivoState extends State<_DialogEdicaoObjetivo> {
  late TextEditingController _descController;
  late TextEditingController _metaController;
  late TextEditingController _dataInicioController;
  late TextEditingController _dataLimiteController;

  double _metaNumerica = 0;
  DateTime? _dataInicioSelecionada;
  DateTime? _dataLimiteSelecionada;

  @override
  void initState() {
    super.initState();
    _metaNumerica =
        double.tryParse(widget.objetivo['valor_meta'].toString()) ?? 0;
    _descController = TextEditingController(text: widget.objetivo['descricao']);
    _metaController = TextEditingController(
      text: NumberFormat.currency(
        symbol: "R\$",
        locale: "pt_BR",
      ).format(_metaNumerica),
    );

    if (widget.objetivo['data_inicio'] != null) {
      _dataInicioSelecionada = DateTime.tryParse(
        widget.objetivo['data_inicio'].toString(),
      );
      _dataInicioController = TextEditingController(
        text: _dataInicioSelecionada != null
            ? DateFormat('dd/MM/yyyy').format(_dataInicioSelecionada!)
            : '',
      );
    } else {
      _dataInicioController = TextEditingController();
    }

    if (widget.objetivo['data_limite'] != null) {
      _dataLimiteSelecionada = DateTime.tryParse(
        widget.objetivo['data_limite'].toString(),
      );
      _dataLimiteController = TextEditingController(
        text: _dataLimiteSelecionada != null
            ? DateFormat('dd/MM/yyyy').format(_dataLimiteSelecionada!)
            : '',
      );
    } else {
      _dataLimiteController = TextEditingController();
    }
  }

  Future<DateTime?> _abrirCalendario(
    BuildContext context,
    DateTime dataInicial,
  ) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return await showDatePicker(
      context: context,
      initialDate: dataInicial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: isDark
              ? ThemeData.dark().copyWith(
                  colorScheme: ColorScheme.dark(
                    primary: widget.corVerde,
                    onPrimary: Colors.black,
                    surface: const Color(0xFF1E1E1E),
                    onSurface: Colors.white,
                  ),
                )
              : ThemeData.light().copyWith(
                  colorScheme: ColorScheme.light(
                    primary: widget.corVerde,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black87,
                  ),
                ),
          child: child!,
        );
      },
    );
  }

  @override
  void dispose() {
    _descController.dispose();
    _metaController.dispose();
    _dataInicioController.dispose();
    _dataLimiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text(
        "Editar Objetivo",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Valor da Meta",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            TextField(
              controller: _metaController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              cursorColor: widget.corVerde,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: widget.corVerde,
              ),
              onChanged: (value) {
                String cleanString = value.replaceAll(RegExp(r'[^0-9]'), '');
                if (cleanString.isEmpty) cleanString = '0';
                double valor = double.parse(cleanString) / 100;
                _metaNumerica = valor;
                setState(() {
                  _metaController.value = TextEditingValue(
                    text: NumberFormat.currency(
                      symbol: "R\$",
                      locale: "pt_BR",
                    ).format(valor),
                    selection: TextSelection.collapsed(
                      offset: NumberFormat.currency(
                        symbol: "R\$",
                        locale: "pt_BR",
                      ).format(valor).length,
                    ),
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
                labelStyle: const TextStyle(fontSize: 14),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: widget.corVerde),
                ),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _dataInicioController,
              readOnly: true,
              onTap: () async {
                final escolhida = await _abrirCalendario(
                  context,
                  _dataInicioSelecionada ?? DateTime.now(),
                );
                if (escolhida != null) {
                  setState(() {
                    _dataInicioSelecionada = escolhida;
                    _dataInicioController.text = DateFormat(
                      'dd/MM/yyyy',
                    ).format(escolhida);
                  });
                }
              },
              decoration: InputDecoration(
                labelText: "Data de Início",
                labelStyle: const TextStyle(fontSize: 14),
                suffixIcon: Icon(
                  Icons.calendar_today,
                  color: widget.corVerde,
                  size: 20,
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: widget.corVerde),
                ),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _dataLimiteController,
              readOnly: true,
              onTap: () async {
                final escolhida = await _abrirCalendario(
                  context,
                  _dataLimiteSelecionada ?? DateTime.now(),
                );
                if (escolhida != null) {
                  setState(() {
                    _dataLimiteSelecionada = escolhida;
                    _dataLimiteController.text = DateFormat(
                      'dd/MM/yyyy',
                    ).format(escolhida);
                  });
                }
              },
              decoration: InputDecoration(
                labelText: "Data Limite (Opcional)",
                labelStyle: const TextStyle(fontSize: 14),
                suffixIcon: Icon(
                  Icons.outlined_flag,
                  color: widget.corVerde,
                  size: 20,
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: widget.corVerde),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.corVerde,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () async {
            try {
              await ObjetivoService().atualizarObjetivo(
                id: widget.objetivo['id'].toString(),
                descricao: _descController.text,
                valorMeta: _metaNumerica,
                dataInicio: _dataInicioSelecionada?.toIso8601String().split('T')[0],
                dataLimite: _dataLimiteSelecionada?.toIso8601String().split('T')[0],
              );
              widget.onRefresh();
              if (mounted) Navigator.pop(context);
              
              widget.onNotificacao(
                sucesso: true,
                mensagem: "Objetivo atualizado com sucesso!",
              );
            } catch (e) {
              widget.onNotificacao(
                sucesso: false,
                mensagem: "Erro ao salvar alterações",
              );
            }
          },
          child: const Text("Salvar"),
        ),
      ],
    );
  }
}