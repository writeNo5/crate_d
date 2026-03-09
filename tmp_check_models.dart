import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:io';

void main() async {
  await dotenv.load(fileName: ".env");
  final apiKey = (dotenv.env['GEMINI_API_KEY'] ?? '').trim();
  
  if (apiKey.isEmpty) {
    print('No GEMINI_API_KEY found in .env');
    return;
  }

  print('Listing models for key: ${apiKey.substring(0, 5)}...');
  
  // NOTE: GenerativeModel doesn't have listModels, it's on the client or similar?
  // Actually, google_generative_ai doesn't seem to have a top-level listModels in 0.4.7.
  // Wait, let's try a direct request if possible.
  
  final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
  try {
    final content = [Content.text('test')];
    final response = await model.generateContent(content);
    print('Response: ${response.text}');
  } catch (e) {
    print('Error with gemini-1.5-flash: $e');
  }

  final model2 = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
  try {
    final content = [Content.text('test')];
    final response = await model2.generateContent(content);
    print('Response: ${response.text}');
  } catch (e) {
    print('Error with gemini-pro: $e');
  }
}
