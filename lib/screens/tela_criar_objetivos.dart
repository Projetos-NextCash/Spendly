import 'package:flutter/material.dart';
import 'package:app_nextcash/services/objetivo_service.dart';
import 'package:app_nextcash/services/usuario_service.dart';
import 'package:intl/intl.dart';

class TelaCriarObjetivos extends StatefulWidget {
  const TelaCriarObjetivos({super.key});

  @override
  State<TelaCriarObjetivos> createState() => _TelaCriarObjetivosState();
}

class _TelaCriarObjetivosState extends State<TelaCriarObjetivos> {
  final _valorController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _dataInicioController = TextEditingController();
  final _dataLimiteController = TextEditingController();

  final _objetivoService = ObjetivoService();
  final _usuarioService = UsuarioService();

  String _dataInicioIso = "";
  String _dataLimiteIso = "";
  String? _idObjetivoEdicao;
  bool _estaCarregando = false;

  @override
  void initState() {
    super.initState();
    _configurarDataInicial();
  }

  void _configurarDataInicial() {
    final agora = DateTime.now();
    _dataInicioIso = agora.toIso8601String().split('T')[0];
    _dataInicioController.text = DateFormat('dd/MM/yyyy').format(agora);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _carregarDadosEdicao();
  }

  void _carregarDadosEdicao() {
    final argumento = ModalRoute.of(context)?.settings.arguments;

    if (argumento != null && argumento is Map<String, dynamic> && _idObjetivoEdicao == null) {
      _idObjetivoEdicao = argumento['id'].toString();
      _descricaoController.text = argumento['descricao'] ?? "";

      double valorMeta = double.tryParse(argumento['valor_meta'].toString()) ?? 0.0;
      _valorController.text = valorMeta.toStringAsFixed(2).replaceAll('.', ',');

      if (argumento['data_inicio'] != null) {
        _dataInicioIso = argumento['data_inicio'];
        _dataInicioController.text = _formatarDataIsoParaBr(_dataInicioIso);
      }

      if (argumento['data_limite'] != null) {
        _dataLimiteIso = argumento['data_limite'];
        _dataLimiteController.text = _formatarDataIsoParaBr(_dataLimiteIso);
      }
    }
  }

