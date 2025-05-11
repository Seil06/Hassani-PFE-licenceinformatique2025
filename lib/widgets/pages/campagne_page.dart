import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:myapp/models/association.dart';

class CampagneDetailsPage extends StatefulWidget {
  final Campagne campagne;
  const CampagneDetailsPage({super.key, required this.campagne});
  @override
  State<CampagneDetailsPage> createState() => _CampagneDetailsPageState();
}

class _CampagneDetailsPageState extends State<CampagneDetailsPage> {
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
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
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
          ],
        ),
      ),
    );
  }
}