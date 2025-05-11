import 'package:myapp/models/association.dart';
import 'package:myapp/models/don.dart';
import 'package:myapp/services/SearchService.dart';
import 'package:myapp/services/geo_utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CampagneService {
  final SupabaseClient _client;

  CampagneService(this._client);

  /// Fetch all campaigns from the database with related data
  Future<List<Campagne>> getAllCampagnes() async {
    try {
      final response = await _client
          .from('campagne')
          .select('''
              id_campagne, etat_campagne, date_debut, date_fin, 
              lieu_evenement, type_campagne, montant_objectif, montant_recolte, 
              nombre_participants, id_association,
              association(nom_association),
              post!id_campagne(
                id_post, titre, description, type_post, image, date_limite, 
                note_moyenne, id_acteur, id_don,
                post_mot_cle!left(id_post, id_mot_cle, mot_cle(nom))
              )
          ''')
          .order('date_debut', ascending: false);

      if (response.isEmpty) {
        throw Exception('No campaigns found');
      }

      return response.map<Campagne>((data) {
        final postData = data['post'] as Map<String, dynamic>? ?? {};
        final motsClesData = postData['post_mot_cle'] as List<dynamic>? ?? [];
        final motsCles = motsClesData
            .map((mc) => MotCles.values.byName((mc['mot_cle']['nom'] as String?) ?? 'autre'))
            .toList();

        TypeDon typeDon;
        switch (data['type_campagne']?.toString()) {
          case 'collecte':
            typeDon = TypeDon.materiel;
            break;
          case 'evenement':
            typeDon = TypeDon.service;
            break;
          case 'volontariat':
            typeDon = TypeDon.benevolat;
            break;
          case 'sensibilisation':
            typeDon = TypeDon.autre;
            break;
          default:
            typeDon = TypeDon.autre;
        }

        double? latitude;
        double? longitude;
        String? lieuEvenement;
        final lieuRaw = data['lieu_evenement'];
        final coords = GeoUtils.parsePoint(lieuRaw);
        latitude = coords['latitude'];
        longitude = coords['longitude'];
        lieuEvenement = lieuRaw?.toString();

        return Campagne(
          idPost: int.tryParse(data['id_campagne'].toString()) ?? 0,
          titre: postData['titre']?.toString() ?? 'Titre inconnu',
          description: postData['description']?.toString() ?? '',
          typeDon: typeDon,
          lieuActeur: postData['lieu_acteur']?.toString() ?? '',
          typeCampagne: data['type_campagne'] != null
              ? TypeCampagne.values.byName(data['type_campagne'].toString())
              : TypeCampagne.collecte,
          etatCampagne: data['etat_campagne'] != null
              ? EtatCampagne.values.byName(data['etat_campagne'].toString())
              : EtatCampagne.brouillon,
          dateDebut: data['date_debut'] != null
              ? DateTime.tryParse(data['date_debut'].toString())
              : null,
          dateFin: data['date_fin'] != null
              ? DateTime.tryParse(data['date_fin'].toString())
              : null,
          lieuEvenement: lieuEvenement,
          montantObjectif: double.tryParse(data['montant_objectif']?.toString() ?? '0') ?? 0.0,
          montantRecolte: double.tryParse(data['montant_recolte']?.toString() ?? '0') ?? 0.0,
          nombreParticipants: int.tryParse(data['nombre_participants']?.toString() ?? '0') ?? 0,
          image: postData['image']?.toString(),
          dateLimite: postData['date_limite'] != null
              ? DateTime.tryParse(postData['date_limite'].toString())
              : null,
          latitude: latitude,
          longitude: longitude,
          idActeur: int.tryParse(postData['id_acteur']?.toString() ?? '0') ?? 0,
          idAssociation: int.tryParse(data['id_association']?.toString() ?? '0') ?? 0,
          motsCles: motsCles,
        );
      }).toList();
    } catch (e) {
      print('Error fetching campaigns: $e');
      throw Exception('Failed to fetch campaigns: $e');
    }
  }

  /// Fetch campaigns by association ID
  Future<List<Campagne>> getCampagnesByAssociation(int associationId) async {
    try {
      final response = await _client
          .from('campagne')
          .select('''
              id_campagne, etat_campagne, date_debut, date_fin, 
              lieu_evenement, type_campagne, montant_objectif, montant_recolte, 
              nombre_participants, id_association,
              association(nom_association),
              post!id_campagne(
                id_post, titre, description, type_post, image, date_limite, 
                note_moyenne, id_acteur, id_don,
                post_mot_cle!left(id_post, id_mot_cle, mot_cle(nom))
              )
          ''')
          .eq('id_association', associationId)
          .order('date_debut', ascending: false);

    if (response.isEmpty) {
        throw Exception('No campaigns found');
      }

      return response.map<Campagne>((data) {
        final postData = data['post'] as Map<String, dynamic>? ?? {};
        final motsClesData = postData['post_mot_cle'] as List<dynamic>? ?? [];
        final motsCles = motsClesData
            .map((mc) => MotCles.values.byName((mc['mot_cle']['nom'] as String?) ?? 'autre'))
            .toList();

        TypeDon typeDon;
        switch (data['type_campagne']?.toString()) {
          case 'collecte':
            typeDon = TypeDon.materiel;
            break;
          case 'evenement':
            typeDon = TypeDon.service;
            break;
          case 'volontariat':
            typeDon = TypeDon.benevolat;
            break;
          case 'sensibilisation':
            typeDon = TypeDon.autre;
            break;
          default:
            typeDon = TypeDon.autre;
        }

        double? latitude;
        double? longitude;
        String? lieuEvenement;
        final lieuRaw = data['lieu_evenement'];
        final coords = GeoUtils.parsePoint(lieuRaw);
        latitude = coords['latitude'];
        longitude = coords['longitude'];
        lieuEvenement = lieuRaw?.toString();

        return Campagne(
          idPost: int.tryParse(data['id_campagne'].toString()) ?? 0,
          titre: postData['titre']?.toString() ?? 'Titre inconnu',
          description: postData['description']?.toString() ?? '',
          typeDon: typeDon,
          lieuActeur: postData['lieu_acteur']?.toString() ?? '',
          typeCampagne: data['type_campagne'] != null
              ? TypeCampagne.values.byName(data['type_campagne'].toString())
              : TypeCampagne.collecte,
          etatCampagne: data['etat_campagne'] != null
              ? EtatCampagne.values.byName(data['etat_campagne'].toString())
              : EtatCampagne.brouillon,
          dateDebut: data['date_debut'] != null
              ? DateTime.tryParse(data['date_debut'].toString())
              : null,
          dateFin: data['date_fin'] != null
              ? DateTime.tryParse(data['date_fin'].toString())
              : null,
          lieuEvenement: lieuEvenement,
          montantObjectif: double.tryParse(data['montant_objectif']?.toString() ?? '0') ?? 0.0,
          montantRecolte: double.tryParse(data['montant_recolte']?.toString() ?? '0') ?? 0.0,
          nombreParticipants: int.tryParse(data['nombre_participants']?.toString() ?? '0') ?? 0,
          image: postData['image']?.toString(),
          dateLimite: postData['date_limite'] != null
              ? DateTime.tryParse(postData['date_limite'].toString())
              : null,
          latitude: latitude,
          longitude: longitude,
          idActeur: int.tryParse(postData['id_acteur']?.toString() ?? '0') ?? 0,
          idAssociation: int.tryParse(data['id_association']?.toString() ?? '0') ?? 0,
          motsCles: motsCles,
        );
      }).toList();
    } catch (e) {
      print('Error fetching campaigns by association: $e');
      throw Exception('Failed to fetch campaigns: $e');
    }
  }

  /// Fetch campaigns by campaign type
  Future<List<Campagne>> getCampagnesByType(TypeCampagne type) async {
    try {
      final response = await _client
          .from('campagne')
          .select('''
              id_campagne, etat_campagne, date_debut, date_fin, 
              lieu_evenement, type_campagne, montant_objectif, montant_recolte, 
              nombre_participants, id_association,
              association(nom_association),
              post!id_campagne(
                id_post, titre, description, type_post, image, date_limite, 
                note_moyenne, id_acteur, id_don,
                post_mot_cle!left(id_post, id_mot_cle, mot_cle(nom))
              )
          ''')
          .eq('type_campagne', type.name)
          .order('date_debut', ascending: false);

      if (response.isEmpty) {
        throw Exception('Failed to fetch campaigns');
      }

      return response.map<Campagne>((data) {
        final postData = data['post'] as Map<String, dynamic>? ?? {};
        final motsClesData = postData['post_mot_cle'] as List<dynamic>? ?? [];
        final motsCles = motsClesData
            .map((mc) => MotCles.values.byName((mc['mot_cle']['nom'] as String?) ?? 'autre'))
            .toList();

        TypeDon typeDon;
        switch (data['type_campagne']?.toString()) {
          case 'collecte':
            typeDon = TypeDon.materiel;
            break;
          case 'evenement':
            typeDon = TypeDon.service;
            break;
          case 'volontariat':
            typeDon = TypeDon.benevolat;
            break;
          case 'sensibilisation':
            typeDon = TypeDon.autre;
            break;
          default:
            typeDon = TypeDon.autre;
        }

        double? latitude;
        double? longitude;
        String? lieuEvenement;
        final lieuRaw = data['lieu_evenement'];
        final coords = GeoUtils.parsePoint(lieuRaw);
        latitude = coords['latitude'];
        longitude = coords['longitude'];
        lieuEvenement = lieuRaw?.toString();

        return Campagne(
          idPost: int.tryParse(data['id_campagne'].toString()) ?? 0,
          titre: postData['titre']?.toString() ?? 'Titre inconnu',
          description: postData['description']?.toString() ?? '',
          typeDon: typeDon,
          lieuActeur: postData['lieu_acteur']?.toString() ?? '',
          typeCampagne: data['type_campagne'] != null
              ? TypeCampagne.values.byName(data['type_campagne'].toString())
              : TypeCampagne.collecte,
          etatCampagne: data['etat_campagne'] != null
              ? EtatCampagne.values.byName(data['etat_campagne'].toString())
              : EtatCampagne.brouillon,
          dateDebut: data['date_debut'] != null
              ? DateTime.tryParse(data['date_debut'].toString())
              : null,
          dateFin: data['date_fin'] != null
              ? DateTime.tryParse(data['date_fin'].toString())
              : null,
          lieuEvenement: lieuEvenement,
          montantObjectif: double.tryParse(data['montant_objectif']?.toString() ?? '0') ?? 0.0,
          montantRecolte: double.tryParse(data['montant_recolte']?.toString() ?? '0') ?? 0.0,
          nombreParticipants: int.tryParse(data['nombre_participants']?.toString() ?? '0') ?? 0,
          image: postData['image']?.toString(),
          dateLimite: postData['date_limite'] != null
              ? DateTime.tryParse(postData['date_limite'].toString())
              : null,
          latitude: latitude,
          longitude: longitude,
          idActeur: int.tryParse(postData['id_acteur']?.toString() ?? '0') ?? 0,
          idAssociation: int.tryParse(data['id_association']?.toString() ?? '0') ?? 0,
          motsCles: motsCles,
        );
      }).toList();
    } catch (e) {
      print('Error fetching campaigns by type: $e');
      throw Exception('Failed to fetch campaigns: $e');
    }
  }

  /// Fetch campaigns by state
  Future<List<Campagne>> getCampagnesByState(EtatCampagne state) async {
    try {
      final response = await _client
          .from('campagne')
          .select('''
              id_campagne, etat_campagne, date_debut, date_fin, 
              lieu_evenement, type_campagne, montant_objectif, montant_recolte, 
              nombre_participants, id_association,
              association(nom_association),
              post!id_campagne(
                id_post, titre, description, type_post, image, date_limite, 
                note_moyenne, id_acteur, id_don,
                post_mot_cle!left(id_post, id_mot_cle, mot_cle(nom))
              )
          ''')
          .eq('etat_campagne', state.name)
          .order('date_debut', ascending: false);

      if (response.isEmpty) {
        throw Exception('Failed to fetch campaigns');
      }

      return response.map<Campagne>((data) {
        final postData = data['post'] as Map<String, dynamic>? ?? {};
        final motsClesData = postData['post_mot_cle'] as List<dynamic>? ?? [];
        final motsCles = motsClesData
            .map((mc) => MotCles.values.byName((mc['mot_cle']['nom'] as String?) ?? 'autre'))
            .toList();

        TypeDon typeDon;
        switch (data['type_campagne']?.toString()) {
          case 'collecte':
            typeDon = TypeDon.materiel;
            break;
          case 'evenement':
            typeDon = TypeDon.service;
            break;
          case 'volontariat':
            typeDon = TypeDon.benevolat;
            break;
          case 'sensibilisation':
            typeDon = TypeDon.autre;
            break;
          default:
            typeDon = TypeDon.autre;
        }

        double? latitude;
        double? longitude;
        String? lieuEvenement;
        final lieuRaw = data['lieu_evenement'];
        final coords = GeoUtils.parsePoint(lieuRaw);
        latitude = coords['latitude'];
        longitude = coords['longitude'];
        lieuEvenement = lieuRaw?.toString();

        return Campagne(
          idPost: int.tryParse(data['id_campagne'].toString()) ?? 0,
          titre: postData['titre']?.toString() ?? 'Titre inconnu',
          description: postData['description']?.toString() ?? '',
          typeDon: typeDon,
          lieuActeur: postData['lieu_acteur']?.toString() ?? '',
          typeCampagne: data['type_campagne'] != null
              ? TypeCampagne.values.byName(data['type_campagne'].toString())
              : TypeCampagne.collecte,
          etatCampagne: data['etat_campagne'] != null
              ? EtatCampagne.values.byName(data['etat_campagne'].toString())
              : EtatCampagne.brouillon,
          dateDebut: data['date_debut'] != null
              ? DateTime.tryParse(data['date_debut'].toString())
              : null,
          dateFin: data['date_fin'] != null
              ? DateTime.tryParse(data['date_fin'].toString())
              : null,
          lieuEvenement: lieuEvenement,
          montantObjectif: double.tryParse(data['montant_objectif']?.toString() ?? '0') ?? 0.0,
          montantRecolte: double.tryParse(data['montant_recolte']?.toString() ?? '0') ?? 0.0,
          nombreParticipants: int.tryParse(data['nombre_participants']?.toString() ?? '0') ?? 0,
          image: postData['image']?.toString(),
          dateLimite: postData['date_limite'] != null
              ? DateTime.tryParse(postData['date_limite'].toString())
              : null,
          latitude: latitude,
          longitude: longitude,
          idActeur: int.tryParse(postData['id_acteur']?.toString() ?? '0') ?? 0,
          idAssociation: int.tryParse(data['id_association']?.toString() ?? '0') ?? 0,
          motsCles: motsCles,
        );
      }).toList();
    } catch (e) {
      print('Error fetching campaigns by state: $e');
      throw Exception('Failed to fetch campaigns: $e');
    }
  }

  /// Fetch campaign participants
  Future<List<int>> getCampagneParticipants(int campaignId) async {
    try {
      final response = await _client
          .from('don')
          .select('donateur!id_donateur(id_acteur)')
          .eq('id_campagne', campaignId);

      if (response.isEmpty) {
        throw Exception('Failed to fetch campaign participants');
      }

      return List<int>.from(response.map((item) => item['donateur']['id_acteur'] as int));
    } catch (e) {
      print('Error fetching campaign participants: $e');
      throw Exception('Failed to fetch campaign participants: $e');
    }
  }

  /// Fetch campaign followers
  Future<List<int>> getCampagneFollowers(int campaignId) async {
    try {
      final response = await _client
          .from('campagne_suivi')
          .select('id_utilisateur')
          .eq('id_campagne', campaignId);

      if (response.isEmpty) {
        throw Exception('Failed to fetch campaign followers');
      }

      return List<int>.from(response.map((item) => item['id_utilisateur'] as int));
    } catch (e) {
      print('Error fetching campaign followers: $e');
      throw Exception('Failed to fetch campaign followers: $e');
    }
  }

  /// Create a new campaign
  Future<Campagne> createCampagne(Campagne campagne) async {
    try {
      // First create the post
      final postData = {
        'titre': campagne.titre,
        'description': campagne.description,
        'type_post': 'campagne',
        'type_don': campagne.typeDon?.name,
        'image': campagne.image,
        'date_limite': campagne.dateLimite?.toIso8601String(),
        'adresse_utilisateur': campagne.latitude != null && campagne.longitude != null
            ? GeoUtils.pointToString(campagne.latitude!, campagne.longitude!)
            : null,
        'lieu_acteur': campagne.lieuActeur,
        'id_acteur': campagne.idActeur,
      };

      final postResponse = await _client.from('post').insert(postData).select('id_post').single();

      if (postResponse.isEmpty) {
        throw Exception('Failed to create post for campaign');
      }

      final postId = postResponse['id_post'] as int;

      // Now create the campaign with the post ID
      final campaignData = {
        'id_campagne': postId,
        'etat_campagne': campagne.etatCampagne.name,
        'date_debut': campagne.dateDebut?.toIso8601String(),
        'date_fin': campagne.dateFin?.toIso8601String(),
        'lieu_evenement': campagne.lieuEvenement != null
            ? GeoUtils.pointToString(campagne.latitude!, campagne.longitude!)
            : null,
        'type_campagne': campagne.typeCampagne.name,
        'montant_objectif': campagne.montantObjectif,
        'montant_recolte': campagne.montantRecolte,
        'nombre_participants': campagne.nombreParticipants,
        'id_association': campagne.idAssociation,
      };

      await _client.from('campagne').insert(campaignData);

      // Add campaign tags/keywords if provided
      if (campagne.motsCles.isNotEmpty) {
        final tagsData = campagne.motsCles.map((tag) async {
          final motCleBD = await _client
              .from('mot_cle')
              .select('id_mot_cle')
              .eq('nom', tag.name)
              .single();
          return {
            'id_post': postId,
            'id_mot_cle': motCleBD['id_mot_cle'],
          };
        }).toList();

        // Wait for all tag insertions
        for (var tag in tagsData) {
          await _client.from('post_mot_cle').insert(tag);
        }
      }

      return campagne.copyWith(idPost: postId);
    } catch (e) {
      print('Error creating campaign: $e');
      throw Exception('Failed to create campaign: $e');
    }
  }

  /// Update an existing campaign
  Future<void> updateCampagne(Campagne campagne) async {
    try {
      if (campagne.idPost == null) {
        throw Exception('Campaign ID is required for update');
      }

      // Update post data
      final postData = {
        'titre': campagne.titre,
        'description': campagne.description,
        'type_don': campagne.typeDon?.name,
        'image': campagne.image,
        'date_limite': campagne.dateLimite?.toIso8601String(),
        'adresse_utilisateur': campagne.latitude != null && campagne.longitude != null
            ? GeoUtils.pointToString(campagne.latitude!, campagne.longitude!)
            : null,
        'lieu_acteur': campagne.lieuActeur,
      };

      await _client
          .from('post')
          .update(postData)
          .eq('id_post', campagne.idPost ?? (throw Exception('idPost cannot be null')));

      // Update campaign data
      final campaignData = {
        'etat_campagne': campagne.etatCampagne.name,
        'date_debut': campagne.dateDebut?.toIso8601String(),
        'date_fin': campagne.dateFin?.toIso8601String(),
        'lieu_evenement': campagne.lieuEvenement != null
            ? GeoUtils.pointToString(campagne.latitude!, campagne.longitude!)
            : null,
        'type_campagne': campagne.typeCampagne.name,
        'montant_objectif': campagne.montantObjectif,
        'montant_recolte': campagne.montantRecolte,
        'nombre_participants': campagne.nombreParticipants,
      };

      await _client
          .from('campagne')
          .update(campaignData)
          .eq('id_campagne', campagne.idPost ?? (throw Exception('idPost cannot be null')));

      // Update keywords if changed
      if (campagne.idPost != null) {
        await _client.from('post_mot_cle').delete().eq('id_post', campagne.idPost!);
      } else {
        throw Exception('idPost cannot be null');
      }
      if (campagne.motsCles.isNotEmpty) {
        final tagsData = campagne.motsCles.map((tag) async {
          final motCleBD = await _client
              .from('mot_cle')
              .select('id_mot_cle')
              .eq('nom', tag.name)
              .single();
          return {
            'id_post': campagne.idPost,
            'id_mot_cle': motCleBD['id_mot_cle'],
          };
        }).toList();

        for (var tag in tagsData) {
          await _client.from('post_mot_cle').insert(tag);
        }
      }
    } catch (e) {
      print('Error updating campaign: $e');
      throw Exception('Failed to update campaign: $e');
    }
  }

  /// Delete a campaign
  Future<void> deleteCampagne(int campaignId) async {
    try {
      // Note: Due to foreign key constraints, deleting from post table will cascade to campaign
      await _client.from('post').delete().eq('id_post', campaignId);
    } catch (e) {
      print('Error deleting campaign: $e');
      throw Exception('Failed to delete campaign: $e');
    }
  }
}