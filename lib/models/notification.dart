import 'package:myapp/models/acteur.dart';
import 'package:myapp/models/dashboard.dart';

enum TypeNotification {
  nouveau_post,
  nouvelle_campagne,
  avertissement,
  message,
  autre,
}

class Notification {
  final int? idNotification;
  final String titre;
  final String contenu;
  final DateTime date;
  final TypeNotification typeNotification;
  final Acteur idActeur;
  final Dashboard idDashboard;
  final bool isRead;

  Notification({
    this.idNotification,
    required this.titre,
    required this.contenu,
    required this.date,
    required this.typeNotification,
    required this.idActeur,
    required this.idDashboard,
    this.isRead = false,
  }) {
    if (titre.isEmpty) throw ArgumentError('Le titre ne peut pas être vide');
    if (contenu.isEmpty) throw ArgumentError('Le contenu ne peut pas être vide');
  }

  Map<String, dynamic> toMap() {
    return {
      'id_notification': idNotification,
      'titre': titre,
      'contenu': contenu,
      'date': date.toIso8601String(),
      'type_notification': typeNotification.name,
      'id_acteur': idActeur.id,
      'id_dashboard': idDashboard.idDashboard,
      'is_read': isRead,
    };
  }

  factory Notification.fromMap(Map<String, dynamic> map) {
    return Notification(
      idNotification: map['id_notification'],
      titre: map['titre'],
      contenu: map['contenu'],
      date: DateTime.parse(map['date']),
      typeNotification: TypeNotification.values.byName(map['type_notification']),
      idActeur: Acteur.fromMap(map['id_acteur']),
      idDashboard: Dashboard.fromMap(map['id_dashboard']),
      isRead: map['is_read'] ?? false,
    );
  }


  @override
  String toString() {
    return 'Notification(idNotification: $idNotification, titre: $titre, contenu: $contenu, date: $date, typeNotification: $typeNotification, idActeur: $idActeur, idDashboard: $idDashboard, isRead: $isRead)';
  }
}