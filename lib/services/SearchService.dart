import 'package:myapp/models/commentaire.dart';
import 'package:myapp/models/like.dart';
import 'package:myapp/models/note.dart';
import 'package:myapp/models/post.dart';
import 'package:myapp/models/utilisateur.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum MotCles {
  urgence,
  eau,
  nourriture,
  affaire_scolaire,
  eidElFitr,
  eidElAdha,
  ramadan,
  sadaquah,
  yennayer,
  hiver,
  animaux,
  sante,
  medicament,
  marriage,
  mosquee,
  vetement,
  boisement,
  recyclage,
  autre,
  vetementHivers,
  inondations,
  tremblementDeTerre,
  refuges,
  femmes,
  reservoirsOxygene,
}

class SearchService {
  Map<MotCles, String> categoriesImages = {
    MotCles.urgence: 'assets/icons/Urgent-amico.ico',
    MotCles.eau: 'assets/icons/Bottleofwater-pana.ico',
    MotCles.nourriture: 'assets/icons/nourriture.ico',
    MotCles.affaire_scolaire: 'assets/icons/affaire_scolaire.ico',
    MotCles.eidElFitr: 'assets/icons/EidElFitr.ico',
    MotCles.eidElAdha: 'assets/icons/EidElAdha.ico',
    MotCles.ramadan: 'assets/icons/Ramadan.ico',
    MotCles.sadaquah: 'assets/icons/sadaquah.ico',
    MotCles.yennayer: 'assets/icons/Yanayer.ico',
    MotCles.hiver: 'assets/icons/Hiver.ico',
    MotCles.animaux: 'assets/icons/Animaux.ico',
    MotCles.sante: 'assets/icons/Sante.ico',
    MotCles.medicament: 'assets/icons/medicament.ico',
    MotCles.marriage: 'assets/icons/mariage.ico',
    MotCles.mosquee: 'assets/icons/mosquee.ico',
    MotCles.vetement: 'assets/icons/vetement.ico',
    MotCles.boisement: 'assets/icons/Boisement.ico',
    MotCles.recyclage: 'assets/icons/Recyclage.ico',
    MotCles.autre: 'assets/icons/autre1.ico',
    MotCles.vetementHivers: 'assets/icons/vetementHivers.ico',
    MotCles.inondations: 'assets/icons/Inondations.ico',
    MotCles.tremblementDeTerre: 'assets/icons/tremblementDeTerre.ico',
    MotCles.refuges: 'assets/icons/Refuges.ico',
    MotCles.femmes: 'assets/icons/femmes.ico',
    MotCles.reservoirsOxygene: 'assets/icons/Reservoirs_oxygene.ico',
  };

  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Post>> searchPosts({String query = '', MotCles? motCle}) async {
    try {
      // Build the initial query for posts
      var postQuery = _supabase
          .from('post')
          .select('*, don:id_don(*)')
          .order('id_post', ascending: false);

      // Apply search query if provided
  if (query.isNotEmpty) {
  final allPosts = await postQuery;
  return allPosts
      .where((post) => post['titre']?.toLowerCase().contains(query.toLowerCase()) ?? false)
      .map((post) => Post.fromMap(post))
      .toList();
   }

      final response = await postQuery;

      List<Post> posts = [];

      for (final postData in response) {
        Post post = Post.fromMap(postData);

        // Fetch motsCles
        var motsClesQuery = _supabase
            .from('post_mot_cle')
            .select('mot_cle:id_mot_cle(nom)')
            .eq('id_post', post.idPost ?? 0);

        final motsClesData = await motsClesQuery;
        List<MotCles> motsCles = motsClesData
            .map<MotCles>((item) => MotCles.values.firstWhere((e) => e.toString().split('.').last == item['mot_cle']['nom']))
            .toList();

        // Apply motCle filter if provided
        if (motCle != null && !motsCles.contains(motCle)) {
          continue; // Skip this post if it doesn't match the motCle filter
        }

        // Fetch notes
        final notesData = await _supabase
            .from('note')
            .select('*')
            .eq('id_post', post.idPost ?? 0);
        List<Note> notes = notesData.map<Note>((note) => Note.fromMap(note)).toList();

        // Fetch likes
        final likesData = await _supabase
            .from('like')
            .select('*')
            .eq('id_post', post.idPost ?? 0);
        List<Like> likes = likesData.map<Like>((like) => Like.fromMap(like)).toList();

        // Fetch commentaires
        final commentairesData = await _supabase
            .from('commentaire')
            .select('*')
            .eq('id_post', post.idPost ?? 0);
        List<Commentaire> commentaires = commentairesData
            .map<Commentaire>((comment) => Commentaire.fromMap(comment))
            .toList();

        // Fetch tagged users
        final tagsData = await _supabase
            .from('post_utilisateur_tag')
            .select('utilisateur:id_utilisateur(*)')
            .eq('id_post', post.idPost ?? 0);
        List<Utilisateur> utilisateursTaguer = tagsData
            .map<Utilisateur>((tag) => Utilisateur.fromMap(tag['utilisateur']))
            .toList();

        // Create the complete post
        Post completPost = Post(
          idPost: post.idPost,
          titre: post.titre,
          description: post.description,
          typePost: post.typePost,
          typeDon: post.typeDon,
          image: post.image,
          lieuActeur: post.lieuActeur,
          dateLimite: post.dateLimite,
          latitude: post.latitude,
          longitude: post.longitude,
          notes: notes,
          likes: likes,
          commentaires: commentaires,
          utilisateursTaguer: utilisateursTaguer,
          motsCles: motsCles,
          idActeur: post.idActeur,
          don: post.don,
        );

        completPost.calculateNoteMoyenne();
        posts.add(completPost);
      }

      return posts;
    } catch (e) {
      print('Error in searchPosts: $e');
      throw Exception('Failed to search posts: $e');
    }
  }
}