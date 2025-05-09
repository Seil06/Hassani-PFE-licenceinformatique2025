import 'package:flutter/material.dart';
import 'package:myapp/models/acteur.dart';
import 'package:myapp/models/post.dart';
import 'package:myapp/models/donateur.dart';
import 'package:myapp/models/association.dart'; // For Campagne
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
  List<Campagne> _campagnes = []; // List to hold campaigns
  List<Post> _posts = []; // List to hold posts
  Mot_cles? _selectedCategory;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<List<Donateur>> fetchCampagneParticipants(int campagneId) async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('don')
        .select(
            'donateur(id_acteur, nom, prenom, utilisateur(email, telephone, adresse, location), acteur(id_profile, profile(photo_url, bio)))')
        .eq('id_campagne', campagneId);

    // Deduplicate by id_acteur
    final uniqueDonateurs = <int, Map>{};
    for (var map in response) {
      final idActeur = map['donateur']['id_acteur'] as int;
      if (!uniqueDonateurs.containsKey(idActeur)) {
        uniqueDonateurs[idActeur] = map['donateur'];
      }
    }

    return uniqueDonateurs.values.map((map) => Donateur.fromMap(map.cast<String, dynamic>())).toList();
  }

  Future<List<int>> fetchCampagneFollowers(int campagneId) async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('campagne_suivi')
        .select('id_utilisateur')
        .eq('id_campagne', campagneId);

    return response.map<int>((map) => map['id_utilisateur'] as int).toList();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final supabase = Supabase.instance.client;
      final campagneResponse = await supabase
          .from('post')
          .select(
              '*, campagne!fk_post(id_campagne, etat_campagne, date_debut, date_fin, lieu_evenement, type_campagne, montant_objectif, montant_recolte, nombre_participants), post_mot_cle!inner(id_mot_cle, mot_cle(nom)), acteur(email)')
          .eq('type_post', TypePost.campagne.name);

      _campagnes = campagneResponse.map<Campagne>((map) {
        final campagne = Campagne.fromMap({
          ...map,
          ...map['campagne'],
          'id_acteur': map['id_acteur'],
          'titre': map['titre'],
          'description': map['description'],
          'type_don': map['type_don'],
          'lieu_acteur': map['lieu_acteur'],
          'image': map['image'],
          'video': map['video'],
          'date_limite': map['date_limite'],
          'location': map['location'],
        });
        return campagne;
      }).toList();

      // Load participants and followers for each campaign
      for (var i = 0; i < _campagnes.length; i++) {
        final participants = await fetchCampagneParticipants(_campagnes[i].idPost!);
        final followers = await fetchCampagneFollowers(_campagnes[i].idPost!);
        _campagnes[i] = _campagnes[i].copyWith(participants: participants, followers: followers);
      }

      _posts = await _searchService.searchPosts(
        query: '',
        motCle: _selectedCategory,
      );
    } catch (e) {
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
                        .eq('id_acteur', supabase.auth.currentUser?.id ?? '')
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
                          (SELECT nom, prenom FROM donateur WHERE donateur.id_acteur = acteur.id_acteur LIMIT 1),
                          (SELECT nom, prenom FROM beneficiaire WHERE beneficiaire.id_acteur = acteur.id_acteur LIMIT 1)
                        ''').eq('id_acteur', supabase.auth.currentUser?.id ?? '').single(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final data = snapshot.data as Map;
                        final type = TypeActeur.values.byName(data['type_acteur']);
                        String displayName = 'Utilisateur';
                        if (type == TypeActeur.admin) {
                          displayName = '${data['prenom_admin']} ${data['nom_admin']}';
                        } else if (data['nom_association'] != null) {
                          displayName = data['nom_association'];
                        } else if (data['donateur'] != null &&
                            (data['donateur'] as Map).containsKey('nom')) {
                          displayName =
                              '${(data['donateur'] as Map)['prenom']} ${(data['donateur'] as Map)['nom']}';
                        } else if (data['beneficiaire'] != null &&
                            (data['beneficiaire'] as Map).containsKey('nom')) {
                          displayName =
                              '${(data['beneficiaire'] as Map)['prenom']} ${(data['beneficiaire'] as Map)['nom']}';
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
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.notifications_none,
                    color: LightAppPallete.accentDark,
                    size: 20,
                  ),
                  onPressed: () {},
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
        // Navigate to SearchPage (to be implemented)
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
              spreadRadius: 0,
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
      return const Text('Aucune campagne en cours');
    }
    return SizedBox(
      height: 220, // Increased height to accommodate participants
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
        // Navigate to CampagneDetailsPage (to be implemented)
        // Navigator.pushNamed(context, '/campagne-details', arguments: campagne);
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
              spreadRadius: 0,
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
                  child: Image.network(
                    campagne.image ?? 'assets/images/placeholder.jpg',
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
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
                      campagne.typeDon.name,
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
                    future: supabase.from('acteur').select('''
                          type_acteur,
                          nom_admin,
                          prenom_admin,
                          nom_association,
                          email,
                          (SELECT nom, prenom FROM donateur WHERE donateur.id_acteur = acteur.id_acteur LIMIT 1),
                          (SELECT nom, prenom FROM beneficiaire WHERE beneficiaire.id_acteur = acteur.id_acteur LIMIT 1)
                        ''').eq('id_acteur', campagne.idActeur).single(),
                    builder: (context, snapshot) {
                      String orgName = 'Inconnu';
                      if (snapshot.hasData) {
                        final data = snapshot.data as Map;
                        final type = TypeActeur.values.byName(data['type_acteur']);
                        if (type == TypeActeur.admin) {
                          orgName = '${data['prenom_admin']} ${data['nom_admin']}';
                        } else if (data['nom_association'] != null) {
                          orgName = data['nom_association'];
                        } else if (data['donateur'] != null &&
                            (data['donateur'] as Map).containsKey('nom')) {
                          orgName =
                              '${(data['donateur'] as Map)['prenom']} ${(data['donateur'] as Map)['nom']}';
                        } else if (data['beneficiaire'] != null &&
                            (data['beneficiaire'] as Map).containsKey('nom')) {
                          orgName =
                              '${(data['beneficiaire'] as Map)['prenom']} ${(data['beneficiaire'] as Map)['nom']}';
                        } else {
                          orgName = data['email']?.split('@')[0] ?? 'Inconnu';
                        }
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
    final categories = Mot_cles.values.map((motCle) {
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
                      : category['motCle'] as Mot_cles?;
                });
                _fetchData();
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
                    color: (category['isSelected'] as bool) ? Colors.white : Colors.grey[600],
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
        // Navigate to PostDetailsPage (to be implemented)
        // Navigator.pushNamed(context, '/post-details', arguments: post);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                post.image ?? 'assets/images/placeholder.jpg',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Image.asset(
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
                          (SELECT nom, prenom FROM donateur WHERE donateur.id_acteur = acteur.id_acteur LIMIT 1),
                          (SELECT nom, prenom FROM beneficiaire WHERE beneficiaire.id_acteur = acteur.id_acteur LIMIT 1)
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
                        } else if (data['donateur'] != null &&
                            (data['donateur'] as Map).containsKey('nom')) {
                          creatorName =
                              '${(data['donateur'] as Map)['prenom']} ${(data['donateur'] as Map)['nom']}';
                        } else if (data['beneficiaire'] != null &&
                            (data['beneficiaire'] as Map).containsKey('nom')) {
                          creatorName =
                              '${(data['beneficiaire'] as Map)['prenom']} ${(data['beneficiaire'] as Map)['nom']}';
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
          Row(
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
            spreadRadius: 0,
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