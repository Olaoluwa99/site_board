import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../../core/secrets/app_secrets.dart';
import '../models/project_summary_model.dart';

abstract interface class GeminiRemoteDataSource {
  Future<ProjectSummaryModel> generateSummary({required String promptText});
}

class GeminiRemoteDataSourceImpl implements GeminiRemoteDataSource {
  final GenerativeModel _model;

  GeminiRemoteDataSourceImpl()
      : _model = GenerativeModel(
    model: 'gemini-2.0-flash',
    apiKey: AppSecrets.geminiApiKey,
    generationConfig: GenerationConfig(
      responseMimeType: 'application/json',
      responseSchema: Schema.object(
        properties: {
          "title": Schema.string(),
          "date_range": Schema.string(),
          "overview": Schema.string(),
          "completed_tasks": Schema.array(items: Schema.string()),
          "issues_raised": Schema.array(items: Schema.string()),
          "upcoming_plans": Schema.string(),
        },
      ),
    ),
  );

  @override
  Future<ProjectSummaryModel> generateSummary({
    required String promptText,
  }) async {
    try {
      final content = [Content.text(promptText)];
      final response = await _model.generateContent(content);

      if (response.text == null) {
        throw ServerException('No response generated from AI.');
      }

      String cleanedText = response.text!;

      // Remove Markdown code fences if present
      if (cleanedText.startsWith('```json')) {
        cleanedText = cleanedText.replaceFirst('```json', '').replaceFirst('```', '');
      } else if (cleanedText.startsWith('```')) {
        cleanedText = cleanedText.replaceFirst('```', '').replaceFirst('```', '');
      }

      cleanedText = cleanedText.trim();

      final jsonResponse = jsonDecode(cleanedText);
      return ProjectSummaryModel.fromJson(jsonResponse);
    } catch (e) {
      debugPrint("Gemini Error: $e");
      // Provide a clearer error message for parsing failures
      if (e is FormatException) {
        throw ServerException("Failed to parse AI response. The summary might have been cut off or formatted incorrectly. Please try again.");
      }
      throw ServerException(e.toString());
    }
  }
}