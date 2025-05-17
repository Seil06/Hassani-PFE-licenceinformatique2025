import 'package:flutter/material.dart';
import 'package:myapp/models/association.dart';
import 'package:myapp/models/post.dart';
import 'package:myapp/services/PostService.dart';
import 'package:myapp/services/CampagneService.dart';
import 'package:myapp/services/SearchService.dart';
import 'package:myapp/theme/app_pallete.dart';
import 'package:myapp/widgets/bars/bottom_nav_bar.dart';
import 'package:myapp/widgets/bars/header_bar.dart';
import 'package:myapp/widgets/cards/campagne_card.dart';
import 'package:myapp/widgets/cards/post_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:myapp/routes/routes_beneficiaire.dart';

// Beneficiaire home page showing posts and campaigns they can participate in
class BeneficiaireHome extends StatefulWidget {
  const BeneficiaireHome({super.key});

  @override
  State<BeneficiaireHome> createState() => _BeneficiaireHomeState();
}

class _BeneficiaireHomeState extends State<BeneficiaireHome> {
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
      _posts = (await postService.getPostsByType(TypePost.demande)).where((post) => post.typePost != TypePost.campagne).toList();
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

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index != 0) {
      Navigator.pushReplacementNamed(context, [
        RouteGeneratorBeneficiaire.home,
        RouteGeneratorBeneficiaire.search,
        RouteGeneratorBeneficiaire.gestionPostDemande,
        RouteGeneratorBeneficiaire.map,
        RouteGeneratorBeneficiaire.profile,
      ][index]);
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
                    const HeaderBar(),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSearchBar(),
                          const SizedBox(height: 24),
                          _buildSectionHeader('Campagnes Disponibles'),
                          const SizedBox(height: 16),
                          _buildCampagnesSection(),
                          const SizedBox(height: 24),
                          _buildSectionHeader('Demandes'),
                          const SizedBox(height: 16),
                          _buildCategoryChips(),
                          const SizedBox(height: 16),
                          _buildPostsSection(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onNavItemTapped,
      ),
    );
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, RouteGeneratorBeneficiaire.search);
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
              Navigator.pushNamed(context, RouteGeneratorBeneficiaire.campagneDetails, arguments: {'campagne': _campagnes[index]});
            },
            onTap: () {
              Navigator.pushNamed(context, RouteGeneratorBeneficiaire.campagneDetails, arguments: {'campagne': _campagnes[index]});
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
        child: const Center(child: Text('Aucune demande', style: TextStyle(color: Colors.grey))),
      );
    }
    return Column(
      children: _posts.map((post) {
        return PostCard(
          post: post,
          onTap: () {
            Navigator.pushNamed(context, RouteGeneratorBeneficiaire.postDetails, arguments: {'post': post});
          },
        );
      }).toList(),
    );
  }
}
/*import 'package:flutter/material.dart';
import 'package:myapp/routes/routes.dart';
import 'package:myapp/widgets/pages/feed_page.dart';
import 'package:myapp/widgets/buttons/sign_out_button.dart';

class BeneficiaireHome extends StatelessWidget {
  const BeneficiaireHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil Bénéficiaire'),
        actions: [
          SignOutButton(routeAfterSignOut: RouteGenerator.login),
        ],
      ),
      body: const FeedPage(),//userType: 'beneficiaire'),
    );
  }
}*/