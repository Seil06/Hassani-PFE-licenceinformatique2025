import 'package:myapp/models/commentaire.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommentService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Commentaire>> getCommentsForPost(int postId) async {
    try {
      final response = await _supabase
          .from('commentaire')
          .select('*, acteur(id_acteur, email)')
          .eq('id_post', postId)
          .order('date', ascending: false);

      return response.map((map) => Commentaire.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des commentaires: $e');
    }
  }

  Future<List<Commentaire>> getCommentsForCampagne(int campagneId) async {
    try {
      final response = await _supabase
          .from('commentaire')
          .select('*, acteur(id_acteur, email)')
          .eq('id_campagne', campagneId)
          .order('date', ascending: false);

      return response.map((map) => Commentaire.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des commentaires: $e');
    }
  }

  Future<void> submitComment(Commentaire comment) async {
    try {
      await _supabase.from('commentaire').insert(comment.toMap());
    } catch (e) {
      throw Exception('Erreur lors de la soumission du commentaire: $e');
    }
  }
}