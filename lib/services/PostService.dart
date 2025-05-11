import 'package:myapp/services/SearchService.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:myapp/models/post.dart';
import 'package:myapp/models/don.dart';
import 'package:myapp/models/note.dart';
import 'package:myapp/models/like.dart';
import 'package:myapp/models/commentaire.dart';
import 'package:myapp/models/utilisateur.dart';
import 'package:myapp/services/geo_utils.dart';

class PostService {
  final SupabaseClient _supabase;

  PostService(this._supabase);

  /// Récupère tous les posts avec leurs relations en une seule requête
  Future<List<Post>> getAllPosts() async {
    try {
      final response = await _supabase
          .from('post')
          .select('''
              id_post, titre, description, type_post, image, date_limite, 
              adresse_utilisateur, note_moyenne, id_acteur, id_don,
              don!fk_don(*),
              post_mot_cle!left(id_post, id_mot_cle, mot_cle(nom)),
              note(*),
              like(*),
              commentaire(*),
              post_utilisateur_tag!left(utilisateur!id_utilisateur(*))
          ''').neq('type_post', 'campagne')
          .order('id_post', ascending: false);

      print('Raw post response from PostService: $response'); // Debug log

      return response.map<Post>((data) {
        final motsClesData = data['post_mot_cle'] as List<dynamic>? ?? [];
        final motsCles = motsClesData
            .map((mc) => MotCles.values.byName((mc['mot_cle']['nom'] as String?) ?? 'autre'))
            .toList()
                .toList();
            if (motsCles.isEmpty) {
              motsCles.add(MotCles.autre);
            }

        double? latitude;
        double? longitude;
        if (data['adresse_utilisateur'] != null) {
          final coords = GeoUtils.parsePoint(data['adresse_utilisateur']);
          latitude = coords['latitude'];
          longitude = coords['longitude'];
        }

        final notes = (data['note'] as List<dynamic>? ?? [])
            .map((note) => Note.fromMap(note))
            .toList();

        final likes = (data['like'] as List<dynamic>? ?? [])
            .map((like) => Like.fromMap(like))
            .toList();

        final commentaires = (data['commentaire'] as List<dynamic>? ?? [])
            .map((comment) => Commentaire.fromMap(comment))
            .toList();

        final utilisateursTaguer = (data['post_utilisateur_tag'] as List<dynamic>? ?? [])
            .map((tag) => Utilisateur.fromMap(tag['utilisateur']))
            .toList();

        final post = Post(
          idPost: int.tryParse(data['id_post'].toString()) ?? 0,
          titre: data['titre']?.toString() ?? 'Titre inconnu',
          description: data['description']?.toString() ?? '',
          typePost: TypePost.values.byName(data['type_post']),
          typeDon: data['id_don'] != null && data['don'] != null && data['don']['type_don'] != null
              ? TypeDon.values.byName(data['don']['type_don'])
              : null,
          image: data['image']?.toString(),
          lieuActeur: '', // Adjust if lieu_acteur is stored elsewhere
          dateLimite: data['date_limite'] != null
              ? DateTime.tryParse(data['date_limite'].toString())
              : null,
          latitude: latitude,
          longitude: longitude,
          notes: notes,
          likes: likes,
          commentaires: commentaires,
          utilisateursTaguer: utilisateursTaguer,
          motsCles: motsCles,
          idActeur: int.tryParse(data['id_acteur'].toString()) ?? 0,
          don: data['id_don'] != null && data['don'] != null ? Don.fromMap(data['don']) : null,
        );

        post.calculateNoteMoyenne();
        return post;
      }).toList();
    } catch (e) {
      print('Erreur lors de la récupération des posts: $e');
      throw Exception('Échec de la récupération des posts: $e');
    }
  }

