import 'package:myapp/models/utilisateur.dart';

class Like {
  final int? idLike;
  final DateTime dateLike;
  final Utilisateur auteur;

  Like({
    this.idLike,
    required this.dateLike,
    required this.auteur,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_like': idLike,
      'date_like': dateLike.toIso8601String(),
      'id_utilisateur': auteur.id,
    };
  }

  factory Like.fromMap(Map<String, dynamic> map) {
    return Like(
      idLike: map['id_like'],
      dateLike: DateTime.parse(map['date_like']),
      auteur: Utilisateur.fromMap(map['auteur']),
    );
  }
}