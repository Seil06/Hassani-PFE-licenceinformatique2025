import 'package:myapp/models/utilisateur.dart';

class Note {
  final int? idNote;
  final double note;
  final DateTime date;
  final String? raison;
  final Utilisateur auteur;
  final int? idPost;
  final int? idProfile;
  final int? idCampagne;

  Note({
    this.idNote,
    required this.note,
    required this.date,
    this.raison,
    required this.auteur,
    this.idPost,
    this.idProfile,
    this.idCampagne,
  }) {
    if (note < 0 || note > 5) throw ArgumentError('La note doit être entre 0 et 5');
    if (idPost == null && idProfile == null && idCampagne == null) {
      throw ArgumentError('Une note doit être associée à un post, un profil ou une campagne');
    }
    if ((idPost != null && idProfile != null) ||
        (idPost != null && idCampagne != null) ||
        (idProfile != null && idCampagne != null)) {
      throw ArgumentError('Une note ne peut être associée qu’à une seule entité (post, profil ou campagne)');
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id_note': idNote,
      'note': note,
      'date': date.toIso8601String(),
      'raison': raison,
      'id_utilisateur_auteur': auteur.id,
      'id_post': idPost,
      'id_profile': idProfile,
      'id_campagne': idCampagne,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      idNote: map['id_note'],
      note: map['note'],
      date: DateTime.parse(map['date']),
      raison: map['raison'],
      auteur: Utilisateur.fromMap(map['utilisateur_auteur']),
      idPost: map['id_post'],
      idProfile: map['id_profile'],
      idCampagne: map['id_campagne'],
    );
  }
}