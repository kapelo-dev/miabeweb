import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'chat_screen.dart';
import 'commande_screen.dart';
import 'history_screen.dart';
import 'package:miabe_pharmacie/services/pharmacie_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _screens = <Widget>[
    HomeScreenContent(),
    ChatScreen(),
    CommandeScreen(),
    HistoryScreen(),
  ];

  void _loadPharmacies() {
    // Appeler la méthode dans HomeScreenContent pour charger les pharmacies
    if (_selectedIndex == 0) {
      final homeScreenContentState = context.findAncestorStateOfType<_HomeScreenContentState>();
      homeScreenContentState?._fetchNearbyPharmacies();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF6AAB64),
        title: GestureDetector(
          onTap: _loadPharmacies, // Charger les pharmacies au clic sur "Home"
          child: const Text(
            'Miabé pharmacie',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        elevation: 0,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF6AAB64),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: Colors.black.withOpacity(0.2),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              backgroundColor: const Color(0xFF6AAB64),
              color: Colors.white,
              activeColor: Colors.white,
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              gap: 8,
              tabs: const [
                GButton(icon: Icons.home, text: 'Home'),
                GButton(icon: Icons.headset_mic, text: 'Assistant'),
                GButton(icon: Icons.shopping_cart, text: 'Commande'),
                GButton(icon: Icons.person, text: 'Profil'),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreenContent extends StatefulWidget {
  @override
  _HomeScreenContentState createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  final PharmacieService _pharmacieService = PharmacieService();
  late MapController _mapController;
  LatLng? _currentLocation;
  List<Map<String, dynamic>> _nearbyPharmacies = [];
  List<LatLng> _route = [];
  bool _isLoading = true;
  bool _isGardeActive = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
          _showError('Permission de localisation refusée.');
          setState(() => _isLoading = false);
          return;
        }
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showError('Veuillez activer le service de localisation.');
        setState(() => _isLoading = false);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
      _mapController.move(_currentLocation!, 13.0);
      await _fetchNearbyPharmacies(); // Charger les pharmacies immédiatement
    } catch (e) {
      _showError('Erreur lors de la récupération de la localisation : $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchNearbyPharmacies() async {
    if (_currentLocation == null) return;

    setState(() {
      _isLoading = true;
      _isGardeActive = false;
    });
    try {
      final pharmacies = await _pharmacieService.getPharmaciesProches(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
        rayon: 3.0,
        limit: 10,
      );
      setState(() {
        _nearbyPharmacies = List<Map<String, dynamic>>.from(pharmacies);
        _route = [];
        _isLoading = false;
      });
      _fitMapToPharmacies();
    } catch (e) {
      _showError('Erreur lors de la récupération des pharmacies : $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchGardePharmacies() async {
    if (_currentLocation == null) return;

    setState(() {
      _isLoading = true;
      _isGardeActive = true;
    });
    try {
      final pharmacies = await _pharmacieService.getPharmaciesGardeProches(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
        rayon: 3.0,
        limit: 10,
      );
      setState(() {
        _nearbyPharmacies = List<Map<String, dynamic>>.from(pharmacies);
        _route = [];
        _isLoading = false;
      });
      _fitMapToPharmacies();
    } catch (e) {
      _showError('Erreur lors de la récupération des pharmacies de garde : $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchRoute(LatLng destination) async {
    if (_currentLocation == null) return;

    final url = Uri.parse(
        'http://router.project-osrm.org/route/v1/driving/'
        '${_currentLocation!.longitude},${_currentLocation!.latitude};'
        '${destination.longitude},${destination.latitude}?overview=full&geometries=polyline');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0]['geometry'];
          setState(() {
            _route = _decodePolyline(route);
          });
          _fitRouteBounds();
        } else {
          _showError('Aucun itinéraire trouvé.');
        }
      } else {
        _showError('Échec de la récupération de l\'itinéraire.');
      }
    } catch (e) {
      _showError('Erreur réseau : $e');
    }
  }

  List<LatLng> _decodePolyline(String polyline) {
    const factor = 1e5;
    List<LatLng> points = [];
    int index = 0, len = polyline.length;
    int lat = 0, lon = 0;

    while (index < len) {
      int shift = 0, result = 0;
      int byte;
      do {
        byte = polyline.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        byte = polyline.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);
      int dlon = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lon += dlon;

      points.add(LatLng(lat / factor, lon / factor));
    }
    return points;
  }

  void _fitMapToPharmacies() {
    if (_nearbyPharmacies.isEmpty || _currentLocation == null) return;

    double minLat = _currentLocation!.latitude;
    double maxLat = _currentLocation!.latitude;
    double minLon = _currentLocation!.longitude;
    double maxLon = _currentLocation!.longitude;

    for (var pharmacy in _nearbyPharmacies) {
      double lat = pharmacy['latitude'].toDouble();
      double lon = pharmacy['longitude'].toDouble();
      if (lat < minLat) minLat = lat;
      if (lat > maxLat) maxLat = lat;
      if (lon < minLon) minLon = lon;
      if (lon > maxLon) maxLon = lon;
    }

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds(
          LatLng(minLat, minLon),
          LatLng(maxLat, maxLon),
        ),
        padding: const EdgeInsets.all(50),
      ),
    );
  }

  void _fitRouteBounds() {
    if (_route.isEmpty) return;

    double minLat = _route[0].latitude;
    double maxLat = _route[0].latitude;
    double minLon = _route[0].longitude;
    double maxLon = _route[0].longitude;

    for (var point in _route) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLon) minLon = point.longitude;
      if (point.longitude > maxLon) maxLon = point.longitude;
    }

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds(
          LatLng(minLat, minLon),
          LatLng(maxLat, maxLon),
        ),
        padding: const EdgeInsets.all(50),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Produit Spécifique',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              suffixIcon: const Icon(Icons.search, color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey.shade200,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _fetchNearbyPharmacies,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isGardeActive ? Colors.grey.shade400 : const Color(0xFF6AAB64),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Pharmacie Ouverte',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: _fetchGardePharmacies,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isGardeActive ? const Color(0xFF6AAB64) : Colors.grey.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Pharmacie de Garde',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _currentLocation == null
                  ? const Center(child: Text('Localisation non disponible'))
                  : FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _currentLocation!,
                        initialZoom: 13.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                          subdomains: const ['a', 'b', 'c'],
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              width: 80.0,
                              height: 80.0,
                              point: _currentLocation!,
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.blue,
                                size: 40.0,
                              ),
                            ),
                            ..._nearbyPharmacies.map(
                              (pharmacy) => Marker(
                                width: 80.0,
                                height: 80.0,
                                point: LatLng(
                                  pharmacy['latitude'].toDouble(),
                                  pharmacy['longitude'].toDouble(),
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text(pharmacy['nom']),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Emplacement: ${pharmacy['emplacement']}'),
                                            Text('Téléphone: ${pharmacy['telephone1']}'),
                                            Text('Distance: ${pharmacy['distance'].toStringAsFixed(2)} km'),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () async {
                                              Navigator.of(context).pop();
                                              await _fetchRoute(LatLng(
                                                pharmacy['latitude'].toDouble(),
                                                pharmacy['longitude'].toDouble(),
                                              ));
                                            },
                                            child: const Text('Itinéraire'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(),
                                            child: const Text('Fermer'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  child: const Icon(
                                    Icons.local_pharmacy,
                                    color: Colors.green,
                                    size: 40.0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        PolylineLayer(
                          polylines: [
                            if (_route.isNotEmpty)
                              Polyline(
                                points: _route,
                                strokeWidth: 4.0,
                                color: Colors.red,
                              ),
                          ],
                        ),
                      ],
                    ),
        ),
      ],
    );
  }
}