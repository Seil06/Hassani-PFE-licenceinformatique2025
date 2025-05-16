import 'package:myapp/models/acteur.dart';
import 'package:myapp/models/association.dart';
import 'package:myapp/models/dashboard.dart';
import 'package:myapp/models/don.dart';
import 'package:myapp/models/historique.dart';
import 'package:myapp/models/message.dart';
import 'package:myapp/models/notification.dart';
import 'package:myapp/models/utilisateur.dart';
import 'package:myapp/models/post.dart';
import 'package:myapp/models/zakat.dart';

class Donateur extends Utilisateur {
  final String nom;
  final String prenom;
  final List<Post> followedPosts;
  final List<Campagne> followedCampagnes;
  final List<Don> dons;
  final List<Zakat> zakats;

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
    this.zakats = const [],
    required super.numCarteIdentite,
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
    final id = map['id_acteur'];
    final nom = map['nom']?.toString() ?? 'Unknown';
    final prenom = map['prenom']?.toString() ?? 'Unknown';

    final utilisateur = map['utilisateur'] as Map<String, dynamic>?;
    final telephone = utilisateur?['telephone']?.toString();
    final adresse = utilisateur?['adresse_utilisateur']?.toString();

    final acteur = utilisateur?['acteur'] as Map<String, dynamic>?;
    final email = acteur?['email']?.toString();
    final idProfile = acteur?['id_profile'];
    final profileMap = acteur?['profile'] as Map<String, dynamic>? ?? {};

    return Donateur(
      id: id,
      nom: nom,
      prenom: prenom,
      email: email ?? '',
      motDePasse: '********',
      telephone: telephone ?? '',
      adresse: adresse ?? '',
      latitude: null,
      longitude: null,
      profile: Profile.fromMap({
        'id_profile': idProfile,
        'photo_url': profileMap['photo_url']?.toString() ?? '',
        'bio': profileMap['bio']?.toString() ?? '',
      }),
      dashboard: Dashboard.empty(),
      numCarteIdentite: '',
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
    List<Zakat>? zakats,
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
      zakats: zakats ?? this.zakats,
      numCarteIdentite: numCarteIdentite,
    );
  }
}