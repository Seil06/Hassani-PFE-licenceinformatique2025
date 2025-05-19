import 'package:flutter/material.dart';
import 'package:myapp/models/post.dart';
import 'package:myapp/services/SearchService.dart';
import 'package:myapp/theme/app_pallete.dart';
import 'package:myapp/widgets/cards/post_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Stateful widget for searching posts by query or category
class SearchPageAssociation extends StatefulWidget {
  const SearchPageAssociation({super.key});

  @override
  State<SearchPageAssociation> createState() => _SearchPageAssociationState();
}

class _SearchPageAssociationState extends State<SearchPageAssociation> {
  final _searchController = TextEditingController(); // Controller for search input
  List<Post> _posts = []; // List of search results
  MotCles? _selectedMotCle; // Selected category filter
  bool _isLoading = false; // Loading state
  String? _errorMessage; // Error message for display
  final _searchService = SearchService(); // Instance of SearchService

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged); // Listen for search input changes
    _fetchPosts(); // Initial fetch with no filters
  }

  // Fetches posts based on query or selected MotCles
  Future<void> _fetchPosts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final posts = await _searchService.searchPosts(
        query: _searchController.text.trim(),
        motCle: _selectedMotCle,
      );
      setState(() {
        _posts = posts;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la recherche: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Handles search input changes with debounce
  void _onSearchChanged() {
    // Debounce to avoid excessive queries
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _fetchPosts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trouver une publication'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Image.asset(
              'assets/images/FatherDay.png',
              height: 80,
            ),
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: const Color.fromARGB(255, 245, 172, 197),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Effectuer une recherche...',
                  prefixIcon: Icon(Icons.search, color: LightAppPallete.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  filled: true,
                  fillColor: const Color.fromARGB(255, 245, 172, 197),
                ),
              ),
              const SizedBox(height: 16),
              // Category chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: MotCles.values.map((motCle) {
                    final isSelected = _selectedMotCle == motCle;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedMotCle = isSelected ? null : motCle;
                            _fetchPosts(); // Refresh results
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? LightAppPallete.accent : LightAppPallete.surfaceLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                _searchService.categoriesImages[motCle] ?? 'assets/icons/autre.ico',
                                width: 40,
                                height: 40,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                motCle.name[0].toUpperCase() + motCle.name.substring(1),
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.grey[600],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              // Error message
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 16),
              // Search results
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _posts.isEmpty
                        ? Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: Text(
                                'Aucune publication trouvée',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _posts.length,
                            itemBuilder: (context, index) {
                              return PostCard(
                                post: _posts[index],
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/post-details',
                                    arguments: {'post': _posts[index]},
                                  );
                                },
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }
}