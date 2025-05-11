import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:myapp/models/association.dart';
import 'package:myapp/theme/app_pallete.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CampagneCard extends StatefulWidget {
  final Campagne campagne;
  final VoidCallback onDonate;

  const CampagneCard({super.key, required this.campagne, required this.onDonate});

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
        width: 280,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Type Badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: widget.campagne.image ?? 'https://via.placeholder.com/280x160',
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 160,
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 160,
                      color: Colors.grey[100],
                      child: const Center(
                        child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      widget.campagne.typeCampagne.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Content Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.campagne.titre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  
                  // Organization Name
                  FutureBuilder(
                    future: Supabase.instance.client
                        .from('association')
                        .select('nom_association')
                        .eq('id_acteur', widget.campagne.idAssociation)
                        .single(),
                    builder: (context, snapshot) {
                      String orgName = 'Chargement...';
                      if (snapshot.hasData) {
                        orgName = (snapshot.data as Map)['nom_association'] ?? 'Inconnu';
                      } else if (snapshot.hasError) {
                        orgName = 'Inconnu';
                      }
                      return Text(
                        orgName,
                        style: TextStyle(
                          color: LightAppPallete.accentDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Engagement Metrics
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Likes
                      Row(
                        children: [
                          Icon(
                            Icons.favorite,
                            size: 18,
                            color: const Color.fromARGB(255, 195, 12, 12),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.campagne.likes.length}',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      
                      // Comments
                      Row(
                        children: [
                          Icon(
                            Icons.comment_outlined,
                            size: 18,
                            color: Colors.grey[700],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.campagne.commentaires.length}',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      
                      // Participants
                      Row(
                        children: [
                          Icon(
                            Icons.group_outlined,
                            size: 18,
                            color: Colors.grey[700],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.campagne.participants.length}',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Progress Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Objectif atteint',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${widget.campagne.pourcentage.toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: LightAppPallete.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: widget.campagne.pourcentage / 100,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(LightAppPallete.primary),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Actions Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Follow Button
                      InkWell(
                        onTap: _toggleFollow,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: _isFollowing 
                                ? Colors.grey[200] 
                                : LightAppPallete.accentDark.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _isFollowing ? Icons.check : Icons.add,
                                size: 16,
                                color: _isFollowing 
                                    ? Colors.grey[700] 
                                    : LightAppPallete.accentDark,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _isFollowing ? 'Suivi' : 'Suivre',
                                style: TextStyle(
                                  color: _isFollowing 
                                      ? Colors.grey[700] 
                                      : LightAppPallete.accentDark,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Donate Button
                      ElevatedButton(
                        onPressed: widget.onDonate,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: LightAppPallete.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Faire un don',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Rating Section  
                  const SizedBox(height: 16),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(5, (index) {
                        return InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => _submitRating(index + 1.0),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              index < _userRating ? Icons.star_rounded : Icons.star_outline_rounded,
                              color: Colors.amber,
                              size: 24,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}