  /// Récupère un post spécifique avec toutes ses relations
  Future<Post> getPostById(int postId) async {
    try {
      final response = await _supabase
          .from('post')
          .select('''
              id_post, titre, description, type_post, image, date_limite, 
              adresse_utilisateur, note_moyenne, id_acteur, id_don,
              don!fk_don(*),
              post_mot_cle!left(id_post, id_mot_cle, mot_cle(nom)),
              note(*),
              like(*),
              commentaire(*),
              post_utilisateur_tag!left(utilisateur!id_utilisateur(*))
          ''').neq('type_post', 'campagne')
          .eq('id_post', postId)
          .single();

      final motsClesData = response['post_mot_cle'] as List<dynamic>? ?? [];
      final motsCles = motsClesData
          .map((mc) => MotCles.values.byName((mc['mot_cle']['nom'] as String?) ?? 'autre'))
          .toList()
              .toList();
          if (motsCles.isEmpty) {
            motsCles.add(MotCles.autre);
          }

      double? latitude;
      double? longitude;
      if (response['adresse_utilisateur'] != null) {
        final coords = GeoUtils.parsePoint(response['adresse_utilisateur']);
        latitude = coords['latitude'];
        longitude = coords['longitude'];
      }

      final notes = (response['note'] as List<dynamic>? ?? [])
          .map((note) => Note.fromMap(note))
          .toList();

      final likes = (response['like'] as List<dynamic>? ?? [])
          .map((like) => Like.fromMap(like))
          .toList();

      final commentaires = (response['commentaire'] as List<dynamic>? ?? [])
          .map((comment) => Commentaire.fromMap(comment))
          .toList();

      final utilisateursTaguer = (response['post_utilisateur_tag'] as List<dynamic>? ?? [])
          .map((tag) => Utilisateur.fromMap(tag['utilisateur']))
          .toList();

      final post = Post(
        idPost: int.tryParse(response['id_post'].toString()) ?? 0,
        titre: response['titre']?.toString() ?? 'Titre inconnu',
        description: response['description']?.toString() ?? '',
        typePost: TypePost.values.byName(response['type_post']),
        typeDon: response['id_don'] != null && response['don'] != null && response['don']['type_don'] != null
            ? TypeDon.values.byName(response['don']['type_don'])
            : null,
        image: response['image']?.toString(),
        lieuActeur: '', // Adjust if lieu_acteur is stored elsewhere
        dateLimite: response['date_limite'] != null
            ? DateTime.tryParse(response['date_limite'].toString())
            : null,
        latitude: latitude,
        longitude: longitude,
        notes: notes,
        likes: likes,
        commentaires: commentaires,
        utilisateursTaguer: utilisateursTaguer,
        motsCles: motsCles,
        idActeur: int.tryParse(response['id_acteur'].toString()) ?? 0,
        don: response['id_don'] != null && response['don'] != null ? Don.fromMap(response['don']) : null,
      );

      post.calculateNoteMoyenne();
      return post;
    } catch (e) {
      print('Erreur lors de la récupération du post $postId: $e');
      throw Exception('Échec de la récupération du post: $e');
    }
  }

  /// Méthode pour récupérer les posts par type
  Future<List<Post>> getPostsByType(TypePost typePost) async {
    try {
      final response = await _supabase
          .from('post')
          .select('''
              id_post, titre, description, type_post, image, date_limite, 
              adresse_utilisateur, note_moyenne, id_acteur, id_don,
              don(*),
              post_mot_cle!left(id_post, id_mot_cle, mot_cle(nom)),
              note(*),
              like(*),
              commentaire(*),
              post_utilisateur_tag!left(utilisateur!id_utilisateur(*))
          ''').neq('type_post', 'campagne')
          .eq('type_post', typePost.name)
          .order('id_post', ascending: false);

      return response.map<Post>((data) {
        final motsClesData = data['post_mot_cle'] as List<dynamic>? ?? [];
        final motsCles = motsClesData
            .map((mc) => MotCles.values.byName((mc['mot_cle']['nom'] as String?) ?? 'autre'))
            .toList()
                .toList();
            if (motsCles.isEmpty) {
              motsCles.add(MotCles.autre);
            }

        double? latitude;
        double? longitude;
        if (data['adresse_utilisateur'] != null) {
          final coords = GeoUtils.parsePoint(data['adresse_utilisateur']);
          latitude = coords['latitude'];
          longitude = coords['longitude'];
        }

        final notes = (data['note'] as List<dynamic>? ?? [])
            .map((note) => Note.fromMap(note))
            .toList();

        final likes = (data['like'] as List<dynamic>? ?? [])
            .map((like) => Like.fromMap(like))
            .toList();

        final commentaires = (data['commentaire'] as List<dynamic>? ?? [])
            .map((comment) => Commentaire.fromMap(comment))
            .toList();

        final utilisateursTaguer = (data['post_utilisateur_tag'] as List<dynamic>? ?? [])
            .map((tag) => Utilisateur.fromMap(tag['utilisateur']))
            .toList();

        final post = Post(
          idPost: int.tryParse(data['id_post'].toString()) ?? 0,
          titre: data['titre']?.toString() ?? 'Titre inconnu',
          description: data['description']?.toString() ?? '',
          typePost: TypePost.values.byName(data['type_post']),
          typeDon: data['id_don'] != null && data['don'] != null && data['don']['type_don'] != null
              ? TypeDon.values.byName(data['don']['type_don'])
              : null,
          image: data['image']?.toString(),
          lieuActeur: '', // Adjust if lieu_acteur is stored elsewhere
          dateLimite: data['date_limite'] != null
              ? DateTime.tryParse(data['date_limite'].toString())
              : null,
          latitude: latitude,
          longitude: longitude,
          notes: notes,
          likes: likes,
          commentaires: commentaires,
          utilisateursTaguer: utilisateursTaguer,
          motsCles: motsCles,
          idActeur: int.tryParse(data['id_acteur'].toString()) ?? 0,
          don: data['id_don'] != null && data['don'] != null ? Don.fromMap(data['don']) : null,
        );

        post.calculateNoteMoyenne();
        return post;
      }).toList();
    } catch (e) {
      print('Erreur lors de la récupération des posts de type ${typePost.name}: $e');
      throw Exception('Échec de la récupération des posts: $e');
    }
  }

