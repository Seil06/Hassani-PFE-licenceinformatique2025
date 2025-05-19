import 'package:supabase_flutter/supabase_flutter.dart';

class PostService {
  final SupabaseClient _supabase;
  
  PostService({SupabaseClient? supabaseClient}) 
      : _supabase = supabaseClient ?? Supabase.instance.client;

  /// Fetches complete post data with all related information
  Future<Map<String, dynamic>?> fetchDataPost(int idPost) async {
    try {
      // Fetch the main post data with actor information
      final postResponse = await _supabase
          .from('post')
          .select('''
            *,
            acteur:id_acteur(
              id_acteur,
              email,
              type_acteur,
              note_moyenne,
              profile:id_profile(
                photo_url,
                bio
              )
            ),
            don:id_don(
              id_don,
              montant,
              type_don,
              etat_don,
              date_don
            )
          ''')
          .eq('id_post', idPost)
          .single();

      if (postResponse == null) return null;

      // Fetch comments for this post
      final commentairesResponse = await _supabase
          .from('commentaire')
          .select('''
            *,
            acteur:id_acteur(
              id_acteur,
              email,
              type_acteur,
              profile:id_profile(
                photo_url,
                bio
              )
            )
          ''')
          .eq('id_post', idPost)
          .order('date', ascending: false);

      // Fetch tagged users
      final taggedUsersResponse = await _supabase
          .from('post_utilisateur_tag')
          .select('''
            utilisateur:id_utilisateur(
              id_acteur,
              type_utilisateur,
              telephone,
              acteur:id_acteur(
                email,
                profile:id_profile(
                  photo_url,
                  bio
                )
              )
            )
          ''')
          .eq('id_post', idPost);

      // Fetch keywords/tags
      final motsClesResponse = await _supabase
          .from('post_mot_cle')
          .select('''
            mot_cle:id_mot_cle(
              id_mot_cle,
              nom
            )
          ''')
          .eq('id_post', idPost);

      // Fetch likes
      final likesResponse = await _supabase
          .from('like')
          .select('''
            *,
            utilisateur:id_utilisateur(
              id_acteur,
              acteur:id_acteur(
                email,
                profile:id_profile(
                  photo_url,
                  bio
                )
              )
            )
          ''')
          .eq('id_post', idPost);

      // Fetch notes/ratings
      final notesResponse = await _supabase
          .from('note')
          .select('''
            *,
            utilisateur_auteur:id_utilisateur_auteur(
              id_acteur,
              acteur:id_acteur(
                email,
                profile:id_profile(
                  photo_url,
                  bio
                )
              )
            )
          ''')
          .eq('id_post', idPost);

      // If this is a campaign post, fetch campaign details
      Map<String, dynamic>? campagneData;
      if (postResponse['type_post'] == 'campagne') {
        final campagneResponse = await _supabase
            .from('campagne')
            .select('''
              *,
              association:id_association(
                id_acteur,
                nom_association,
                statut_validation,
                acteur:id_acteur(
                  email,
                  profile:id_profile(
                    photo_url,
                    bio
                  )
                )
              )
            ''')
            .eq('id_campagne', idPost)
            .maybeSingle();
        
        if (campagneResponse != null) {
          campagneData = campagneResponse;
          
          // Fetch campaign participants
          final participantsResponse = await _supabase
              .from('participants_campagne')
              .select('''
                utilisateur:id_utilisateur(
                  id_acteur,
                  type_utilisateur,
                  acteur:id_acteur(
                    email,
                    profile:id_profile(
                      photo_url,
                      bio
                    )
                  )
                )
              ''')
              .eq('id_campagne', idPost);
          
          campagneData?['participants'] = participantsResponse;
        }
      }

      // Construct the complete post data
      return {
        'post': postResponse,
        'commentaires': commentairesResponse ?? [],
        'utilisateurs_tagges': taggedUsersResponse?.map((tag) => tag['utilisateur']).toList() ?? [],
        'mots_cles': motsClesResponse?.map((motCle) => motCle['mot_cle']).toList() ?? [],
        'likes': likesResponse ?? [],
        'notes': notesResponse ?? [],
        'campagne': campagneData,
        'stats': {
          'nb_commentaires': (commentairesResponse?.length ?? 0),
          'nb_likes': (likesResponse?.length ?? 0),
          'note_moyenne': postResponse['note_moyenne'] ?? 0.0,
        }
      };
    } catch (e) {
      print('Error fetching post data: $e');
      return null;
    }
  }

