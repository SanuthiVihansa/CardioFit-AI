import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

import '../screens/diet_plan/api_key.dart';


class ApiService {
  final Dio _dio = Dio();

  Future<String> encodeImage(File image) async {
    final bytes = await image.readAsBytes();
    return base64Encode(bytes);
  }

  Future<String> sendMessageGPT({required String prescriptionInfo}) async {
    try {
      final response = await _dio.post(
        "$BASE_URL/chat/completions",
        options: Options(
          headers: {
            HttpHeaders.authorizationHeader: 'Bearer $API_KEY',
            HttpHeaders.contentTypeHeader: "application/json",
          },
        ),
        data: {
          "model": 'gpt-3.5-turbo',
          "messages": [
            {
              "role": "user",
              "content": "upon receiving the text, Analyse and structure the content in dictionary key manner, to be used in alert system. provide the following details for each mentioned in a structured format:Medicine Name,Dosage (e.g., mg, ml),Intake Frequency (e.g., once a day, twice a day),Duration (e.g., 5 days, 1 week),Pill Intake per Time (e.g., 1 pill at a time). Avoid unnecessary details.The text is $prescriptionInfo",
              //"GPT,Read the image and write its details in a dictionary format for patient understanding. Each entry should include the medicine name, dosage, frequency, and any specific instructions.",
                  //"upon receiving the name of a plant disease, provide three precautionary measures to prevent or manage the disease. These measures should be concise, clear, and limited to one sentence each. No additional information or context is needed—only the three precautions in bullet-point format. The disease is $diseaseName",
            }
          ],
        },
      );

      final jsonResponse = response.data;

      if (jsonResponse['error'] != null) {
        throw HttpException(jsonResponse['error']["message"]);
      }

      return jsonResponse["choices"][0]["message"]["content"];
    } catch (error) {
      throw Exception('Error: $error');
    }
  }

  Future<String> sendImageToGPT4Vision({
    required File image,
    int maxTokens = 400,
    String model = "gpt-4o",
  }) async {
    final String base64Image = await encodeImage(image);

    try {
      final response = await _dio.post(
        "$BASE_URL/chat/completions",
        options: Options(
          headers: {
            HttpHeaders.authorizationHeader: 'Bearer $API_KEY',
            HttpHeaders.contentTypeHeader: "application/json",
          },
        ),
        data: jsonEncode({
          'model': model,
          'messages': [
            {
              'role': 'system',
              'content': 'You have to give concise and short answers'
            },
            {
              'role': 'user',
              'content': [
                {
                  'type': 'text',
                  'text': 'Read and analyse the content as much as possible'
                  //'GPT assume you are nurse,analyze the attached image of a handwritten prescription. Extract all the details and provide the following details for each mentioned in a structured format:Medicine Name,Dosage (e.g., mg, ml),Intake Frequency (e.g., once a day, twice a day),Duration (e.g., 5 days, 1 week),Pill Intake per Time (e.g., 1 pill at a time).The prescription may contain multiple medicines. You should be able to identify special notations used by doctors, and provide the details in a way a patient understand. Ensure that details for all medicines are extracted.Format the output as a list of dictionaries with the following keys: "Medicine Name", "Dosage", "Intake Frequency", "Duration", and "Pill Intake per Time". Do not output anything else.',
                  //'GPT, I am to make a alert system,I want you to scan and analyse the uploaded image and output its content such as medicine name, dosage, frequency, and any specific instructions or number of pills per intake.',
                  //'GPT assume you are nurse,analyze the attached image of a handwritten prescription. Extract all the details and provide the following details for each mentioned in a structured format:Medicine Name,Dosage (e.g., mg, ml),Intake Frequency (e.g., once a day, twice a day),Duration (e.g., 5 days, 1 week),Pill Intake per Time (e.g., 1 pill at a time).The prescription may contain multiple medicines. You should be able to identify special notations used by doctors, and provide the details in a way a patient understand. Ensure that details for all medicines are extracted.Format the output as a list of dictionaries with the following keys: "Medicine Name", "Dosage", "Intake Frequency", "Duration", and "Pill Intake per Time". Do not output anything else, than what was requested.If the inserted image is not a medicine prescription, display "Invalid request".',

                },
                {
                  'type': 'image_url',
                  'image_url': {
                    'url': 'data:image/jpeg;base64,$base64Image',
                  },
                },
              ],
            },
          ],
          'max_tokens': maxTokens,
        }),
      );

      final jsonResponse = response.data;

      if (jsonResponse['error'] != null) {
        throw HttpException(jsonResponse['error']["message"]);
      }
      return jsonResponse["choices"][0]["message"]["content"];
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
