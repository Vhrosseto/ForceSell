import 'dart:convert';
import 'package:http/http.dart' as http;

class CepService {
  static const String _baseUrl = 'https://viacep.com.br/ws';

  static Future<Map<String, dynamic>?> buscarCep(String cep) async {
    try {
      // Remove caracteres não numéricos do CEP
      cep = cep.replaceAll(RegExp(r'[^0-9]'), '');

      if (cep.length != 8) {
        throw Exception('CEP deve conter 8 dígitos');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/$cep/json/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Verifica se o CEP foi encontrado
        if (data['erro'] != null) {
          return null;
        }

        return {
          'cep': data['cep'],
          'endereco': data['logradouro'],
          'bairro': data['bairro'],
          'cidade': data['localidade'],
          'uf': data['uf'],
        };
      } else {
        throw Exception('Erro ao consultar CEP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao consultar CEP: $e');
    }
  }

  static bool validarCep(String cep) {
    cep = cep.replaceAll(RegExp(r'[^0-9]'), '');
    return cep.length == 8;
  }

  static String formatarCep(String cep) {
    cep = cep.replaceAll(RegExp(r'[^0-9]'), '');
    if (cep.length == 8) {
      return '${cep.substring(0, 5)}-${cep.substring(5)}';
    }
    return cep;
  }
}
