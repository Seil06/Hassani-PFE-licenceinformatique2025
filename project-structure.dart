//Project Structure

// lib/
// ├── main.dart                   // Entry point of the application
// ├── onboarding_screen.dart      // Onboarding screen for new users
// ├── splash_screen.dart          // Splash screen displayed on app launch
// ├── bloc/                       // State management (BLoC pattern)
// ├── models/                     // Data models
// │   ├── acteur.dart
// │   ├── admin.dart
// │   ├── association.dart
// │   ├── beneficiaire.dart
// │   ├── commentaire.dart
// │   ├── dashboard.dart
// │   ├── don.dart
// │   ├── donateur.dart
// │   ├── historique.dart
// │   ├── like.dart
// │   ├── message.dart
// │   ├── note.dart
// │   ├── notification.dart
// │   ├── post.dart
// │   ├── utilisateur.dart
// │   └── utils.dart
// ├── routes/                     // App routing
// │   └── routes.dart
// ├── screens/                    // UI screens
// │   ├── admin/                  // Admin-specific screens
// │   │   └── admin_home.dart     // Admin home screen
// │   ├── auth/                   // Authentication screens
// │   │   ├── AuthGateScreen.dart
// │   │   ├── connexion.dart
// │   │   └── inscription.dart
// │   └── utilisateur/            // User-specific screens
// │       ├── association/
// │       │   └── association_home.dart // Association home screen
// │       ├── beneficiaire/
// │       │   └── beneficiaire_home.dart // Beneficiary home screen
// │       └── donateur/
// │           └── donateur_home.dart // Donor home screen
// ├── services/                   // Business logic and services
// │   ├── geo_utils.dart          // Geolocation utilities
// │   ├── notification_service.dart
// │   ├── PostService.dart        // Service for managing posts
// │   ├── SearchService.dart      // Service for searching posts
// │   └── ZakatService.dart
// ├── theme/                      // App theming
// │   ├── app_pallete.dart        // Color palette
// │   └── theme.dart              // Theme configuration
// └── widgets/                    // Reusable UI components
//     ├── buttons/
//     │   └── sign_out_button.dart
//     ├── cards/
//     │   └── campagne_card.dart  // Card for displaying campaigns
//     └── pages/
//         ├── feed_page.dart      // Feed page for posts and campaigns
//         ├── campagne_page.dart  // Campaign details page
//         ├── post_page.dart      // Post details page
//         └── home_base.dart      // Base page for the home screen

