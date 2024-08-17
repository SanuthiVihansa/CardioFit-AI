import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

import '../screens/diet_plan/AlertService/api_key.dart';


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
    String model = "gpt-4o",}) async {
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
                  'text': 'Read and analyse the content as much as possible. And follow this format Medicine Name: The name of the medicine.Dosage: The dosage prescribed.Frequency: How often the medicine should be taken,give in user understanding manner, avoid medical notations.Duration: The duration for which the medicine should be taken. Pill Intake : Number of pills per intake (if given).Additional Instructions: (if specified) Any additional instructions provided by the doctor.give output in json format'

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

  //Send Image to GPT to get report information
  // Future<String> sendImageToGPT4VisionReport({
  //   required File image,
  //   int maxTokens = 400,
  //   String model = "gpt-4o",}) async {
  //   final String base64Image = await encodeImage(image);
  //   try {
  //     final response = await _dio.post(
  //       "$BASE_URL/chat/completions",
  //       options: Options(
  //         headers: {
  //           HttpHeaders.authorizationHeader: 'Bearer $API_KEY',
  //           HttpHeaders.contentTypeHeader: "application/json",
  //         },
  //       ),
  //       data: jsonEncode({
  //         'model': model,
  //         'messages': [
  //           {
  //             'role': 'system',
  //             'content': 'You have to give concise and short answers'
  //           },
  //           {
  //             'role': 'user',
  //             'content': [
  //               {
  //                 'type': 'text',
  //                 'text': 'As an intelligent OCR reader read the Test Name, result and units correctly. Do not provide any other information, provide the result in one line.Avoid providing unessary characters like . or : or , in the output'
  //
  //               },
  //               {
  //                 'type': 'image_url',
  //                 'image_url': {
  //                   'url': 'data:image/jpeg;base64,$base64Image',
  //                 },
  //               },
  //             ],
  //           },
  //         ],
  //         'max_tokens': maxTokens,
  //       }),
  //     );
  //
  //     final jsonResponse = response.data;
  //
  //     if (jsonResponse['error'] != null) {
  //       throw HttpException(jsonResponse['error']["message"]);
  //     }
  //     return jsonResponse["choices"][0]["message"]["content"];
  //   } catch (e) {
  //     throw Exception('Error: $e');
  //   }
  // }

  Future<List<String>> sendImagesToGPT4VisionReports({
    required List<File> images,
    int maxTokens = 400,
    String model = "gpt-4o",
  }) async {
    List<String> results = [];

    for (File image in images) {
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
                    'text': 'As an intelligent OCR reader read the Test Name, result and units correctly. Do not provide any other information, provide the result in JSON format. Avoid providing unnecessary characters like . or : or , in the output'
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

        // Extract the response from the GPT-4 Vision model
        final result = response.data['choices'][0]['message']['content'];
        results.add(result);

      } catch (e) {
        print('Error processing image: $e');
        results.add('Error processing image: $e');
      }
    }

    return results;
  }

}
