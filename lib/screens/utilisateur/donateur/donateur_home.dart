import 'package:flutter/material.dart';
import 'package:myapp/routes/routes_donateur.dart';
import 'package:myapp/services/SearchService.dart';
import 'package:myapp/models/association.dart';
import 'package:myapp/models/post.dart';
import 'package:myapp/services/PostService.dart';
import 'package:myapp/services/CampagneService.dart';
import 'package:myapp/theme/app_pallete.dart';
import 'package:myapp/widgets/cards/campagne_card.dart';
import 'package:myapp/widgets/cards/post_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Donateur home page showing posts and campaigns for donation/participation
class DonateurHome extends StatefulWidget {
  const DonateurHome({super.key});

  @override
  State<DonateurHome> createState() => _DonateurHomeState();
}

class _DonateurHomeState extends State<DonateurHome> {
  int _selectedIndex = 0;
  List<Campagne> _campagnes = [];
  List<Post> _posts = [];
  MotCles? _selectedCategory;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final supabase = Supabase.instance.client;
      final postService = PostService(supabase);
      final campagneService = CampagneService(supabase);
      _campagnes = await campagneService.getAllCampagnes();
      _posts = (await postService.getPostsByType(TypePost.invite)).where((post) => post.typePost != TypePost.campagne).toList();
      if (_selectedCategory != null) {
        _posts = _posts.where((post) => post.motsCles.contains(_selectedCategory)).toList();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    final routes = [
      RouteGeneratorDonateur.home,
      RouteGeneratorDonateur.search,
      RouteGeneratorDonateur.gestionPostoffreEtInvite,
      RouteGeneratorDonateur.map,
      RouteGeneratorDonateur.profile,
    ];
    if (index == 2) {
      // "Créer" button: fetch user info and navigate with arguments
      _navigateToGestionPost();
    } else if (index != 0) {
      Navigator.pushReplacementNamed(context, routes[index]);
    }
  }

  Future<void> _navigateToGestionPost() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Utilisateur non connecté.')),
        );
        return;
      }

      final acteurData = await Supabase.instance.client
          .from('acteur')
          .select('''
            id_acteur,
            utilisateur!id_acteur (
              adresse_utilisateur,
              donateur!id_acteur (nom, prenom)
            )
          ''')
          .eq('supabase_user_id', user.id)
          .single();

      if (acteurData == null || acteurData['id_acteur'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible de récupérer votre profil utilisateur.')),
        );
        return;
      }

      final int idActeur = acteurData['id_acteur'];
      final Map<String, dynamic> userData = acteurData;

      Navigator.pushNamed(
        context,
        RouteGeneratorDonateur.gestionPostoffreEtInvite,
        arguments: {
          'idActeur': idActeur,
          'userData': userData,
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la récupération du profil: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: HeaderBar(),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSearchBar(),
                      const SizedBox(height: 24),
                      _buildSectionHeader('Campagnes'),
                      const SizedBox(height: 16),
                      _buildCampagnesSection(),
                      const SizedBox(height: 24),
                      _buildSectionHeader('Offres et Invites'),
                      const SizedBox(height: 16),
                      _buildCategoryChips(),
                      const SizedBox(height: 16),
                      _buildPostsSection(),
                    ],
                  ),
                ),
              ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, RouteGeneratorDonateur.search);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: Colors.grey[400]),
            const SizedBox(width: 12),
            Text('Rechercher...', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  }

  Widget _buildCampagnesSection() {
    if (_campagnes.isEmpty) {
      return const Center(child: Text('Aucune campagne', style: TextStyle(color: Colors.grey)));
    }
    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _campagnes.length,
        itemBuilder: (context, index) {
          return CampagneCard(
            campagne: _campagnes[index],
            onDonate: () {
              Navigator.pushNamed(context, RouteGeneratorDonateur.campagneDetails, arguments: {'campagne': _campagnes[index]});
            },
            onTap: () {
              Navigator.pushNamed(context, RouteGeneratorDonateur.campagneDetails, arguments: {'campagne': _campagnes[index]});
            },
          );
        },
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: MotCles.values.map((motCle) {
          final isSelected = _selectedCategory == motCle;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = isSelected ? null : motCle;
                  _fetchData();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? LightAppPallete.accent : Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  motCle.name[0].toUpperCase() + motCle.name.substring(1),
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[600],
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

  Widget _buildPostsSection() {
    if (_posts.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(16)),
        child: const Center(child: Text('Aucune publication', style: TextStyle(color: Colors.grey))),
      );
    }
    return Column(
      children: _posts.map((post) {
        return PostCard(
          post: post,
          onTap: () {
            Navigator.pushNamed(context, RouteGeneratorDonateur.postDetails, arguments: {'post': post});
          },
        );
      }).toList(),
    );
  }
}


