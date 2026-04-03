import 'package:flutter/material.dart';
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

  String? filtroTipo; // receita / despesa
  int? filtroMes;

  @override
  void initState() {
    super.initState();
    carregarExtrato();
  }

  void abrirEditarTransacao(Map<String, dynamic> t) {
    final valorController = TextEditingController(
      text: t["valor"].abs().toStringAsFixed(2).replaceAll('.', ','),
    );

    final descricaoController = TextEditingController(
      text: t["descricao"] ?? "",
    );

    final novaCategoriaController = TextEditingController();

    String tipoSelecionado = t["valor"] < 0 ? "Despesa" : "Receita";
    String categoriaSelecionada = t["categoria"];

    const cinzaCampo = Color(0xFF2A2A2A);
    const verde = Color(0xFF00CC44);

    final categorias = [
      'Alimentação',
      'Transporte',
      'Saúde',
      'Lazer',
      'Moradia',
      'Outros',
    ];

    if (!categorias.contains(categoriaSelecionada)) {
      categorias.add(categoriaSelecionada);
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              backgroundColor: const Color(0xFF0B0B0B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Editar Transação",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // VALOR
                      TextField(
                        controller: valorController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "Valor",
                          labelStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: cinzaCampo,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // DESCRIÇÃO
                      TextField(
                        controller: descricaoController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "Descrição",
                          labelStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: cinzaCampo,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // TIPO
                      DropdownButtonFormField<String>(
                        value: tipoSelecionado,
                        dropdownColor: const Color(0xFF0B0B0B),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: cinzaCampo,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: "Receita",
                            child: Text("Receita"),
                          ),
                          DropdownMenuItem(
                            value: "Despesa",
                            child: Text("Despesa"),
                          ),
                        ],
                        onChanged: (v) {
                          setStateDialog(() {
                            tipoSelecionado = v!;
                          });
                        },
                      ),

                      const SizedBox(height: 12),

                      // CATEGORIA
                      DropdownButtonFormField<String>(
                        value: categoriaSelecionada,
                        dropdownColor: const Color(0xFF0B0B0B),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: cinzaCampo,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: categorias.map((c) {
                          return DropdownMenuItem(value: c, child: Text(c));
                        }).toList(),
                        onChanged: (v) {
                          setStateDialog(() {
                            categoriaSelecionada = v!;
                          });
                        },
                      ),

                      if (categoriaSelecionada == "Outros") ...[
                        const SizedBox(height: 12),
                        TextField(
                          controller: novaCategoriaController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Nova categoria",
                            filled: true,
                            fillColor: cinzaCampo,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                "Cancelar",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),

                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: verde,
                              ),
                              onPressed: () async {
                                final service = TransacaoService();

                                String valor = valorController.text
                                    .replaceAll('.', '')
                                    .replaceAll(',', '.');

                                if (tipoSelecionado == "Despesa") {
                                  valor = "-$valor";
                                }

                                String categoriaFinal = categoriaSelecionada;

                                if (categoriaSelecionada == "Outros" &&
                                    novaCategoriaController.text.isNotEmpty) {
                                  categoriaFinal = novaCategoriaController.text;
                                }

                                await service.atualizarTransacao(
                                  id: t["id"].toString(),
                                  valor: valor,
                                  descricao: descricaoController.text,
                                  categoria: categoriaFinal,
                                  tipo: tipoSelecionado,
                                );

                                Navigator.pop(context);
                                carregarExtrato();
                              },
                              child: const Text("Salvar"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> carregarExtrato() async {
    final usuarioService = UsuarioService();
    final token = await usuarioService.getUsuarioFromToken();

    if (token == null) return;

    final idUsuario = token["id"];
    final service = TransacaoService();
    final response = await service.listarTransacoes(idUsuario);

    final List<dynamic> transacoesRaw = response["transacoes"] ?? [];

    List<Map<String, dynamic>> lista = [];

    for (var t in transacoesRaw) {
      final data = DateTime.parse(t["data_transacao"]).toLocal();
      final valor = (t["valor"] as num).toDouble();

      lista.add({
        "id": t["id"],
        "categoria": t["categoria"],
        "descricao": t["descricao"],
        "valor": valor,
        "data": data,
      });
    }

    // ORDEM MAIS RECENTE PRIMEIRO (igual home)
    lista = lista.reversed.toList();

    setState(() {
      transacoes = lista;
      aplicarFiltros();
    });
  }

  void aplicarFiltros() {
    List<Map<String, dynamic>> lista = [...transacoes];

    // filtro tipo
    if (filtroTipo != null) {
      if (filtroTipo == "receita") {
        lista = lista.where((t) => t["valor"] > 0).toList();
      } else {
        lista = lista.where((t) => t["valor"] < 0).toList();
      }
    }

    // filtro mes
    if (filtroMes != null) {
      lista = lista.where((t) => t["data"].month == filtroMes).toList();
    }

    setState(() {
      transacoesFiltradas = lista;
    });
  }

  void limparFiltros() {
    setState(() {
      filtroTipo = null;
      filtroMes = null;
      transacoesFiltradas = [...transacoes];
    });
  }

  String _formatarValor(double v) {
    return "R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}";
  }

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return "$dia/$mes";
  }

  void _deletarTransacao(String id) async {
    final service = TransacaoService();
    await service.apagarTransacao(id);
    carregarExtrato();
  }

  @override
  Widget build(BuildContext context) {
    const fundo = Color(0xFF0B0B0B);
    const branco = Colors.white;
    const cinza = Color(0xFFBDBDBD);
    const vermelho = Color(0xFFD64545);
    const verde = Color(0xFF00CC44);

    return Scaffold(
      backgroundColor: fundo,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: branco),
                  ),
                  const Text(
                    "Extrato",
                    style: TextStyle(
                      color: branco,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // FILTROS
              Row(
                children: [
                  // filtro tipo
                  DropdownButton<String>(
                    dropdownColor: fundo,
                    hint: const Text("Tipo", style: TextStyle(color: branco)),
                    value: filtroTipo,
                    items: const [
                      DropdownMenuItem(
                        value: "receita",
                        child: Text("Receita", style: TextStyle(color: branco)),
                      ),
                      DropdownMenuItem(
                        value: "despesa",
                        child: Text("Despesa", style: TextStyle(color: branco)),
                      ),
                    ],
                    onChanged: (v) {
                      filtroTipo = v;
                      aplicarFiltros();
                    },
                  ),

                  const SizedBox(width: 20),

                  // filtro mes
                  DropdownButton<int>(
                    dropdownColor: fundo,
                    hint: const Text("Mês", style: TextStyle(color: branco)),
                    value: filtroMes,
                    items: List.generate(12, (index) {
                      final mes = index + 1;
                      return DropdownMenuItem(
                        value: mes,
                        child: Text(
                          mes.toString().padLeft(2, '0'),
                          style: const TextStyle(color: branco),
                        ),
                      );
                    }),
                    onChanged: (v) {
                      filtroMes = v;
                      aplicarFiltros();
                    },
                  ),

                  const Spacer(),

                  // limpar filtros
                  TextButton(
                    onPressed: limparFiltros,
                    child: const Text(
                      "Limpar",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Expanded(
                child: ListView.builder(
                  itemCount: transacoesFiltradas.length,
                  itemBuilder: (context, index) {
                    final t = transacoesFiltradas[index];
                    final valor = t["valor"] as double;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _formatarData(t["data"]),
                                      style: const TextStyle(
                                        color: cinza,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      t["categoria"],
                                      style: const TextStyle(
                                        color: branco,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      t["descricao"] ?? "",
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Row(
                                children: [
                                  Text(
                                    "${valor < 0 ? '-' : '+'}${_formatarValor(valor.abs())}",
                                    style: TextStyle(
                                      color: valor < 0 ? vermelho : verde,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),

                                  const SizedBox(width: 6),

                                  // BOTÃO EDITAR
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    onPressed: () => abrirEditarTransacao(t),
                                  ),

                                  // BOTÃO DELETE
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: vermelho,
                                      size: 20,
                                    ),
                                    onPressed: () =>
                                        _deletarTransacao(t["id"].toString()),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const Divider(color: Colors.white10, thickness: 1),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
