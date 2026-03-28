import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class LocalStorage {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // ==========================
  // KEYS
  // ==========================
  static const String _keyUsuario = "usuario";
  static const String _keyToken = "jwt";

  // ==========================
  // USUÁRIO
  // ==========================
  static Future<void> salvarUsuario(Map<String, dynamic> usuario) async {
    await _storage.write(
      key: _keyUsuario,
      value: jsonEncode(usuario),
    );
  }

  static Future<Map<String, dynamic>?> getUsuario() async {
    final data = await _storage.read(key: _keyUsuario);

    if (data == null) return null;

    try {
      return jsonDecode(data);
    } catch (e) {
      return null;
    }
  }

  static Future<void> removerUsuario() async {
    await _storage.delete(key: _keyUsuario);
  }

  // ==========================
  // TOKEN (JWT)
  // ==========================
  static Future<void> salvarToken(String token) async {
    await _storage.write(
      key: _keyToken,
      value: token,
    );
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  static Future<void> removerToken() async {
    await _storage.delete(key: _keyToken);
  }

  // ==========================
  // SESSÃO (COMPLETO)
  // ==========================
  static Future<void> salvarSessao({
    required Map<String, dynamic> usuario,
    required String token,
  }) async {
    await salvarUsuario(usuario);
    await salvarToken(token);
  }

  static Future<void> limparSessao() async {
    await removerUsuario();
    await removerToken();
  }

  // ==========================
  // VERIFICAÇÕES
  // ==========================
  static Future<bool> isLogado() async {
    final token = await getToken();
    return token != null;
  }
}