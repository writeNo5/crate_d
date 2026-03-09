import 'dart:convert';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

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
  AiVisionService();

  Future<AiAnalysisResult?> analyzeVinylCover(XFile imageFile) async {
    try {
      final apiKey = (dotenv.env['GEMINI_API_KEY'] ?? '').trim();
      if (apiKey.isEmpty || apiKey == 'YOUR_GEMINI_API_KEY_HERE') {
        print("Warning: Gemini API Key not set. Returning mock data.");
        await Future.delayed(const Duration(seconds: 2));
        return AiAnalysisResult(
          artist: 'Mock Artist',
          title: 'Mock Album',
          genre: 'Jazz',
          year: 2026,
        );
      }

      late Uint8List bytes;
      if (imageFile.path.startsWith('assets/')) {
        final byteData = await rootBundle.load(imageFile.path);
        bytes = byteData.buffer.asUint8List();
      } else {
        bytes = await imageFile.readAsBytes();
      }
      
      String mimeType = imageFile.mimeType ?? '';
      if (mimeType.isEmpty) {
        if (imageFile.name.toLowerCase().endsWith('.png') || imageFile.path.toLowerCase().endsWith('.png')) {
          mimeType = 'image/png';
        } else if (bytes.length > 4 && bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) {
          mimeType = 'image/png';
        } else {
          mimeType = 'image/jpeg';
        }
      }

      final String base64Image = base64Encode(bytes);
      
      final String promptText = '''
        Analyze this vinyl record cover. Please extract the following information and return it strictly in JSON format.
        Do not add Markdown formatting to the output, just raw JSON.
        
        Required fields:
        - "artist": The name of the artist or band.
        - "album_title": The title of the album.
        - "genre": Guess the musical genre based on the visual style (e.g., Jazz, Electronic, Rock, Ambient, Classical).
        - "year": Guess the decade or year of release based on the style, just the number (e.g., 1980, 2010).
      ''';

      final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey');
      
      final requestBody = {
        "contents": [
          {
            "parts": [
              {"text": promptText},
              {
                "inline_data": {
                  "mime_type": mimeType,
                  "data": base64Image
                }
              }
            ]
          }
        ],
        "generationConfig": {
          "responseMimeType": "application/json"
        }
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rawText = data['candidates']?[0]['content']['parts']?[0]['text'] ?? '';
        
        String jsonString = rawText.trim();
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
      } else {
        throw Exception('HTTP Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Error during AI analysis: $e');
      throw Exception('AI API Error: $e');
    }
  }
}
