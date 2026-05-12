import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_nextcash/services/transacao_service.dart';
import 'package:app_nextcash/services/usuario_service.dart';

class TelaExtrato extends StatefulWidget {
  const TelaExtrato({super.key});

  @override
  State<TelaExtrato> createState() => _TelaExtratoState();
}

class _TelaExtratoState extends State<TelaExtrato> {
  List<Map<String, dynamic>> transacoes = [];
  List<Map<String, dynamic>> transacoesFiltradas = [];
  bool carregando = true;

  String? filtroTipo;
  int? filtroMes;

  final Color corVerdeApp = const Color(0xFF00C853);

  final Map<int, String> nomesMeses = {
    1: "Jan", 2: "Fev", 3: "Mar", 4: "Abr", 5: "Mai", 6: "Jun",
    7: "Jul", 8: "Ago", 9: "Set", 10: "Out", 11: "Nov", 12: "Dez"
  };

  @override
  void initState() {
    super.initState();
    carregarExtrato();
  }

  Future<void> carregarExtrato() async {
    setState(() => carregando = true);
    try {
      final usuarioService = UsuarioService();
      final token = await usuarioService.getUsuarioFromToken();
      if (token == null) return;

      final idUsuario = token["id"];
      final response = await TransacaoService().listarTransacoes(idUsuario);
      final List<dynamic> raw = response["transacoes"] ?? [];

      final lista = raw.map((t) {
        return {
          "id": t["id"].toString(),
          "categoria": t["categoria"],
          "descricao": t["descricao"] ?? "",
          "valor": (t["valor"] as num).toDouble(),
          "data": DateTime.parse(t["data_transacao"]).toLocal(),
        };
      }).toList();

      setState(() {
        transacoes = lista.reversed.toList();
        aplicarFiltros();
      });
    } finally {
      setState(() => carregando = false);
    }
  }

