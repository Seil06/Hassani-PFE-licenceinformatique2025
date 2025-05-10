import 'package:myapp/models/acteur.dart';
import 'package:myapp/models/dashboard.dart';

class Admin extends Acteur {
  final String nomAdmin;
  final String prenomAdmin;

  Admin({
    super.id,
    required this.nomAdmin,
    required this.prenomAdmin,
    required super.email,
    required super.motDePasse,
    required super.numCarteIdentite,
    required super.profile,
    required super.dashboard,
    super.posts = const [],
    super.messages = const [],
    super.notifications = const [],
    super.historiques = const [],
  }) : super(typeA: TypeActeur.admin) {
    if (nomAdmin.isEmpty) throw ArgumentError('Le nom ne peut pas être vide');
    if (prenomAdmin.isEmpty) throw ArgumentError('Le prénom ne peut pas être vide');
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'nom_admin': nomAdmin,
      'prenom_admin': prenomAdmin,
    };
  }

  factory Admin.fromMap(Map<String, dynamic> map) {
    return Admin(
      id: map['id_acteur'],
      nomAdmin: map['nom_admin'],
      prenomAdmin: map['prenom_admin'],
      email: map['email'],
      motDePasse: map['mot_de_passe'],
      numCarteIdentite: map['num_carte_identite'],
      profile: Profile.fromMap(map['profile']),
      dashboard: Dashboard.fromMap(map['dashboard']),
    );
  }
}