import 'package:myapp/services/SearchService.dart';
import 'package:myapp/models/note.dart';
import 'package:myapp/models/like.dart';
import 'package:myapp/models/commentaire.dart';
import 'package:myapp/models/utils.dart';
import 'package:myapp/models/utilisateur.dart';

enum TypePost { officiel, offre, demande, campagne }
enum TypeDon { financier, materiel, alimentaire, medicament, benevolat, service, autre }

class Post {
  final int? idPost;
  final String titre;
  final String description;
  final TypePost typePost;
  final TypeDon typeDon;
  final String? image;
  final String? video;
  final String lieuActeur;
  final DateTime? dateLimite;
  final double? latitude;
  final double? longitude;
  final List<Note> notes;
  final List<Like> likes;
  final List<Commentaire> commentaires;
  final List<Utilisateur> utilisateursTaguer;
  final List<Mot_cles> motsCles;
  final int idActeur; // Added to store the actor who created the post
  double _noteMoyenne = 0.0;

  Post({
    this.idPost,
    required this.titre,
    required this.description,
    required this.typePost,
    required this.typeDon,
    this.image,
    this.video,
    required this.lieuActeur,
    this.dateLimite,
    this.latitude,
    this.longitude,
    this.notes = const [],
    this.likes = const [],
    this.commentaires = const [],
    this.utilisateursTaguer = const [],
    this.motsCles = const [],
    required this.idActeur, // Required field
  }) {
    if (titre.isEmpty) throw ArgumentError('Le titre ne peut pas être vide');
    if (description.isEmpty) throw ArgumentError('La description ne peut pas être vide');
    if (motsCles.isEmpty) throw ArgumentError('Un post doit avoir au moins un mot-clé');
  }

  double get noteMoyenne => _noteMoyenne;
  set noteMoyenne(double value) {
    if (value < 0 || value > 5) throw ArgumentError('La note doit être entre 0 et 5');
    _noteMoyenne = value;
  }

  Map<String, dynamic> toMap() {
    return {
      'id_post': idPost,
      'titre': titre,
      'description': description,
      'type_post': typePost.name,
      'type_don': typeDon.name,
      'image': image,
      'video': video,
      'lieu_acteur': lieuActeur,
      'date_limite': dateLimite?.toIso8601String(),
      'location': latitude != null && longitude != null
          ? 'POINT($longitude $latitude)'
          : null,
      'note_moyenne': _noteMoyenne,
      'id_acteur': idActeur, // Added to map
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    final post = Post(
      idPost: map['id_post'],
      titre: map['titre'],
      description: map['description'],
      typePost: TypePost.values.byName(map['type_post']),
      typeDon: TypeDon.values.byName(map['type_don']),
      image: map['image'],
      video: map['video'],
      lieuActeur: map['lieu_acteur'],
      dateLimite: map['date_limite'] != null
          ? DateTime.parse(map['date_limite'])
          : null,
      latitude: map['location'] != null
          ? GeoUtils.parsePoint(map['location'])['latitude']
          : null,
      longitude: map['location'] != null
          ? GeoUtils.parsePoint(map['location'])['longitude']
          : null,
      motsCles: [], // Load via separate query
      idActeur: map['id_acteur'], // Added to map
    );
    post._noteMoyenne = map['note_moyenne'] ?? 0.0;
    return post;
  }

  void calculateNoteMoyenne() {
    if (notes.isEmpty) {
      noteMoyenne = 0.0;
      return;
    }
    final average = notes.map((note) => note.note).reduce((a, b) => a + b) / notes.length;
    noteMoyenne = double.parse(average.toStringAsFixed(2));
  }
}