  String _formatarDataIsoParaBr(String iso) {
    try {
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(iso));
    } catch (_) {
      return iso;
    }
  }

  @override
  void dispose() {
    _valorController.dispose();
    _descricaoController.dispose();
    _dataInicioController.dispose();
    _dataLimiteController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData(bool isInicio) async {
    final tema = Theme.of(context);

    final DateTime? colhida = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: tema.copyWith(
            colorScheme: tema.colorScheme.copyWith(
              primary: tema.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (colhida != null) {
      String dataBr = DateFormat('dd/MM/yyyy').format(colhida);
      String dataIso = colhida.toIso8601String().split('T')[0];

      setState(() {
        if (isInicio) {
          _dataInicioController.text = dataBr;
          _dataInicioIso = dataIso;
        } else {
          _dataLimiteController.text = dataBr;
          _dataLimiteIso = dataIso;
        }
      });
    }
  }

  Future<void> _salvarObjetivo() async {
    final descricao = _descricaoController.text.trim();
    final valorTexto = _valorController.text.trim();

    if (descricao.isEmpty || valorTexto.isEmpty) {
      _mostrarAlerta("Preencha todos os campos");
      return;
    }

    setState(() => _estaCarregando = true);

    try {
      String valorLimpo = valorTexto.replaceAll('.', '').replaceAll(',', '.');

      if (_idObjetivoEdicao != null) {
        await _objetivoService.atualizarObjetivo(
          id: _idObjetivoEdicao!,
          descricao: descricao,
          valorMeta: valorLimpo,
          dataInicio: _dataInicioIso,
          dataLimite: _dataLimiteIso.isEmpty ? null : _dataLimiteIso,
        );
      } else {
        final usuario = await _usuarioService.getUsuarioFromToken();
        if (usuario == null) throw Exception("Sessão expirada");

        await _objetivoService.criarObjetivo(
          idUsuario: usuario["id"].toString(),
          descricao: descricao,
          valorMeta: valorLimpo,
          dataInicio: _dataInicioIso,
          dataLimite: _dataLimiteIso.isEmpty ? null : _dataLimiteIso,
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
      
    } catch (_) {
      _mostrarAlerta("Erro ao salvar objetivo");
    } finally {
      if (mounted) setState(() => _estaCarregando = false);
    }
  }

  void _mostrarAlerta(String mensagem, {bool sucesso = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: sucesso ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final isEscuro = tema.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: tema.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: tema.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _idObjetivoEdicao != null ? 'Editar Objetivo' : 'Novo Objetivo',
          style: TextStyle(
            color: tema.colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: _estaCarregando
            ? Center(child: CircularProgressIndicator(color: tema.primaryColor))
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                child: Column(
                  children: [
                    _CampoFormulario(
                      label: 'Valor da Meta',
                      controller: _valorController,
                      prefixText: 'R\$ ',
                      isMoeda: true,
                    ),

                    const SizedBox(height: 20),

                    _CampoFormulario(
                      label: 'Descrição',
                      hint: 'Ex: Viagem de férias',
                      controller: _descricaoController,
                      maxLines: 2,
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: _CampoDataSeletor(
                            label: 'Início',
                            controller: _dataInicioController,
                            onTap: () => _selecionarData(true),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _CampoDataSeletor(
                            label: 'Prazo Limite',
                            controller: _dataLimiteController,
                            onTap: () => _selecionarData(false),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    _BotaoAcaoObjetivo(
                      texto: _idObjetivoEdicao != null ? 'Salvar Alterações' : 'Criar Objetivo',
                      onPressed: _salvarObjetivo,
                      cor: tema.primaryColor,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _CampoFormulario extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? prefixText;
  final int maxLines;
  final bool isMoeda;

  const _CampoFormulario({
    required this.label,
    required this.controller,
    this.hint,
    this.keyboardType,
    this.prefixText,
    this.maxLines = 1,
    this.isMoeda = false,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final isDark = tema.brightness == Brightness.dark;

    final bg = isDark ? Colors.grey[850] : Colors.grey[100];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: tema.textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 8),

        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,

          // 💰 mantém sua lógica de moeda intacta
          onChanged: isMoeda
              ? (value) {
                  String numbers = value.replaceAll(RegExp(r'[^0-9]'), '');
                  if (numbers.isEmpty) {
                    controller.text = '';
                    return;
                  }

                  double valor = double.parse(numbers) / 100;

                  controller.text =
                      valor.toStringAsFixed(2).replaceAll('.', ',');

                  controller.selection = TextSelection.fromPosition(
                    TextPosition(offset: controller.text.length),
                  );
                }
              : null,

          style: TextStyle(
            color: tema.textTheme.bodyLarge?.color,
            fontWeight: FontWeight.w500,
          ),

          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefixText,

            filled: true,
            fillColor: bg,

            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _CampoDataSeletor extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final VoidCallback onTap;

  const _CampoDataSeletor({required this.label, required this.controller, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isEscuro = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: IgnorePointer(
            child: TextField(
              controller: controller,
              readOnly: true,
              decoration: InputDecoration(
                suffixIcon: const Icon(Icons.calendar_today, size: 18),
                filled: true,
                fillColor: isEscuro ? const Color(0xFF2B2B2B) : Colors.grey[200],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BotaoAcaoObjetivo extends StatelessWidget {
  final String texto;
  final VoidCallback onPressed;
  final Color cor;

  const _BotaoAcaoObjetivo({required this.texto, required this.onPressed, required this.cor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: cor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: Text(texto, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}