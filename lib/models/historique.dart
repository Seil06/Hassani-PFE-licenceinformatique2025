import 'package:myapp/models/acteur.dart';

class Historique {
  final int? idHistorique;
  final DateTime date;
  final String action;
  final String details;
  final Acteur? acteur;

  Historique({
    this.idHistorique,
    required this.date,
    required this.action,
    required this.details,
    this.acteur,
  }) {
    if (action.isEmpty) throw ArgumentError('L’action ne peut pas être vide');
    if (details.isEmpty) throw ArgumentError('Les détails ne peuvent pas être vides');
  }

  Map<String, dynamic> toMap() {
    return {
      'id_historique': idHistorique,
      'date': date.toIso8601String(),
      'action': action,
      'details': details,
      'id_acteur': acteur?.id,
    };
  }

  factory Historique.fromMap(Map<String, dynamic> map) {
    return Historique(
      idHistorique: map['id_historique'],
      date: DateTime.parse(map['date']),
      action: map['action'],
      details: map['details'],
      acteur: map['acteur'] != null ? Acteur.fromMap(map['acteur']) : null,
    );
  }
}