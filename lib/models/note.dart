import 'package:myapp/models/utilisateur.dart';

class Note {
  final int? idNote;
  final double note;
  final DateTime dateLike;
  final String? raison;
  final Utilisateur auteur;

  Note({
    this.idNote,
    required this.note,
    required this.dateLike,
    this.raison,
    required this.auteur,
  }) {
    if (note < 0 || note > 5) throw ArgumentError('La note doit être entre 0 et 5');
  }

  Map<String, dynamic> toMap() {
    return {
      'id_note': idNote,
      'note': note,
      'date_like': dateLike.toIso8601String(),
      'raison': raison,
      'id_utilisateur_auteur': auteur.id,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      idNote: map['id_note'],
      note: map['note'],
      dateLike: DateTime.parse(map['date_like']),
      raison: map['raison'],
      auteur: Utilisateur.fromMap(map['auteur']),
    );
  }
}