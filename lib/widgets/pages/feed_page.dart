import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:geolocator/geolocator.dart';
import 'package:myapp/models/acteur.dart';
import 'package:myapp/models/commentaire.dart';
import 'package:myapp/models/don.dart';
import 'package:myapp/models/like.dart';
import 'package:myapp/models/post.dart';
import 'package:myapp/models/donateur.dart';
import 'package:myapp/models/association.dart';
import 'package:myapp/models/utils.dart'; // Import for GeoUtils
import 'package:myapp/services/SearchService.dart';
import 'package:myapp/theme/app_pallete.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:myapp/main.dart';

class FeedPage extends StatefulWidget {
  final String userType;
  const FeedPage({super.key, required this.userType});
  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  int _selectedIndex = 0;
  final SearchService _searchService = SearchService();
  List<Campagne> _campagnes = [];
  List<Post> _posts = [];
  MotCles? _selectedCategory;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _fetchData();
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied')),
        );
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission denied forever')),
      );
      return;
    }
  }

  Future<List<Donateur>> fetchCampagneParticipants(int campagneId) async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('don')
        .select(
            'donateur(id_acteur, nom, prenom, utilisateur(email, telephone, adresse_utilisateur), acteur(id_profile, profile(photo_url, bio)))')
        .eq('id_campagne', campagneId);

    final uniqueDonateurs = <int, Map>{};
    for (var map in response) {
      final idActeur = int.tryParse(map['donateur']['id_acteur'].toString()) ?? 0;
      if (!uniqueDonateurs.containsKey(idActeur)) {
        uniqueDonateurs[idActeur] = map['donateur'];
      }
    }

    return uniqueDonateurs.values
        .map((map) => Donateur.fromMap(map.cast<String, dynamic>()))
        .toList();
  }

  Future<List<int>> fetchCampagneFollowers(int campagneId) async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('campagne_suivi')
        .select('id_utilisateur')
        .eq('id_campagne', campagneId);

    return response.map<int>((map) => int.tryParse(map['id_utilisateur'].toString()) ?? 0).toList();
  }

  Future<List<Like>> fetchCampagneLikes(int campagneId) async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('like')
        .select('id_like, date_like, id_utilisateur')
        .eq('id_campagne', campagneId);

    return response.map((map) => Like.fromMap({
          ...map,
          'utilisateur': {
            'id_acteur': int.tryParse(map['id_utilisateur'].toString()) ?? 0,
          }
        })).toList();
  }

  Future<List<Commentaire>> fetchCampagneComments(int campagneId) async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('commentaire')
        .select('id_commentaire, contenu, date, id_acteur')
        .eq('id_campagne', campagneId);

    return response.map((map) => Commentaire.fromMap({
          ...map,
          'acteur': {
            'id_acteur': int.tryParse(map['id_acteur'].toString()) ?? 0,
          }
        })).toList();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final supabase = Supabase.instance.client;
      // Fetch campaigns directly from the campagne table
      final campagneResponse = await supabase
          .from('campagne')
          .select('''
              id_campagne, etat_campagne, date_debut, date_fin, 
              lieu_evenement, type_campagne, montant_objectif, montant_recolte, 
              nombre_participants, id_association,
              association(nom_association),
              post!id_campagne(
                id_post, titre, description, type_post, image, date_limite, 
                note_moyenne, id_acteur, id_don
              ),
              post_mot_cle!left(id_post, id_mot_cle, mot_cle(nom))
          ''');

      print('Raw campagneResponse: $campagneResponse'); // Debug log
      _campagnes = campagneResponse.map<Campagne>((data) {
        print('Raw data: $data'); // Debug log

        // Extract post data and merge with campaign data
        final postData = data['post'] as Map<String, dynamic>? ?? {};
        final mergedData = {
          ...data,
          ...postData,
          'id_post': data['id_campagne'],
        };
        print('Merged data: $mergedData'); // Debug log

        final motsCles = (data['post_mot_cle'] as List<dynamic>? ?? [])
            .map((mc) => MotCles.values.byName((mc['mot_cle']['nom'] as String?) ?? 'autre'))
            .toList();

        // Map type_campagne to TypeDon
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

        // Parse lieu_evenement (GEOGRAPHY field)
        double? latitude;
        double? longitude;
        String? lieuEvenement;
        if (data['lieu_evenement'] != null) {
          final lieuRaw = data['lieu_evenement'].toString();
          print('Raw lieu_evenement: $lieuRaw'); // Debug log
          if (lieuRaw.startsWith('POINT(')) {
            final coords = GeoUtils.parsePoint(lieuRaw);
            latitude = coords['latitude'];
            longitude = coords['longitude'];
            lieuEvenement = lieuRaw;
          } else if (lieuRaw.isNotEmpty) {
            print('Unexpected lieu_evenement format: $lieuRaw');
          }
        }

        return Campagne(
          idPost: int.tryParse(mergedData['id_campagne'].toString()) ?? 0,
          titre: mergedData['titre']?.toString() ?? 'Titre inconnu',
          description: mergedData['description']?.toString() ?? '',
          typeDon: typeDon,
          lieuActeur: mergedData['lieu_acteur']?.toString() ?? '',
          typeCampagne: mergedData['type_campagne'] != null
              ? TypeCampagne.values.byName(mergedData['type_campagne'].toString())
              : TypeCampagne.collecte,
          etatCampagne: mergedData['etat_campagne'] != null
              ? EtatCampagne.values.byName(mergedData['etat_campagne'].toString())
              : EtatCampagne.brouillon,
          dateDebut: mergedData['date_debut'] != null
              ? DateTime.tryParse(mergedData['date_debut'].toString())
              : null,
          dateFin: mergedData['date_fin'] != null
              ? DateTime.tryParse(mergedData['date_fin'].toString())
              : null,
          lieuEvenement: lieuEvenement,
          montantObjectif: double.tryParse(mergedData['montant_objectif']?.toString() ?? '0') ?? 0.0,
          montantRecolte: double.tryParse(mergedData['montant_recolte']?.toString() ?? '0') ?? 0.0,
          nombreParticipants: int.tryParse(mergedData['nombre_participants']?.toString() ?? '0') ?? 0,
          image: mergedData['image']?.toString(),
          dateLimite: mergedData['date_limite'] != null
              ? DateTime.tryParse(mergedData['date_limite'].toString())
              : null,
          latitude: latitude,
          longitude: longitude,
          idActeur: int.tryParse(mergedData['id_acteur']?.toString() ?? '0') ?? 0,
          idAssociation: int.tryParse(mergedData['id_association']?.toString() ?? '0') ?? 0,
          motsCles: motsCles,
        );
      }).toList();

      // Load participants, followers, likes, and comments
      for (var i = 0; i < _campagnes.length; i++) {
        try {
          final participants = await fetchCampagneParticipants(_campagnes[i].idPost ?? 0);
          final followers = await fetchCampagneFollowers(_campagnes[i].idPost ?? 0);
          final likes = await fetchCampagneLikes(_campagnes[i].idPost ?? 0);
          final comments = await fetchCampagneComments(_campagnes[i].idPost ?? 0);
          _campagnes[i] = _campagnes[i].copyWith(
            participants: participants,
            followers: followers,
            likes: likes,
            commentaires: comments,
          );
        } catch (e) {
          print('Error loading details for campagne ${_campagnes[i].idPost}: $e');
        }
      }

      // Fetch posts
      _posts = await _searchService.searchPosts(
        query: '',
        motCle: _selectedCategory,
      );
    } catch (e) {
      print('Error in _fetchData: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des données : $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileHeader(),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSearchBar(),
                          const SizedBox(height: 24),
                          _buildSectionHeader("Campagnes en cours", true),
                          const SizedBox(height: 16),
                          _buildCampagnesSection(),
                          const SizedBox(height: 24),
                          _buildFeaturedPostsSection(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: LightAppPallete.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  FutureBuilder(
                    future: supabase
                        .from('acteur')
                        .select('profile(photo_url), type_acteur')
                        .eq('supabase_user_id', supabase.auth.currentUser?.id ?? '')
                        .single(),
                    builder: (context, snapshot) {
                      String? photoUrl;
                      if (snapshot.hasData) {
                        photoUrl = (snapshot.data as Map)['profile']['photo_url'];
                      }
                      return Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          image: DecorationImage(
                            image: photoUrl != null
                                ? NetworkImage(photoUrl)
                                : const AssetImage('assets/images/profile.jpg')
                                    as ImageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  FutureBuilder(
                    future: supabase.from('acteur').select('''
                          type_acteur,
                          nom_admin,
                          prenom_admin,
                          nom_association,
                          email,
                          donateur(nom, prenom),
                          beneficiaire(nom, prenom)
                        ''').eq('supabase_user_id', supabase.auth.currentUser?.id ?? '').single(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final data = snapshot.data as Map;
                        final type = TypeActeur.values.byName(data['type_acteur']);
                        String displayName = 'Utilisateur';
                        if (type == TypeActeur.admin) {
                          displayName = '${data['prenom_admin']} ${data['nom_admin']}';
                        } else if (data['nom_association'] != null) {
                          displayName = data['nom_association'];
                        } else if (data['donateur'] != null) {
                          displayName = '${data['donateur']['prenom']} ${data['donateur']['nom']}';
                        } else if (data['beneficiaire'] != null) {
                          displayName = '${data['beneficiaire']['prenom']} ${data['beneficiaire']['nom']}';
                        } else {
                          displayName = data['email']?.split('@')[0] ?? 'Utilisateur';
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Bienvenue $displayName',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.thumb_up,
                                  color: LightAppPallete.info,
                                  size: 16,
                                ),
                              ],
                            ),
                            const Text(
                              'Il reste beaucoup de bien à faire...',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        );
                      }
                      return const Text('Chargement...');
                    },
                  ),
                ],
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.notifications_none,
                    color: LightAppPallete.accentDark,
                    size: 20,
                  ),
                  onPressed: () {
                    // TODO: Navigate to NotificationsPage
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to SearchPage
        // Navigator.pushNamed(context, '/search');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 231, 240),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: Colors.grey[400]),
            const SizedBox(width: 12),
            Text(
              'Rechercher des causes',
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampagnesSection() {
    if (_campagnes.isEmpty) {
      return const Center(
        child: Text(
          'Aucune campagne en cours',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    return SizedBox(
      height: 240,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _campagnes.map((campagne) => _buildCampagneCard(campagne)).toList(),
        ),
      ),
    );
  }

  Widget _buildCampagneCard(Campagne campagne) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/campagne-details',
          arguments: {'campagne': campagne},
        );
      },
      child: Container(
        width: 250,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 253, 221, 232),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: campagne.image ?? 'https://via.placeholder.com/250x120',
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => Image.asset(
                      'assets/images/placeholder.jpg',
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      campagne.typeCampagne.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    campagne.titre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  FutureBuilder(
                    future: supabase
                        .from('association')
                        .select('nom_association')
                        .eq('id_acteur', campagne.idAssociation)
                        .single(),
                    builder: (context, snapshot) {
                      String orgName = 'Inconnu';
                      if (snapshot.hasData) {
                        orgName = (snapshot.data as Map)['nom_association'] ?? 'Inconnu';
                      }
                      return Text(
                        orgName,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.favorite, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            '${campagne.likes.length}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.comment, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            '${campagne.commentaires.length}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.group, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${campagne.participants.length} participants',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: campagne.pourcentage / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(LightAppPallete.primary),
                  ),
                  Text(
                    '${campagne.pourcentage.toStringAsFixed(1)}% atteint',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await Supabase.instance.client.from('don').insert({
                          'num_carte_bancaire': '1234567890123456',
                          'montant': 5000.0,
                          'date_don': DateTime.now().toIso8601String(),
                          'type_don': 'financier',
                          'etat_don': 'enAttente',
                          'id_donateur': 4, // Replace with actual user ID
                          'id_campagne': campagne.idPost,
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Donation successful')),
                        );
                        // Refresh the campaign data to update participant count
                        await _fetchData();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Donation failed: $e')),
                        );
                      }
                    },
                    child: const Text('Faire un don'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedPostsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Publications", true),
        const SizedBox(height: 16),
        _buildCategoryChips(),
        const SizedBox(height: 16),
        _buildFeaturedPostsList(),
      ],
    );
  }

  Widget _buildCategoryChips() {
    final categories = MotCles.values.map((motCle) {
      return {
        'title': motCle.name[0].toUpperCase() + motCle.name.substring(1),
        'isSelected': _selectedCategory == motCle,
        'motCle': motCle,
      };
    }).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = (category['isSelected'] as bool)
                      ? null
                      : category['motCle'] as MotCles?;
                  _fetchData();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: (category['isSelected'] as bool)
                      ? LightAppPallete.accent
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  category['title'] as String,
                  style: TextStyle(
                    color: (category['isSelected'] as bool)
                        ? Colors.white
                        : Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFeaturedPostsList() {
    if (_posts.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            'Aucune publication trouvée',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      children: _posts.map((post) => _buildPostCard(post)).toList(),
    );
  }

  Widget _buildPostCard(Post post) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/post-details',
          arguments: {'post': post},
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: post.image ?? 'https://via.placeholder.com/100x100',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Image.asset(
                  'assets/images/placeholder.jpg',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.titre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  FutureBuilder(
                    future: supabase.from('acteur').select('''
                          type_acteur,
                          nom_admin,
                          prenom_admin,
                          nom_association,
                          email,
                          donateur(nom, prenom),
                          beneficiaire(nom, prenom)
                        ''').eq('id_acteur', post.idActeur).single(),
                    builder: (context, snapshot) {
                      String creatorName = 'Inconnu';
                      if (snapshot.hasData) {
                        final data = snapshot.data as Map;
                        final type = TypeActeur.values.byName(data['type_acteur']);
                        if (type == TypeActeur.admin) {
                          creatorName = '${data['prenom_admin']} ${data['nom_admin']}';
                        } else if (data['nom_association'] != null) {
                          creatorName = data['nom_association'];
                        } else if (data['donateur'] != null) {
                          creatorName = '${data['donateur']['prenom']} ${data['donateur']['nom']}';
                        } else if (data['beneficiaire'] != null) {
                          creatorName = '${data['beneficiaire']['prenom']} ${data['beneficiaire']['nom']}';
                        } else {
                          creatorName = data['email']?.split('@')[0] ?? 'Inconnu';
                        }
                      }
                      return Row(
                        children: [
                          Text(
                            creatorName,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            decoration: BoxDecoration(
                              color: LightAppPallete.primary,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(2),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 10,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.favorite, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            '${post.likes.length}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.comment, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            '${post.commentaires.length}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            post.dateLimite != null
                                ? '${post.dateLimite!.difference(DateTime.now()).inDays} jours restants'
                                : 'Pas de limite',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool showViewAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (showViewAll)
          GestureDetector(
            onTap: () {
              // TODO: Navigate to AllPostsPage or AllCampagnesPage
            },
            child: Row(
              children: [
                Text(
                  'Voir tout',
                  style: TextStyle(
                    color: LightAppPallete.accentDark,
                    fontSize: 12,
                  ),
                ),
                Icon(
                  Icons.arrow_forward,
                  color: LightAppPallete.accentDark,
                  size: 16,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
              // TODO: Handle navigation
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: LightAppPallete.primary,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.format_list_bulleted),
              label: 'Liste des Dons',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              label: 'Mes Dons',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Compte',
            ),
          ],
        ),
      ),
    );
  }
}