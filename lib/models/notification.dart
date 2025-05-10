import 'package:myapp/models/acteur.dart';

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
  final Acteur acteur;
  final bool isRead;

  Notification({
    this.idNotification,
    required this.titre,
    required this.contenu,
    required this.date,
    required this.typeNotification,
    required this.acteur,
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
      'id_acteur': acteur.id,
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
      acteur: Acteur.fromMap(map['acteur']),
      isRead: map['is_read'] ?? false,
    );
  }

  @override
  String toString() {
    return 'Notification(idNotification: $idNotification, titre: $titre, contenu: $contenu, date: $date, typeNotification: $typeNotification, acteur: $acteur, isRead: $isRead)';
  }
}