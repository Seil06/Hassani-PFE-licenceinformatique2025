import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:myapp/theme/app_pallete.dart';

// Stateful widget for the header bar
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
                          ? 'https://eouymrxocetlfxyyibou.supabase.co/storage/v1/object/public/profile/${profileData['photo_url']}'
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
