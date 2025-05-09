import 'package:myapp/models/historique.dart';
import 'package:myapp/models/notification.dart';
import 'package:myapp/models/post.dart';

class Dashboard {
  final int? idDashboard;
  final List<Post> posts;
  final Historique historique;
  final List<Notification> notifications;

  Dashboard({
    this.idDashboard,
    required this.posts,
    required this.historique,
    required this.notifications,
  });

  factory Dashboard.empty() => Dashboard(
        posts: const [],
        historique: Historique(date: DateTime.now(), action: '', details: ''),
        notifications: const [],
      );

  Map<String, dynamic> toMap() {
    return {
      'id_dashboard': idDashboard,
      'id_historique': historique.idHistorique,
    };
  }

  factory Dashboard.fromMap(Map<String, dynamic> map) {
    return Dashboard(
      idDashboard: map['id_dashboard'],
      posts: [], // Load via separate query
      historique: Historique.fromMap(map['historique']),
      notifications: [], // Load via separate query
    );
  }
}