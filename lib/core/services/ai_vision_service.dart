import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AiAnalysisResult {
  final String artist;
  final String title;
  final String genre;
  final int year;
  
  AiAnalysisResult({
    required this.artist,
    required this.title,
    required this.genre,
    required this.year,
  });

  factory AiAnalysisResult.fromJson(Map<String, dynamic> json) {
    return AiAnalysisResult(
      artist: json['artist'] ?? 'Unknown Artist',
      title: json['album_title'] ?? 'Unknown Title',
      genre: json['genre'] ?? 'Unknown',
      year: json['year'] ?? 0,
    );
  }
}

class AiVisionService {
  final GenerativeModel _model;

  AiVisionService()
      : _model = GenerativeModel(
          model: 'gemini-1.5-flash', // Or gemini-2.5-flash if available
          apiKey: dotenv.env['GEMINI_API_KEY'] ?? '',
          generationConfig: GenerationConfig(
            responseMimeType: 'application/json',
          ),
        );

  Future<AiAnalysisResult?> analyzeVinylCover(XFile imageFile) async {
    try {
      if (dotenv.env['GEMINI_API_KEY'] == null || dotenv.env['GEMINI_API_KEY']!.isEmpty || dotenv.env['GEMINI_API_KEY'] == 'YOUR_GEMINI_API_KEY_HERE') {
        // Fallback or early return if no API key is set
        print("Warning: Gemini API Key not set. Returning mock data.");
        await Future.delayed(const Duration(seconds: 2));
        return AiAnalysisResult(
          artist: 'Mock Artist',
          title: 'Mock Album',
          genre: 'Jazz',
          year: 2026,
        );
      }

      final bytes = await imageFile.readAsBytes();
      final prompt = TextPart('''
        Analyze this vinyl record cover. Please extract the following information and return it strictly in JSON format.
        Do not add Markdown formatting to the output, just raw JSON.
        
        Required fields:
        - "artist": The name of the artist or band.
        - "album_title": The title of the album.
        - "genre": Guess the musical genre based on the visual style (e.g., Jazz, Electronic, Rock, Ambient, Classical).
        - "year": Guess the decade or year of release based on the style, just the number (e.g., 1980, 2010).
      ''');
      
      final imagePart = DataPart('image/jpeg', bytes);
      
      final response = await _model.generateContent([
        Content.multi([prompt, imagePart])
      ]);

      if (response.text != null) {
        final rawText = response.text!.trim();
        // Sometimes it still returns with markdown block despite instructions
        String jsonString = rawText;
        if (jsonString.startsWith('```json')) {
          jsonString = jsonString.substring(7);
          if (jsonString.endsWith('```')) {
            jsonString = jsonString.substring(0, jsonString.length - 3);
          }
        } else if (jsonString.startsWith('```')) {
          jsonString = jsonString.substring(3);
          if (jsonString.endsWith('```')) {
            jsonString = jsonString.substring(0, jsonString.length - 3);
          }
        }
        
        final Map<String, dynamic> jsonData = jsonDecode(jsonString.trim());
        return AiAnalysisResult.fromJson(jsonData);
      }
      return null;
    } catch (e) {
      print('Error during AI analysis: $e');
      return null;
    }
  }
}
