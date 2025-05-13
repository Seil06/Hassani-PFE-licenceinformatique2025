import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:myapp/models/association.dart';
import 'package:myapp/theme/app_pallete.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CampagneCard extends StatefulWidget {
  final Campagne campagne;
  final VoidCallback onDonate;

  const CampagneCard({
    super.key,
    required this.campagne,
    required this.onDonate,
  });

  @override
  _CampagneCardState createState() => _CampagneCardState();
}

class _CampagneCardState extends State<CampagneCard> {
  double _userRating = 0.0;
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    _checkFollowStatus();
  }

  Future<void> _checkFollowStatus() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final response = await Supabase.instance.client
        .from('campagne_suivi')
        .select('id_utilisateur')
        .eq('id_campagne', widget.campagne.idPost ?? 0)
        .eq('id_utilisateur', (await _getCurrentUserId()) ?? -1);

    setState(() {
      _isFollowing = response.isNotEmpty;
    });
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

  Future<void> _submitRating(double rating) async {
    final userId = await _getCurrentUserId();
    if (userId == null) return;

    await Supabase.instance.client.from('note').insert({
      'note': rating,
      'date': DateTime.now().toIso8601String(),
      'id_utilisateur_auteur': userId,
      'id_campagne': widget.campagne.idPost,
    });

    setState(() {
      _userRating = rating;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Note soumise avec succès!')),
    );
  }

  Future<void> _toggleFollow() async {
    final userId = await _getCurrentUserId();
    if (userId == null) return;

    if (_isFollowing) {
      await Supabase.instance.client
          .from('campagne_suivi')
          .delete()
          .eq('id_campagne', widget.campagne.idPost ?? 0)
          .eq('id_utilisateur', userId);
    } else {
      await Supabase.instance.client.from('campagne_suivi').insert({
        'id_campagne': widget.campagne.idPost,
        'id_utilisateur': userId,
      });
    }

    setState(() {
      _isFollowing = !_isFollowing;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isFollowing ? 'Suivi activé!' : 'Suivi désactivé!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/campagne-details',
          arguments: {'campagne': widget.campagne},
        );
      },
      child: Container(
        width: 250,
        margin: const EdgeInsets.only(right: 16),
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageSection(),
              _buildDetailsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: CachedNetworkImage(
            imageUrl: widget.campagne.image ?? 'https://via.placeholder.com/250x120',
            height: 120,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => Image.asset(
              'assets/images/placeholder.jpg',
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.campagne.typeCampagne.name,
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsSection() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleAndOrganization(),
          const SizedBox(height: 8),
          _buildStatsRow(),
          const SizedBox(height: 4),
          _buildParticipantsRow(),
          const SizedBox(height: 4),
          _buildProgressIndicator(),
          const SizedBox(height: 8),
          _buildActionsRow(),
          const SizedBox(height: 8),
          ElevatedButton(
  onPressed: widget.onDonate,
  style: TextButton.styleFrom(
    backgroundColor: LightAppPallete.accentDark,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
  ),
  child: const Text(
    'Faire un don',
    style: TextStyle(color: Colors.white), // Ensures the text is visible
  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleAndOrganization() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.campagne.titre,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        FutureBuilder(
          future: Supabase.instance.client
              .from('association')
              .select('nom_association')
              .eq('id_acteur', widget.campagne.idAssociation)
              .single(),
          builder: (context, snapshot) {
            String orgName = 'Inconnu';
            if (snapshot.hasData) {
              orgName = (snapshot.data as Map)['nom_association'] ?? 'Inconnu';
            }
            return Text(
              orgName,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.favorite, size: 16, color: const Color.fromARGB(255, 195, 12, 12)),
            const SizedBox(width: 4),
            Text(
              '${widget.campagne.likes.length}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        Row(
          children: [
            Icon(Icons.comment, size: 16, color: LightAppPallete.grey),
            const SizedBox(width: 4),
            Text(
              '${widget.campagne.commentaires.length}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildParticipantsRow() {
    return Row(
      children: [
        Icon(Icons.group, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          '${widget.campagne.participants.length} participants',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: widget.campagne.pourcentage / 100,
          backgroundColor: const Color.fromARGB(255, 255, 235, 242),
          valueColor: AlwaysStoppedAnimation<Color>(LightAppPallete.accentLight),
        ),
        Text(
          '${widget.campagne.pourcentage.toStringAsFixed(1)}% atteint',
          style: TextStyle(color: Colors.grey[600], fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildActionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: List.generate(5, (index) {
            return IconButton(
              icon: Icon(
                index < _userRating ? Icons.star : Icons.star_border,
                color: LightAppPallete.accent,
                size: 16,
              ),
              onPressed: () {
                _submitRating(index + 1.0);
              },
            );
          }),
        ),
        ElevatedButton(
          onPressed: _toggleFollow,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isFollowing ? LightAppPallete.grey : LightAppPallete.accent,
          ),
          child: Text(_isFollowing ? 'Suivi' : 'Suivre'),
        ),
      ],
    );
  }
}