  /// Méthode pour créer un nouveau post
  Future<Post> createPost(Post post) async {
    try {
      // Insertion du post
      final responsePost = await _supabase
          .from('post')
          .insert(post.toMap())
          .select('*') //neither .neq and .not('type_post', 'eq', 'campagne') was defined
          .single();

      int postId = responsePost['id_post'];

      // Ajout des mots-clés
      for (var motCle in post.motsCles) {
        final motsCleBD = await _supabase
            .from('mot_cle')
            .select('id_mot_cle')
            .eq('nom', motCle.name)
            .single();

        int motCleId = motsCleBD['id_mot_cle'];

        await _supabase
            .from('post_mot_cle')
            .insert({
              'id_post': postId,
              'id_mot_cle': motCleId
            });
      }

      // Tagging des utilisateurs
      for (var utilisateur in post.utilisateursTaguer) {
        await _supabase
            .from('post_utilisateur_tag')
            .insert({
              'id_post': postId,
              'id_utilisateur': utilisateur.idActeur
            });
      }

      // Récupérer le post complet
      return await getPostById(postId);
    } catch (e) {
      print('Erreur lors de la création du post: $e');
      throw Exception('Échec de la création du post: $e');
    }
  }

  /// Méthode pour mettre à jour un post
  Future<Post> updatePost(Post post) async {
    try {
      if (post.idPost == null) {
        throw ArgumentError('ID du post requis pour la mise à jour');
      }

      // Mise à jour du post
      await _supabase
          .from('post')
          .update(post.toMap()).neq('type_post', 'campagne')
          .eq('id_post', post.idPost ?? (throw ArgumentError('post.idPost cannot be null')));

      // Mettre à jour les mots-clés si nécessaire
      // D'abord supprimer les anciens
      await _supabase.from('post_mot_cle').delete().eq('id_post', post.idPost ?? (throw ArgumentError('post.idPost cannot be null')));

      // Puis ajouter les nouveaux
      for (var motCle in post.motsCles) {
        final motsCleBD = await _supabase
            .from('mot_cle')
            .select('id_mot_cle')
            .eq('nom', motCle.name)
            .single();

        int motCleId = motsCleBD['id_mot_cle'];

        await _supabase
            .from('post_mot_cle')
            .insert({
              'id_post': post.idPost,
              'id_mot_cle': motCleId
            });
      }

      // Mettre à jour les tags d'utilisateurs
      await _supabase.from('post_utilisateur_tag').delete().eq('id_post', post.idPost!);
      for (var utilisateur in post.utilisateursTaguer) {
        await _supabase
            .from('post_utilisateur_tag')
            .insert({
              'id_post': post.idPost,
              'id_utilisateur': utilisateur.idActeur
            });
      }

      // Récupérer le post mis à jour
      return await getPostById(post.idPost!);
    } catch (e) {
      print('Erreur lors de la mise à jour du post: $e');
      throw Exception('Échec de la mise à jour du post: $e');
    }
  }

  /// Méthode pour supprimer un post
  Future<void> deletePost(int postId) async {
    try {
      // Supprimer les relations en premier
      await _supabase.from('post_mot_cle').delete().eq('id_post', postId);
      await _supabase.from('post_utilisateur_tag').delete().eq('id_post', postId);
      await _supabase.from('like').delete().eq('id_post', postId);
      await _supabase.from('commentaire').delete().eq('id_post', postId);
      await _supabase.from('note').delete().eq('id_post', postId);

      // Enfin, supprimer le post
      await _supabase.from('post').delete().eq('id_post', postId);
    } catch (e) {
      print('Erreur lors de la suppression du post: $e');
      throw Exception('Échec de la suppression du post: $e');
    }
  }
}