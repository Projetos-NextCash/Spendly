import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'tela_home.dart';
import '/services/transacao_service.dart';
import 'package:app_nextcash/services/usuario_service.dart';

class TelaTransacao extends StatefulWidget {
  const TelaTransacao({super.key});

  @override
  State<TelaTransacao> createState() => _TelaTransacaoState();
}

class _TelaTransacaoState extends State<TelaTransacao> {
  final TextEditingController _valorController = TextEditingController(
    text: "R\$ 0,00",
  );
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _novaCategoriaController =
      TextEditingController();

  String _tipoSelecionado = 'Receita'; // 'Receita' = Entrada, 'Despesa' = Saída
  String _categoriaSelecionada = 'Alimentação';
  double _valorNumerico = 0.0;
  bool _carregandoCategorias = true;

  final Color corVerdeApp = const Color(0xFF00C853);

  // Lista base padrão do app
  final List<String> _categorias = [
    'Alimentação',
    'Transporte',
    'Saúde',
    'Lazer',
    'Moradia',
    'Outros',
  ];

  @override
  void initState() {
    super.initState();
    _carregarCategoriasDoUsuario();
  }

  // Busca o histórico e adiciona novas categorias dinamicamente
  Future<void> _carregarCategoriasDoUsuario() async {
    try {
      final usuario = await UsuarioService().getUsuarioFromToken();
      if (usuario != null) {
        final uid = usuario["id"].toString();
        final dados = await TransacaoService().listarTransacoes(uid);
        final listaTransacoes = dados["transacoes"] ?? [];

        final Set<String> categoriasEncontradas = {};

        for (var t in listaTransacoes) {
          if (t["categoria"] != null &&
              t["categoria"].toString().trim().isNotEmpty) {
            categoriasEncontradas.add(t["categoria"].toString().trim());
          }
        }

        if (mounted) {
          setState(() {
            // Remove 'Outros' temporariamente para inseri-lo sempre no final da lista
            _categorias.remove('Outros');

            for (var cat in categoriasEncontradas) {
              if (!_categorias.contains(cat)) {
                _categorias.add(cat);
              }
            }

            // Garante que 'Outros' continue sendo a última opção
            _categorias.add('Outros');

            // Valida se a categoria atualmente selecionada ainda existe na lista reconstruída
            if (!_categorias.contains(_categoriaSelecionada)) {
              _categoriaSelecionada = _categorias.first;
            }

            _carregandoCategorias = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Erro ao carregar categorias personalizadas: $e");
      if (mounted) {
        setState(() => _carregandoCategorias = false);
      }
    }
  }

  void _atualizarValor(String value) {
    String cleanString = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanString.isEmpty) cleanString = '0';
    double valor = double.parse(cleanString) / 100;
    _valorNumerico = valor;

    setState(() {
      _valorController.value = TextEditingValue(
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
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final isDark = tema.brightness == Brightness.dark;
    final inputColor = isDark ? const Color(0xFF212121) : Colors.grey[200];

    return Scaffold(
      backgroundColor: tema.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Movimentação",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Valor"),
            TextField(
              controller: _valorController,
              keyboardType: TextInputType.number,
              onChanged: _atualizarValor,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: _tipoSelecionado == 'Despesa'
                    ? Colors.redAccent
                    : corVerdeApp,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: inputColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 20),
              ),
            ),

            const SizedBox(height: 24),

            _buildLabel("Descrição"),
            TextField(
              controller: _descricaoController,
              maxLines: 3,
              decoration: _inputDecoration("Digite uma descrição", inputColor!),
            ),

            const SizedBox(height: 24),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Tipo"),
                      _buildBotaoTipo(
                        "Entrada",
                        "Receita",
                        Icons.add_circle_outline,
                      ),
                      const SizedBox(height: 8),
                      _buildBotaoTipo(
                        "Saída",
                        "Despesa",
                        Icons.remove_circle_outline,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Categoria"),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        height: 48,
                        decoration: BoxDecoration(
                          color: inputColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _carregandoCategorias
                            ? const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _categoriaSelecionada,
                                  isExpanded: true,
                                  dropdownColor: isDark
                                      ? const Color(0xFF2B2B2B)
                                      : Colors.white,
                                  items: _categorias
                                      .map(
                                        (c) => DropdownMenuItem(
                                          value: c,
                                          child: Text(c),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) {
                                    setState(() {
                                      _categoriaSelecionada = v!;
                                    });
                                  },
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (_categoriaSelecionada == 'Outros') ...[
              const SizedBox(height: 20),
              _buildLabel("Nova Categoria"),
              TextField(
                controller: _novaCategoriaController,
                textCapitalization: TextCapitalization.sentences,
                decoration: _inputDecoration(
                  "Qual o nome da nova categoria?",
                  inputColor,
                ),
              ),
            ],

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: _salvar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: corVerdeApp,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Adicionar",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String texto) => Padding(
    padding: const EdgeInsets.only(bottom: 8, left: 4),
    child: Text(
      texto,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
        color: Colors.grey,
      ),
    ),
  );

  Widget _buildBotaoTipo(String label, String value, IconData icone) {
    final selecionado = _tipoSelecionado == value;
    final cor = value == "Receita" ? corVerdeApp : Colors.redAccent;

    return GestureDetector(
      onTap: () => setState(() => _tipoSelecionado = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: selecionado ? cor.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selecionado ? cor : Colors.grey.withOpacity(0.3),
            width: selecionado ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icone, size: 18, color: selecionado ? cor : Colors.grey),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selecionado
                    ? (Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black)
                    : Colors.grey,
                fontWeight: selecionado ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, Color fill) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: fill,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.all(16),
  );

  Future<void> _salvar() async {
    if (_valorNumerico == 0) return;

    final usuario = await UsuarioService().getUsuarioFromToken();
    final idUsuario = usuario?['id'];

    String valorFinal = _tipoSelecionado == 'Despesa'
        ? (-_valorNumerico).toString()
        : _valorNumerico.toString();

    String categoriaFinal = _categoriaSelecionada;

    if (_categoriaSelecionada == 'Outros' &&
        _novaCategoriaController.text.trim().isNotEmpty) {
      categoriaFinal = _novaCategoriaController.text.trim();
    }

    try {
      await TransacaoService().criarTransacao(
        valor: valorFinal,
        descricao: _descricaoController.text,
        tipo: _tipoSelecionado,
        categoria: categoriaFinal,
        dataTransacao: DateTime.now().toIso8601String(),
        idUsuario: idUsuario,
      );

      if (!mounted) return;

      Navigator.pop(context, {
        "sucesso": true,
        "mensagem": "Movimentação realizada com sucesso!",
      });
    } catch (e) {
      if (!mounted) return;

      Navigator.pop(context, {
        "sucesso": false,
        "mensagem": "Erro ao realizar movimentação.",
      });
    }
  }
}
