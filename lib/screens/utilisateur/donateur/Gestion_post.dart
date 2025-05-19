import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:myapp/routes/routes_donateur.dart';
import 'package:myapp/services/post_service.dart';
import 'package:myapp/theme/app_pallete.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/services/geo_utils.dart';

extension StringCasingExtension on String {
  String capitalize() => isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : '';
}

class GestionPost extends StatefulWidget {
  final int idActeur;
  final Map<String, dynamic> userData;

  const GestionPost({super.key, required this.idActeur, required this.userData})
      : assert(idActeur != null, 'idActeur cannot be null');

  @override
  _GestionPostState createState() => _GestionPostState();
}

class _GestionPostState extends State<GestionPost> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PostService _postService = PostService();
  List<Map<String, dynamic>> _userPosts = [];
  bool _isLoadingPosts = true;

  // Post creation variables
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titreController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  DateTime? _dateLimite;
  List<String> _selectedMotsCles = [];
  String? _imageUrl;
  List<Map<String, dynamic>> _availableMotsCles = [];

  LatLng? _selectedLocation;
  final Completer<GoogleMapController> _mapController = Completer();
  final _places = GoogleMapsPlaces(apiKey: "AIzaSyDm7nwkWyl3djkqjOS6-Ygg-shDVT-1aKI");

  List<Map<String, dynamic>> _followers = [];
  List<int> _selectedUsers = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserPosts();
    _loadMotsCles();
    _setDefaultLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _loadFollowers();
    });
  }

  void _setDefaultLocation() {
    final location = widget.userData['utilisateur']?['adresse_utilisateur'];
    if (location != null) {
      final coords = GeoUtils.parsePoint(location);
      _latitudeController.text = coords['latitude'].toString();
      _longitudeController.text = coords['longitude'].toString();
      _selectedLocation = LatLng(coords['latitude'] ?? 0.0, coords['longitude'] ?? 0.0);
    } else {
      // Default to Algiers if no location
      _selectedLocation = const LatLng(36.7538, 3.0588);
      _latitudeController.text = '36.7538';
      _longitudeController.text = '3.0588';
    }
  }

  Future<void> _loadMotsCles() async {
    final motsCles = await _postService.getAvailableMotsCles();
    setState(() => _availableMotsCles = motsCles);
  }

  Future<void> _loadUserPosts() async {
    try {
      final response = await Supabase.instance.client
          .from('post')
          .select('''
            *, 
            mots_cles:post_mot_cle(mot_cle:mot_cle(nom)),
            utilisateurs_tagges:post_utilisateur_tag(utilisateur:utilisateur(id_acteur))
          ''')
          .eq('id_acteur', widget.idActeur)
          .order('date_limite', ascending: false);

      setState(() {
        _userPosts = List<Map<String, dynamic>>.from(response);
        _isLoadingPosts = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de chargement: $e')),
      );
    }
  }

Future<void> _pickImage() async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  
  if (pickedFile != null) {
    final fileExtension = pickedFile.path.split('.').last;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
    
    // Use the correct bucket name 'post'
    await Supabase.instance.client.storage
        .from('post')  
        .upload(fileName, File(pickedFile.path));

    setState(() {
      // Get URL from correct bucket
      _imageUrl = Supabase.instance.client.storage
          .from('post')  
          .getPublicUrl(fileName);
    });
  }
}

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) return;

    final newPost = await _postService.createPostDonateur(
      titre: _titreController.text,
      description: _descriptionController.text,
      idActeur: widget.idActeur,
      image: _imageUrl,
      dateLimite: _dateLimite,
      latitude: double.tryParse(_latitudeController.text),
      longitude: double.tryParse(_longitudeController.text),
      motsCles: _selectedMotsCles,
      utilisateursTagges: _selectedUsers,
    );

    if (newPost != null) {
      await _loadUserPosts();
      _resetForm();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Publication créée avec succès!')),
        );
        Navigator.pushNamed(context, RouteGeneratorDonateur.profile);
      }
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _titreController.clear();
    _descriptionController.clear();
    _selectedMotsCles.clear();
    _imageUrl = null;
    _dateLimite = null;
    _setDefaultLocation();
  }

  Widget _buildCreationSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _titreController,
              decoration: const InputDecoration(
                labelText: 'Titre de la publication',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Ce champ est obligatoire' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              validator: (value) => value?.isEmpty ?? true ? 'Ce champ est obligatoire' : null,
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickImage,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _imageUrl != null 
                    ? Image.network(_imageUrl!, fit: BoxFit.cover)
                    : const Center(child: Icon(Icons.add_a_photo, size: 40)),
              ),
            ),
            const SizedBox(height: 16),
            _buildUserTaggingSection(),
            const SizedBox(height: 16),
            _buildLocationSection(),
            const SizedBox(height: 16),
            _buildMotsClesSection(),
            const SizedBox(height: 16),
            _buildDateLimiteSection(),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.send),
              label: const Text('Publier'),
              style: ElevatedButton.styleFrom(
                backgroundColor: LightAppPallete.successBackground,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              onPressed: _submitPost,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePlaceSearch() async {
  try {
    // Get current location or use Algiers as default
    final LatLng centerLocation = _selectedLocation ?? const LatLng(36.7538, 3.0588);
    
    Prediction? p = await PlacesAutocomplete.show(
      context: context,
      apiKey: "AIzaSyDm7nwkWyl3djkqjOS6-Ygg-shDVT-1aKI",
      mode: Mode.overlay,
      language: "fr",
      location: Location(lat: centerLocation.latitude, lng: centerLocation.longitude),
      radius: 50000, // 50km radius around the location
      components: [Component(Component.country, "dz")], // Algeria country code
      region: "dz", // Algeria region code
    );

    if (p != null) {
      PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(p.placeId!);
      final lat = detail.result.geometry!.location.lat;
      final lng = detail.result.geometry!.location.lng;

      setState(() {
        _selectedLocation = LatLng(lat, lng);
        _latitudeController.text = lat.toString();
        _longitudeController.text = lng.toString();
      });

      final controller = await _mapController.future;
      controller.animateCamera(CameraUpdate.newLatLng(_selectedLocation!));
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erreur de recherche: $e')),
    );
  }
}
  Widget _buildLocationSection() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Localisation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              readOnly: true,
              onTap: _handlePlaceSearch,
              decoration: const InputDecoration(
                hintText: 'Rechercher un lieu...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            if (_selectedLocation != null)
              SizedBox(
                height: 200,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _selectedLocation!,
                    zoom: 14,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId('selected-location'),
                      position: _selectedLocation!,
                    )
                  },
                  onMapCreated: (controller) => _mapController.complete(controller),
                  zoomControlsEnabled: false,
                  myLocationEnabled: false,
                  onCameraMove: (position) {
                    setState(() {
                      _selectedLocation = position.target;
                      _latitudeController.text = position.target.latitude.toString();
                      _longitudeController.text = position.target.longitude.toString();
                    });
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMotsClesSection() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sélectionner au moins 1 mots clés', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _availableMotsCles.map((motCle) {
                final isSelected = _selectedMotsCles.contains(motCle['nom']);
                return FilterChip(
                  label: Text(motCle['nom']),
                  selected: isSelected,
                  onSelected: (selected) => setState(() {
                    if (selected) {
                      _selectedMotsCles.add(motCle['nom']);
                    } else {
                      _selectedMotsCles.remove(motCle['nom']);
                    }
                  }),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateLimiteSection() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Date limite', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(DateTime.now().year + 1),
                );
                if (selectedDate != null) {
                  setState(() => _dateLimite = selectedDate);
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(_dateLimite != null 
                    ? '${_dateLimite!.day}/${_dateLimite!.month}/${_dateLimite!.year}'
                    : 'Sélectionner une date'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsList() {
    if (_isLoadingPosts) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_userPosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.post_add, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Aucune publication trouvée',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Créez votre première publication dans l\'onglet "Créer"',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _userPosts.length,
      itemBuilder: (context, index) {
        final post = _userPosts[index];
        return Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: post['image'] != null 
                ? Image.network(post['image'], width: 60, height: 60, fit: BoxFit.cover)
                : const Icon(Icons.post_add),
            title: Text(post['titre']),
            subtitle: Text(post['description'].length > 50 
                ? '${post['description'].substring(0, 50)}...'
                : post['description']),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Modifier'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete),
                    title: Text('Supprimer'),
                  ),
                ),
              ],
              onSelected: (value) async {
                if (value == 'delete') {
                  await _postService.deletePost(post['id_post']);
                  await _loadUserPosts();
                } else if (value == 'edit') {
                  // Implement edit functionality
                }
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _loadFollowers() async {
  final followers = await _postService.getFollowers(widget.idActeur);
  setState(() => _followers = List<Map<String, dynamic>>.from(followers));
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion Publications'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Image.asset(
              'assets/images/images2/onboarding3.png',
              height: 100, 
            ),
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushNamed(context, RouteGeneratorDonateur.home),
        ),
        backgroundColor: LightAppPallete.successBackground,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.add) , text: 'Créer une publication',), 
            Tab(icon: Icon(Icons.list), text: 'Modifier une publication',)
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCreationSection(),
          _buildPostsList(),
        ],
      ),
    );
  }

  Widget _buildUserTaggingSection() {
  return Card(
    elevation: 3,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tagger des utilisateurs', 
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _followers.isEmpty 
            ? const Text('Aucun abonné à taguer')
            : Wrap(
                spacing: 8,
                children: _followers.map((user) {
                  final userId = user['id_acteur'] as int;
                  final isSelected = _selectedUsers.contains(userId);
                  return FilterChip(
                    label: Text(user['acteur']['email']),
                    avatar: CircleAvatar(
                      backgroundImage: NetworkImage(
                        user['acteur']['profile']?['photo_url'] ?? 
                        'https://example.com/default.jpg'),
                    ),
                    selected: isSelected,
                    onSelected: (selected) => setState(() {
                      if (selected) {
                        _selectedUsers.add(userId);
                      } else {
                        _selectedUsers.remove(userId);
                      }
                    }),
                  );
                }).toList(),
              ),
        ],
      ),
    ),
  );
} 
}