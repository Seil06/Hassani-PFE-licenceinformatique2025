class Commentaire {
  final int? idCommentaire;
  final String commentaire;
  final DateTime dateCreation;

  Commentaire({
    this.idCommentaire,
    required this.commentaire,
    required this.dateCreation,
  }) {
    if (commentaire.isEmpty) throw ArgumentError('Le commentaire ne peut pas être vide');
  }

  Map<String, dynamic> toMap() {
    return {
      'id_commentaire': idCommentaire,
      'commentaire': commentaire,
      'date_creation': dateCreation.toIso8601String(),
    };
  }

  factory Commentaire.fromMap(Map<String, dynamic> map) {
    return Commentaire(
      idCommentaire: map['id_commentaire'],
      commentaire: map['commentaire'],
      dateCreation: DateTime.parse(map['date_creation']),
    );
  }
}