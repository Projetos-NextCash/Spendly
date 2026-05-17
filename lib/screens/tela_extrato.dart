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
  List<String> categorias = [];

  bool carregando = true;

  String? filtroTipo;
  String? filtroPeriodo;
  String? filtroCategoria;
  String ordenacao = "mais_recente";
  String buscaTexto = "";

  final Color corVerdeApp = const Color(0xFF00C853);

  @override
  void initState() {
    super.initState();
    carregarExtrato();
  }

  // =========================
  // CARREGAMENTO
  // =========================
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

      categorias = lista.map((e) => e["categoria"].toString()).toSet().toList();
      transacoes = lista.reversed.toList();

      aplicarFiltros();
    } catch (e) {
      // Evita travamentos caso a API falhe
      debugPrint("Erro ao carregar extrato: $e");
    } finally {
      setState(() => carregando = false);
    }
  }

  // =========================
  // FILTROS & LÓGICA
  // =========================
  void aplicarFiltros() {
    List<Map<String, dynamic>> lista = [...transacoes];

    // TIPO
    if (filtroTipo != null) {
      lista = lista.where((t) {
        return filtroTipo == "receita" ? t["valor"] > 0 : t["valor"] < 0;
      }).toList();
    }

    // CATEGORIA
    if (filtroCategoria != null) {
      lista = lista.where((t) => t["categoria"] == filtroCategoria).toList();
    }

    // BUSCA
    if (buscaTexto.isNotEmpty) {
      lista = lista.where((t) {
        final cat = t["categoria"].toString().toLowerCase();
        final desc = t["descricao"].toString().toLowerCase();
        return cat.contains(buscaTexto) || desc.contains(buscaTexto);
      }).toList();
    }

    // PERÍODO (Corrigido o bug do cast de DateTime)
    DateTime now = DateTime.now();
    if (filtroPeriodo != null) {
      lista = lista.where((t) {
        final data = t["data"] as DateTime;

        switch (filtroPeriodo) {
          case "7dias":
            return data.isAfter(now.subtract(const Duration(days: 7)));
          case "30dias":
            return data.isAfter(now.subtract(const Duration(days: 30)));
          case "3meses":
            return data.isAfter(DateTime(now.year, now.month - 3));
          case "ano":
            return data.year == now.year;
          default:
            return true;
        }
      }).toList();
    }

    // ORDENAÇÃO
    switch (ordenacao) {
      case "mais_recente":
        lista.sort((a, b) => b["data"].compareTo(a["data"]));
        break;
      case "mais_antigo":
        lista.sort((a, b) => a["data"].compareTo(b["data"]));
        break;
      case "maior_valor":
        lista.sort((a, b) => b["valor"].abs().compareTo(a["valor"].abs()));
        break;
      case "menor_valor":
        lista.sort((a, b) => a["valor"].abs().compareTo(b["valor"].abs()));
        break;
    }

    setState(() {
      transacoesFiltradas = lista;
    });
  }

  void limparFiltros() {
    setState(() {
      filtroTipo = null;
      filtroPeriodo = null;
      filtroCategoria = null;
      buscaTexto = "";
      ordenacao = "mais_recente";
      transacoesFiltradas = [...transacoes];
    });
  }

  String _formatarValor(double v) =>
      "R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}";

  String _formatarData(DateTime d) =>
      "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}";

  // =========================
  // BUILD PRINCIPAL
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Movimentações",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // Campo de busca com padding lateral fixo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildBusca(),
          ),
          const SizedBox(height: 12),

          // Chips de Filtro Horizontais deslizando até a borda da tela
          _buildFiltrosChips(),
          const SizedBox(height: 8),

          // Seção discreta de Ordenação e Resultados
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${transacoesFiltradas.length} transações",
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                _buildOrdenacaoMenu(),
              ],
            ),
          ),
          const Divider(height: 20, thickness: 1),

          // Lista de Transações
          Expanded(
            child: carregando
                ? Center(
                    child: CircularProgressIndicator(color: corVerdeApp),
                  )
                : transacoesFiltradas.isEmpty
                    ? Center(
                        child: Text(
                          "Nenhuma transação encontrada",
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: transacoesFiltradas.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final t = transacoesFiltradas[index];
                          final valor = t["valor"] as double;
                          final isDespesa = valor < 0;

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 8,
                            ),
                            title: Text(
                              t["categoria"],
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            subtitle: Text(
                              "${t["descricao"]}\n${_formatarData(t["data"])}",
                              style: const TextStyle(height: 1.3),
                            ),
                            trailing: Text(
                              "${isDespesa ? '-' : '+'}${_formatarValor(valor.abs())}",
                              style: TextStyle(
                                color: isDespesa ? Colors.red[700] : corVerdeApp,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
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

  // =========================
  // NOVOS COMPONENTES RE-ESTILIZADOS
  // =========================

  Widget _buildBusca() {
  final tema = Theme.of(context);
  final isEscuro = tema.brightness == Brightness.dark;

  return TextField(
    onChanged: (v) {
      buscaTexto = v.toLowerCase();
      aplicarFiltros();
    },
    // Garante que a cor do texto digitado mude de acordo com o tema
    style: TextStyle(
      color: isEscuro ? Colors.white : Colors.black87,
    ),
    decoration: InputDecoration(
      hintText: "Buscar descrição ou categoria",
      hintStyle: TextStyle(
        color: isEscuro ? Colors.grey[400] : Colors.grey[600],
      ),
      prefixIcon: Icon(
        Icons.search, 
        size: 22,
        color: isEscuro ? Colors.grey[400] : Colors.grey[600],
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 0),
      filled: true,
      // Altera o fundo dinamicamente baseado no tema ativo
      fillColor: isEscuro ? Colors.grey[850] : Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
  );
}

  Widget _buildFiltrosChips() {
  final tema = Theme.of(context);
  final isEscuro = tema.brightness == Brightness.dark;

  final temFiltroAtivo = filtroTipo != null ||
      filtroPeriodo != null ||
      filtroCategoria != null;

  // Estilização padrão para os chips combinarem com o tema escuro/claro
  final labelStyleAtivo = const TextStyle(color: Colors.white, fontWeight: FontWeight.bold);
  final labelStyleInativo = TextStyle(color: isEscuro ? Colors.grey[300] : Colors.black87);

  return SizedBox(
    height: 40,
    child: ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        // Botão Limpar Filtros
        if (temFiltroAtivo) ...[
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: limparFiltros,
            icon: const Icon(Icons.clear_all, color: Colors.red),
            tooltip: "Limpar filtros",
          ),
          const SizedBox(width: 8),
        ],

        // Filtro por Tipo de transação (Entrada/Saída)
        PopupMenuButton<String>(
          onSelected: (v) {
            setState(() => filtroTipo = v == "todos" ? null : v);
            aplicarFiltros();
          },
          // Garante que o fundo do menu herde as cores do tema
          color: isEscuro ? Colors.grey[900] : Colors.white,
          itemBuilder: (context) => [
            PopupMenuItem(value: "todos", child: Text("Todos os tipos", style: TextStyle(color: isEscuro ? Colors.white : Colors.black87))),
            PopupMenuItem(value: "receita", child: Text("Entradas", style: TextStyle(color: isEscuro ? Colors.white : Colors.black87))),
            PopupMenuItem(value: "despesa", child: Text("Saídas", style: TextStyle(color: isEscuro ? Colors.white : Colors.black87))),
          ],
          // O segredo está aqui: passar onSelected como null faz o chip repassar o clique para o PopupMenuButton
          child: FilterChip(
            label: Text(
              filtroTipo == "receita"
                  ? "Entradas"
                  : filtroTipo == "despesa"
                      ? "Saídas"
                      : "Tipo",
              style: filtroTipo != null ? labelStyleAtivo : labelStyleInativo,
            ),
            selected: filtroTipo != null,
            selectedColor: corVerdeApp,
            checkmarkColor: Colors.white,
            backgroundColor: isEscuro ? Colors.grey[800] : Colors.grey[200],
            onSelected: null, 
          ),
        ),
        const SizedBox(width: 8),

        // Filtro por Período
        PopupMenuButton<String>(
          onSelected: (v) {
            setState(() => filtroPeriodo = v == "todos" ? null : v);
            aplicarFiltros();
          },
          color: isEscuro ? Colors.grey[900] : Colors.white,
          itemBuilder: (context) => [
            PopupMenuItem(value: "todos", child: Text("Todo o período", style: TextStyle(color: isEscuro ? Colors.white : Colors.black87))),
            PopupMenuItem(value: "7dias", child: Text("Últimos 7 dias", style: TextStyle(color: isEscuro ? Colors.white : Colors.black87))),
            PopupMenuItem(value: "30dias", child: Text("Últimos 30 dias", style: TextStyle(color: isEscuro ? Colors.white : Colors.black87))),
            PopupMenuItem(value: "3meses", child: Text("Últimos 3 meses", style: TextStyle(color: isEscuro ? Colors.white : Colors.black87))),
            PopupMenuItem(value: "ano", child: Text("Deste ano", style: TextStyle(color: isEscuro ? Colors.white : Colors.black87))),
          ],
          child: FilterChip(
            label: Text(
              filtroPeriodo == "7dias"
                  ? "7 dias"
                  : filtroPeriodo == "30dias"
                      ? "30 dias"
                      : filtroPeriodo == "3meses"
                          ? "3 meses"
                          : filtroPeriodo == "ano"
                              ? "Este ano"
                              : "Período",
              style: filtroPeriodo != null ? labelStyleAtivo : labelStyleInativo,
            ),
            selected: filtroPeriodo != null,
            selectedColor: corVerdeApp,
            checkmarkColor: Colors.white,
            backgroundColor: isEscuro ? Colors.grey[800] : Colors.grey[200],
            onSelected: null,
          ),
        ),
        const SizedBox(width: 8),

        // Filtro por Categorias dinâmicas
        if (categorias.isNotEmpty)
          PopupMenuButton<String>(
            onSelected: (v) {
              setState(() => filtroCategoria = v == "todos" ? null : v);
              aplicarFiltros();
            },
            color: isEscuro ? Colors.grey[900] : Colors.white,
            itemBuilder: (context) => [
              PopupMenuItem(
                  value: "todos", 
                  child: Text("Todas categorias", style: TextStyle(color: isEscuro ? Colors.white : Colors.black87))),
              ...categorias.map(
                (c) => PopupMenuItem(value: c, child: Text(c, style: TextStyle(color: isEscuro ? Colors.white : Colors.black87))),
              ),
            ],
            child: FilterChip(
              label: Text(
                filtroCategoria ?? "Categoria",
                style: filtroCategoria != null ? labelStyleAtivo : labelStyleInativo,
              ),
              selected: filtroCategoria != null,
              selectedColor: corVerdeApp,
              checkmarkColor: Colors.white,
              backgroundColor: isEscuro ? Colors.grey[800] : Colors.grey[200],
              onSelected: null,
            ),
          ),
      ],
    ),
  );
}

  Widget _buildOrdenacaoMenu() {
    final Map<String, String> opcoes = {
      "mais_recente": "Mais recente",
      "mais_antigo": "Mais antigo",
      "maior_valor": "Maior valor",
      "menor_valor": "Menor valor",
    };

    return PopupMenuButton<String>(
      initialValue: ordenacao,
      onSelected: (v) {
        setState(() => ordenacao = v);
        aplicarFiltros();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        child: Row(
          children: [
            Text(
              opcoes[ordenacao]!,
              style: TextStyle(
                color: corVerdeApp,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            Icon(Icons.arrow_drop_down, color: corVerdeApp, size: 20),
          ],
        ),
      ),
      itemBuilder: (context) => opcoes.entries
          .map((e) => PopupMenuItem(value: e.key, child: Text(e.value)))
          .toList(),
    );
  }
}