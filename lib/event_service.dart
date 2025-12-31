import 'dart:convert';
import 'package:http/http.dart' as http;
import 'event_model.dart';

class EventService {
  EventService._();
  static final EventService instance = EventService._();

  static const String baseUrl = 'http://10.0.2.2/compuse_app';

  Future<List<EventModel>> fetchEventsForGroup(String group) async {
    final uri = Uri.parse('$baseUrl/view_events.php')
        .replace(queryParameters: {'group': group});

    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}');
    }

    final map = jsonDecode(res.body) as Map<String, dynamic>;
    if (map['success'] != true) {
      throw Exception(map['error'] ?? 'Unknown error');
    }

    final List list = map['events'] ?? [];
    return list
        .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
