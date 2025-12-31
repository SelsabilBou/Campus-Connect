import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'event_model.dart';
import 'main.dart'; // pour accéder à flutterLocalNotificationsPlugin

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  // Canal par défaut pour Android
  static const AndroidNotificationDetails _androidDetails =
  AndroidNotificationDetails(
    'events_channel', // id du canal
    'Events & Exams', // nom
    channelDescription: 'Notifications for upcoming events and exams',
    importance: Importance.max,
    priority: Priority.high,
  );

  static const NotificationDetails _notificationDetails =
  NotificationDetails(android: _androidDetails);

  /// Affiche une notification immédiate pour un event
  Future<void> showEventNotification(EventModel event) async {
    final id = event.id; // utilise l’id de la BD comme id de notif

    await flutterLocalNotificationsPlugin.show(
      id,
      event.title, // titre
      event.description.isNotEmpty
          ? event.description
          : 'Event at ${event.eventDate}', // body
      _notificationDetails,
    );
  }
}
