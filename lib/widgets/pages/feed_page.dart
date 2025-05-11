import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:geolocator/geolocator.dart';
import 'package:myapp/models/acteur.dart';
import 'package:myapp/models/commentaire.dart';
import 'package:myapp/models/like.dart';
import 'package:myapp/models/post.dart';
import 'package:myapp/models/donateur.dart';
import 'package:myapp/models/association.dart';
import 'package:myapp/services/PostService.dart'; // Import PostService
import 'package:myapp/services/CampagneService.dart'; // Import CampagneService
import 'package:myapp/services/SearchService.dart';
import 'package:myapp/theme/app_pallete.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:myapp/main.dart';
import 'package:flutter/services.dart';
import 'package:myapp/widgets/cards/campagne_card.dart';
import 'package:myapp/widgets/cards/post_card.dart';

class FeedPage extends StatefulWidget {
  final String userType;
  const FeedPage({super.key, required this.userType});
  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  int _selectedIndex = 0;
  List<Campagne> _campagnes = [];
  List<Post> _posts = [];
  MotCles? _selectedCategory;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _selectedCategory = null; // Force no filtering initially for testing
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

  Future<int?> _getCurrentDonorId() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return null;

      final response = await Supabase.instance.client
          .from('acteur')
          .select('''
          id_acteur,
          utilisateur!inner(type_utilisateur)
        ''')
          .eq('supabase_user_id', user.id)
          .eq('utilisateur.type_utilisateur', 'donateur')
          .single();

