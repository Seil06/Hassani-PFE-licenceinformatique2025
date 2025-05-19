import 'package:flutter/foundation.dart' show kIsWeb; // For platform detection
import 'package:flutter/material.dart';
import 'package:myapp/routes/routes_association.dart';
import 'package:myapp/routes/routes_beneficiaire.dart';
import 'package:myapp/routes/routes_donateur.dart';
import 'package:myapp/theme/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:myapp/main.dart';
import 'package:myapp/theme/app_pallete.dart';
import 'connexion.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert'; // For utf8.encode
import 'dart:io' as io; // Alias for dart:io to avoid conflicts on web
import 'package:file_picker/file_picker.dart';

class Inscription extends StatefulWidget {
  static route() => MaterialPageRoute(
        builder: (context) => const Inscription(),
      );

  const Inscription({super.key});

  @override
  State<Inscription> createState() => _InscriptionState();
}

class _InscriptionState extends State<Inscription> {
  String userType = 'donateur';
  String? typeBeneficiaire; // Store the selected type_beneficiaire
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nomController = TextEditingController();
  final prenomController = TextEditingController();
  final nomAssociationController = TextEditingController();
  final numCarteIdentiteController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  PlatformFile? _selectedFile; // Store the selected file information (for association or beneficiaire)
  String? _fileName; // Store the selected file name for display
  bool _fileError = false; // Track file selection error

  // List of options for type_beneficiaire dropdown (matches schema)
  final List<String> beneficiaireTypes = [
    'pauvre',
    'sdf',
    'orphelin',
    'enfantMalade',
    'personneAgee',
    'malade',
    'handicape',
    'femmeDivorcee',
    'femmeSeule',
    'femmeVeuve',
    'autre',
  ];

  // Function to format type_beneficiaire for display
  String _formatBeneficiaireType(String type) {
    switch (type) {
      case 'pauvre':
        return 'Pauvre';
      case 'sdf':
        return 'Sans-abri (SDF)';
      case 'orphelin':
        return 'Orphelin';
      case 'enfantMalade':
        return 'Enfant Malade';
      case 'personneAgee':
        return 'Personne Âgée';
      case 'malade':
        return 'Malade';
      case 'handicape':
        return 'Personne Handicapée';
      case 'femmeDivorcee':
        return 'Femme Divorcée';
      case 'femmeSeule':
        return 'Femme Seule';
      case 'femmeVeuve':
        return 'Femme Veuve';
      case 'autre':
        return 'Autre';
      default:
        return type;
    }
  }

  // Function to hash the password using SHA-256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  // Normalize userType to match database expected values
  String _normalizeUserType(String userType) {
    switch (userType) {
      case 'donateur':
        return 'donateur';
      case 'association':
        return 'association';
      case 'bénéficiaire':
        return 'beneficiaire'; // Map accented version to non-accented for database
      default:
        return userType;
    }
  }

