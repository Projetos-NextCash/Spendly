import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import '../storage/local_storage.dart' as local;

class UsuarioService {
  final supabase = Supabase.instance.client;

  final String jwtSecret = "Spendly_API_SECRET_2026";

  // ==========================
  // CADASTRAR
  // ==========================
  Future<Map<String, dynamic>> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    if (nome.isEmpty || email.isEmpty || senha.isEmpty) {
      throw Exception("Por favor preencha todos os campos");
    }

    final existente = await supabase
        .from('usuarios')
        .select()
        .eq('email', email);

    if (existente.isNotEmpty) {
      throw Exception("Usuário já cadastrado");
    }

    final senhaHash = BCrypt.hashpw(senha, BCrypt.gensalt());

    final response = await supabase.from('usuarios').insert({
      "nome": nome,
      "email": email,
      "senha": senhaHash,
    }).select();

    return {
      "message": "Usuário cadastrado com sucesso",
      "usuario": response,
    };
  }

  // ==========================
  // LOGIN
  // ==========================
  Future<Map<String, dynamic>> login({
    required String email,
    required String senha,
  }) async {
    if (email.isEmpty || senha.isEmpty) {
      throw Exception("Informe email e senha");
    }

    final usuario = await supabase
        .from('usuarios')
        .select()
        .eq('email', email)
        .maybeSingle();

    if (usuario == null) {
      throw Exception("Email ou senha incorretos");
    }

    final senhaValida = BCrypt.checkpw(senha, usuario['senha']);

    if (!senhaValida) {
      throw Exception("Email ou senha incorretos");
    }

    usuario.remove('senha');

    // 🔥 JWT MELHORADO (mais completo)
    final jwt = JWT({
      'id': usuario['id'],
      'email': usuario['email'],
      'nome': usuario['nome'],
    });

    final token = jwt.sign(
      SecretKey(jwtSecret),
      expiresIn: const Duration(hours: 2),
    );

    // ✅ salva usando LocalStorage
    await local.LocalStorage.salvarSessao(
      usuario: usuario,
      token: token,
    );

    return {
      "token": token,
      "usuario": usuario,
    };
  }

  // ==========================
  // ATUALIZAR
  // ==========================
  Future<Map<String, dynamic>> atualizar({
    required String id,
    String? nome,
    String? email,
    String? senha,
  }) async {
    final usuarioExistente = await supabase
        .from('usuarios')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (usuarioExistente == null) {
      throw Exception("Usuário não encontrado");
    }

    final dadosAtualizados = <String, dynamic>{};

    if (nome != null) dadosAtualizados['nome'] = nome;
    if (email != null) dadosAtualizados['email'] = email;

    if (senha != null) {
      dadosAtualizados['senha'] =
          BCrypt.hashpw(senha, BCrypt.gensalt());
    }

    if (dadosAtualizados.isEmpty) {
      throw Exception("Nenhum dado para atualizar");
    }

    final response = await supabase
        .from('usuarios')
        .update(dadosAtualizados)
        .eq('id', id)
        .select();

    return {
      "message": "Usuário atualizado com sucesso",
      "usuario": response,
    };
  }

  // ==========================
  // RECUPERAR SENHA
  // ==========================
  Future<Map<String, dynamic>> recuperarSenha({
    required String email,
    required String senha,
  }) async {
    final usuario = await supabase
        .from('usuarios')
        .select()
        .eq('email', email)
        .maybeSingle();

    if (usuario == null) {
      throw Exception("Email não encontrado");
    }

    final senhaHash = BCrypt.hashpw(senha, BCrypt.gensalt());

    await supabase
        .from('usuarios')
        .update({"senha": senhaHash})
        .eq('email', email);

    return {
      "message": "Senha atualizada com sucesso",
    };
  }

  // ==========================
  // BUSCAR POR ID
  // ==========================
  Future<Map<String, dynamic>> buscarPorId(String id) async {
    final usuario = await supabase
        .from('usuarios')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (usuario == null) {
      throw Exception("Usuário não encontrado");
    }

    return {"usuario": usuario};
  }

  // ==========================
  // DELETAR
  // ==========================
  Future<Map<String, dynamic>> deletar(String id) async {
    final usuarioExistente = await supabase
        .from('usuarios')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (usuarioExistente == null) {
      throw Exception("Usuário não encontrado");
    }

    await supabase.from('usuarios').delete().eq('id', id);

    return {
      "message": "Usuário deletado com sucesso",
    };
  }

  // ==========================
  // USUÁRIO PELO TOKEN
  // ==========================
  Future<Map<String, dynamic>?> getUsuarioFromToken() async {
    final token = await local.LocalStorage.getToken();

    if (token == null) return null;

    try {
      final jwt = JWT.verify(token, SecretKey(jwtSecret));
      return jwt.payload;
    } catch (e) {
      return null;
    }
  }

  // ==========================
  // LOGOUT
  // ==========================
  Future<void> logout() async {
    await local.LocalStorage.limparSessao();
  }
}