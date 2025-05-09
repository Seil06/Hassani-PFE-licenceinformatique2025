import 'package:myapp/models/acteur.dart';
import 'package:myapp/models/association.dart';
import 'package:myapp/models/dashboard.dart';
import 'package:myapp/models/don.dart';
import 'package:myapp/models/historique.dart';
import 'package:myapp/models/message.dart';
import 'package:myapp/models/notification.dart';
import 'package:myapp/models/utils.dart';
import 'package:myapp/models/utilisateur.dart';
import 'package:myapp/models/post.dart';

class Donateur extends Utilisateur {
  final String nom;
  final String prenom;
  final List<Post> followedPosts;
  final List<Campagne> followedCampagnes;
  final List<Don> dons;

  Donateur({
    super.id,
    required this.nom,
    required this.prenom,
    required super.email,
    required super.motDePasse,
    required super.telephone,
    required super.adresse,
    super.latitude,
    super.longitude,
    required super.profile,
    required super.dashboard,
    super.posts = const [],
    super.messages = const [],
    super.notifications = const [],
    super.historiques = const [],
    super.followers = const [],
    super.avertissements = const [],
    this.followedPosts = const [],
    this.followedCampagnes = const [],
    this.dons = const [],
  }) : super(typeU: TypeUtilisateur.donateur) {
    if (nom.isEmpty) throw ArgumentError('Le nom ne peut pas être vide');
    if (prenom.isEmpty) throw ArgumentError('Le prénom ne peut pas être vide');
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'nom': nom,
      'prenom': prenom,
    };
  }

  factory Donateur.fromMap(Map<String, dynamic> map) {
    return Donateur(
      id: map['id_acteur'],
      nom: map['nom'],
      prenom: map['prenom'],
      email: map['utilisateur'] != null ? map['utilisateur']['email'] : map['email'],
      motDePasse: map['utilisateur'] != null ? map['utilisateur']['mot_de_passe'] ?? '********' : map['mot_de_passe'],
      telephone: map['utilisateur'] != null ? map['utilisateur']['telephone'] : map['telephone'],
      adresse: map['utilisateur'] != null ? map['utilisateur']['adresse'] : map['adresse'],
      latitude: map['utilisateur'] != null && map['utilisateur']['location'] != null
          ? GeoUtils.parsePoint(map['utilisateur']['location'])['latitude']
          : map['location'] != null
              ? GeoUtils.parsePoint(map['location'])['latitude']
              : null,
      longitude: map['utilisateur'] != null && map['utilisateur']['location'] != null
          ? GeoUtils.parsePoint(map['utilisateur']['location'])['longitude']
          : map['location'] != null
              ? GeoUtils.parsePoint(map['location'])['longitude']
              : null,
      profile: Profile.fromMap(map['acteur'] != null ? map['acteur']['profile'] : map['profile']),
      dashboard: Dashboard.fromMap(map['dashboard'] ?? {}),
      dons: map['dons'] != null ? (map['dons'] as List).map((don) => Don.fromMap(don)).toList() : [],
    );
  }

  Donateur copyWith({
    int? id,
    String? nom,
    String? prenom,
    String? email,
    String? motDePasse,
    String? telephone,
    String? adresse,
    double? latitude,
    double? longitude,
    Profile? profile,
    Dashboard? dashboard,
    List<Post>? posts,
    List<Message>? messages,
    List<Notification>? notifications,
    List<Historique>? historiques,
    List<Utilisateur>? followers,
    List<Avertissement>? avertissements,
    List<Post>? followedPosts,
    List<Campagne>? followedCampagnes,
    List<Don>? dons,
  }) {
    return Donateur(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      email: email ?? this.email,
      motDePasse: motDePasse ?? this.motDePasse,
      telephone: telephone ?? this.telephone,
      adresse: adresse ?? this.adresse,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      profile: profile ?? this.profile,
      dashboard: dashboard ?? this.dashboard,
      posts: posts ?? this.posts,
      messages: messages ?? this.messages,
      notifications: notifications ?? this.notifications,
      historiques: historiques ?? this.historiques,
      followers: followers ?? this.followers,
      avertissements: avertissements ?? this.avertissements,
      followedPosts: followedPosts ?? this.followedPosts,
      followedCampagnes: followedCampagnes ?? this.followedCampagnes,
      dons: dons ?? this.dons,
    );
  }
}