      return response['id_acteur'] as int?;
    } catch (e) {
      print('Error getting donor ID: $e');
      return null;
    }
  }

  Future<List<Donateur>> fetchCampagneParticipants(int campagneId) async {
    final supabase = Supabase.instance.client;
    final uniqueDonateurs = <int, Donateur>{};

    try {
      final response = await supabase
          .from('don')
          .select('''
              donateur!id_donateur(
                id_acteur, nom, prenom, 
                utilisateur!id_acteur(id_profile, email, telephone, adresse_utilisateur)
              )
          ''')
          .eq('id_campagne', campagneId);

      for (var map in response) {
        final donateurData = map['donateur'] as Map<String, dynamic>?;
        if (donateurData == null) continue;

        final idActeur = int.tryParse(donateurData['id_acteur'].toString()) ?? 0;
        if (uniqueDonateurs.containsKey(idActeur)) continue;

        final utilisateurData = donateurData['utilisateur'] as Map<String, dynamic>? ?? {};
        final idProfile = utilisateurData['id_profile'];

        Map<String, dynamic> profileData = {};
        if (idProfile != null) {
          final profileResponse = await supabase
              .from('profile')
              .select('photo_url, bio')
              .eq('id_profile', idProfile)
              .maybeSingle();

          if (profileResponse != null) {
            profileData = profileResponse;
          }
        }

        final donateurMap = {
          'id_acteur': idActeur,
          'nom': donateurData['nom'],
          'prenom': donateurData['prenom'],
          'email': utilisateurData['email'],
          'telephone': utilisateurData['telephone'],
          'adresse_utilisateur': utilisateurData['adresse_utilisateur'],
          'profile': {
            'id_profile': idProfile,
            'photo_url': profileData['photo_url'],
            'bio': profileData['bio'],
          },
        };

        uniqueDonateurs[idActeur] = Donateur.fromMap(donateurMap.cast<String, dynamic>());
      }

      return uniqueDonateurs.values.toList();
    } catch (e) {
      print('Error in fetchCampagneParticipants: $e');
      return [];
    }
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
      final postService = PostService(supabase);
      final campagneService = CampagneService(supabase);

      // Fetch campaigns using CampagneService
      _campagnes = await campagneService.getAllCampagnes();

      // Fetch additional data for each campaign
      for (var i = 0; i < _campagnes.length; i++) {
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
      }

      // Fetch posts using PostService
      final allPosts = await postService.getAllPosts();

      // Filter posts based on selected category
      _posts = allPosts.where((post) {
        
        print('Post ${post.idPost} motsCles: ${post.motsCles}'); // Debug log
        print('Selected category: $_selectedCategory'); // Debug log

     // Exclude campaign-type posts
    if (post.typePost == TypePost.campagne) return false;
  
    // Existing category filter
   if (_selectedCategory == null) return true;
   final matchesCategory = post.motsCles.contains(_selectedCategory);
   if (!allPosts.any((p) => p.motsCles.contains(_selectedCategory))) {
    return true;
   }
        return matchesCategory;
      }).toList();

      print('Final posts: $_posts'); // Debug log
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
  Future<void> _submitDonation(
    Campagne campagne,
    String amount,
    String cardNumber,
    String expiry,
    String cvv,
  ) async {
    final donorId = await _getCurrentDonorId();
    if (donorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun donateur trouvé')),
      );
      return;
    }

    try {
      await Supabase.instance.client.from('don').insert({
        'num_carte_bancaire': cardNumber,
        'montant': int.parse(amount),
        'date_don': DateTime.now().toIso8601String(),
        'type_don': 'financier', // Fixed to 'financier'
        'etat_don': 'enAttente',
        'id_donateur': donorId,
        'id_campagne': campagne.idPost,
        'date_expiration': expiry,
        'cvv': cvv,
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Donation réussie!')),
      );
      await _fetchData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  void _showDonationDialog(Campagne campagne) {
    final amountController = TextEditingController(text: '0');
    final cardController = TextEditingController();
    final expiryController = TextEditingController();
    final cvvController = TextEditingController();
    int amount = 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Column(
          children: [
            FutureBuilder(
              future: supabase
                  .from('association')
                  .select('nom_association')
                  .eq('id_acteur', campagne.idAssociation)
                  .single(),
              builder: (context, snapshot) {
                return Text(
                  'Donation to ${snapshot.hasData ? (snapshot.data as Map)['nom_association'] ?? 'Unknown' : '...'}',
                  style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 20, color: LightAppPallete.primaryDark),
                  textAlign: TextAlign.center
                );
              },
            ),
            Text(
              campagne.titre,
              style: const TextStyle(fontSize: 10, color: LightAppPallete.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/transactions.png', height: 100),
              const SizedBox(height: 16),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      amount = amount > 0 ? amount - 100 : 0;
                      amountController.text = amount.toString();
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Montant (DZD)',
                        prefixIcon: Icon(Icons.attach_money_outlined),
                      ),
                      onChanged: (value) {
                        amount = int.tryParse(value) ?? 0;
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      amount += 100;
                      amountController.text = amount.toString();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16), // Equal spacing
              TextField(
                controller: cardController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Numéro de carte (16 chiffres)',
                  prefixIcon: Icon(Icons.credit_card),
                ),
                maxLength: 16,
              ),
              const SizedBox(height: 16), // Equal spacing
              TextField(
                controller: expiryController,
                decoration: const InputDecoration(
                  labelText: 'MM/AA',
                  hintText: '12/25',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(5),
                  _CardExpiryFormatter(), // Custom formatter for MM/AA
                ],
              ),
              const SizedBox(height: 16), // Equal spacing
              TextField(
                controller: cvvController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'CVV',
                  prefixIcon: Icon(Icons.lock),
                ),
                maxLength: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Enhanced validation
              final expiryRegExp = RegExp(r'^(0[1-9]|1[0-2])\/?([0-9]{2})$');
              final cvvRegExp = RegExp(r'^[0-9]{3,4}$');

              if (cardController.text.length != 16) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Numéro de carte invalide')),
                );
                return;
              }

              if (!expiryRegExp.hasMatch(expiryController.text)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Format expiration invalide (MM/AA)')),
                );
                return;
              }

              if (!cvvRegExp.hasMatch(cvvController.text)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('CVV invalide (3-4 chiffres)')),
                );
                return;
              }

              if (amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Montant invalide')),
                );
                return;
              }

              // Submit donation logic
              await _submitDonation(
                campagne,
                amount.toString(),
                cardController.text,
                expiryController.text,
                cvvController.text,
              );
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
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
        color: LightAppPallete.accentDark,
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
                        final profileData = (snapshot.data as Map)['profile'];
                        photoUrl = profileData?['photo_url'] != null 
                            ? 'https://eouymrxocetlfxyyibou.supabase.co/storage/v1/object/public/profile/${profileData['photo_url']}'
                            : null;
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
                                : const AssetImage('assets/images/profile.jpg') as ImageProvider,
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
          children: _campagnes.map((campagne) {
            return CampagneCard(
              campagne: campagne,
              onDonate: () => _showDonationDialog(campagne),
            );
          }).toList(),
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
      children: _posts.map((post) {
        return PostCard(
          post: post,
          onTap: () {
            Navigator.pushNamed(
              context,
              '/post-details',
              arguments: {'post': post},
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildSectionHeader(String title, bool showViewAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                  style: TextStyle(color: LightAppPallete.accentDark, fontSize: 12),
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

extension ListExtensions<T> on List<T> {
  List<T> ifEmpty(List<T> Function() defaultList) => isEmpty ? defaultList() : this;
}

class _CardExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(text[i]);
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}