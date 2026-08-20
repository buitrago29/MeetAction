import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:meet_action/core/errors/exceptions.dart';
import 'package:meet_action/features/minutes_ai/data/models/meeting_analysis_model.dart';

abstract class GeminiRemoteDataSource {
  Future<MeetingAnalysisModel> analyzeAudioContent({
    required String audioBase64,
    required String mimeType,
  });
}

class GeminiRemoteDataSourceImpl implements GeminiRemoteDataSource {
  final http.Client client;
  final String apiKey;
  final String modelName;

  static const String _promptInstructions = '''
Eres un asistente ejecutivo experto de MeetAction. Analiza el audio de la reunión proporcionado y extrae la información en un formato JSON estrictamente estructurado según el siguiente esquema:
- title: Título representativo de la reunión.
- executiveSummary: Síntesis ejecutiva de los temas discutidos.
- meetingTone: Tono general de la reunión (constructive, urgent, consensus, debate).
- participants: Lista de nombres de los participantes detectados.
- topics: Lista de objetos con 'title' y 'keyPoints'.
- keyDecisions: Lista de acuerdos y decisiones clave tomadas.
- actionItems: Lista de compromisos con 'assigneeName', 'description', 'suggestedDueDate' (formato ISO 8601 o null) y 'priority' (low, medium, high, urgent).
''';

  GeminiRemoteDataSourceImpl({
    required this.client,
    required this.apiKey,
    this.modelName = 'gemini-1.5-flash',
  });

  @override
  Future<MeetingAnalysisModel> analyzeAudioContent({
    required String audioBase64,
    required String mimeType,
  }) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent?key=$apiKey',
    );

    final requestBody = {
      'contents': [
        {
          'parts': [
            {'text': _promptInstructions},
            {
              'inlineData': {
                'mimeType': mimeType,
                'data': audioBase64,
              }
            }
          ]
        }
      ],
      'generationConfig': {
        'responseMimeType': 'application/json',
      }
    };

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode != 200) {
        throw ServerException(
          'Gemini API error (Status ${response.statusCode}): ${response.body}',
        );
      }

      final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
      final candidates = jsonMap['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) {
        throw const ServerException('No candidates returned from Gemini API');
      }

      final content = candidates.first['content'] as Map<String, dynamic>?;
      final parts = content?['parts'] as List<dynamic>?;
      final text = parts?.first?['text'] as String?;

      if (text == null || text.isEmpty) {
        throw const ServerException('Empty content returned from Gemini API');
      }

      final parsedData = jsonDecode(text) as Map<String, dynamic>;
      return MeetingAnalysisModel.fromJson(parsedData);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to process Gemini request: $e');
    }
  }
}
