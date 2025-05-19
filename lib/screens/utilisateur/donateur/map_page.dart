import 'package:flutter/material.dart';
import 'package:myapp/routes/routes_donateur.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:myapp/theme/app_pallete.dart';

class MapPageDonateur extends StatefulWidget {
  const MapPageDonateur({Key? key}) : super(key: key);

  @override
  _MapPageDonateurState createState() => _MapPageDonateurState();
}

class _MapPageDonateurState extends State<MapPageDonateur> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proches de chez vous'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Image.asset(
              'assets/images/images2/Charity.png',
              height: 80,
            ),
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamed(context, RouteGeneratorDonateur.home);
          },
        ),
        backgroundColor: const Color.fromARGB(255, 245, 172, 197),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Effectuer une recherche...',
                prefixIcon: Icon(Icons.search, color: LightAppPallete.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
                fillColor: Color.fromARGB(255, 245, 172, 197),
              ),
            ),
            const SizedBox(height: 16),
            // Title for first map card
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                "Utilisateurs proches",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            Card(
              elevation: 4,
              child: SizedBox(
                height: 200,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(36.7538, 3.0588), // Algiers
                    zoom: 12,
                  ),
                  myLocationEnabled: false,
                  zoomControlsEnabled: false,
                  onMapCreated: (controller) {},
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Title for second map card
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                "Demande de besoin et campagnes proches",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            Card(
              elevation: 4,
              child: SizedBox(
                height: 260,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(36.7538, 3.0588), // Algiers
                    zoom: 12,
                  ),
                  myLocationEnabled: false,
                  zoomControlsEnabled: false,
                  onMapCreated: (controller) {},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}