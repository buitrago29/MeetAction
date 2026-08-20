import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:meet_action/core/errors/exceptions.dart';
import 'package:meet_action/features/action_items/domain/entities/action_item.dart';
import 'package:meet_action/features/minutes_ai/data/datasources/gemini_remote_datasource.dart';
import 'package:meet_action/features/minutes_ai/data/models/meeting_analysis_model.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late GeminiRemoteDataSourceImpl dataSource;
  late MockHttpClient mockHttpClient;

  setUpAll(() {
    registerFallbackValue(Uri.parse('https://example.com'));
  });

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = GeminiRemoteDataSourceImpl(
      client: mockHttpClient,
      apiKey: 'test-api-key',
    );
  });

  const tAudioBase64 = 'UklGRiQAAABXQVZFZm10IBAAAAABAAEAQB8AAEAfAAABAAgAZGF0YQAAAAA=';
  const tMimeType = 'audio/mp4';

  final tGeminiResponsePayload = {
    'candidates': [
      {
        'content': {
          'parts': [
            {
              'text': jsonEncode({
                'title': 'Reunión de Sincronización',
                'executiveSummary': 'Resumen ejecutivo de la reunión...',
                'meetingTone': 'consensus',
                'participants': ['Alice', 'Bob'],
                'topics': [
                  {
                    'title': 'Sprint Review',
                    'keyPoints': 'Se completaron 8 de 10 historias.',
                  }
                ],
                'keyDecisions': ['Mover las 2 historias al siguiente sprint'],
                'actionItems': [
                  {
                    'assigneeName': 'Alice',
                    'description': 'Actualizar tablero Jira',
                    'suggestedDueDate': '2026-08-22T18:00:00.000Z',
                    'priority': 'high',
                  }
                ]
              })
            }
          ]
        }
      }
    ]
  };

  test('should perform POST request with audio and return MeetingAnalysisModel on 200',
      () async {
    // arrange
    when(() => mockHttpClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        )).thenAnswer(
      (_) async => http.Response(jsonEncode(tGeminiResponsePayload), 200),
    );

    // act
    final result = await dataSource.analyzeAudioContent(
      audioBase64: tAudioBase64,
      mimeType: tMimeType,
    );

    // assert
    expect(result, isA<MeetingAnalysisModel>());
    expect(result.title, 'Reunión de Sincronización');
    expect(result.executiveSummary, 'Resumen ejecutivo de la reunión...');
    expect(result.meetingTone, 'consensus');
    expect(result.participants, ['Alice', 'Bob']);
    expect(result.topics.first.title, 'Sprint Review');
    expect(result.keyDecisions.first, 'Mover las 2 historias al siguiente sprint');
    expect(result.actionItems.first.priority, PriorityLevel.high);
    verify(() => mockHttpClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        )).called(1);
  });

  test('should throw ServerException when response code is not 200', () async {
    // arrange
    when(() => mockHttpClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        )).thenAnswer(
      (_) async => http.Response('Internal Server Error', 500),
    );

    // act
    final call = dataSource.analyzeAudioContent(
      audioBase64: tAudioBase64,
      mimeType: tMimeType,
    );

    // assert
    expect(() => call, throwsA(isA<ServerException>()));
  });
}
