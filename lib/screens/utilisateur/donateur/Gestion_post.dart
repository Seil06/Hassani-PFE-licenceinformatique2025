import 'package:flutter/material.dart';
import 'package:myapp/models/post.dart';
import 'package:myapp/services/SearchService.dart';
import 'package:myapp/theme/app_pallete.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Stateless widget for creating a new post (invite type) for donateurs
class GestionPost extends StatefulWidget {
  const GestionPost({super.key});

  @override
  State<GestionPost> createState() => _GestionPostState();
}

class _GestionPostState extends State<GestionPost> {
  final _titleController = TextEditingController(); // Controller for title input
  final _contentController = TextEditingController(); // Controller for description
  MotCles? _selectedMotCle; // Selected keyword
  bool _isLoading = false; // Loading state for submission
  String? _errorMessage; // Error message for display

  // Fetches the current user's id_acteur and verifies donateur status
  Future<Map<String, dynamic>?> _getCurrentUserData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return null;
    try {
      final response = await Supabase.instance.client
          .from('acteur')
          .select('id_acteur, utilisateur(type_utilisateur)')
          .eq('supabase_user_id', user.id)
          .maybeSingle();
      return response;
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la récupération des données: $e';
      });
      return null;
    }
  }

  // Submits the post to the post table
  Future<void> _submitPost() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty || _selectedMotCle == null) {
      setState(() {
        _errorMessage = 'Veuillez remplir tous les champs';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final userData = await _getCurrentUserData();
    if (userData == null || userData['utilisateur']['type_utilisateur'] != 'donateur') {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Seuls les donateurs peuvent créer des publications';
      });
      return;
    }

    try {
      await Supabase.instance.client.from('post').insert({
        'id_acteur': userData['id_acteur'],
        'titre': _titleController.text,
        'contenu': _contentController.text,
        'type_post': 'invite',
        'mots_cles': [_selectedMotCle!.name],
        'date_post': DateTime.now().toIso8601String(),
        'etat_post': 'actif',
      });

      if (mounted) {
        Navigator.pop(context); // Return to FeedPage
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Publication créée avec succès')),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la création: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer une Publication'),
        backgroundColor: LightAppPallete.accentDark,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<MotCles>(
                value: _selectedMotCle,
                hint: const Text('Sélectionner une catégorie'),
                items: MotCles.values.map((motCle) {
                  return DropdownMenuItem(
                    value: motCle,
                    child: Text(motCle.name[0].toUpperCase() + motCle.name.substring(1)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMotCle = value;
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: LightAppPallete.accentDark,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Publier'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}