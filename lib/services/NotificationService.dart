import 'package:myapp/models/notification.dart';
import 'package:myapp/models/acteur.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  static Future<Notification> createNotification({
    required String titre,
    required String contenu,
    required TypeNotification typeNotification,
    required Acteur acteur,
  }) async {
    final supabase = Supabase.instance.client;

    final notificationData = Notification(
      titre: titre,
      contenu: contenu,
      date: DateTime.now(),
      typeNotification: typeNotification,
      acteur: acteur,
    ).toMap();

    final response = await supabase
        .from('notification')
        .insert(notificationData)
        .select()
        .single();

    return Notification.fromMap(response);
  }

  static Future<List<Notification>> getNotificationsForActeur({
    required int idActeur,
    bool onlyUnread = false,
  }) async {
    final supabase = Supabase.instance.client;

    var query = supabase
        .from('notification')
        .select('*, acteur(*)')
        .eq('id_acteur', idActeur)
        .order('date', ascending: false);

    if (onlyUnread) {
      query = (query as PostgrestFilterBuilder).eq('is_read', false) as PostgrestTransformBuilder<PostgrestList>;
    }

    final response = await query;

    return response
        .map<Notification>((map) => Notification.fromMap(map))
        .toList();
  }

  static Future<void> markNotificationAsRead(int idNotification) async {
    final supabase = Supabase.instance.client;

    await supabase
        .from('notification')
        .update({'is_read': true})
        .eq('id_notification', idNotification);
  }

  static Future<void> markAllNotificationsAsRead(int idActeur) async {
    final supabase = Supabase.instance.client;

    await supabase
        .from('notification')
        .update({'is_read': true})
        .eq('id_acteur', idActeur)
        .eq('is_read', false);
  }
}