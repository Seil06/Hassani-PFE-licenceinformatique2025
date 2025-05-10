import 'package:myapp/models/acteur.dart';

enum RoleMembre { admin, membre }

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

class ConversationGroupe {
  final int? idConversation;
  final String nom;
  final String? description;
  final DateTime dateCreation;
  final Acteur createur;
  final List<MembreConversation> membres;

  ConversationGroupe({
    this.idConversation,
    required this.nom,
    this.description,
    required this.dateCreation,
    required this.createur,
    this.membres = const [],
  }) {
    if (nom.isEmpty) throw ArgumentError('Le nom du groupe ne peut pas être vide');
  }

  Map<String, dynamic> toMap() {
    return {
      'id_conversation': idConversation,
      'nom': nom,
      'description': description,
      'date_creation': dateCreation.toIso8601String(),
      'id_createur': createur.id,
    };
  }

  factory ConversationGroupe.fromMap(Map<String, dynamic> map) {
    return ConversationGroupe(
      idConversation: map['id_conversation'],
      nom: map['nom'],
      description: map['description'],
      dateCreation: DateTime.parse(map['date_creation']),
      createur: Acteur.fromMap(map['createur']),
      membres: [], // Load via separate query
    );
  }
}

class MembreConversation {
  final int idConversation;
  final Acteur acteur;
  final DateTime dateAjout;
  final RoleMembre role;

  MembreConversation({
    required this.idConversation,
    required this.acteur,
    required this.dateAjout,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_conversation': idConversation,
      'id_acteur': acteur.id,
      'date_ajout': dateAjout.toIso8601String(),
      'role': role.name,
    };
  }

  factory MembreConversation.fromMap(Map<String, dynamic> map) {
    return MembreConversation(
      idConversation: map['id_conversation'],
      acteur: Acteur.fromMap(map['acteur']),
      dateAjout: DateTime.parse(map['date_ajout']),
      role: RoleMembre.values.byName(map['role']),
    );
  }
}

class MessageDestinataire {
  final int idMessage;
  final Acteur destinataire;

  MessageDestinataire({
    required this.idMessage,
    required this.destinataire,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_message': idMessage,
      'id_destinataire': destinataire.id,
    };
  }

  factory MessageDestinataire.fromMap(Map<String, dynamic> map) {
    return MessageDestinataire(
      idMessage: map['id_message'],
      destinataire: Acteur.fromMap(map['destinataire']),
    );
  }
}

class Message {
  final int? idMessage;
  final String contenu;
  final DateTime dateEnvoi;
  final Acteur expediteur;
  final bool estGroupe;
  final ConversationGroupe? conversation;
  final List<MessageDestinataire> destinataires;
  final List<PieceJointe> piecesJointes;

  Message({
    this.idMessage,
    required this.contenu,
    required this.dateEnvoi,
    required this.expediteur,
    this.estGroupe = false,
    this.conversation,
    this.destinataires = const [],
    this.piecesJointes = const [],
  }) {
    if (contenu.isEmpty) throw ArgumentError('Le contenu ne peut pas être vide');
    if (estGroupe && conversation == null) {
      throw ArgumentError('Un message de groupe doit être associé à une conversation');
    }
    if (!estGroupe && destinataires.isEmpty) {
      throw ArgumentError('Un message 1:1 doit avoir au moins un destinataire');
    }
    if (!estGroupe && conversation != null) {
      throw ArgumentError('Un message 1:1 ne peut pas être associé à une conversation de groupe');
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id_message': idMessage,
      'contenu': contenu,
      'date_envoi': dateEnvoi.toIso8601String(),
      'id_expediteur': expediteur.id,
      'est_groupe': estGroupe,
      'id_conversation': conversation?.idConversation,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      idMessage: map['id_message'],
      contenu: map['contenu'],
      dateEnvoi: DateTime.parse(map['date_envoi']),
      expediteur: Acteur.fromMap(map['expediteur']),
      estGroupe: map['est_groupe'] ?? false,
      conversation: map['id_conversation'] != null
          ? ConversationGroupe.fromMap(map['conversation'])
          : null,
      destinataires: [], // Load via separate query
      piecesJointes: [], // Load via separate query
    );
  }
}