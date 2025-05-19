import 'package:flutter/material.dart';
import 'package:myapp/routes/routes.dart';
import 'package:myapp/routes/routes_donateur.dart';
import 'package:myapp/theme/app_pallete.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileDonateur extends StatefulWidget {
  const ProfileDonateur({super.key});

  @override
  _ProfileDonateurState createState() => _ProfileDonateurState();
}

class _ProfileDonateurState extends State<ProfileDonateur> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        Navigator.pushReplacementNamed(context, RouteGenerator.login);
        return;
      }

      final response = await Supabase.instance.client
          .from('acteur')
          .select('''
            profile: id_profile (photo_url, bio),
            email, 
            note_moyenne,
            utilisateur!id_acteur (
              telephone,
              adresse_utilisateur,
              num_carte_identite,
              donateur!id_acteur (nom, prenom),
              followers: utilisateur_suivi!id_suivi (count),
              following: utilisateur_suivi!id_suiveur (count),
              followed_campaigns: campagne_suivi!id_utilisateur (
                campagne:campagne (
                  id_campagne,
                  post:post!id_post (
                    titre,
                    description
                  )
                )
              )
            ),
            posts: post!id_acteur (
              id_post,
              titre,
              description,
              type_post,
              image,
              date_limite
            )
          ''')
          .eq('supabase_user_id', user.id)
          .single();

      setState(() {
        _userData = response;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de chargement: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: LightAppPallete.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: LightAppPallete.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: LightAppPallete.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: LightAppPallete.accent, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: LightAppPallete.accentDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[200],
                  ),
                  child: post['image'] != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            post['image'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => 
                                Icon(Icons.image_not_supported, color: Colors.grey[400]),
                          ),
                        )
                      : Icon(Icons.post_add, color: Colors.grey[400], size: 30),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post['titre'] ?? 'Sans titre',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: LightAppPallete.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          post['type_post'] ?? 'Post',
                          style: TextStyle(
                            fontSize: 12,
                            color: LightAppPallete.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (post['description'] != null && post['description'].toString().isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                post['description'],
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (post['date_limite'] != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Échéance: ${post['date_limite']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCampaignCard(Map<String, dynamic> campaign) {
    final campaignData = campaign['campagne'];
    final postData = campaignData?['post'];
    
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: LightAppPallete.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.campaign,
                    color: LightAppPallete.success,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        postData?['titre'] ?? 'Campagne sans titre',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: LightAppPallete.warningBackground.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle, size: 12, color: LightAppPallete.warning),
                            const SizedBox(width: 4),
                            Text(
                              'Suivie',
                              style: TextStyle(
                                fontSize: 12,
                                color: LightAppPallete.warningBackground,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (postData?['description'] != null && postData['description'].toString().isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                postData['description'],
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPosts() {
    final posts = List<Map<String, dynamic>>.from(_userData?['posts'] ?? []);
    if (posts.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                Icons.post_add,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Aucune publication pour le moment',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ];
    }
    return posts.map((post) => _buildPostCard(post)).toList();
  }

  List<Widget> _buildCampaigns() {
    final campaigns = List<Map<String, dynamic>>.from(
      _userData?['utilisateur']?['followed_campaigns'] ?? []
    );
    if (campaigns.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                Icons.campaign,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Aucune campagne suivie',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ];
    }
    return campaigns.map((campaign) => _buildCampaignCard(campaign)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Donateur'),
        backgroundColor: LightAppPallete.infoBackground,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calculate),
            onPressed: () => Navigator.pushNamed(context, RouteGeneratorDonateur.calculateurZakat),
            tooltip: 'Calculateur de Zakat',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, RouteGeneratorDonateur.setting),
            tooltip: 'Paramètres',
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushNamed(context, RouteGeneratorDonateur.home),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          LightAppPallete.primary.withOpacity(0.1),
                          LightAppPallete.primary.withOpacity(0.05),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: LightAppPallete.primary.withOpacity(0.3),
                              width: 3,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage(
                              _userData?['profile']?['photo_url'] ?? 
                              'https://eouymrxocetlfxyyibou.supabase.co/storage/v1/object/public/profile//profile.jpg',
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${_userData?['utilisateur']?['donateur']?['prenom'] ?? ''} ${_userData?['utilisateur']?['donateur']?['nom'] ?? ''}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _userData?['email'] ?? 'Email non disponible',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Stats cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          'Abonnés',
                          '${_userData?['utilisateur']?['followers']?[0]?['count'] ?? 0}',
                          Icons.people,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildInfoCard(
                          'Abonnements',
                          '${_userData?['utilisateur']?['following']?[0]?['count'] ?? 0}',
                          Icons.people_outline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Other info cards
                  _buildInfoCard(
                    'Note moyenne',
                    '${(_userData?['note_moyenne'] ?? 0).toStringAsFixed(1)} / 5.0',
                    Icons.star,
                  ),
                  _buildInfoCard(
                    'Téléphone',
                    _userData?['utilisateur']?['telephone'] ?? 'Non renseigné',
                    Icons.phone,
                  ),
                  _buildInfoCard(
                    'Carte d\'identité',
                    _userData?['utilisateur']?['num_carte_identite'] ?? 'Non renseignée',
                    Icons.credit_card,
                  ),
                  
                  // Bio section
                  const SizedBox(height: 16),
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: LightAppPallete.primary),
                              const SizedBox(width: 8),
                              Text(
                                'Bio',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _userData?['profile']?['bio'] ?? 'Aucune bio disponible',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Posts section
                  _buildSectionTitle('Vos publications', Icons.article),
                  ..._buildPosts(),
                  
                  // Campaigns section
                  _buildSectionTitle('Campagnes suivies', Icons.campaign),
                  ..._buildCampaigns(),
                ],
              ),
            ),
    );
  }
}