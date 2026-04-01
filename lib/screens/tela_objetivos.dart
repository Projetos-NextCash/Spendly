import 'package:flutter/material.dart';

/// Tela de cadastro de objetivo financeiro em tema escuro.
///
/// Para usar rapidamente no app:
/// `home: const TelaObjetivos(),`
class TelaObjetivos extends StatefulWidget {
  const TelaObjetivos({super.key});

  @override
  State<TelaObjetivos> createState() => _TelaObjetivosState();
}

class _TelaObjetivosState extends State<TelaObjetivos> {
  // Variáveis para facilitar manutenção e futuras integrações.
  final TextEditingController _valorController =
      TextEditingController(text: 'R\$ 0,00');
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _dataInicioController =
      TextEditingController(text: '01/03/2026');
  final TextEditingController _dataLimiteController =
      TextEditingController(text: '30/12/2026');

  @override
  void dispose() {
    _valorController.dispose();
    _descricaoController.dispose();
    _dataInicioController.dispose();
    _dataLimiteController.dispose();
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
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Objetivo Financeiro',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                CampoValorObjetivo(
                  controller: _valorController,
                  corFundo: cinzaCampo,
                ),
                const SizedBox(height: 18),
                CampoDescricaoObjetivo(
                  controller: _descricaoController,
                  corFundo: cinzaCampo,
                ),
                const SizedBox(height: 18),
                CamposDataObjetivo(
                  dataInicioController: _dataInicioController,
                  dataLimiteController: _dataLimiteController,
                  corFundo: cinzaCampo,
                ),
                const SizedBox(height: 30),
                Center(
                  child: BotaoAcaoObjetivo(
                    texto: 'Gravar',
                    corFundo: verde,
                    onPressed: () {
                      // TODO: integrar persistência do objetivo.
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

class CampoValorObjetivo extends StatelessWidget {
  const CampoValorObjetivo({
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
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          cursorColor: const Color(0xFF00CC44),
          decoration: InputDecoration(
            filled: true,
            fillColor: corFundo,
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

class CampoDescricaoObjetivo extends StatelessWidget {
  const CampoDescricaoObjetivo({
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
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
          cursorColor: const Color(0xFF00CC44),
          decoration: InputDecoration(
            filled: true,
            fillColor: corFundo,
            hintText: 'Digite a descrição do objetivo',
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

class CamposDataObjetivo extends StatelessWidget {
  const CamposDataObjetivo({
    super.key,
    required this.dataInicioController,
    required this.dataLimiteController,
    required this.corFundo,
  });

  final TextEditingController dataInicioController;
  final TextEditingController dataLimiteController;
  final Color corFundo;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CampoDataObjetivo(
            label: 'Data Início',
            controller: dataInicioController,
            corFundo: corFundo,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CampoDataObjetivo(
            label: 'Data Limite',
            controller: dataLimiteController,
            corFundo: corFundo,
          ),
        ),
      ],
    );
  }
}

class CampoDataObjetivo extends StatelessWidget {
  const CampoDataObjetivo({
    super.key,
    required this.label,
    required this.controller,
    required this.corFundo,
  });

  final String label;
  final TextEditingController controller;
  final Color corFundo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: corFundo,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
            cursorColor: const Color(0xFF00CC44),
            decoration: const InputDecoration(
              suffixIcon: Icon(Icons.calendar_today, color: Colors.white70, size: 18),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class BotaoAcaoObjetivo extends StatelessWidget {
  const BotaoAcaoObjetivo({
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
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