  /// Fetches all posts with their complete data
  Future<List<Map<String, dynamic>>> getAllPosts({
    int? limit,
    int? offset,
    String? typePost,
    List<String>? motsCles,
    String? orderBy = 'date_limite',
    bool ascending = false,
  }) async {
    try {
      dynamic query = _supabase
          .from('post')
          .select('id_post');

      // Apply filters
      if (typePost != null) {
        query = query.eq('type_post', typePost);
      }

      // Apply ordering
      if (orderBy != null) {
        query = query.order(orderBy, ascending: ascending);
      }

      // Apply pagination
      if (limit != null) {
        query = query.limit(limit);
      }
      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 100) - 1);
      }

      final postsResponse = await query;
      
      if (postsResponse.isEmpty) return [];

      List<Map<String, dynamic>> allPosts = [];
      
      // Fetch complete data for each post
      for (var post in postsResponse) {
        final completePost = await fetchDataPost(post['id_post']);
        if (completePost != null) {
          // Filter by keywords if specified
          if (motsCles != null && motsCles.isNotEmpty) {
            final postMotsCles = completePost['mots_cles'] as List;
            final postKeywords = postMotsCles.map((mc) => mc['nom'] as String).toList();
            
            bool hasMatchingKeyword = motsCles.any((keyword) => 
                postKeywords.contains(keyword));
            
            if (hasMatchingKeyword) {
              allPosts.add(completePost);
            }
          } else {
            allPosts.add(completePost);
          }
        }
      }

      return allPosts;
    } catch (e) {
      print('Error fetching all posts: $e');
      return [];
    }
  }

  /// Creates a post for a donateur (type: invite)
  Future<Map<String, dynamic>?> createPostDonateur({
  required String titre,
  required String description,
  required int idActeur,
  String? image,
  DateTime? dateLimite,
  double? latitude,
  double? longitude,
  List<String>? motsCles,
  List<int>? utilisateursTagges,
  }) async {
  try {
    // Create location point if coordinates provided
    String? locationPoint;
    if (latitude != null && longitude != null) {
      locationPoint = 'POINT($longitude $latitude)';
    }

    // Insert the post without donation reference
    final postResponse = await _supabase
        .from('post')
        .insert({
          'titre': titre,
          'description': description,
          'type_post': 'invite',
          'image': image,
          'date_limite': dateLimite?.toIso8601String(),
          'adresse_utilisateur': locationPoint,
          'note_moyenne': 0.0,
          'id_acteur': idActeur,
          'id_don': null, // Explicitly set to null
        })
        .select()
        .single();

    final postId = postResponse['id_post'];

    // Add keywords if provided
    if (motsCles != null && motsCles.isNotEmpty) {
      await _addMotsClestoPost(postId, motsCles);
    }

    // Add tagged users if provided
    if (utilisateursTagges != null && utilisateursTagges.isNotEmpty) {
      await _addTaggedUsersToPost(postId, utilisateursTagges);
    }

    return await fetchDataPost(postId);
  } catch (e) {
    print('Error creating post: $e');
    return null;
  }
}

