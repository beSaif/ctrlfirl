import 'dart:async';
import 'dart:convert';
import 'package:ctrlfirl/models/messages_model.dart';
import 'package:flutter/material.dart';
import '../.env';
import 'package:http/http.dart' as http;

class OpenaiHelper {
  var header = {
    "Authorization": "Bearer $OPENAI_API_KEY",
    'Content-Type': 'application/json',
  };
  var data = {};
  String openaiChatURL = 'https://api.openai.com/v1/chat/completions';

  late http.Client client;

  Future<String> generateTitle(List<MessagesModel> messages) async {
    String systemMesssage =
        '''You're a bot that generates a title for a given content.
        You can see the content below and generate a title for it.
        Only respond with a title. Not prefix or suffix paragraph or texts.
        Be short and precise.
        ''';

    MessagesModel sysMessage = MessagesModel(
      id: '0',
      role: OpenAIRole.system,
      content: systemMesssage,
    );
    messages.add(sysMessage);

    data['messages'] = messages.reversed.map((e) => e.toJson()).toList();
    data['model'] = "gpt-4-1106-preview";

    var response = await http.post(
      Uri.parse(openaiChatURL),
      headers: header,
      body: jsonEncode(data),
    );
    String title =
        jsonDecode(response.body)['choices'][0]['message']['content'];
    debugPrint('Title: $title');
    return title;
  }

  Stream<String> streamAPIResponse(List<MessagesModel> messages) async* {
    debugPrint("streamAPIResponse");

    data['stream'] = true;
    data['messages'] = messages.reversed.map((e) => e.toJson()).toList();
    data['model'] = "gpt-4-1106-preview";

    debugPrint('Messages: ${data['messages']}');

    client = http.Client();
    final url = Uri.parse(openaiChatURL);
    String body = jsonEncode(data);

    var request = http.Request('POST', url)
      ..headers.addAll(header)
      ..body = body;

    final http.StreamedResponse response = await client.send(request);
    StringBuffer buffer = StringBuffer();
    await for (var chunk in response.stream.transform(utf8.decoder)) {
      buffer.write(chunk);

      while (buffer.toString().contains('\n')) {
        var line = buffer.toString().split('\n').first;
        buffer = StringBuffer(buffer.toString().split('\n').skip(1).join('\n'));

        yield line;
      }
    }
    // yield* response.stream.transform(utf8.decoder);
  }
}
