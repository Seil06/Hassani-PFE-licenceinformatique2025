import 'package:myapp/models/utilisateur.dart';

class Like {
  final int? idLike;
  final DateTime dateLike;
  final Utilisateur utilisateur;
  final int? idPost;
  final int? idCampagne;

  Like({
    this.idLike,
    required this.dateLike,
    required this.utilisateur,
    this.idPost,
    this.idCampagne,
  }) {
    if (idPost == null && idCampagne == null) {
      throw ArgumentError('Un like doit être associé à un post ou une campagne');
    }
    if (idPost != null && idCampagne != null) {
      throw ArgumentError('Un like ne peut pas être associé à un post et une campagne simultanément');
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id_like': idLike,
      'date_like': dateLike.toIso8601String(),
      'id_utilisateur': utilisateur.id,
      'id_post': idPost,
      'id_campagne': idCampagne,
    };
  }

  factory Like.fromMap(Map<String, dynamic> map) {
    return Like(
      idLike: map['id_like'],
      dateLike: DateTime.parse(map['date_like']),
      utilisateur: Utilisateur.fromMap(map['utilisateur']),
      idPost: map['id_post'],
      idCampagne: map['id_campagne'],
    );
  }
}