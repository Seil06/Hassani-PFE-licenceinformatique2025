import 'package:myapp/models/don.dart';
import 'package:myapp/services/SearchService.dart';
import 'package:myapp/models/note.dart';
import 'package:myapp/models/like.dart';
import 'package:myapp/models/commentaire.dart';
import 'package:myapp/models/utils.dart';
import 'package:myapp/models/utilisateur.dart';

enum TypePost { officiel, invite, demande, campagne }

class Post {
  final int? idPost;
  final String titre;
  final String description;
  final TypePost typePost;
  final TypeDon? typeDon;
  final String? image;
  final String lieuActeur;
  final DateTime? dateLimite;
  final double? latitude;
  final double? longitude;
  final List<Note> notes;
  final List<Like> likes;
  final List<Commentaire> commentaires;
  final List<Utilisateur> utilisateursTaguer;
  final List<MotCles> motsCles;
  final int idActeur;
  final Don? don;
  double _noteMoyenne = 0.0;

  Post({
    this.idPost,
    required this.titre,
    required this.description,
    required this.typePost,
    this.typeDon,
    this.image,
    required this.lieuActeur,
    this.dateLimite,
    this.latitude,
    this.longitude,
    this.notes = const [],
    this.likes = const [],
    this.commentaires = const [],
    this.utilisateursTaguer = const [],
    this.motsCles = const [],
    required this.idActeur,
    this.don,
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
      'type_don': typeDon?.name,
      'image': image,
      'adresse_utilisateur': latitude != null && longitude != null
          ? 'POINT($longitude $latitude)'
          : null,
      'date_limite': dateLimite?.toIso8601String(),
      'note_moyenne': _noteMoyenne,
      'id_acteur': idActeur,
      'id_don': don?.idDon,
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    final post = Post(
      idPost: map['id_post'],
      titre: map['titre'],
      description: map['description'],
      typePost: TypePost.values.byName(map['type_post']),
      typeDon: map['type_don'] != null ? TypeDon.values.byName(map['type_don']) : null,
      image: map['image'],
      lieuActeur: map['lieu_acteur'] ?? '',
      dateLimite: map['date_limite'] != null
          ? DateTime.parse(map['date_limite'])
          : null,
      latitude: map['adresse_utilisateur'] != null
          ? GeoUtils.parsePoint(map['adresse_utilisateur'])['latitude']
          : null,
      longitude: map['adresse_utilisateur'] != null
          ? GeoUtils.parsePoint(map['adresse_utilisateur'])['longitude']
          : null,
      motsCles: [], // Load via separate query
      idActeur: map['id_acteur'],
      don: map['id_don'] != null ? Don.fromMap(map['don']) : null,
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

  Post copyWith({
  int? idPost,
  String? titre,
  String? description,
  TypePost? typePost,
  TypeDon? typeDon,
  String? image,
  String? lieuActeur,
  DateTime? dateLimite,
  double? latitude,
  double? longitude,
  List<Note>? notes,
  List<Like>? likes,
  List<Commentaire>? commentaires,
  List<Utilisateur>? utilisateursTaguer,
  List<MotCles>? motsCles,
  int? idActeur,
  Don? don,
}) {
  return Post(
    idPost: idPost ?? this.idPost,
    titre: titre ?? this.titre,
    description: description ?? this.description,
    typePost: typePost ?? this.typePost,
    typeDon: typeDon ?? this.typeDon,
    image: image ?? this.image,
    lieuActeur: lieuActeur ?? this.lieuActeur,
    dateLimite: dateLimite ?? this.dateLimite,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    notes: notes ?? this.notes,
    likes: likes ?? this.likes,
    commentaires: commentaires ?? this.commentaires,
    utilisateursTaguer: utilisateursTaguer ?? this.utilisateursTaguer,
    motsCles: motsCles ?? this.motsCles,
    idActeur: idActeur ?? this.idActeur,
    don: don ?? this.don,
  ).._noteMoyenne = this._noteMoyenne;
}

 bool get isCampagne => typePost == TypePost.campagne;

}