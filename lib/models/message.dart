import 'package:myapp/models/acteur.dart';

class PieceJointe {
  final int? idPieceJointe;
  final String urlFichier;
  final String typeFichier;
  final int idMessage;

  PieceJointe({
    this.idPieceJointe,
    required this.urlFichier,
    required this.typeFichier,
    required this.idMessage,
  }) {
    if (urlFichier.isEmpty) throw ArgumentError('L’URL du fichier ne peut pas être vide');
    if (typeFichier.isEmpty) throw ArgumentError('Le type de fichier ne peut pas être vide');
  }

  Map<String, dynamic> toMap() {
    return {
      'id_piece_jointe': idPieceJointe,
      'url_fichier': urlFichier,
      'type_fichier': typeFichier,
      'id_message': idMessage,
    };
  }

  factory PieceJointe.fromMap(Map<String, dynamic> map) {
    return PieceJointe(
      idPieceJointe: map['id_piece_jointe'],
      urlFichier: map['url_fichier'],
      typeFichier: map['type_fichier'],
      idMessage: map['id_message'],
    );
  }
}

class Message {
  final int? idMessage;
  final String contenu;
  final DateTime dateEnvoi;
  final Acteur expediteur;
  final List<Acteur> destinataires;
  final bool estGroupe;
  final List<PieceJointe> piecesJointes;

  Message({
    this.idMessage,
    required this.contenu,
    required this.dateEnvoi,
    required this.expediteur,
    required this.destinataires,
    this.estGroupe = false,
    this.piecesJointes = const [],
  }) {
    if (contenu.isEmpty) throw ArgumentError('Le contenu ne peut pas être vide');
    if (destinataires.isEmpty) throw ArgumentError('Il faut au moins un destinataire');
  }

  Map<String, dynamic> toMap() {
    return {
      'id_message': idMessage,
      'contenu': contenu,
      'date_envoi': dateEnvoi.toIso8601String(),
      'id_expediteur': expediteur.id,
      'est_groupe': estGroupe ? 1 : 0,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      idMessage: map['id_message'],
      contenu: map['contenu'],
      dateEnvoi: DateTime.parse(map['date_envoi']),
      expediteur: Acteur.fromMap(map['expediteur']),
      destinataires: [], // Load via DestinataireMessage query
      estGroupe: map['est_groupe'] == 1,
      piecesJointes: [], // Load via separate query
    );
  }
}