/*Project Structure

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
// │   │   ├── admin_home.dart     // Admin home screen
// │   │   └── profile_admin.dart   // Admin profile screen
// │   ├── auth/                   // Authentication screens
// │   │   ├── AuthGateScreen.dart
// │   │   ├── connexion.dart
// │   │   └── inscription.dart
// │   ├── utilisateur/            // User-specific screens
// │   │   ├── association/
// │   │   │   ├── association_home.dart // Association home screen
// │   │   │   ├── association_profile.dart // Association profile screen
// │   │   │   ├── Gestion_campagne.dart  //create new cmapagnes, update darft cmapagnes or alreday published ones, delete campaigns or dtafted ones
// │   │   │   └── profile_association.dart // Association profile screen
// │   │   ├── beneficiaire/
// │   │   │   ├── beneficiaire_home.dart // Beneficiary home screen
// │   │   │   ├── beneficiaire_profile.dart // Beneficiary profile screen
// │   │   │   ├── Gestion_post_demande.dart // Create post demande, update post demande, delete post demande, possibility to add payment methods if the typedon=financier
// │   │   │   └── profile_beneficiaire.dart // Beneficiary profile screen
// │   │   └── donateur/
// │   │       ├── donateur_home.dart // Donateur feed page
// │   │       ├── donateur_profile.dart // Donateur profile screen
// │   │       ├── calculateur_zakat_screen.dart //doanetur clacluer leur montant de zakat et choix de faire directemnt lenvoie de montant a une association ou un beneficiaire ou non pas d'envoie!
// │   │       ├── Gestion_post.dart // Create post invite ou Offre, update post, delete post invite no possibility to add payment methods since, possibility to add utilidateur taguer when create the post (see the schema.sql)
// │   │       └── profile_donateur.dart // Donor profile screen
// │   |
// │   └── shared/  // Shared screens across user types
// │           ├── campagne_page.dart  // Campaign details page of feed : display all the comments, likes, all list of participants (who already clicked the button donate if it's a finance campaign/ button participate if the campaign type doesn't equal financier)
// │           ├── research_page.dart  // Search page for posts, campaigns, and users
// │           ├── map_page.dart      // page to display 2 blocks of maps cards : 1st block map card displays the actors who are nearby to the current user, 2nd block display posts and campagnes with location nearby to the current user
// |           └── settings_page.dart  // page paramettres : modifier mot de passe, deconnexion : sign out, log out, modifer profile, connsulter historique
// |
// ├── services/                   // Business logic and services
// │   ├── campagne_service.dart     // Service for managing campaigns
// │   ├── CommentaireService.dart   // Service for managing comments
// │   ├── geo_utils.dart          // Geolocation utilities
// │   ├── NotificationService.dart
// │   ├── PostService.dart        // Service for managing posts
// │   ├── RatingService.dart        // Service for managing user data
// │   ├── SearchService.dart      // for Advanced search system for (post,campagne,users) post search by nearby location to user, typedon, typepost :demande,invite,offre,technique..ect, MotCles, lieu Utilisateur , tilte of post and Description of post, plus the date / Cmapagne search by : nearby location to user, typeDon , typeCampagne, nombre participants, temps restant, lieu evenments, MotCles...ect/ user search by : nearby location to user, nom et perenom ou nom association, typeUtilisaetur (beneficiaire, donateur, association)...ect
// │   └── ZakatService.dart
// |
// ├── theme/                      // App theming
// │   ├── animated_gradient_background.dart // Animated gradient background widget
// │   ├── app_pallete.dart          // Main theme configuration
// │   ├── custom_gradient_pallete.dart // Custom gradient palette
// │   └── theme.dart              // Theme configuration
// |
// └── widgets/                    // Reusable UI components
//     ├── buttons/
//     │   ├── log_out_button.dart
//     │   └── sign_out_button.dart
//     ├── cards/
//     │   ├── post_card.dart      // Card for displaying user information
//     │   └── campagne_card.dart  // Card for displaying campaigns
//     └── pages/
//         ├── feed_page.dart      // will movee theis pages to screens folder than dapt it for each actor since they have a bit different roles when it comes to who can particpate to a campagne or not!
//         ├── campagne_page.dart  // will movee this page to shared folder
//         └── post_page.dart      // will movee this page to shared folder

*/