Future<List> getFollowers(int idDonateur) async {
  try {
    final response = await _supabase
        .from('utilisateur_suivi')
        .select('''
          suiveur:id_suiveur(
            id_acteur,
            type_utilisateur,
            acteur:id_acteur(
              email,
              profile:id_profile(
                photo_url,
                bio
              )
            )
          )
        ''')
        .eq('id_suivi', idDonateur);

    return List<Map<String, dynamic>>.from(response)
        .map((e) => e['suiveur'])
        .toList();
  } catch (e) {
    print('Error fetching followers: $e');
    return [];
  }
}

  /// Creates a post for a beneficiaire (type: demande)
  Future<Map<String, dynamic>?> createPostBeneficiaire({
    required String titre,
    required String description,
    required int idActeur,
    String? image,
    DateTime? dateLimite,
    double? latitude,
    double? longitude,
    List<String>? motsCles,
    List<int>? utilisateursTagges,
  }) async {
    return await _createPost(
      titre: titre,
      description: description,
      typePost: 'demande',
      idActeur: idActeur,
      image: image,
      dateLimite: dateLimite,
      latitude: latitude,
      longitude: longitude,
      motsCles: motsCles,
      utilisateursTagges: utilisateursTagges,
    );
  }

  /// Creates a post for an admin (type: officiel)
  Future<Map<String, dynamic>?> createPostAdmin({
    required String titre,
    required String description,
    required int idActeur,
    String? image,
    DateTime? dateLimite,
    List<String>? motsCles,
    List<int>? utilisateursTagges,
  }) async {
    return await _createPost(
      titre: titre,
      description: description,
      typePost: 'officiel',
      idActeur: idActeur,
      image: image,
      dateLimite: dateLimite,
      latitude: null, // Admin posts don't have location
      longitude: null,
      motsCles: motsCles,
      utilisateursTagges: utilisateursTagges,
    );
  }

  /// Creates a campaign post (type: campagne)
  Future<Map<String, dynamic>?> createPostCampagne({
    required String titre,
    required String description,
    required int idActeur,
    required DateTime dateDebut,
    required DateTime dateFin,
    required double latitudeLieu,
    required double longitudeLieu,
    required String typeCampagne,
    String? image,
    double? montantObjectif,
    List<String>? motsCles,
    List<int>? utilisateursTagges,
  }) async {
    try {
      // First create the post
      final post = await _createPost(
        titre: titre,
        description: description,
        typePost: 'campagne',
        idActeur: idActeur,
        image: image,
        dateLimite: dateFin,
        latitude: null, // Campaign location is stored separately
        longitude: null,
        motsCles: motsCles,
        utilisateursTagges: utilisateursTagges,
      );

      if (post == null) return null;

      // Create the campaign entry
      final campagneResponse = await _supabase
          .from('campagne')
          .insert({
            'id_campagne': post['post']['id_post'],
            'etat_campagne': 'brouillon',
            'date_debut': dateDebut.toIso8601String(),
            'date_fin': dateFin.toIso8601String(),
            'lieu_evenement': 'POINT($longitudeLieu $latitudeLieu)',
            'type_campagne': typeCampagne,
            'montant_objectif': montantObjectif ?? 0.0,
            'montant_recolte': 0.0,
            'nombre_participants': 0,
            'id_association': idActeur,
          })
          .select()
          .single();

      // Fetch the complete campaign data
      return await fetchDataPost(post['post']['id_post']);
    } catch (e) {
      print('Error creating campaign post: $e');
      return null;
    }
  }

  /// Private method to create a post
  Future<Map<String, dynamic>?> _createPost({
    required String titre,
    required String description,
    required String typePost,
    required int idActeur,
    String? image,
    DateTime? dateLimite,
    double? latitude,
    double? longitude,
    List<String>? motsCles,
    List<int>? utilisateursTagges,
  }) async {
    try {
      // Create location point if coordinates provided
      String? locationPoint;
      if (latitude != null && longitude != null) {
        locationPoint = 'POINT($longitude $latitude)';
      }

      // Insert the post
      final postResponse = await _supabase
          .from('post')
          .insert({
            'titre': titre,
            'description': description,
            'type_post': typePost,
            'image': image,
            'date_limite': dateLimite?.toIso8601String(),
            'adresse_utilisateur': locationPoint,
            'note_moyenne': 0.0,
            'id_acteur': idActeur,
          })
          .select()
          .single();

      final postId = postResponse['id_post'];

      // Add keywords if provided
      if (motsCles != null && motsCles.isNotEmpty) {
        await _addMotsClestoPost(postId, motsCles);
      }

      // Add tagged users if provided
      if (utilisateursTagges != null && utilisateursTagges.isNotEmpty) {
        await _addTaggedUsersToPost(postId, utilisateursTagges);
      }

      // Fetch and return complete post data
      return await fetchDataPost(postId);
    } catch (e) {
      print('Error creating post: $e');
      return null;
    }
  }

  /// Adds keywords to a post
  Future<void> _addMotsClestoPost(int postId, List<String> motsCles) async {
    try {
      for (String motCle in motsCles) {
        // Get the mot_cle ID
        final motCleResponse = await _supabase
            .from('mot_cle')
            .select('id_mot_cle')
            .eq('nom', motCle)
            .single();

        if (motCleResponse != null) {
          await _supabase
              .from('post_mot_cle')
              .insert({
                'id_post': postId,
                'id_mot_cle': motCleResponse['id_mot_cle'],
              });
        }
      }
    } catch (e) {
      print('Error adding keywords to post: $e');
    }
  }

  /// Adds tagged users to a post
  Future<void> _addTaggedUsersToPost(int postId, List<int> utilisateursTagges) async {
    try {
      for (int userId in utilisateursTagges) {
        await _supabase
            .from('post_utilisateur_tag')
            .insert({
              'id_post': postId,
              'id_utilisateur': userId,
            });
      }
    } catch (e) {
      print('Error adding tagged users to post: $e');
    }
  }

  /// Deletes a post and all related data
  Future<bool> deletePost(int idPost) async {
    try {
      // Delete related data first (due to foreign key constraints)
      await _supabase.from('post_mot_cle').delete().eq('id_post', idPost);
      await _supabase.from('post_utilisateur_tag').delete().eq('id_post', idPost);
      await _supabase.from('commentaire').delete().eq('id_post', idPost);
      await _supabase.from('like').delete().eq('id_post', idPost);
      await _supabase.from('note').delete().eq('id_post', idPost);
      
      // Check if it's a campaign and delete campaign data
      final campagne = await _supabase
          .from('campagne')
          .select('id_campagne')
          .eq('id_campagne', idPost)
          .maybeSingle();
      
      if (campagne != null) {
        await _supabase.from('participants_campagne').delete().eq('id_campagne', idPost);
        await _supabase.from('campagne_suivi').delete().eq('id_campagne', idPost);
        await _supabase.from('rappel_evenement').delete().eq('id_campagne', idPost);
        await _supabase.from('campagne').delete().eq('id_campagne', idPost);
      }

      // Finally delete the post
      await _supabase.from('post').delete().eq('id_post', idPost);
      
      return true;
    } catch (e) {
      print('Error deleting post: $e');
      return false;
    }
  }

  /// Updates a post
  Future<Map<String, dynamic>?> updatePost({
    required int idPost,
    String? titre,
    String? description,
    String? image,
    DateTime? dateLimite,
    double? latitude,
    double? longitude,
    List<String>? motsCles,
    List<int>? utilisateursTagges,
  }) async {
    try {
      Map<String, dynamic> updateData = {};
      
      if (titre != null) updateData['titre'] = titre;
      if (description != null) updateData['description'] = description;
      if (image != null) updateData['image'] = image;
      if (dateLimite != null) updateData['date_limite'] = dateLimite.toIso8601String();
      
      if (latitude != null && longitude != null) {
        updateData['adresse_utilisateur'] = 'POINT($longitude $latitude)';
      }

      if (updateData.isNotEmpty) {
        await _supabase
            .from('post')
            .update(updateData)
            .eq('id_post', idPost);
      }

      // Update keywords if provided
      if (motsCles != null) {
        // Remove existing keywords
        await _supabase.from('post_mot_cle').delete().eq('id_post', idPost);
        // Add new keywords
        await _addMotsClestoPost(idPost, motsCles);
      }

      // Update tagged users if provided
      if (utilisateursTagges != null) {
        // Remove existing tagged users
        await _supabase.from('post_utilisateur_tag').delete().eq('id_post', idPost);
        // Add new tagged users
        await _addTaggedUsersToPost(idPost, utilisateursTagges);
      }

      // Return updated post data
      return await fetchDataPost(idPost);
    } catch (e) {
      print('Error updating post: $e');
      return null;
    }
  }

  /// Gets available keywords
  Future<List<Map<String, dynamic>>> getAvailableMotsCles() async {
    try {
      final response = await _supabase
          .from('mot_cle')
          .select('*')
          .order('nom');
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching keywords: $e');
      return [];
    }
  }

  /// Searches posts by title and description
  Future<List<Map<String, dynamic>>> searchPosts({
    required String searchTerm,
    int? limit,
    String? typePost,
  }) async {
    try {
      var query = _supabase
          .from('post')
          .select('id_post')
          .textSearch('titre,description', searchTerm);

      if (typePost != null) {
        query = query.eq('type_post', typePost);
      }

      // Chain .limit() directly without reassigning to query
      if (limit != null) {
        query = (query as dynamic).limit(limit);
      }

      final searchResults = await query;
      
      List<Map<String, dynamic>> posts = [];
      for (var result in searchResults) {
        final postData = await fetchDataPost(result['id_post']);
        if (postData != null) {
          posts.add(postData);
        }
      }

      return posts;
    } catch (e) {
      print('Error searching posts: $e');
      return [];
    }
  }

  /// Gets posts by location radius
  Future<List<Map<String, dynamic>>> getPostsByLocation({
    required double latitude,
    required double longitude,
    required double radiusInMeters,
    int? limit,
  }) async {
    try {
      final point = 'POINT($longitude $latitude)';
      
      final response = await _supabase
          .rpc('get_posts_within_radius', params: {
            'center_point': point,
            'radius_meters': radiusInMeters,
            'max_results': limit ?? 100,
          });

      List<Map<String, dynamic>> posts = [];
      for (var result in response) {
        final postData = await fetchDataPost(result['id_post']);
        if (postData != null) {
          posts.add(postData);
        }
      }

      return posts;
    } catch (e) {
      print('Error fetching posts by location: $e');
      return [];
    }
  }
}