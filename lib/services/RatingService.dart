import 'package:supabase_flutter/supabase_flutter.dart';

class RatingService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> submitRating({
    required double rating,
    int? postId,
    int? campagneId,
    required int userId,
  }) async {
    try {
      // Check if the user has already rated this post/campaign
      final existingRating = await _supabase
          .from('note')
          .select()
          .eq('id_utilisateur_auteur', userId)
          .eq(postId != null ? 'id_post' : 'id_campagne', postId ?? campagneId!)
          .maybeSingle();

      if (existingRating != null) {
        // Update existing rating
        await _supabase
            .from('note')
            .update({
              'note': rating,
              'date': DateTime.now().toIso8601String(),
            })
            .eq('id_utilisateur_auteur', userId)
            .eq(postId != null ? 'id_post' : 'id_campagne', postId ?? campagneId!);
      } else {
        // Insert new rating
        await _supabase.from('note').insert({
          'note': rating,
          'date': DateTime.now().toIso8601String(),
          'id_utilisateur_auteur': userId,
          'id_post': postId,
          'id_campagne': campagneId,
        });
      }
    } catch (e) {
      throw Exception('Erreur lors de la soumission de la note: $e');
    }
  }

  Future<double?> getUserRatingForPost(int postId, int userId) async {
    try {
      final response = await _supabase
          .from('note')
          .select('note')
          .eq('id_post', postId)
          .eq('id_utilisateur_auteur', userId)
          .maybeSingle();

      if (response != null) {
        return response['note']?.toDouble();
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la note: $e');
    }
  }

  Future<double?> getUserRatingForCampagne(int campagneId, int userId) async {
    try {
      final response = await _supabase
          .from('note')
          .select('note')
          .eq('id_campagne', campagneId)
          .eq('id_utilisateur_auteur', userId)
          .maybeSingle();

      if (response != null) {
        return response['note']?.toDouble();
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la note: $e');
    }
  }

  Future<double> getAverageRatingForPost(int postId) async {
    try {
      final response = await _supabase
          .from('note')
          .select('note')
          .eq('id_post', postId);

      if (response.isEmpty) return 0.0;

      final ratings = response.map((e) => (e['note'] as num).toDouble()).toList();
      return ratings.reduce((a, b) => a + b) / ratings.length;
    } catch (e) {
      throw Exception('Erreur lors du calcul de la note moyenne: $e');
    }
  }

  Future<double> getAverageRatingForCampagne(int campagneId) async {
    try {
      final response = await _supabase
          .from('note')
          .select('note')
          .eq('id_campagne', campagneId);

      if (response.isEmpty) return 0.0;

      final ratings = response.map((e) => (e['note'] as num).toDouble()).toList();
      return ratings.reduce((a, b) => a + b) / ratings.length;
    } catch (e) {
      throw Exception('Erreur lors du calcul de la note moyenne: $e');
    }
  }
}