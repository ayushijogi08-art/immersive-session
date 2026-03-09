import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/ambience.dart';

class AmbienceRepository {
  Future<List<Ambience>> getAmbiences() async {
    try {
      // Load the JSON string from assets
      final String response = await rootBundle.loadString('assets/data/ambiences.json');
      final List<dynamic> data = json.decode(response);
      
      // Map JSON array to a List of Ambience objects
      return data.map((json) => Ambience.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load ambiences: $e');
    }
  }
}