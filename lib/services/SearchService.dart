import 'package:myapp/models/post.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum Mot_cles {
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
  Map<Mot_cles, String> categoriesImages = {
    Mot_cles.urgence: 'assets/icons/Urgent-amico.ico',
    Mot_cles.eau: 'assets/icons/Bottleofwater-pana.ico',
    Mot_cles.nourriture: 'assets/icons/nourriture.ico',
    Mot_cles.affaire_scolaire: 'assets/icons/affaire_scolaire.ico',
    Mot_cles.eidElFitr: 'assets/icons/EidElFitr.ico',
    Mot_cles.eidElAdha: 'assets/icons/EidElAdha.ico',
    Mot_cles.ramadan: 'assets/icons/Ramadan.ico',
    Mot_cles.sadaquah: 'assets/icons/sadaquah.ico',
    Mot_cles.yennayer: 'assets/icons/Yanayer.ico',
    Mot_cles.hiver: 'assets/icons/Hiver.ico',
    Mot_cles.animaux: 'assets/icons/Animaux.ico',
    Mot_cles.sante: 'assets/icons/Sante.ico',
    Mot_cles.medicament: 'assets/icons/medicament.ico',
    Mot_cles.marriage: 'assets/icons/mariage.ico',
    Mot_cles.mosquee: 'assets/icons/mosquee.ico',
    Mot_cles.vetement: 'assets/icons/vetement.ico',
    Mot_cles.boisement: 'assets/icons/Boisement.ico', 
    Mot_cles.recyclage: 'assets/icons/Recyclage.ico',
    Mot_cles.autre: 'assets/icons/autre1.ico', 
    Mot_cles.vetementHivers: 'assets/icons/vetementHivers.ico',
    Mot_cles.inondations: 'assets/icons/Inondations.ico',
    Mot_cles.tremblementDeTerre: 'assets/icons/tremblementDeTerre.ico',
    Mot_cles.refuges: 'assets/icons/Refuges.ico',
    Mot_cles.femmes: 'assets/icons/femmes.ico',
    Mot_cles.reservoirsOxygene: 'assets/icons/Reservoirs_oxygene.ico',
  };

  Future<List<Post>> searchPosts({
    required String query,
    Mot_cles? motCle,
    double? latitude,
    double? longitude,
    double maxDistanceKm = 50.0,
  }) async {
    final supabase = Supabase.instance.client;
    var queryBuilder = supabase.from('post').select('*, post_mot_cle!inner(id_mot_cle, mot_cle(nom))');

    if (query.isNotEmpty) {
      queryBuilder = queryBuilder.ilike('titre', '%$query%').ilike('description', '%$query%');
    }

    if (motCle != null) {
      queryBuilder = queryBuilder.eq('post_mot_cle.mot_cle.nom', motCle.name);
    }

    if (latitude != null && longitude != null) {
      queryBuilder = queryBuilder.filter(
        'location',
        'st_dwithin',
        'st_point($longitude, $latitude), $maxDistanceKm * 1000',
      );
    }

    final response = await queryBuilder; // Remplacement de .execute()
    return response
        .map<Post>((map) => Post.fromMap(map))
        .toList();
  }

  Future<List<Mot_cles>> getKeywordsForPost(int postId) async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('post_mot_cle')
        .select('mot_cle(nom)')
        .eq('id_post', postId); // Remplacement de .execute()

    if (response.isEmpty) {
      return [];
    }

    return response
        .map<Mot_cles>((map) => Mot_cles.values.byName(map['mot_cle']['nom']))
        .toList();
  }
}