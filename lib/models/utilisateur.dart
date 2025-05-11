import 'package:myapp/models/acteur.dart';
import 'package:myapp/models/dashboard.dart';
import 'package:myapp/models/utils.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum TypeUtilisateur { donateur, association, beneficiaire }

class Avertissement {
  final int? idAvertissement;
  final String message;
  final DateTime date;
  final int idAdmin;
  final int idUtilisateur;

  Avertissement({
    this.idAvertissement,
    required this.message,
    required this.date,
    required this.idAdmin,
    required this.idUtilisateur,
  }) {
    if (message.isEmpty) throw ArgumentError('Le message de l’avertissement ne peut pas être vide');
  }

  Map<String, dynamic> toMap() {
    return {
      'id_avertissement': idAvertissement,
      'message': message,
      'date': date.toIso8601String(),
      'id_admin': idAdmin,
      'id_utilisateur': idUtilisateur,
    };
  }

  factory Avertissement.fromMap(Map<String, dynamic> map) {
    return Avertissement(
      idAvertissement: map['id_avertissement'],
      message: map['message'],
      date: DateTime.parse(map['date']),
      idAdmin: map['id_admin'],
      idUtilisateur: map['id_utilisateur'],
    );
  }
}

class Utilisateur extends Acteur {
  final TypeUtilisateur typeU;
  final String? telephone;
  final String adresse;
  double? latitude;
  double? longitude;
  final List<Utilisateur> followers;
  final List<Avertissement> avertissements;

  Utilisateur({
    super.id,
    required this.typeU,
    required super.email,
    required super.motDePasse,
    required super.numCarteIdentite,
    required super.profile,
    required super.dashboard,
    this.telephone,
    required this.adresse,
    this.latitude,
    this.longitude,
    super.posts = const [],
    super.messages = const [],
    super.notifications = const [],
    super.historiques = const [],
    this.followers = const [],
    this.avertissements = const [],
  }) : super(typeA: TypeActeur.utilisateur) {
    if (telephone != null && !RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(telephone!)) {
      throw ArgumentError('Numéro de téléphone invalide');
    }
    if (adresse.isEmpty) throw ArgumentError('L’adresse ne peut pas être vide');
  }

   int get idActeur => id ?? (throw Exception('idActeur cannot be null')); // Use 'id' inherited from the Acteur class

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'type_utilisateur': typeU.name,
      'telephone': telephone,
      'adresse_utilisateur': latitude != null && longitude != null
          ? 'POINT($longitude $latitude)'
          : null,
      'adresse': adresse,
    };
  }

  factory Utilisateur.fromMap(Map<String, dynamic> map) {
    return Utilisateur(
      id: map['id_acteur'],
      typeU: TypeUtilisateur.values.byName(map['type_utilisateur']),
      email: map['email'],
      motDePasse: map['mot_de_passe'],
      numCarteIdentite: map['num_carte_identite'],
      profile: Profile.fromMap(map['profile']),
      dashboard: Dashboard.fromMap(map['dashboard']),
      telephone: map['telephone'],
      adresse: map['adresse'] ?? '',
      latitude: map['adresse_utilisateur'] != null
          ? GeoUtils.parsePoint(map['adresse_utilisateur'])['latitude']
          : null,
      longitude: map['adresse_utilisateur'] != null
          ? GeoUtils.parsePoint(map['adresse_utilisateur'])['longitude']
          : null,
      followers: [], // Load via separate query
      avertissements: [], // Load via separate query
    );
  }

  Future<void> updateLocalisation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Les services de localisation sont désactivés');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permission de localisation refusée');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Permission de localisation refusée de manière permanente');
      }

      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );

      Position position = await Geolocator.getCurrentPosition();
      latitude = position.latitude;
      longitude = position.longitude;

      final supabase = Supabase.instance.client;
      await supabase.from('utilisateur').update({
        'adresse_utilisateur': 'POINT(${position.longitude} ${position.latitude})',
      }).eq('id_acteur', id!);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de la localisation: $e');
    }
  }
}