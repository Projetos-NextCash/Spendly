import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const _tokenKey = "token";
  static const _usuarioKey = "usuario";

  static const _primeiroAcessoKey = "primeiro_acesso";

static Future<bool> deveMostrarBoasVindas() async {
  final prefs = await SharedPreferences.getInstance();

  return prefs.getBool(_primeiroAcessoKey) ?? true;
}

static Future<void> marcarBoasVindasComoVista() async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.setBool(_primeiroAcessoKey, false);
}

  // salvar sessão
  static Future<void> salvarSessao({
    required Map<String, dynamic> usuario,
    required String token,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_tokenKey, token);
    await prefs.setString(
      _usuarioKey,
      jsonEncode(usuario),
    );
  }

  // pegar token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(_tokenKey);
  }

  // pegar usuário
  static Future<Map<String, dynamic>?> getUsuario() async {
    final prefs = await SharedPreferences.getInstance();

    final usuarioJson = prefs.getString(_usuarioKey);

    if (usuarioJson == null) return null;

    return jsonDecode(usuarioJson);
  }

  // limpar sessão
   static Future<void> limparSessao() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_tokenKey);
    await prefs.remove(_usuarioKey);
  }

  // verificar login
  static Future<bool> estaLogado() async {
    final token = await getToken();

    return token != null;
  }
}