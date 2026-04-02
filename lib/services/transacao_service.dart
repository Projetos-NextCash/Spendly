import 'package:supabase_flutter/supabase_flutter.dart';

class TransacaoService {
  final supabase = Supabase.instance.client;

  // ==========================
  // CRIAR TRANSAÇÃO
  // ==========================
  Future<Map<String, dynamic>> criarTransacao({
    required String descricao,
    required dynamic valor,
    required String categoria,
    required String tipo,
    required String dataTransacao,
    required String idUsuario,
  }) async {
    try {
      if (descricao.isEmpty ||
          valor == null ||
          categoria.isEmpty ||
          tipo.isEmpty ||
          dataTransacao.isEmpty ||
          idUsuario.isEmpty) {
        throw Exception("Por favor preencha todos os campos");
      }

      // 🔥 NORMALIZAR VALOR
      String valorNormalizado = valor.toString().trim();

      if (valorNormalizado.contains(",") &&
          valorNormalizado.contains(".")) {
        valorNormalizado =
            valorNormalizado.replaceAll(".", "").replaceAll(",", ".");
      } else if (valorNormalizado.contains(",")) {
        valorNormalizado = valorNormalizado.replaceAll(",", ".");
      }

      final valorNumerico = double.tryParse(valorNormalizado);

      if (valorNumerico == null) {
        throw Exception("Valor inválido");
      }

      final valorCerto = tipo == "Despesa"
          ? -valorNumerico.abs()
          : valorNumerico.abs();

      // 🔍 VERIFICAR DUPLICIDADE
      final existente = await supabase
          .from("transacao")
          .select()
          .eq("descricao", descricao)
          .eq("valor", valorCerto)
          .eq("categoria", categoria)
          .eq("tipo", tipo)
          .eq("data_transacao", dataTransacao)
          .eq("id_usuario", idUsuario);

      if (existente.isNotEmpty) {
        throw Exception("Transação já cadastrada");
      }

      // 💾 INSERIR
      final data = await supabase.from("transacao").insert({
        "descricao": descricao,
        "valor": valorCerto,
        "categoria": categoria,
        "tipo": tipo,
        "data_transacao": dataTransacao,
        "id_usuario": idUsuario,
      }).select();

      return {
        "message": "Transação criada com sucesso",
        "transacao": data[0],
      };
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // ==========================
  // LISTAR TRANSAÇÕES
  // ==========================
  Future<Map<String, dynamic>> listarTransacoes(String idUsuario) async {
    try {
      final data = await supabase
          .from("transacao")
          .select()
          .eq("id_usuario", idUsuario);

      // 💰 CALCULAR SALDO
      double saldo = 0;

      for (var t in data) {
        saldo += (t['valor'] as num).toDouble();
      }

      return {
        "message": "Transações listadas com sucesso",
        "transacoes": data,
        "saldo": saldo,
      };
    } catch (e) {
      throw Exception("Erro ao listar transações");
    }
  }

  // ==========================
  // APAGAR TRANSAÇÃO
  // ==========================
  Future<Map<String, dynamic>> apagarTransacao(String id) async {
    try {
      final data = await supabase
          .from("transacao")
          .delete()
          .eq("id", id)
          .select();

      return {
        "message": "Transação apagada com sucesso",
        "transacao": data,
      };
    } catch (e) {
      throw Exception("Erro ao apagar transação");
    }
  }

  // ==========================
  // ATUALIZAR TRANSAÇÃO
  // ==========================
  Future<Map<String, dynamic>> atualizarTransacao({
    required String id,
    String? descricao,
    dynamic valor,
    String? categoria,
    String? tipo,
    String? dataTransacao,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (descricao != null) updateData['descricao'] = descricao;
      if (categoria != null) updateData['categoria'] = categoria;
      if (tipo != null) updateData['tipo'] = tipo;
      if (dataTransacao != null) {
        updateData['data_transacao'] = dataTransacao;
      }

      // 💰 TRATAR VALOR
      if (valor != null) {
        final valorNum = double.tryParse(valor.toString());

        if (valorNum == null) {
          throw Exception("Valor inválido");
        }

        final valorFinal = tipo == "Despesa"
            ? -valorNum.abs()
            : valorNum.abs();

        updateData['valor'] = valorFinal;
      }

      final data = await supabase
          .from("transacao")
          .update(updateData)
          .eq("id", id)
          .select();

      return {
        "message": "Transação atualizada",
        "transacao": data[0],
      };
    } catch (e) {
      throw Exception("Erro ao atualizar transação");
    }
  }
}