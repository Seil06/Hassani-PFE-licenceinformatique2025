import 'package:flutter/material.dart';
import 'package:myapp/routes/routes.dart';
import 'package:myapp/theme/app_pallete.dart';
import 'package:myapp/widgets/buttons/sign_out_button.dart';
import 'package:myapp/widgets/buttons/modify_profile_button.dart';

class SettingsPageDonateur extends StatefulWidget {
  const SettingsPageDonateur({Key? key}) : super(key: key);

  @override
  _SettingsPageDonateurState createState() => _SettingsPageDonateurState();
}

class _SettingsPageDonateurState extends State<SettingsPageDonateur> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _darkModeEnabled = false;
  bool _biometricEnabled = false;

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: LightAppPallete.primaryDark,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? iconColor,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (iconColor ?? LightAppPallete.primary).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor ?? LightAppPallete.primary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              )
            : null,
        trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    Color? iconColor,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: SwitchListTile(
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (iconColor ?? LightAppPallete.primary).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor ?? LightAppPallete.primary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              )
            : null,
        value: value,
        onChanged: onChanged,
        activeColor: LightAppPallete.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            LightAppPallete.primary.withOpacity(0.1),
            LightAppPallete.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LightAppPallete.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: LightAppPallete.primary.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(
                'https://eouymrxocetlfxyyibou.supabase.co/storage/v1/object/public/profile//profile.jpg',
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Votre Profil',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Gérez vos informations personnelles',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            child: ModifyProfileButton(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Paramètres',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            
            // Profile Header
            _buildProfileHeader(),
            
            // Account Section
            _buildSectionHeader('COMPTE'),
            _buildSettingsTile(
              icon: Icons.person_outline,
              title: 'Informations personnelles',
              subtitle: 'Nom, email, téléphone',
              onTap: () {
                // Navigate to personal info page
              },
            ),
            _buildSettingsTile(
              icon: Icons.security,
              title: 'Sécurité et confidentialité',
              subtitle: 'Mot de passe, authentification',
              onTap: () {
                // Navigate to security page
              },
            ),
            _buildSettingsTile(
              icon: Icons.payment,
              title: 'Méthodes de paiement',
              subtitle: 'Cartes bancaires, portefeuilles',
              onTap: () {
                // Navigate to payment methods
              },
            ),
            
            // Notifications Section
            _buildSectionHeader('NOTIFICATIONS'),
            _buildSwitchTile(
              icon: Icons.notifications_outlined,
              title: 'Notifications push',
              subtitle: 'Recevoir les notifications sur votre appareil',
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            _buildSwitchTile(
              icon: Icons.email_outlined,
              title: 'Notifications email',
              subtitle: 'Recevoir les notifications par email',
              value: _emailNotifications,
              onChanged: (value) {
                setState(() {
                  _emailNotifications = value;
                });
              },
            ),
            
            // Preferences Section
            _buildSectionHeader('PRÉFÉRENCES'),
            _buildSwitchTile(
              icon: Icons.dark_mode_outlined,
              title: 'Mode sombre',
              subtitle: 'Activer le thème sombre',
              value: _darkModeEnabled,
              onChanged: (value) {
                setState(() {
                  _darkModeEnabled = value;
                });
              },
            ),
            _buildSettingsTile(
              icon: Icons.language,
              title: 'Langue',
              subtitle: 'Français',
              onTap: () {
                // Navigate to language selection
              },
            ),
            _buildSwitchTile(
              icon: Icons.fingerprint,
              title: 'Authentification biométrique',
              subtitle: 'Utiliser empreinte/Face ID',
              value: _biometricEnabled,
              onChanged: (value) {
                setState(() {
                  _biometricEnabled = value;
                });
              },
            ),
            
            // Support Section
            _buildSectionHeader('SUPPORT'),
            _buildSettingsTile(
              icon: Icons.help_outline,
              title: 'Centre d\'aide',
              subtitle: 'FAQ et assistance',
              onTap: () {
                // Navigate to help center
              },
            ),
            _buildSettingsTile(
              icon: Icons.feedback_outlined,
              title: 'Envoyer un commentaire',
              subtitle: 'Aidez-nous à améliorer l\'app',
              onTap: () {
                // Navigate to feedback page
              },
            ),
            _buildSettingsTile(
              icon: Icons.info_outline,
              title: 'À propos',
              subtitle: 'Version 1.0.0',
              onTap: () {
                // Show about dialog
                showAboutDialog(
                  context: context,
                  applicationName: 'Donations App',
                  applicationVersion: '1.0.0',
                  applicationIcon: Icon(
                    Icons.favorite,
                    color: LightAppPallete.primary,
                    size: 32,
                  ),
                );
              },
            ),
            
            // Danger Zone
            _buildSectionHeader('ZONE DANGEREUSE'),
            _buildSettingsTile(
              icon: Icons.delete_outline,
              title: 'Supprimer le compte',
              subtitle: 'Supprimer définitivement votre compte',
              iconColor: Colors.red,
              trailing: const Icon(Icons.chevron_right, color: Colors.red),
              onTap: () {
                // Show delete account confirmation
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Supprimer le compte'),
                    content: const Text(
                      'Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Annuler'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Implement account deletion
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Supprimer'),
                      ),
                    ],
                  ),
                );
              },
            ),
            
            // Sign Out Section
            const SizedBox(height: 32),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              width: double.infinity,
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.red.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.logout,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Se déconnecter',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.red,
                          ),
                        ),
                      ),
                      SignOutButton(routeAfterSignOut: RouteGenerator.login),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}