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
          onTap: _loadPharmacies,
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
  String? _errorMessage; // Pour stocker le message d'erreur

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
      _mapController.move(_currentLocation!, 15.0);
      await _fetchNearbyPharmacies();
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
      _errorMessage = null; // Réinitialiser le message d'erreur
    });
    try {
      final pharmacies = await _pharmacieService.getPharmaciesProches(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
        rayon: 3.0,
        limit: 10,
      );

      // Filtrer les pharmacies ouvertes selon l'heure actuelle
      final filteredPharmacies = _filterOpenPharmacies(pharmacies);

      setState(() {
        _nearbyPharmacies = filteredPharmacies;
        _route = [];
        _isLoading = false;
        if (filteredPharmacies.isEmpty) {
          _errorMessage = 'Aucune pharmacie ouverte à cette heure.';
        }
      });
      _fitMapToPharmacies();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _nearbyPharmacies = []; // Vider la liste des pharmacies
        _errorMessage = 'Erreur lors de la récupération des pharmacies : $e';
      });
    }
  }

  Future<void> _fetchGardePharmacies() async {
    if (_currentLocation == null) return;

    setState(() {
      _isLoading = true;
      _isGardeActive = true;
      _errorMessage = null; // Réinitialiser le message d'erreur
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
        if (_nearbyPharmacies.isEmpty) {
          _errorMessage = 'Aucune pharmacie de garde trouvée à proximité.';
        }
      });
      _fitMapToPharmacies();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _nearbyPharmacies = []; // Vider la liste des pharmacies
        _errorMessage = 'Erreur lors de la récupération des pharmacies de garde : $e';
      });
    }
  }

  List<Map<String, dynamic>> _filterOpenPharmacies(List<dynamic> pharmacies) {
    final now = DateTime.now();
    final currentHour = now.hour;
    final currentMinute = now.minute;
    final currentTimeInMinutes = currentHour * 60 + currentMinute;

    return pharmacies.where((pharmacy) {
      if (pharmacy['ouverture'] == null || pharmacy['fermeture'] == null) {
        return false; // Exclure les pharmacies sans horaires
      }

      final openTime = _parseTime(pharmacy['ouverture']);
      final closeTime = _parseTime(pharmacy['fermeture']);

      if (openTime == null || closeTime == null) return false;

      if (closeTime < openTime) {
        return currentTimeInMinutes >= openTime || currentTimeInMinutes <= closeTime;
      } else {
        return currentTimeInMinutes >= openTime && currentTimeInMinutes <= closeTime;
      }
    }).toList().cast<Map<String, dynamic>>();
  }

  int? _parseTime(String time) {
    try {
      final parts = time.replaceAll('h', ':').split(':');
      final hour = int.parse(parts[0]);
      final minute = parts.length > 1 ? int.parse(parts[1]) : 0;
      return hour * 60 + minute;
    } catch (e) {
      return null;
    }
  }

  Future<void> _fetchRoute(LatLng destination) async {
    if (_currentLocation == null) return;

    // Ajout de paramètres pour un itinéraire plus précis
    final url = Uri.parse(
        'http://router.project-osrm.org/route/v1/driving/'
        '${_currentLocation!.longitude},${_currentLocation!.latitude};'
        '${destination.longitude},${destination.latitude}'
        '?overview=full&geometries=polyline&steps=true&annotations=true');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0]['geometry'];
          final newRoute = _decodePolyline(route);

          // Vérification de la validité des points
          if (newRoute.length < 2) {
            _showError('Itinéraire invalide : pas assez de points.');
            return;
          }

          // Vérification des distances entre points pour éviter les sauts
          for (int i = 0; i < newRoute.length - 1; i++) {
            final distance = Geolocator.distanceBetween(
              newRoute[i].latitude,
              newRoute[i].longitude,
              newRoute[i + 1].latitude,
              newRoute[i + 1].longitude,
            );
            if (distance > 1000) { // Si la distance entre deux points est > 1km, suspect
              _showError('Itinéraire invalide : points trop éloignés.');
              return;
            }
          }

          setState(() {
            _route = newRoute;
          });
          _fitRouteBounds();
        } else {
          _showError('Aucun itinéraire trouvé.');
        }
      } else {
        _showError('Échec de la récupération de l\'itinéraire : ${response.statusCode}');
      }
    } catch (e) {
      _showError('Erreur réseau lors de la récupération de l\'itinéraire : $e');
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
    if (_currentLocation == null) return;

    if (_nearbyPharmacies.isEmpty) {
      // Si aucune pharmacie, centrer sur la position actuelle
      _mapController.move(_currentLocation!, 15.0);
      return;
    }

    double minLat = _currentLocation!.latitude;
    double maxLat = _currentLocation!.latitude;
    double minLon = _currentLocation!.longitude;
    double maxLon = _currentLocation!.longitude;

    for (var pharmacy in _nearbyPharmacies) {
      double lat = double.parse(pharmacy['latitude'].toString());
      double lon = double.parse(pharmacy['longitude'].toString());
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
    if (_route.isEmpty || _currentLocation == null) return;

    double minLat = _currentLocation!.latitude;
    double maxLat = _currentLocation!.latitude;
    double minLon = _currentLocation!.longitude;
    double maxLon = _currentLocation!.longitude;

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
        padding: const EdgeInsets.all(30), // Réduction du padding pour un zoom plus serré
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
          child: Stack(
            children: [
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _currentLocation == null
                      ? const Center(child: Text('Localisation non disponible'))
                      : FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: _currentLocation!,
                            initialZoom: 15.0,
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
                                      double.parse(pharmacy['latitude'].toString()),
                                      double.parse(pharmacy['longitude'].toString()),
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
                                                    double.parse(pharmacy['latitude'].toString()),
                                                    double.parse(pharmacy['longitude'].toString()),
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
              if (_errorMessage != null)
                Positioned(
                  top: 10,
                  left: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.black.withOpacity(0.7),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}