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
import 'package:myapp/models/zakat.dart';
import 'package:myapp/services/SearchService.dart';

class Association extends Utilisateur {
  final String nomAssociation;
  final String documentAuthorisation;
  final bool statutValidation;
  final List<Campagne> campagnes;
  final List<Campagne> followedCampagnes;
  final List<Don> dons;
  final List<Zakat> zakats;


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
    this.followedCampagnes = const [],
    this.dons = const [],
    this.zakats = const [],
  }) : super(typeU: TypeUtilisateur.association, numCarteIdentite: 'defaultNumCarteIdentite') {
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
      zakats: [], // Load via separate query
    );
  }
}

enum TypeCampagne { evenement, volontariat, sensibilisation, collecte }
enum EtatCampagne { brouillon, publiee, enCours, objectif_atteint, annulee, cloturee}

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
  final int idAssociation;
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
    super.dateLimite,
    super.latitude,
    super.longitude,
    super.notes = const [],
    super.likes = const [],
    super.commentaires = const [],
    super.utilisateursTaguer = const [],
    super.motsCles = const [],
    required super.idActeur,
    required this.idAssociation,
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
      'id_association': idAssociation,
    };
  }

factory Campagne.fromMap(Map<String, dynamic> map) {
  print('Campagne.fromMap input: $map'); // Debug log
  double? latitude;
  double? longitude;
  String? lieuEvenement;
  if (map['lieu_evenement'] != null) {
    final lieuRaw = map['lieu_evenement'].toString();
    print('Raw lieu_evenement: $lieuRaw'); // Debug log
    if (lieuRaw.startsWith('POINT(')) {
      final coords = GeoUtils.parsePoint(lieuRaw);
      latitude = coords['latitude'];
      longitude = coords['longitude'];
      lieuEvenement = lieuRaw;
    }
  }

  return Campagne(
    idPost: int.tryParse(map['id_campagne'].toString()) ?? 0,
    titre: map['titre']?.toString() ?? 'Titre inconnu',
    description: map['description']?.toString() ?? '',
    typeDon: map['type_don'] != null
        ? TypeDon.values.byName(map['type_don'].toString())
        : TypeDon.autre,
    lieuActeur: map['lieu_acteur']?.toString() ?? '',
    typeCampagne: map['type_campagne'] != null
        ? TypeCampagne.values.byName(map['type_campagne'].toString())
        : TypeCampagne.collecte,
    etatCampagne: map['etat_campagne'] != null
        ? EtatCampagne.values.byName(map['etat_campagne'].toString())
        : EtatCampagne.brouillon,
    dateDebut: map['date_debut'] != null
        ? DateTime.tryParse(map['date_debut'].toString())
        : null,
    dateFin: map['date_fin'] != null
        ? DateTime.tryParse(map['date_fin'].toString())
        : null,
    lieuEvenement: lieuEvenement,
    montantObjectif: map['montant_objectif'] != null
        ? double.tryParse(map['montant_objectif'].toString()) ?? 0.0
        : 0.0,
    montantRecolte: map['montant_recolte'] != null
        ? double.tryParse(map['montant_recolte'].toString()) ?? 0.0
        : 0.0,
    nombreParticipants: int.tryParse(map['nombre_participants']?.toString() ?? '0') ?? 0,
    image: map['image']?.toString(),
    dateLimite: map['date_limite'] != null
        ? DateTime.tryParse(map['date_limite'].toString())
        : null,
    latitude: latitude,
    longitude: longitude,
    idActeur: int.tryParse(map['id_acteur']?.toString() ?? '0') ?? 0,
    idAssociation: int.tryParse(map['id_association']?.toString() ?? '0') ?? 0,
    participants: [], // Load via separate query
    followers: (map['followers'] as List<dynamic>?)?.cast<int>() ?? [],
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
    DateTime? dateLimite,
    double? latitude,
    double? longitude,
    List<Note>? notes,
    List<Like>? likes,
    List<Commentaire>? commentaires,
    List<Utilisateur>? utilisateursTaguer,
    List<MotCles>? motsCles,
    int? idActeur,
    int? idAssociation,
    List<Donateur>? participants,
    List<int>? followers,
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
      dateLimite: dateLimite ?? this.dateLimite,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      notes: notes ?? this.notes,
      likes: likes ?? this.likes,
      commentaires: commentaires ?? this.commentaires,
      utilisateursTaguer: utilisateursTaguer ?? this.utilisateursTaguer,
      motsCles: motsCles ?? this.motsCles,
      idActeur: idActeur ?? this.idActeur,
      idAssociation: idAssociation ?? this.idAssociation,
      participants: participants ?? this.participants,
      followers: followers ?? this.followers,
    );
  }
}