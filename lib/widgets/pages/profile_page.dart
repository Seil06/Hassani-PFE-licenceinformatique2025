import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:myapp/theme/app_pallete.dart';
import 'package:myapp/models/acteur.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  int _donationCount = 0;
  int _followedCampaignsCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchUserStats();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final response = await Supabase.instance.client
          .from('acteur')
          .select('''
            id_acteur, type_acteur, nom_admin, prenom_admin, nom_association, email,
            donateur(nom, prenom), beneficiaire(nom, prenom),
            profile(id_profile, photo_url, bio),
            utilisateur(type_utilisateur)
          ''')
          .eq('supabase_user_id', user.id)
          .single();

      setState(() {
        _userData = response;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement du profil: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchUserStats() async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) return;

      final supabase = Supabase.instance.client;

      // Fetch donation count
      final donationResponse = await supabase
          .from('don')
          .select('id_don')
          .eq('id_donateur', userId);

      // Fetch followed campaigns count
      final followedResponse = await supabase
          .from('campagne_suivi')
          .select('id_campagne')
          .eq('id_utilisateur', userId);

      setState(() {
        _donationCount = donationResponse.length;
        _followedCampaignsCount = followedResponse.length;
      });
    } catch (e) {
      print('Error fetching user stats: $e');
    }
  }

  Future<int?> _getCurrentUserId() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return null;

    final response = await Supabase.instance.client
        .from('acteur')
        .select('id_acteur')
        .eq('supabase_user_id', user.id)
        .single();

    return response['id_acteur'] as int?;
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Déconnexion réussie')),
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
                  children: [
                    _buildProfileHeader(),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildUserInfoSection(),
                          const SizedBox(height: 24),
                          _buildStatsSection(),
                          const SizedBox(height: 24),
                          _buildActionButtons(),
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
    String? photoUrl;
    if (_userData?['profile']?['photo_url'] != null) {
      photoUrl =
          'https://eouymrxocetlfxyyibou.supabase.co/storage/v1/object/public/profile/${_userData!['profile']['photo_url']}';
    }

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
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Text(
                'Profil',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 40), // Placeholder for symmetry
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: 100,
            height: 100,
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
          ),
          const SizedBox(height: 12),
          Text(
            _getDisplayName(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _userData?['email'] ?? 'Email non disponible',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _getDisplayName() {
    final typeActeur = _userData?['type_acteur'] ?? 'utilisateur';
    final typeUtilisateur = _userData?['utilisateur']?['type_utilisateur']?.toString();
    String displayName = 'Utilisateur';

    if (typeActeur == 'admin') {
      displayName = '${_userData?['prenom_admin']} ${_userData?['nom_admin']}';
    } else if (_userData?['nom_association'] != null) {
      displayName = _userData?['nom_association'];
    } else if (typeUtilisateur == 'donateur' && _userData?['donateur'] != null) {
      displayName = '${_userData?['donateur']['prenom']} ${_userData?['donateur']['nom']}';
    } else if (typeUtilisateur == 'beneficiaire' && _userData?['beneficiaire'] != null) {
      displayName = '${_userData?['beneficiaire']['prenom']} ${_userData?['beneficiaire']['nom']}';
    }
    return displayName;
  }

  Widget _buildUserInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'À propos',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: LightAppPallete.backgroundAlt,
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
              Text(
                'Bio',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _userData?['profile']?['bio'] ?? 'Aucune bio disponible',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statistiques',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStatCard('Dons', _donationCount.toString(), Icons.monetization_on),
            _buildStatCard('Campagnes suivies', _followedCampaignsCount.toString(), Icons.bookmark),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.42,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LightAppPallete.backgroundAlt,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: LightAppPallete.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // TODO: Navigate to EditProfilePage
              Navigator.pushNamed(context, '/edit-profile');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: LightAppPallete.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Modifier le profil',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _logout,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Déconnexion',
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
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
          currentIndex: 4, // Profile tab is selected
          onTap: (index) {
            if (index == 0) Navigator.pushReplacementNamed(context, '/home');
            if (index == 1) Navigator.pushReplacementNamed(context, '/search');
            if (index == 2) Navigator.pushReplacementNamed(context, '/create');
            if (index == 3) Navigator.pushReplacementNamed(context, '/maps');
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: LightAppPallete.accentDark,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: const [
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