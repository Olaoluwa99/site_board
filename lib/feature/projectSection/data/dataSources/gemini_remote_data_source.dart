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
    // verify this model name exists in your current region/access level
    model: 'gemini-3-flash-preview',
    apiKey: AppSecrets.geminiApiKey,
    generationConfig: GenerationConfig(
      responseMimeType: 'application/json',
      temperature: 0.2, // Lower temperature reduces "creativity" and hallucinations
      maxOutputTokens: 1000,
      responseSchema: Schema.object(
        properties: {
          "title": Schema.string(
            description: "A concise title for the summary",
          ),
          "date_range": Schema.string(
            description: "The formatted date range (e.g., '12 Oct - 15 Oct 2023')",
          ),
          "overview": Schema.string(
            description: "A professional paragraph summarizing progress, weather impact, and workforce.",
          ),
          "completed_tasks": Schema.array(
            items: Schema.string(),
            description: "List of tasks that reached 100% completion",
          ),
          "issues_raised": Schema.array(
            items: Schema.string(),
            description: "List of challenges, delays, or critical observations",
          ),
          "upcoming_plans": Schema.string(
            description: "Suggestions for next steps based on unfinished tasks",
          ),
        },
        requiredProperties: [
          "title",
          "date_range",
          "overview",
          "completed_tasks",
          "issues_raised",
          "upcoming_plans"
        ],
      ),
    ),
  );

  /*GeminiRemoteDataSourceImpl()
    : _model = GenerativeModel(
        // model: 'gemini-1.5-flash',
        model: 'gemini-3-flash-preview',
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
      );*/

  @override
  Future<ProjectSummaryModel> generateSummary({
    required String promptText,
  }) async {
    try {
      debugPrint("Sanity Check: Sending request to Gemini...");
      final content = [Content.text(promptText)];
      final response = await _model
          .generateContent(content)
          .timeout(
            const Duration(seconds: 60),
            onTimeout:
                () =>
                    throw ServerException(
                      'Request timed out. Please check your internet connection.',
                    ),
          );
      debugPrint("Sanity Check: Received response from Gemini.");

      if (response.text == null) {
        throw ServerException('No response generated from AI.');
      }

      String cleanedText = response.text!;

      // Remove Markdown code fences if present
      if (cleanedText.startsWith('```json')) {
        cleanedText = cleanedText
            .replaceFirst('```json', '')
            .replaceFirst('```', '');
      } else if (cleanedText.startsWith('```')) {
        cleanedText = cleanedText
            .replaceFirst('```', '')
            .replaceFirst('```', '');
      }

      cleanedText = cleanedText.trim();
      debugPrint("Distribution phase");
      // Log the full response in chunks to avoid truncation
      final pattern = RegExp('.{1,800}'); // 800 is a safe size for logcat
      pattern
          .allMatches("Gemini JSON Response: $cleanedText")
          .forEach((match) => debugPrint(match.group(0)));

      final jsonResponse = jsonDecode(cleanedText);
      return ProjectSummaryModel.fromJson(jsonResponse);
    } catch (e) {
      debugPrint("Gemini Error: $e");
      // Provide a clearer error message for parsing failures
      if (e is FormatException) {
        throw ServerException(
          "Failed to parse AI response. The summary might have been cut off or formatted incorrectly. Please try again.",
        );
      }
      throw ServerException(e.toString());
    }
  }
}
