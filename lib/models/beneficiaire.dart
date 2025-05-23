import 'package:myapp/models/acteur.dart';
import 'package:myapp/models/association.dart';
import 'package:myapp/models/dashboard.dart';
import 'package:myapp/models/utils.dart';
import 'package:myapp/models/utilisateur.dart';
import 'package:myapp/models/post.dart';
import 'package:myapp/models/zakat.dart';

enum TypeBeneficiaire { pauvre, sdf, orphelin, enfantMalade, personneAgee, malade, handicape, femmeDivorcee, femmeSeule, femmeVeuve, autre}

class Beneficiaire extends Utilisateur {
  final String nom;
  final String prenom;
  final String documentSituation;
  final TypeBeneficiaire typeBeneficiaire;
  final List<Post> followedPosts;
  final List<Campagne> followedCampagnes;
  final List<Zakat> zakats;

  Beneficiaire({
    super.id,
    required this.nom,
    required this.prenom,
    required this.documentSituation,
    required this.typeBeneficiaire,
    required super.email,
    required super.motDePasse,
    required super.telephone,
    required super.adresse,
    required super.numCarteIdentite,
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
    this.zakats = const [],
  }) : super(typeU: TypeUtilisateur.beneficiaire) {
    if (nom.isEmpty) throw ArgumentError('Le nom ne peut pas être vide');
    if (prenom.isEmpty) throw ArgumentError('Le prénom ne peut pas être vide');
    if (documentSituation.isEmpty) throw ArgumentError('Le document de situation ne peut pas être vide');
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'nom': nom,
      'prenom': prenom,
      'document_situation': documentSituation,
      'type_beneficiaire': typeBeneficiaire.name,
    };
  }

  factory Beneficiaire.fromMap(Map<String, dynamic> map) {
    return Beneficiaire(
      id: map['id_acteur'],
      nom: map['nom'],
      prenom: map['prenom'],
      documentSituation: map['document_situation'],
      typeBeneficiaire: TypeBeneficiaire.values.byName(map['type_beneficiaire']),
      email: map['email'],
      motDePasse: map['mot_de_passe'],
      telephone: map['telephone'],
      adresse: map['adresse'],
      numCarteIdentite: map['num_carte_identite'],
      latitude: map['location'] != null
          ? GeoUtils.parsePoint(map['location'])['latitude']
          : null,
      longitude: map['location'] != null
          ? GeoUtils.parsePoint(map['location'])['longitude']
          : null,
      profile: Profile.fromMap(map['profile']),
      dashboard: Dashboard.fromMap(map['dashboard']),
      zakats: [], // Load via separate query
    );
  }
}