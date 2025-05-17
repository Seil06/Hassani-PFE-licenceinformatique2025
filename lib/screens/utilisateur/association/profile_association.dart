import 'package:flutter/material.dart';
import 'package:myapp/routes/routes.dart';
import 'package:myapp/theme/app_pallete.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:myapp/routes/routes_association.dart';

class ProfileAssociation extends StatelessWidget {
  const ProfileAssociation({super.key});

  Future<Map<String, dynamic>?> _getUserData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return null;
    return await Supabase.instance.client
        .from('acteur')
        .select('nom_association')
        .eq('supabase_user_id', user.id)
        .single();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Association'),
        backgroundColor: LightAppPallete.accentDark,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<Map<String, dynamic>?>(
            future: _getUserData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return const Center(child: Text('Erreur lors du chargement du profil'));
              }
              final data = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nom: ${data['nom_association']}', style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, RouteGeneratorAssociation.setting);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: LightAppPallete.accentDark,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Paramètres'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      await Supabase.instance.client.auth.signOut();
                      Navigator.pushReplacementNamed(context, RouteGenerator.login);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Déconnexion'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
/*import 'package:flutter/material.dart';

class ProfileAssociation extends StatelessWidget {
  const ProfileAssociation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Association'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: const Text(
          'Association Profile Screen',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
*/