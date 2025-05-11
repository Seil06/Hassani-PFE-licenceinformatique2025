import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:myapp/models/post.dart';

class PostDetailsPage extends StatefulWidget {
  final Post post;
  const PostDetailsPage({super.key, required this.post});
  @override
  State<PostDetailsPage> createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends State<PostDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post.titre),
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
            if (widget.post.image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: widget.post.image!,
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
              widget.post.titre,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.post.description,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.favorite, color: Colors.grey, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${widget.post.likes.length} Likes',
                      style: const TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.comment, color: Colors.grey, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${widget.post.commentaires.length} Commentaires',
                      style: const TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (widget.post.dateLimite != null)
              Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.grey, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.post.dateLimite!.difference(DateTime.now()).inDays} jours restants',
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}