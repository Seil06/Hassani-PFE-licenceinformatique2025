import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:myapp/models/association.dart';
import 'package:myapp/theme/app_pallete.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CampagneCard extends StatelessWidget {
  final Campagne campagne;
  final VoidCallback onDonate;

  const CampagneCard({super.key, required this.campagne, required this.onDonate});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/campagne-details',
          arguments: {'campagne': campagne},
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
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: campagne.image ?? 'https://via.placeholder.com/250x120',
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
                        campagne.typeCampagne.name,
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      campagne.titre,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    FutureBuilder(
                      future: Supabase.instance.client
                          .from('association')
                          .select('nom_association')
                          .eq('id_acteur', campagne.idAssociation)
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
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.favorite, size: 16, color: const Color.fromARGB(255, 195, 12, 12)),
                            const SizedBox(width: 4),
                            Text(
                              '${campagne.likes.length}',
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.comment, size: 16, color: LightAppPallete.grey),
                            const SizedBox(width: 4),
                            Text(
                              '${campagne.commentaires.length}',
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.group, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${campagne.participants.length} participants',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: campagne.pourcentage / 100,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(LightAppPallete.primary),
                    ),
                    Text(
                      '${campagne.pourcentage.toStringAsFixed(1)}% atteint',
                      style: TextStyle(color: Colors.grey[600], fontSize: 10),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: onDonate,
                      child: const Text('Faire un don'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}