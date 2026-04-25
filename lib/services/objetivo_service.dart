import 'package:supabase_flutter/supabase_flutter.dart';

class ObjetivoService {
  final supabase = Supabase.instance.client;

  // ==========================
  // CRIAR OBJETIVO
  // ==========================
  Future<Map<String, dynamic>> criarObjetivo({
    required String idUsuario,
    required String descricao,
    required dynamic valorMeta,
    dynamic valorAtual,
    String? dataInicio,
    String? dataLimite,
  }) async {
    try {
      if (idUsuario.isEmpty ||
          descricao.isEmpty ||
          valorMeta == null) {
        throw Exception("Campos obrigatórios faltando");
      }

      final meta = double.tryParse(valorMeta.toString());
      final atual =
          valorAtual != null ? double.tryParse(valorAtual.toString()) : 0;

      if (meta == null) {
        throw Exception("Valor meta inválido");
      }

      final data = await supabase
          .from("objetivo_financeiro")
          .insert({
            "id_usuario": idUsuario,
            "descricao": descricao,
            "valor_meta": meta,
            "valor_atual": atual ?? 0,
            "data_inicio": dataInicio,
            "data_limite": dataLimite,
          })
          .select();

      return {
        "success": true,
        "message": "Objetivo criado com sucesso",
        "objetivo": data[0],
      };
    } catch (e) {
      throw Exception("Erro ao criar objetivo: ${e.toString()}");
    }
  }

  // ==========================
  // LISTAR OBJETIVOS
  // ==========================
  Future<Map<String, dynamic>> listarObjetivos(
      String idUsuario) async {
    try {
      if (idUsuario.isEmpty) {
        throw Exception("id_usuario é obrigatório");
      }

      final data = await supabase
          .from("objetivo_financeiro")
          .select()
          .eq("id_usuario", idUsuario)
          .order("data_inicio", ascending: false);

      return {
        "success": true,
        "objetivos": data,
        "total": data.length,
      };
    } catch (e) {
      throw Exception("Erro ao listar objetivos");
    }
  }

  // ==========================
  // ATUALIZAR OBJETIVO
  // ==========================
  Future<Map<String, dynamic>> atualizarObjetivo({
    required String id,
    String? descricao,
    dynamic valorMeta,
    dynamic valorAtual,
    String? dataInicio,
    String? dataLimite,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (descricao != null) updateData['descricao'] = descricao;

      if (valorMeta != null) {
        final meta = double.tryParse(valorMeta.toString());
        if (meta == null) throw Exception("Valor meta inválido");
        updateData['valor_meta'] = meta;
      }

      if (valorAtual != null) {
        final atual = double.tryParse(valorAtual.toString());
        if (atual == null) throw Exception("Valor atual inválido");
        updateData['valor_atual'] = atual;
      }

      if (dataInicio != null) updateData['data_inicio'] = dataInicio;
      if (dataLimite != null) updateData['data_limite'] = dataLimite;

      final data = await supabase
          .from("objetivo_financeiro")
          .update(updateData)
          .eq("id", id)
          .select();

      if (data.isEmpty) {
        throw Exception("Objetivo não encontrado");
      }

      return {
        "success": true,
        "message": "Objetivo atualizado com sucesso",
        "objetivo": data[0],
      };
    } catch (e) {
      throw Exception("Erro ao atualizar objetivo");
    }
  }

  // ==========================
  // DELETAR OBJETIVO
  // ==========================
  Future<Map<String, dynamic>> deletarObjetivo(
      String id) async {
    try {
      await supabase
          .from("objetivo_financeiro")
          .delete()
          .eq("id", id);

      return {
        "success": true,
        "message": "Objetivo deletado com sucesso",
      };
    } catch (e) {
      throw Exception("Erro ao deletar objetivo");
    }
  }

  // ==========================
  // OBTER OBJETIVO
  // ==========================
  Future<Map<String, dynamic>> obterObjetivo(
      String id) async {
    try {
      final data = await supabase
          .from("objetivo_financeiro")
          .select()
          .eq("id", id)
          .maybeSingle();

      if (data == null) {
        throw Exception("Objetivo não encontrado");
      }

      return {
        "success": true,
        "objetivo": data,
      };
    } catch (e) {
      throw Exception("Erro ao obter objetivo");
    }
  }
}