   Future<void> _signUp() async {
  if (!formKey.currentState!.validate()) return;

  // Validation du fichier pour association ou bénéficiaire
  if ((userType == 'association' || userType == 'bénéficiaire') && _selectedFile == null) {
    setState(() => _fileError = true);
    return;
  } else {
    setState(() => _fileError = false);
  }

  setState(() => _isLoading = true);

  try {
    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text.trim();
    final hashedPassword = _hashPassword(password);

    // First, check if user already exists in Supabase Auth
    try {
      await supabase.auth.signInWithPassword(email: email, password: 'dummy');
      // If no exception, user exists
      throw Exception('Cet email est déjà enregistré.');
    } on AuthException catch (e) {
      // If auth fails with invalid credentials, user doesn't exist - this is good
      if (!e.message.toLowerCase().contains('invalid login credentials')) {
        // Some other auth error occurred
        throw e;
      }
      // User doesn't exist, continue with registration
    }

    // Vérifier les doublons dans la base de données AVANT de créer l'utilisateur Auth
    if (userType == 'donateur' || userType == 'bénéficiaire') {
      final existingCarteIdentite = await supabase
          .from('utilisateur')
          .select()
          .eq('num_carte_identite', numCarteIdentiteController.text.trim())
          .maybeSingle();
      if (existingCarteIdentite != null) {
        throw Exception('Ce numéro de carte d\'identité est déjà utilisé.');
      }
    }

    // Check if email already exists in our database
    final existingUser = await supabase
        .from('acteur')
        .select()
        .eq('email', email)
        .maybeSingle();
    if (existingUser != null) {
      throw Exception('Cet email est déjà enregistré.');
    }

    // Now create the Auth user and database transaction together
    User? authUser;
    int? idActeur;
    
    try {
      // Create Auth user
      final authResponse = await supabase.auth.signUp(email: email, password: password);
      authUser = authResponse.user;
      
      if (authUser == null) {
        throw Exception('Erreur lors de la création du compte utilisateur.');
      }

      // Call the stored procedure with the Auth user ID
      final result = await supabase.rpc('create_user_with_transaction', params: {
        'p_email': email,
        'p_hashed_password': hashedPassword,
        'p_user_id': authUser.id,
        'p_user_type': _normalizeUserType(userType),
        'p_nom': nomController.text.trim(),
        'p_prenom': prenomController.text.trim(),
        'p_num_carte_identite': userType == 'donateur' || userType == 'bénéficiaire'
            ? numCarteIdentiteController.text.trim()
            : null,
        'p_nom_association': userType == 'association' ? nomAssociationController.text.trim() : null,
        'p_type_beneficiaire': userType == 'bénéficiaire' ? (typeBeneficiaire ?? 'autre') : null,
      }).select().single();

      idActeur = result['id_acteur'] as int;

    } catch (dbError) {
      // Re-throw the original database error
      throw dbError;
    }

    // Téléversement du fichier APRÈS la transaction réussie
    String? documentUrl;
    if (_selectedFile != null && idActeur != null) {
      try {
        final bucket = userType == 'association' ? 'association-documents' : 'beneficiaire-documents';
        final fileName = '${idActeur}_document_${userType}.${_fileName!.split('.').last}';
        
        if (kIsWeb) {
          if (_selectedFile!.bytes != null) {
            await supabase.storage.from(bucket).uploadBinary(fileName, _selectedFile!.bytes!);
          }
        } else {
          final file = io.File(_selectedFile!.path!);
          await supabase.storage.from(bucket).uploadBinary(fileName, await file.readAsBytes());
        }
        
        documentUrl = supabase.storage.from(bucket).getPublicUrl(fileName);

        // Mettre à jour la table correspondante avec l'URL du document
        if (userType == 'association') {
          await supabase.from('association').update({'document_authorisation': documentUrl}).eq('id_acteur', idActeur);
        } else if (userType == 'bénéficiaire') {
          await supabase.from('beneficiaire').update({'document_situation': documentUrl}).eq('id_acteur', idActeur);
        }
      } catch (fileError) {
        // File upload failed, but user is created. You might want to show a warning
        print('File upload failed: $fileError');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Compte créé mais erreur lors du téléversement du fichier: ${fileError.toString()}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }

    // Redirection après succès
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Inscription réussie ! Bienvenue !')),
    );
    
    String nextRoute = userType == 'donateur'
        ? RouteGeneratorDonateur.home // Donateur route
        : userType == 'association'
            ? RouteGeneratorAssociation.home // Association route
            : RouteGeneratorBeneficiaire.home; // Beneficiaire route
    Navigator.pushReplacementNamed(context, nextRoute);
    
  } catch (error) {
    String errorMessage = 'Erreur : ${error.toString()}';
    if (error is AuthException) {
      errorMessage = error.message.contains('User already registered')
          ? 'Cet email est déjà enregistré.'
          : error.message;
    } else if (error.toString().contains('num_carte_identite')) {
      errorMessage = 'Ce numéro de carte d\'identité est déjà utilisé ou invalide.';
    } else if (error.toString().contains('déjà enregistré') || error.toString().contains('déjà utilisé')) {
      errorMessage = error.toString().replaceAll('Exception: ', '');
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: LightAppPallete.error,
      ),
    );
  } finally {
    setState(() => _isLoading = false);
  }
}

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nomController.dispose();
    prenomController.dispose();
    nomAssociationController.dispose();
    numCarteIdentiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeBackground(
      isDarkMode: Theme.of(context).brightness == Brightness.dark,
      child: Scaffold(
        backgroundColor: Colors.transparent, // Transparent to show gradient
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width > 600 ? 40 : 20,
                vertical: 20,
              ),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  color: LightAppPallete.background,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        height: 80,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.favorite,
                          size: 80,
                          color: LightAppPallete.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'S\'inscrire',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Créez un compte pour aider les nécessiteux',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 24),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width - 48,
                          ),
                          child: ToggleButtons(
                            isSelected: [
                              userType == 'donateur',
                              userType == 'association',
                              userType == 'bénéficiaire',
                            ],
                            onPressed: (index) {
                              setState(() {
                                userType = ['donateur', 'association', 'bénéficiaire'][index];
                                typeBeneficiaire = null; // Reset dropdown when changing user type
                                _selectedFile = null; // Reset selected file when changing user type
                                _fileName = null;
                              });
                            },
                            children: const [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                child: Text('Donateur'),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                child: Text('Association'),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                child: Text('Bénéficiaire'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (userType == 'donateur' || userType == 'bénéficiaire') ...[
                        TextFormField(
                          controller: prenomController,
                          decoration: const InputDecoration(
                            labelText: 'Prénom',
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Prénom requis';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: nomController,
                          decoration: const InputDecoration(
                            labelText: 'Nom',
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Nom requis';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (userType == 'association') ...[
                        TextFormField(
                          controller: nomAssociationController,
                          decoration: const InputDecoration(
                            labelText: 'Nom de l\'association',
                            prefixIcon: Icon(Icons.business),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Nom de l\'association requis';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                      TextFormField(
                        controller: numCarteIdentiteController,
                        decoration: const InputDecoration(
                          labelText: 'Numéro de carte d\'identité biométrique',
                          hintText: 'Ex: 123456789012345678', 
                          hintStyle: TextStyle(color: Colors.grey), 
                          prefixIcon: Icon(Icons.card_membership),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Le numéro de carte d\'identité est requis';
                          }
                          if (value.length != 18) {
                            return 'Le numéro doit avoir exactement 18 caractères';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      if (userType == 'bénéficiaire') ...[
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: typeBeneficiaire,
                            decoration: const InputDecoration(
                              labelText: 'Statut',
                              prefixIcon: Icon(Icons.category),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              border: InputBorder.none,
                            ),
                            isExpanded: true,
                            hint: const Text('Sélectionnez votre situation'),
                            items: beneficiaireTypes
                                .map((type) => DropdownMenuItem(
                                      value: type,
                                      child: Text(
                                        _formatBeneficiaireType(type),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                typeBeneficiaire = value;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Type de bénéficiaire requis';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email requis';
                          } else if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                            return "Format d'email invalide";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Mot de passe',
                          prefixIcon: Icon(Icons.lock),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Mot de passe requis';
                          } else if (value.length < 8) {
                            return 'Le mot de passe doit avoir au moins 8 caractères';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // File picker for Association or Bénéficiaire
                      if (userType == 'association' || userType == 'bénéficiaire') ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey.shade50,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _fileName != null
                                  ? Icon(Icons.check_circle, color: LightAppPallete.accent, size: 48)
                                  : Icon(Icons.cloud_upload, color: LightAppPallete.primary, size: 48),
                              const SizedBox(height: 12),
                              Text(
                                _fileName != null
                                    ? 'Document sélectionné: $_fileName'
                                    : userType == 'association'
                                        ? 'Déposer votre document d\'autorisation ici'
                                        : 'Déposer un document pour confirmer votre situation ici',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _fileName != null ? Colors.black87 : Colors.grey.shade700,
                                  fontWeight: _fileName != null ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                onPressed: () async {
                                  final result = await FilePicker.platform.pickFiles();
                                  if (result != null) {
                                    setState(() {
                                      _selectedFile = result.files.first;
                                      _fileName = _selectedFile!.name;
                                      _fileError = false; // Reset error when file is picked
                                    });
                                  }
                                },
                                icon: Icon(Icons.attach_file, size: 18),
                                label: Text(_fileName == null ? 'Sélectionner un fichier' : 'Changer de fichier'),
                              ),
                            ],
                          ),
                        ),
                        if (_fileError)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              userType == 'association'
                                  ? 'Document d\'autorisation requis'
                                  : 'Document de situation requis',
                              style: const TextStyle(color: Colors.red, fontSize: 13),
                            ),
                          ),
                        const SizedBox(height: 16),
                      ],
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _signUp,
                          child: Text(_isLoading ? 'Inscription...' : 'S\'inscrire'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.push(context, Connexion.route());
                        },
                        child: const Text('Déjà inscrit ? Se connecter'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}