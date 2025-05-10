import 'package:myapp/models/post.dart';
import 'package:myapp/models/association.dart';
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
  boisement,
  recyclage,
  sante,
  medicament,
  marriage,
  mosquee,
  vetement,
  vetementHivers,
  inondations,
  tremblementDeTerre,
  refuges,
  femmes,
  reservoirsOxygene,
  autre,
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

  Future<List<dynamic>> searchContent({
    required String query,
    MotCles? motCle,
    double? latitude,
    double? longitude,
    double maxDistanceKm = 50.0,
    bool includePosts = true,
    bool includeCampagnes = true,
  }) async {
    final supabase = Supabase.instance.client;
    List<dynamic> results = [];

    // Search posts
    if (includePosts) {
      var postQuery = supabase
          .from('post')
          .select('*, post_mot_cle!inner(id_mot_cle, mot_cle(nom))');

      if (query.isNotEmpty) {
        postQuery = postQuery.or('titre.ilike.%$query%,description.ilike.%$query%');
      }

      if (motCle != null) {
        postQuery = postQuery.eq('post_mot_cle.mot_cle.nom', motCle.name);
      }

      if (latitude != null && longitude != null) {
        postQuery = postQuery.filter(
          'adresse_utilisateur',
          'st_dwithin',
          'st_point($longitude, $latitude), ${maxDistanceKm * 1000}',
        );
      }

      final postResponse = await postQuery;
      results.addAll(postResponse.map((map) => Post.fromMap(map)));
    }

    // Search campagnes
    if (includeCampagnes) {
      var campagneQuery = supabase
          .from('campagne')
          .select('*, post_mot_cle!inner(id_mot_cle, mot_cle(nom))');

      if (query.isNotEmpty) {
        campagneQuery = campagneQuery.or('titre.ilike.%$query%,description.ilike.%$query%');
      }

      if (motCle != null) {
        campagneQuery = campagneQuery.eq('post_mot_cle.mot_cle.nom', motCle.name);
      }

      if (latitude != null && longitude != null) {
        campagneQuery = campagneQuery.filter(
          'adresse_utilisateur',
          'st_dwithin',
          'st_point($longitude, $latitude), ${maxDistanceKm * 1000}',
        );
      }

      final campagneResponse = await campagneQuery;
      results.addAll(campagneResponse.map((map) => Campagne.fromMap(map)));
    }

    return results;
  }

  Future<List<MotCles>> getKeywordsForPost(int postId) async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('post_mot_cle')
        .select('mot_cle(nom)')
        .eq('id_post', postId);

    if (response.isEmpty) {
      return [];
    }

    return response
        .map<MotCles>((map) => MotCles.values.byName(map['mot_cle']['nom']))
        .toList();
  }

  Future<List<MotCles>> getKeywordsForCampagne(int campagneId) async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('post_mot_cle')
        .select('mot_cle(nom)')
        .eq('id_campagne', campagneId);

    if (response.isEmpty) {
      return [];
    }

    return response
        .map<MotCles>((map) => MotCles.values.byName(map['mot_cle']['nom']))
        .toList();
  }

  Future<List<Post>> searchPosts({String query = '', MotCles? motCle}) async {
    var queryBuilder = Supabase.instance.client
        .from('post')
        .select('*, post_mot_cle(mot_cle(nom))');
    if (motCle != null) {
      queryBuilder = queryBuilder.eq('post_mot_cle.mot_cle.nom', motCle.name);
    }
    final response = await queryBuilder;
    return (response as List<dynamic>).map((map) => Post.fromMap(map)).toList();
  }
}