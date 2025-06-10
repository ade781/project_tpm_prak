import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';

class ApiService {
  static const String baseUrl =
      'https://683efa761cd60dca33ddcf51.mockapi.io/movie-app';
  static final _logger = Logger();

  static Future<List<Map<String, dynamic>>> fetchMovies(String path) async {
    final Uri url = Uri.parse('$baseUrl/$path');
    _logger.i('GET: $url');

    try {
      final response = await http.get(url);
      _logger.i("Status : ${response.statusCode}");
      _logger.t("Body : ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.cast<Map<String, dynamic>>();
      } else {
        _logger.e("Server error: ${response.statusCode}");
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      _logger.e("Error fetching data: $e");
      throw Exception("Error fetching data: $e");
    }
  }

  static Future<Map<String, dynamic>> getMoviesDetail(String id) async {
    final uri = Uri.parse('$baseUrl/$id');
    _logger.i("GET $uri");

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      _logger.i("Status : ${response.statusCode}");
      _logger.t("Body : ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonMap = json.decode(response.body);
        debugPrint("Response: $jsonMap");
        return jsonMap;
      } else {
        _logger.e("Server error: ${response.statusCode}");
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      _logger.e("Error fetching data: $e");
      throw Exception("Error fetching data: $e");
    }
  }

}
