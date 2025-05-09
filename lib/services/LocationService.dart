import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
//import 'package:myapp/main.dart';
import 'package:myapp/routes/routes.dart';
import 'package:http/http.dart' as http;

class LocationSelectionPage extends StatefulWidget {
  final int idActeur;
  final String userType;

  const LocationSelectionPage({
    super.key,
    required this.idActeur,
    required this.userType,
  });

  @override
  State<LocationSelectionPage> createState() => _LocationSelectionPageState();
}

class _LocationSelectionPageState extends State<LocationSelectionPage> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  LatLng? _selectedLocation;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isLocationServiceEnabled = false;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _placeSuggestions = [];
  final String _googleApiKey = 'AIzaSyDm7nwkWyl3djkqjOS6-Ygg-shDVT-1aKI'; 

  static const CameraPosition _kInitialPosition = CameraPosition(
    target: LatLng(36.737232, 3.086964), // Default to Algiers
    zoom: 12,
  );

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndGetLocation();
  }

  Future<void> _checkPermissionsAndGetLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage = 'Les services de localisation sont désactivés. Veuillez les activer.';
          _isLocationServiceEnabled = false;
        });
        return;
      }

      setState(() {
        _isLocationServiceEnabled = true;
      });

      PermissionStatus permission = await Permission.location.request();
      if (permission.isDenied) {
        setState(() {
          _errorMessage = 'Permission de localisation refusée. Vous pouvez sélectionner votre position manuellement.';
        });
        return;
      }

      if (permission.isPermanentlyDenied) {
        setState(() {
          _errorMessage = 'Permission de localisation refusée de manière permanente. Veuillez l\'activer dans les paramètres.';
        });
        await openAppSettings();
        return;
      }

      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );

      Position position = await Geolocator.getCurrentPosition(locationSettings: locationSettings);
      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
      });

      if (_controller.isCompleted) {
        final GoogleMapController controller = await _controller.future;
        controller.animateCamera(CameraUpdate.newLatLngZoom(_selectedLocation!, 15));
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la récupération de la localisation : $e';
      });
    }
  }

  Future<void> _fetchPlaceSuggestions(String input) async {
    if (input.isEmpty || !_controller.isCompleted) {
      setState(() {
        _placeSuggestions = [];
      });
      return;
    }

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$_googleApiKey&language=fr',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _placeSuggestions = data['predictions'] ?? [];
        });
      } else {
        setState(() {
          _errorMessage = 'Erreur lors de la recherche de lieux.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la recherche : $e';
      });
    }
  }

  Future<void> _getPlaceDetails(String placeId) async {
    if (!_controller.isCompleted) return;

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$_googleApiKey&language=fr',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final location = data['result']['geometry']['location'];
        final lat = location['lat'];
        final lng = location['lng'];
        final formattedAddress = data['result']['formatted_address'];

        setState(() {
          _selectedLocation = LatLng(lat, lng);
          _placeSuggestions = [];
          _searchController.text = formattedAddress;
        });

        final GoogleMapController controller = await _controller.future;
        controller.animateCamera(CameraUpdate.newLatLngZoom(_selectedLocation!, 15));
      } else {
        setState(() {
          _errorMessage = 'Erreur lors de la récupération des détails du lieu.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la récupération des détails : $e';
      });
    }
  }

  Future<void> _saveLocation() async {
    if (_selectedLocation == null || !_controller.isCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une position sur la carte.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.from('utilisateur').update({
        'location': 'POINT(${_selectedLocation!.longitude} ${_selectedLocation!.latitude})',
      }).eq('id_acteur', widget.idActeur);

      if (response.error != null) {
        throw Exception('Erreur Supabase : ${response.error!.message}');
      }

      if (mounted) {
        _navigateToDashboard();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'enregistrement de la localisation : $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToDashboard() {
    try {
      switch (widget.userType.toLowerCase()) {
        case 'donateur':
          Navigator.pushReplacementNamed(context, RouteGenerator.donateurHome);
          break;
        case 'association':
          Navigator.pushReplacementNamed(context, RouteGenerator.associationHome);
          break;
        case 'bénéficiaire':
          Navigator.pushReplacementNamed(context, RouteGenerator.beneficiaireHome);
          break;
        default:
          Navigator.pushReplacementNamed(context, RouteGenerator.login);
      }
    } catch (e) {
      Navigator.pushReplacementNamed(context, RouteGenerator.login);
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    if (_selectedLocation != null) {
      controller.animateCamera(CameraUpdate.newLatLngZoom(_selectedLocation!, 15));
    }
  }

  void _onTap(LatLng position) {
    setState(() {
      _selectedLocation = position;
    });
    _reverseGeocode(position);
  }

  Future<void> _reverseGeocode(LatLng position) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$_googleApiKey&language=fr',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          final address = data['results'][0]['formatted_address'];
          if (mounted) {
            setState(() {
              _searchController.text = address;
            });
          }
        }
      }
    } catch (e) {
      print('Erreur de géocodage inversé : $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    if (_controller.isCompleted) {
      _controller.future.then((controller) => controller.dispose());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sélectionnez votre localisation'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          if (_controller.isCompleted)
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: _kInitialPosition,
              onTap: _onTap,
              markers: _selectedLocation != null
                  ? {
                      Marker(
                        markerId: const MarkerId('selected-location'),
                        position: _selectedLocation!,
                        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                      ),
                    }
                  : {},
              myLocationEnabled: _isLocationServiceEnabled,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: true,
              compassEnabled: true,
              mapToolbarEnabled: false,
              mapType: MapType.normal,
            ),
          if (!_isLocationServiceEnabled && _errorMessage != null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_off, size: 80, color: Colors.red),
                  const SizedBox(height: 20),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _checkPermissionsAndGetLocation,
                    child: const Text('Activer la localisation'),
                  ),
                ],
              ),
            ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Rechercher une adresse',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _placeSuggestions = [];
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onChanged: _fetchPlaceSuggestions,
              ),
            ),
          ),
          if (_placeSuggestions.isNotEmpty)
            Positioned(
              top: 72,
              left: 16,
              right: 16,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _placeSuggestions.length,
                    itemBuilder: (context, index) {
                      final suggestion = _placeSuggestions[index];
                      return ListTile(
                        title: Text(suggestion['description']),
                        onTap: () {
                          _getPlaceDetails(suggestion['place_id']);
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          if (_errorMessage != null && _isLocationServiceEnabled)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                color: Colors.red[400],
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_errorMessage!, style: const TextStyle(color: Colors.white))),
                    ],
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_selectedLocation != null)
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Icon(Icons.pin_drop, color: Colors.green),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _searchController.text.isNotEmpty
                                  ? _searchController.text
                                  : 'Position: ${_selectedLocation!.latitude.toStringAsFixed(5)}, ${_selectedLocation!.longitude.toStringAsFixed(5)}',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _isLoading || !_controller.isCompleted ? null : _saveLocation,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Confirmer la localisation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _navigateToDashboard,
                  child: const Text('Passer cette étape'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.green[600],
                    side: BorderSide(color: Colors.green[600]!),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}