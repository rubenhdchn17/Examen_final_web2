import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/review.dart';

class ReviewService {
  final String baseUrl = 'http://criticasapp.pythonanywhere.com';

  Future<List<Review>> fetchReviews(int sitioId) async {
    final response = await http.get(Uri.parse('$baseUrl?siteId=$sitioId'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((json) => Review.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load reviews');
    }
  }

  Future<void> createReview(Review review) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/reviews'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'contenido': review.contenido,
        'calificacion': review.calificacion,
        'id_usuario': review.idUsuario,
        'id_sitio': review.idSitio,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create review');
    }
  }
}
