import 'dart:convert';

import 'package:dhwani/secrets.dart';
import 'package:http/http.dart' as http;


class OpenAIService {
  final List<Map<String, String>> _messages = [];

  // separated functionality of API connectivity
  Future<http.Response> _connectAPI(String prompt, List<Map<String, String>> messages, [bool isDallE = false]) async {
    String url = 'https://api.openai.com/v1/chat/completions';
    Object body = jsonEncode({
    "model": "gpt-3.5-turbo",
    "messages": messages
    });

    // changing url and body for image querires, as Dall-E has different parameter
    if(isDallE){
      print('check 1');
      url = 'https://api.openai.com/v1/images/generations';
      body = jsonEncode({
        "prompt": prompt,
        "n": 1,
      });
    }
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $openAIAPIKey',
      },
      body: body,
    );
    return response;
  }

  Future<Map<String, dynamic>> isArtPromtAPI(String prompt) async {
    try {
      final response = await _connectAPI(prompt, [
        {
          "role": "user",
          "content":
          "Does the message/query mentioned in double-quotes generate an AI Picture, image, art or anything similar? \"$prompt\", "
              "Simply answer with a 'Yes' or 'No'",
        }
      ]);

      if (response.statusCode == 200) {
        String content = jsonDecode(
            response.body)['choices'][0]['message']['content'];
        content = content.trim();
        print(content);
        if (content == 'yes' || content == 'yes.' || content == 'Yes' ||
            content == 'Yes.') {
          final res = await _dallEAPI(prompt);
          return {
            'content' : res,
            'isDallE' : true,
          };
        }
        else {
          final res = await _chatGPTAPI(prompt);
          return {
            'content' : res,
            'isDallE' : false,
          };
        }
      } else {
        throw Exception('Failed to get completion');
      }
    } catch (e) {
      return {
        'content' : e.toString(),
        'isDallE' : false,
      };
    }
  }

  Future<String> _chatGPTAPI(String prompt) async {
    _messages.add(
        {
          "role": "user",
          "content": prompt
        }
    );
    try {
      final response = await _connectAPI(prompt, _messages);
      if (response.statusCode == 200) {
        String content = jsonDecode(
            response.body)['choices'][0]['message']['content'];
        _messages.add({
          'role': 'assistant',
          'content': content,
        });
        return content;
      }else if (response.statusCode == 429) {
        return 'Too Many requests Please try later';
      } else {
        print('GPT Exception');
        throw Exception('Failed to get completion : ${response.statusCode}');
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> _dallEAPI(String prompt) async {
    _messages.add(
        {
          "role": "user",
          "content": prompt
        }
    );
    try {
      final response = await _connectAPI(prompt, _messages, true);

      if (response.statusCode == 200) {
        String imageUrl = jsonDecode(
            response.body)['data'][0]['url'];
        _messages.add({
          'role': 'assistant',
          'content': imageUrl,
        });
        print('msgs check');
        return imageUrl;
      } else {
        print('DALL-E Exception');
        throw Exception('Failed to get completion');
      }
    } catch (e) {
      return e.toString();
    }
  }
}
