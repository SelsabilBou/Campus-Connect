import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  ChatService._();
  static final ChatService instance = ChatService._();

  // adapte à ton dossier backend
  static const String baseUrl = 'http://10.0.2.2/campus_api';

  Future<List<ChatMessage>> fetchConversation(
      int user1,
      int user2,
      ) async {
    final uri = Uri.parse('$baseUrl/chat_fetch.php')
        .replace(queryParameters: {
      'user1': user1.toString(),
      'user2': user2.toString(),
    });

    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}');
    }

    final map = jsonDecode(res.body) as Map<String, dynamic>;
    if (map['success'] != true) {
      throw Exception(map['error'] ?? 'Unknown error');
    }

    final List list = map['messages'] ?? [];
    return list
        .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> sendMessage({
    required int senderId,
    required int receiverId,
    required String content,
  }) async {
    final uri = Uri.parse('$baseUrl/chat_send.php');
    final body = jsonEncode({
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
    });

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}');
    }

    final map = jsonDecode(res.body) as Map<String, dynamic>;
    if (map['success'] != true) {
      throw Exception(map['error'] ?? 'Send failed');
    }
  }
}

class ChatMessage {
  final int id;
  final int senderId;
  final int receiverId;
  final String content;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: int.parse(json['id'].toString()),
      senderId: int.parse(json['sender_id'].toString()),
      receiverId: int.parse(json['receiver_id'].toString()),
      content: json['content'].toString(),
      createdAt: DateTime.parse(json['created_at'].toString()),
    );
  }
}