// Stateful widget for the header bar----------------------------------------------------------
class HeaderBar extends StatefulWidget {
  const HeaderBar({super.key});

  @override
  State<HeaderBar> createState() => _HeaderBarState();
}

class _HeaderBarState extends State<HeaderBar> {
  // Key to force rebuild of FutureBuilders
  final _refreshKey = GlobalKey();

  // Method to trigger refresh of user data
  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Container for the header with padding and styling
    return Container(
      padding: const EdgeInsets.all(16.0), // Adds padding around content
      decoration: BoxDecoration(
        color: LightAppPallete.accentDark, // Background color from theme
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24), // Rounded bottom-left corner
          bottomRight: Radius.circular(24), // Rounded bottom-right corner
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space out children
        children: [
          // Expanded widget to take available space
          Expanded(
            child: Row(
              children: [
                // Fetch user profile data from Supabase
                FutureBuilder(
                  key: _refreshKey, // Allows rebuilding on refresh
                  future: Supabase.instance.client
                      .from('acteur')
                      .select('profile(photo_url)')
                      .eq('supabase_user_id', Supabase.instance.client.auth.currentUser?.id ?? '')
                      .single(),
                  builder: (context, snapshot) {
                    String? photoUrl;
                    if (snapshot.hasData && snapshot.data != null) {
                      final profileData = (snapshot.data as Map)['profile'];
                      photoUrl = profileData?['photo_url'] != null
                          ? '${profileData['photo_url']}'
                          : null;
                    }
                    // Display profile picture (network or fallback asset)
                    return Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle, // Circular shape
                        border: Border.all(color: Colors.white, width: 2), // White border
                        image: DecorationImage(
                          image: photoUrl != null
                              ? NetworkImage(photoUrl)
                              : const AssetImage('assets/images/profile.jpg') as ImageProvider,
                          fit: BoxFit.cover, // Cover the container
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12), // Space between picture and text
                // Fetch user name for welcome message
                FutureBuilder(
                  future: Supabase.instance.client
                      .from('acteur')
                      .select('donateur(nom, prenom), beneficiaire(nom, prenom), nom_association, email')
                      .eq('supabase_user_id', Supabase.instance.client.auth.currentUser?.id ?? '')
                      .single(),
                  builder: (context, snapshot) {
                    String displayName = 'Utilisateur';
                    if (snapshot.hasData && snapshot.data != null) {
                      final data = snapshot.data as Map;
                      if (data['donateur'] != null) {
                        displayName = '${data['donateur']['prenom']} ${data['donateur']['nom']}';
                      } else if (data['beneficiaire'] != null) {
                        displayName = '${data['beneficiaire']['prenom']} ${data['beneficiaire']['nom']}';
                      } else if (data['nom_association'] != null) {
                        displayName = data['nom_association'];
                      } else {
                        displayName = data['email']?.split('@')[0] ?? 'Utilisateur';
                      }
                    }
                    // Display welcome text
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bienvenue $displayName',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
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
                  },
                ),
              ],
            ),
          ),
          // Notification and Settings buttons
          Row(
            children: [
              // Notification button
              Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(right: 8), // Space between icons
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
                    Navigator.pushNamed(context, '/notifications');
                  },
                ),
              ),
              // Settings button
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
                    Icons.mark_chat_unread,
                    color: LightAppPallete.accentDark,
                    size: 20,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/messages');
                  },
                  tooltip: 'Messages',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Stateless widget for the bottom navigation bar----------------------------------
class BottomNavBar extends StatelessWidget {
  final int selectedIndex; // Tracks the current selected tab
  final Function(int) onItemTapped; // Callback for tap events

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    // Container for styling the navigation bar
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24), // Rounded top-left corner
          topRight: Radius.circular(24), // Rounded top-right corner
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10, // Shadow for elevation effect
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex, // Highlights the current tab
          onTap: onItemTapped, // Calls callback when an item is tapped
          type: BottomNavigationBarType.fixed, // Ensures all items are visible
          backgroundColor: Colors.white, // Background color
          selectedItemColor: LightAppPallete.accentDark, // Color for selected item
          unselectedItemColor: Colors.grey, // Color for unselected items
          showSelectedLabels: true, // Shows labels for selected items
          showUnselectedLabels: true, // Shows labels for unselected items
          items: const [
            // Navigation items
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Rechercher',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle),
              label: 'Créer',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              label: 'Maps',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
