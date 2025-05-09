import 'package:myapp/models/acteur.dart';
import 'package:myapp/models/commentaire.dart';
import 'package:myapp/models/dashboard.dart';
import 'package:myapp/models/don.dart';
import 'package:myapp/models/donateur.dart';
import 'package:myapp/models/like.dart';
import 'package:myapp/models/note.dart';
import 'package:myapp/models/post.dart';
import 'package:myapp/models/utils.dart';
import 'package:myapp/models/utilisateur.dart';
import 'package:myapp/services/SearchService.dart';

class Association extends Utilisateur {
  final String nomAssociation;
  final String documentAuthorisation;
  final bool statutValidation;
  final List<Campagne> campagnes;
  final List<Post> followedPosts;
  final List<Campagne> followedCampagnes;
  final List<Don> dons;

  Association({
    super.id,
    required this.nomAssociation,
    required this.documentAuthorisation,
    this.statutValidation = false,
    required super.email,
    required super.motDePasse,
    required super.telephone,
    required super.adresse,
    super.latitude,
    super.longitude,
    required super.profile,
    required super.dashboard,
    this.campagnes = const [],
    super.posts = const [],
    super.messages = const [],
    super.notifications = const [],
    super.historiques = const [],
    super.followers = const [],
    super.avertissements = const [],
    this.followedPosts = const [],
    this.followedCampagnes = const [],
    this.dons = const [],
  }) : super(typeU: TypeUtilisateur.association) {
    if (nomAssociation.isEmpty) throw ArgumentError('Le nom de l’association ne peut pas être vide');
    if (documentAuthorisation.isEmpty) throw ArgumentError('Le document d’autorisation ne peut pas être vide');
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'nom_association': nomAssociation,
      'document_authorisation': documentAuthorisation,
      'statut_validation': statutValidation,
    };
  }

  factory Association.fromMap(Map<String, dynamic> map) {
    return Association(
      id: map['id_acteur'],
      nomAssociation: map['nom_association'],
      documentAuthorisation: map['document_authorisation'],
      statutValidation: map['statut_validation'],
      email: map['email'],
      motDePasse: map['mot_de_passe'],
      telephone: map['telephone'],
      adresse: map['adresse'],
      latitude: map['location'] != null
          ? GeoUtils.parsePoint(map['location'])['latitude']
          : null,
      longitude: map['location'] != null
          ? GeoUtils.parsePoint(map['location'])['longitude']
          : null,
      profile: Profile.fromMap(map['profile']),
      dashboard: Dashboard.fromMap(map['dashboard']),
      dons: [], // Load via separate query
    );
  }
}

enum TypeCampagne { evenement, volontariat, sensibilisation, collecte }
enum EtatCampagne {
  brouillon,
  publiee,
  enCours,
  objectif_atteint,
  annulee,
  cloturee,
}

class Campagne extends Post {
  final EtatCampagne etatCampagne;
  final DateTime? dateDebut;
  final DateTime? dateFin;
  final String? lieuEvenement;
  final TypeCampagne typeCampagne;
  final double montantObjectif;
  final double montantRecolte;
  final int nombreParticipants;
  final List<Donateur> participants;
  List<int> followers; 

  Campagne({
    super.idPost,
    required super.titre,
    required super.description,
    required super.typeDon,
    required super.lieuActeur,
    required this.typeCampagne,
    this.etatCampagne = EtatCampagne.brouillon,
    this.dateDebut,
    this.dateFin,
    this.lieuEvenement,
    this.montantObjectif = 0.0,
    this.montantRecolte = 0.0,
    this.nombreParticipants = 0,
    this.followers = const [],
    super.image,
    super.video,
    super.dateLimite,
    super.latitude,
    super.longitude,
    super.notes = const [],
    super.likes = const [],
    super.commentaires = const [],
    super.utilisateursTaguer = const [],
    super.motsCles = const [],
    required super.idActeur,
    this.participants = const [],
  }) : super(typePost: TypePost.campagne) {
    if (montantObjectif < 0) throw ArgumentError('L’objectif ne peut pas être négatif');
    if (montantRecolte < 0) throw ArgumentError('Le montant récolté ne peut pas être négatif');
  }

