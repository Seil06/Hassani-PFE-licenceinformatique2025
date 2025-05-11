import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/acteur.dart';
import 'package:myapp/models/association.dart';
import 'package:myapp/models/commentaire.dart';
import 'package:myapp/models/dashboard.dart';
import 'package:myapp/models/historique.dart';
import 'package:myapp/services/CommentService.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CampagneDetailsPage extends StatefulWidget {
  final Campagne campagne;
  const CampagneDetailsPage({super.key, required this.campagne});

  @override
  State<CampagneDetailsPage> createState() => _CampagneDetailsPageState();
}

class _CampagneDetailsPageState extends State<CampagneDetailsPage> {
  final TextEditingController _commentController = TextEditingController();
  List<Commentaire> _comments = [];

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    final comments = await CommentService().getCommentsForCampagne(widget.campagne.idPost ?? 0);
    setState(() {
      _comments = comments;
    });
  }

  Future<void> _submitComment() async {
    if (_commentController.text.isEmpty) return;

    final userData = await _getCurrentUserData();
    if (userData == null) return;

    final newComment = Commentaire(
      contenu: _commentController.text,
      date: DateTime.now(),
      acteur: Acteur(
        id: userData['id_acteur'],
        typeA: TypeActeur.utilisateur,
        email: userData['email'],
        motDePasse: userData['mot_de_passe'] ?? '',
        numCarteIdentite: userData['num_carte_identite'] ?? '123456789012345678', // Must be 18 chars
        profile: Profile(
          idDashboard: userData['id_dashboard'] ?? 0,
          photoUrl: userData['photo_url'],
          bio: userData['bio'],
        ),
        dashboard: Dashboard(
          idDashboard: userData['id_dashboard'],
          posts: const [],
          historique: Historique(
            date: DateTime.now(),
            action: '',
            details: '',
          ),
          notifications: const [],
        ),
      ),
      idCampagne: widget.campagne.idPost,
    );

    await CommentService().submitComment(newComment);
    _commentController.clear();
    await _fetchComments();
  }

  Future<Map<String, dynamic>?> _getCurrentUserData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return null;

    final response = await Supabase.instance.client
        .from('acteur')
        .select('id_acteur, email, mot_de_passe, num_carte_identite, profile(id_dashboard, photo_url, bio), dashboard(id_dashboard)')
        .eq('supabase_user_id', user.id)
        .single();

    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.campagne.titre),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.campagne.image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: widget.campagne.image!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => Image.asset(
                    'assets/images/placeholder.jpg',
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              widget.campagne.titre,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.campagne.description,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Type: ${widget.campagne.typeCampagne.name}',
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Objectif',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    Text(
                      '${widget.campagne.montantObjectif} DZD',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Récolté',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    Text(
                      '${widget.campagne.montantRecolte} DZD',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.group, color: Colors.grey, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${widget.campagne.participants.length} participants',
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (widget.campagne.dateDebut != null && widget.campagne.dateFin != null)
              Text(
                'Du ${widget.campagne.dateDebut!.toString().split(' ')[0]} au ${widget.campagne.dateFin!.toString().split(' ')[0]}',
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            const SizedBox(height: 16),
            if (widget.campagne.lieuEvenement != null)
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.grey, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Lieu: ${widget.campagne.lieuEvenement}',
                      style: const TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            const Text(
              'Commentaires',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _comments.length,
              itemBuilder: (context, index) {
                final comment = _comments[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      comment.acteur.email.isNotEmpty
                          ? comment.acteur.email[0].toUpperCase()
                          : 'U',
                    ),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        comment.acteur.email.isNotEmpty
                            ? comment.acteur.email.split('@')[0]
                            : 'Utilisateur',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        DateFormat('dd MMM yyyy, HH:mm').format(comment.date),
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  subtitle: Text(comment.contenu),
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Ajouter un commentaire...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _submitComment,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}