  // --- ✏️ LÓGICA DE EDIÇÃO PADRONIZADA (ESTILO BANCO) ---
  Future<void> _abrirEdicao(Map<String, dynamic> t) async {
    double valorInicial = (t["valor"] as double).abs();
    final descController = TextEditingController(text: t["descricao"]);
    final catController = TextEditingController(text: t["categoria"]);
    final valorController = TextEditingController(
      text: NumberFormat.currency(symbol: "R\$", locale: "pt_BR").format(valorInicial)
    );
    
    double valorNumericoAtual = valorInicial;
    String tipoOriginal = (t["valor"] as double) < 0 ? "Despesa" : "Receita";

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setPopupState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Editar Lançamento", style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Valor", style: TextStyle(color: Colors.grey, fontSize: 13)),
                TextField(
                  controller: valorController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  cursorColor: corVerdeApp,
                  style: TextStyle(
                    fontSize: 28, 
                    fontWeight: FontWeight.w800, 
                    color: tipoOriginal == "Despesa" ? Colors.redAccent : corVerdeApp
                  ),
                  onChanged: (value) {
                    String cleanString = value.replaceAll(RegExp(r'[^0-9]'), '');
                    if (cleanString.isEmpty) cleanString = '0';
                    double valor = double.parse(cleanString) / 100;
                    valorNumericoAtual = valor;
                    
                    setPopupState(() {
                      valorController.value = TextEditingValue(
                        text: NumberFormat.currency(symbol: "R\$", locale: "pt_BR").format(valor),
                        selection: TextSelection.collapsed(
                          offset: NumberFormat.currency(symbol: "R\$", locale: "pt_BR").format(valor).length
                        ),
                      );
                    });
                  },
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
                const Divider(),
                const SizedBox(height: 8),
                TextField(
                  controller: catController,
                  cursorColor: corVerdeApp,
                  decoration: InputDecoration(
                    labelText: "Categoria",
                    labelStyle: TextStyle(color: Colors.grey[600]),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: corVerdeApp)),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descController,
                  cursorColor: corVerdeApp,
                  decoration: InputDecoration(
                    labelText: "Descrição",
                    labelStyle: TextStyle(color: Colors.grey[600]),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: corVerdeApp)),
                  ),
                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: corVerdeApp,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                try {
                  await TransacaoService().atualizarTransacao(
                    id: t["id"],
                    descricao: descController.text,
                    valor: valorNumericoAtual.toString(),
                    categoria: catController.text,
                    tipo: tipoOriginal,
                  );

                  if (mounted) {
                    Navigator.pop(ctx);
                    carregarExtrato();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Alterações salvas!")),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Erro ao salvar alterações")),
                    );
                  }
                }
              },
              child: const Text("Confirmar", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // --- 🗑️ LÓGICA DE APAGAR ---
  Future<void> _confirmarExclusao(String id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Excluir"),
        content: const Text("Deseja apagar esta transação permanentemente?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancelar")),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Apagar", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      final res = await TransacaoService().apagarTransacao(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res["message"])));
        carregarExtrato();
      }
    }
  }

  void aplicarFiltros() {
    List<Map<String, dynamic>> lista = [...transacoes];
    if (filtroTipo != null) {
      lista = lista.where((t) => filtroTipo == "receita" ? t["valor"] > 0 : t["valor"] < 0).toList();
    }
    if (filtroMes != null) {
      lista = lista.where((t) => t["data"].month == filtroMes).toList();
    }
    setState(() => transacoesFiltradas = lista);
  }

  void limparFiltros() {
    setState(() {
      filtroTipo = null;
      filtroMes = null;
      transacoesFiltradas = [...transacoes];
    });
  }

  String _formatarValor(double v) => "R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}";
  String _formatarData(DateTime d) => "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}";

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final textoPrincipal = tema.textTheme.bodyLarge?.color;
    final textoSecundario = tema.textTheme.bodyMedium?.color;

    return Scaffold(
      backgroundColor: tema.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: textoPrincipal), onPressed: () => Navigator.pop(context)),
        title: Text("Movimentações", style: TextStyle(color: textoPrincipal, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              _buildBarraFiltros(tema, textoPrincipal),
              const SizedBox(height: 20),
              Expanded(
                child: carregando
                    ? Center(child: CircularProgressIndicator(color: corVerdeApp))
                    : transacoesFiltradas.isEmpty
                        ? _buildEmptyState(textoSecundario)
                        : _buildLista(tema, textoPrincipal, textoSecundario),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBarraFiltros(ThemeData tema, Color? textoPrincipal) {
    return Row(
      children: [
        _FiltroDropdown<String>(
          value: filtroTipo,
          hint: "Tipo",
          items: const [
            DropdownMenuItem(value: "receita", child: Text("Entradas")),
            DropdownMenuItem(value: "despesa", child: Text("Saídas")),
          ],
          onChanged: (v) { setState(() => filtroTipo = v); aplicarFiltros(); },
        ),
        const SizedBox(width: 10),
        _FiltroDropdown<int>(
          value: filtroMes,
          hint: "Mês",
          items: nomesMeses.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
          onChanged: (v) { setState(() => filtroMes = v); aplicarFiltros(); },
        ),
        const Spacer(),
        if (filtroTipo != null || filtroMes != null)
          IconButton(onPressed: limparFiltros, icon: const Icon(Icons.filter_alt_off, color: Colors.redAccent)),
      ],
    );
  }

  Widget _buildLista(ThemeData tema, Color? textoPrincipal, Color? textoSecundario) {
    return ListView.separated(
      itemCount: transacoesFiltradas.length,
      separatorBuilder: (_, __) => Divider(color: textoSecundario!.withOpacity(0.08)),
      itemBuilder: (context, index) {
        final t = transacoesFiltradas[index];
        final valor = t["valor"] as double;
        final isDespesa = valor < 0;

        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(t["categoria"], style: TextStyle(color: textoPrincipal, fontWeight: FontWeight.bold)),
          subtitle: Text("${t["descricao"]}\n${_formatarData(t["data"])}", style: TextStyle(color: textoSecundario, fontSize: 12)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${isDespesa ? '-' : '+'}${_formatarValor(valor.abs())}",
                style: TextStyle(
                  color: isDespesa ? Colors.redAccent : corVerdeApp, 
                  fontWeight: FontWeight.bold,
                  fontSize: 15
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, size: 22, color: textoSecundario),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onSelected: (cmd) {
                  if (cmd == 'edit') _abrirEdicao(t);
                  if (cmd == 'delete') _confirmarExclusao(t["id"]);
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text("Editar")])),
                  const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 18), SizedBox(width: 8), Text("Excluir", style: TextStyle(color: Colors.red))])),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(Color? textoSecundario) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, color: textoSecundario?.withOpacity(0.2), size: 70),
          const SizedBox(height: 16),
          Text("Nenhuma movimentação", style: TextStyle(color: textoSecundario, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _FiltroDropdown<T> extends StatelessWidget {
  final T? value;
  final String hint;
  final List<DropdownMenuItem<T>> items;
  final Function(T?) onChanged;

  const _FiltroDropdown({required this.value, required this.hint, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final isDark = tema.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[200],
        borderRadius: BorderRadius.circular(10)
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(hint, style: const TextStyle(fontSize: 14)),
          dropdownColor: isDark ? const Color(0xFF2B2B2B) : Colors.white,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}