  double get pourcentage => montantObjectif > 0 ? (montantRecolte / montantObjectif) * 100 : 0.0;

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'id_campagne': idPost,
      'etat_campagne': etatCampagne.name,
      'date_debut': dateDebut?.toIso8601String(),
      'date_fin': dateFin?.toIso8601String(),
      'lieu_evenement': lieuEvenement,
      'type_campagne': typeCampagne.name,
      'montant_objectif': montantObjectif,
      'montant_recolte': montantRecolte,
      'nombre_participants': nombreParticipants,
      'followers': followers,
      'id_acteur': idActeur,
    };
  }

  factory Campagne.fromMap(Map<String, dynamic> map) {
  return Campagne(
    idPost: map['id_campagne'],
    titre: map['titre'],
    description: map['description'],
    typeDon: TypeDon.values.byName(map['type_don']),
    lieuActeur: map['lieu_acteur'],
    typeCampagne: TypeCampagne.values.byName(map['type_campagne']),
    etatCampagne: EtatCampagne.values.byName(map['etat_campagne']),
    dateDebut: map['date_debut'] != null ? DateTime.parse(map['date_debut']) : null,
    dateFin: map['date_fin'] != null ? DateTime.parse(map['date_fin']) : null,
    lieuEvenement: map['lieu_evenement'],
    montantObjectif: map['montant_objectif'] != null
        ? double.tryParse(map['montant_objectif'].toString()) ?? 0.0
        : 0.0, // Fallback to 0.0 if invalid
    montantRecolte: map['montant_recolte'] != null
        ? double.tryParse(map['montant_recolte'].toString()) ?? 0.0
        : 0.0, // Fallback to 0.0 if invalid
    nombreParticipants: map['nombre_participants'] as int? ?? 0,
    image: map['image'],
    video: map['video'],
    dateLimite: map['date_limite'] != null ? DateTime.parse(map['date_limite']) : null,
    latitude: map['location'] != null
        ? GeoUtils.parsePoint(map['location'])['latitude'] ?? 0.0
        : null, // Fallback to null if location is invalid
    longitude: map['location'] != null
        ? GeoUtils.parsePoint(map['location'])['longitude'] ?? 0.0
        : null, // Fallback to null if location is invalid
    idActeur: map['id_acteur'],
    participants: [], // Load via separate query
  );
}

  Campagne copyWith({
  int? idPost,
  String? titre,
  String? description,
  TypeDon? typeDon,
  String? lieuActeur,
  TypeCampagne? typeCampagne,
  EtatCampagne? etatCampagne,
  DateTime? dateDebut,
  DateTime? dateFin,
  String? lieuEvenement,
  double? montantObjectif,
  double? montantRecolte,
  int? nombreParticipants,
  String? image,
  String? video,
  DateTime? dateLimite,
  double? latitude,
  double? longitude,
  List<Note>? notes,
  List<Like>? likes,
  List<Commentaire>? commentaires,
  List<Utilisateur>? utilisateursTaguer,
  List<Mot_cles>? motsCles,
  int? idActeur,
  List<Donateur>? participants,
  List<int>? followers, // Added followers parameter
}) {
  return Campagne(
    idPost: idPost ?? this.idPost,
    titre: titre ?? this.titre,
    description: description ?? this.description,
    typeDon: typeDon ?? this.typeDon,
    lieuActeur: lieuActeur ?? this.lieuActeur,
    typeCampagne: typeCampagne ?? this.typeCampagne,
    etatCampagne: etatCampagne ?? this.etatCampagne,
    dateDebut: dateDebut ?? this.dateDebut,
    dateFin: dateFin ?? this.dateFin,
    lieuEvenement: lieuEvenement ?? this.lieuEvenement,
    montantObjectif: montantObjectif ?? this.montantObjectif,
    montantRecolte: montantRecolte ?? this.montantRecolte,
    nombreParticipants: nombreParticipants ?? this.nombreParticipants,
    image: image ?? this.image,
    video: video ?? this.video,
    dateLimite: dateLimite ?? this.dateLimite,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    notes: notes ?? this.notes,
    likes: likes ?? this.likes,
    commentaires: commentaires ?? this.commentaires,
    utilisateursTaguer: utilisateursTaguer ?? this.utilisateursTaguer,
    motsCles: motsCles ?? this.motsCles,
    idActeur: idActeur ?? this.idActeur,
    participants: participants ?? this.participants,
    followers: followers ?? this.followers, // Added followers field
  );
}
}