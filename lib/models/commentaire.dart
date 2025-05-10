import 'package:myapp/models/acteur.dart';

class Commentaire {
  final int? idCommentaire;
  final String contenu;
  final DateTime date;
  final Acteur acteur;
  final int? idPost;
  final int? idCampagne;

  Commentaire({
    this.idCommentaire,
    required this.contenu,
    required this.date,
    required this.acteur,
    this.idPost,
    this.idCampagne,
  }) {
    if (contenu.isEmpty) throw ArgumentError('Le contenu ne peut pas être vide');
    if (idPost == null && idCampagne == null) {
      throw ArgumentError('Un commentaire doit être associé à un post ou une campagne');
    }
    if (idPost != null && idCampagne != null) {
      throw ArgumentError('Un commentaire ne peut pas être associé à un post et une campagne simultanément');
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id_commentaire': idCommentaire,
      'contenu': contenu,
      'date': date.toIso8601String(),
      'id_acteur': acteur.id,
      'id_post': idPost,
      'id_campagne': idCampagne,
    };
  }

  factory Commentaire.fromMap(Map<String, dynamic> map) {
    return Commentaire(
      idCommentaire: map['id_commentaire'],
      contenu: map['contenu'],
      date: DateTime.parse(map['date']),
      acteur: Acteur.fromMap(map['acteur']),
      idPost: map['id_post'],
      idCampagne: map['id_campagne'],
    );
  }
}