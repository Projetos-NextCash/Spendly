import 'package:flutter/material.dart';
import 'tela_home.dart';
import '/services/transacao_service.dart';
import 'package:app_nextcash/services/usuario_service.dart';

/// Tela de cadastro de transações financeiras com tema escuro.
class TelaTransacao extends StatefulWidget {
  const TelaTransacao({super.key});

  @override
  State<TelaTransacao> createState() => _TelaTransacaoState();
}

class _TelaTransacaoState extends State<TelaTransacao> {
  // Variáveis de estado para facilitar manutenção.
  final TextEditingController _valorController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _novaCategoriaController =
      TextEditingController();

  String _tipoSelecionado = 'Receita';
  String _categoriaSelecionada = 'Alimentação';
  String _dataAtual = "";

  @override
  void initState() {
    super.initState();

    final agora = DateTime.now();
    _dataAtual =
        "${agora.day.toString().padLeft(2, '0')}/"
        "${agora.month.toString().padLeft(2, '0')}/"
        "${agora.year}";
  }

  final List<String> _categorias = <String>[
    'Alimentação',
    'Transporte',
    'Saúde',
    'Lazer',
    'Moradia',
    'Outros',
  ];

  @override
  void dispose() {
    _valorController.dispose();
    _descricaoController.dispose();
    _novaCategoriaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color fundo = Color(0xFF0B0B0B);
    const Color cinzaCampo = Color(0xFF2A2A2A);
    const Color verde = Color(0xFF00CC44);

    return Scaffold(
      backgroundColor: fundo,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    _BackButtonHeader(),
                    SizedBox(width: 8),
                    Text(
                      'Transações',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                CampoValor(
                  controller: _valorController,
                  corFundo: cinzaCampo,
                  isDespesa: _tipoSelecionado == 'Despesa',
                ),
                const SizedBox(height: 18),
                CampoDescricao(
                  controller: _descricaoController,
                  corFundo: cinzaCampo,
                ),

                const SizedBox(height: 10),
                Text(
                  "Data: $_dataAtual",
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),

                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SelecaoTipo(
                        tipoSelecionado: _tipoSelecionado,
                        onChanged: (String novoTipo) {
                          setState(() {
                            _tipoSelecionado = novoTipo;
                          });
                        },
                        corDestaque: verde,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownCategoria(
                        categoriaAtual: _categoriaSelecionada,
                        categorias: _categorias,
                        corFundo: cinzaCampo,
                        onChanged: (String novaCategoria) {
                          setState(() {
                            _categoriaSelecionada = novaCategoria;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                if (_categoriaSelecionada == 'Outros') ...[
                  const SizedBox(height: 10),
                  TextField(
                    controller: _novaCategoriaController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Digite nova categoria",
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: cinzaCampo,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 30),
                Center(
                  child: BotaoSalvar(
                    texto: 'Salvar',
                    corFundo: verde,
                    onPressed: () async {
                      final usuarioService = UsuarioService();
                      final usuario = await usuarioService
                          .getUsuarioFromToken();
                      final idUsuario = usuario?['id'];

                      final transacaoService = TransacaoService();

                      String valor = _valorController.text
                          .replaceAll('.', '')
                          .replaceAll(',', '.');

                      if (_tipoSelecionado == 'Despesa') {
                        valor = "-$valor";
                      }

                      String descricao = _descricaoController.text;

                      String categoriaFinal = _categoriaSelecionada;

                      if (_categoriaSelecionada == 'Outros' &&
                          _novaCategoriaController.text.isNotEmpty) {
                        categoriaFinal = _novaCategoriaController.text;
                      }

                      // ISO 8601
                      final agora = DateTime.now();
                      final dataTransacao = agora.toIso8601String();

                      print("DATA ISO: $dataTransacao");

                      try {
                        await transacaoService.criarTransacao(
                          valor: valor,
                          descricao: descricao,
                          tipo: _tipoSelecionado,
                          categoria: categoriaFinal,
                          dataTransacao: dataTransacao,
                          idUsuario: idUsuario,
                        );

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => TelaHome()),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(e.toString())));
                      }
                    },
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

class _BackButtonHeader extends StatelessWidget {
  const _BackButtonHeader();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }
}

class CampoValor extends StatelessWidget {
  const CampoValor({
    super.key,
    required this.controller,
    required this.corFundo,
    required this.isDespesa,
  });

  final TextEditingController controller;
  final Color corFundo;
  final bool isDespesa;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Valor',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: TextStyle(
            color: isDespesa ? Colors.red : Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          cursorColor: const Color(0xFF00CC44),
          onChanged: (value) {
            String numbers = value.replaceAll(RegExp(r'[^0-9]'), '');

            if (numbers.isEmpty) {
              controller.text = '';
              return;
            }

            double valor = double.parse(numbers) / 100;

            controller.text = valor.toStringAsFixed(2).replaceAll('.', ',');

            controller.selection = TextSelection.fromPosition(
              TextPosition(offset: controller.text.length),
            );
          },
          decoration: InputDecoration(
            hintText: '0,00',
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: corFundo,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

class CampoDescricao extends StatelessWidget {
  const CampoDescricao({
    super.key,
    required this.controller,
    required this.corFundo,
  });

  final TextEditingController controller;
  final Color corFundo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Descrição',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: 5,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          cursorColor: const Color(0xFF00CC44),
          decoration: InputDecoration(
            filled: true,
            fillColor: corFundo,
            hintText: 'Digite uma descrição',
            hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

class SelecaoTipo extends StatelessWidget {
  const SelecaoTipo({
    super.key,
    required this.tipoSelecionado,
    required this.onChanged,
    required this.corDestaque,
  });

  final String tipoSelecionado;
  final ValueChanged<String> onChanged;
  final Color corDestaque;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        _TipoRadioTile(
          titulo: 'Receita',
          valor: 'Receita',
          groupValue: tipoSelecionado,
          onChanged: onChanged,
          corDestaque: corDestaque,
        ),
        const SizedBox(height: 2),
        _TipoRadioTile(
          titulo: 'Despesa',
          valor: 'Despesa',
          groupValue: tipoSelecionado,
          onChanged: onChanged,
          corDestaque: corDestaque,
        ),
      ],
    );
  }
}

class _TipoRadioTile extends StatelessWidget {
  const _TipoRadioTile({
    required this.titulo,
    required this.valor,
    required this.groupValue,
    required this.onChanged,
    required this.corDestaque,
  });

  final String titulo;
  final String valor;
  final String groupValue;
  final ValueChanged<String> onChanged;
  final Color corDestaque;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(valor),
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          Radio<String>(
            value: valor,
            groupValue: groupValue,
            activeColor: corDestaque,
            onChanged: (String? novoValor) {
              if (novoValor != null) {
                onChanged(novoValor);
              }
            },
          ),
          Text(
            titulo,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class DropdownCategoria extends StatelessWidget {
  const DropdownCategoria({
    super.key,
    required this.categoriaAtual,
    required this.categorias,
    required this.corFundo,
    required this.onChanged,
  });

  final String categoriaAtual;
  final List<String> categorias;
  final Color corFundo;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categoria',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: corFundo,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: categoriaAtual,
              isExpanded: true,
              dropdownColor: const Color(0xFF2A2A2A),
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white70,
              ),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              items: categorias
                  .map(
                    (String categoria) => DropdownMenuItem<String>(
                      value: categoria,
                      child: Text(categoria),
                    ),
                  )
                  .toList(),
              onChanged: (String? novaCategoria) {
                if (novaCategoria != null) {
                  onChanged(novaCategoria);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}

class BotaoSalvar extends StatelessWidget {
  const BotaoSalvar({
    super.key,
    required this.texto,
    required this.corFundo,
    required this.onPressed,
  });

  final String texto;
  final Color corFundo;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: corFundo,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          texto,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
