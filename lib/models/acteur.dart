import 'package:email_validator/email_validator.dart';
import 'package:myapp/models/dashboard.dart';
import 'package:myapp/models/historique.dart';
import 'package:myapp/models/message.dart';
import 'package:myapp/models/note.dart';
import 'package:myapp/models/notification.dart';
import 'package:myapp/models/post.dart';

enum TypeActeur { admin, utilisateur }

class Acteur {
  final int? id;
  final TypeActeur typeA;
  final String email;
  final String motDePasse;
  final String numCarteIdentite;
  final Profile profile;
  final Dashboard dashboard;
  final List<Post>? posts;
  final List<Message>? messages;
  final List<Notification>? notifications;
  final List<Historique>? historiques;
  double _noteMoyenne = 0.0;

  Acteur({
    this.id,
    required this.typeA,
    required this.email,
    required this.motDePasse,
    required this.numCarteIdentite,
    required this.profile,
    required this.dashboard,
    this.posts = const [],
    this.messages = const [],
    this.notifications = const [],
    this.historiques = const [],
  }) {
    if (!EmailValidator.validate(email)) throw ArgumentError('Email invalide');
    if (motDePasse.length < 8) throw ArgumentError('Le mot de passe doit contenir au moins 8 caractères');
    if (numCarteIdentite.length > 18 || numCarteIdentite.length < 18) throw ArgumentError('Numéro de carte d’identité invalide');
  }

  double get noteMoyenne => _noteMoyenne;
  set noteMoyenne(double value) {
    if (value < 0 || value > 5) throw ArgumentError('La note doit être entre 0 et 5');
    _noteMoyenne = value;
  }

  Map<String, dynamic> toMap() {
    return {
      'id_acteur': id,
      'type_acteur': typeA.name,
      'email': email,
      'mot_de_passe': motDePasse,
      'num_carte_identite': numCarteIdentite,
      'id_profile': profile.idProfile,
      'id_dashboard': dashboard.idDashboard,
      'note_moyenne': _noteMoyenne,
    };
  }

  factory Acteur.fromMap(Map<String, dynamic> map) {
    final acteur = Acteur(
      id: map['id_acteur'],
      typeA: TypeActeur.values.byName(map['type_acteur']),
      email: map['email'],
      motDePasse: map['mot_de_passe'],
      numCarteIdentite: map['num_carte_identite'],
      profile: Profile.fromMap(map['profile']),
      dashboard: Dashboard.fromMap(map['dashboard']),
    );
    acteur._noteMoyenne = map['note_moyenne'] ?? 0.0;
    return acteur;
  }

  void calculateNoteMoyenne(List<Note> notes) {
    if (notes.isEmpty) {
      noteMoyenne = 0.0;
      return;
    }
    final average = notes.map((note) => note.note).reduce((a, b) => a + b) / notes.length;
    noteMoyenne = double.parse(average.toStringAsFixed(2));
  }
}

class Profile {
  final int? idProfile;
  final String? photoUrl;
  final String? bio;
  final int idDashboard;

  Profile({
    this.idProfile,
    this.photoUrl,
    this.bio,
    required this.idDashboard,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_profile': idProfile,
      'photo_url': photoUrl,
      'bio': bio,
      'id_dashboard': idDashboard,
    };
  }

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      idProfile: map['id_profile'],
      photoUrl: map['photo_url'],
      bio: map['bio'],
      idDashboard: map['id_dashboard'],
    );
  }
}