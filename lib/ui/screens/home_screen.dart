import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'chat_screen.dart';
import 'commande_screen.dart';
import 'profile_screen.dart';
import 'package:miabe_pharmacie/services/pharmacie_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:miabe_pharmacie/ui/widgets/pharmacy_details_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class ResponsiveLayout {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  static double getScreenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double getScreenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _screens = <Widget>[
    HomeScreenContent(),
    ChatScreen(),
    CommandeScreen(),
    ProfileScreen(),
  ];

  void _loadPharmacies() {
    if (_selectedIndex == 0) {
      final homeScreenContentState =
          context.findAncestorStateOfType<_HomeScreenContentState>();
      homeScreenContentState?._fetchNearbyPharmacies();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = ResponsiveLayout.getScreenWidth(context);
    final screenHeight = ResponsiveLayout.getScreenHeight(context);
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final isTablet = ResponsiveLayout.isTablet(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          width: screenWidth,
          height: screenHeight,
          color: Colors.white,
          child: Row(
            children: [
              if (isDesktop)
                Container(
                  width: 250,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDesktopNavItem(0, 'Pharmacies', Icons.local_pharmacy),
                      _buildDesktopNavItem(1, 'Assistant', Icons.support_agent),
                      _buildDesktopNavItem(2, 'Commandes', Icons.local_hospital),
                      _buildDesktopNavItem(3, 'Profil', Icons.person),
                    ],
                  ),
                ),
              Expanded(
                child: _screens[_selectedIndex],
              ),
            ],
          ),
        ),
      ),
      extendBody: true,
      extendBodyBehindAppBar: true,
      bottomNavigationBar: !isDesktop ? Container(
        height: isTablet ? 75 : 65,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + (isTablet ? 16.0 : 8.0),
          left: isTablet ? 32.0 : 16.0,
          right: isTablet ? 32.0 : 16.0,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(0, 'Pharmacies', Icons.local_pharmacy),
            _buildNavItem(1, 'Assistant', Icons.support_agent),
            _buildNavItem(2, 'Commandes', Icons.local_hospital),
            _buildNavItem(3, 'Profil', Icons.person),
          ],
        ),
      ) : null,
    );
  }

  Widget _buildDesktopNavItem(int index, String label, IconData icon) {
    final isSelected = _selectedIndex == index;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Material(
        color: isSelected ? const Color(0xFF6AAB64).withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => setState(() => _selectedIndex = index),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected ? const Color(0xFF6AAB64) : Colors.grey,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? const Color(0xFF6AAB64) : Colors.grey,
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String label, IconData icon) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _selectedIndex = index),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.green.shade400 : Colors.grey,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.green.shade400 : Colors.grey,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ],
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

class _HomeScreenContentState extends State<HomeScreenContent> with WidgetsBindingObserver {
  final PharmacieService _pharmacieService = PharmacieService();
  late MapController _mapController;
  LatLng? _currentLocation;
  List<Map<String, dynamic>> _nearbyPharmacies = [];
  List<LatLng> _route = [];
  bool _isLoading = true;
  bool _isGardeActive = false;
  String? _errorMessage;
  bool _isMapInitialized = false;
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _mapController = MapController();
    _startInitialization();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startInitialization();
    }
  }

  Future<void> _startInitialization() async {
    if (!_isFirstLoad) return;
    try {
      await _initializeLocation();
    } catch (e) {
      if (!mounted) return;
      _showError('Erreur lors de l\'initialisation : $e');
    }
  }

  Future<void> _initializeLocation() async {
    if (!mounted || !_isFirstLoad) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          throw Exception('Permission de localisation refusée');
        }
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Service de localisation désactivé');
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );

      if (!mounted) return;

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _isLoading = false;
        _isFirstLoad = false;
      });

    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur de localisation : $e';
        _isFirstLoad = false;
      });
      _showError(_errorMessage!);
    }
  }

  void _onMapCreated(MapController controller) {
    if (_isMapInitialized) return;
    
    _isMapInitialized = true;
    if (_currentLocation != null) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          controller.move(_currentLocation!, 15.0);
          _fetchNearbyPharmacies();
        }
      });
    }
  }

  Future<void> _fetchNearbyPharmacies() async {
    if (_currentLocation == null || !mounted) {
      _showError('Position non disponible. Veuillez réessayer.');
      setState(() => _isLoading = false);
      return;
    }

    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _isGardeActive = false;
      _errorMessage = null;
      _route = [];
    });

    try {
      print('Récupération des pharmacies proches...');
      print('Position: ${_currentLocation!.latitude}, ${_currentLocation!.longitude}');

      final pharmacies = await _pharmacieService.getPharmaciesProches(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
        rayon: 3.0,
        limit: 10,
      );

      if (!mounted) return;

      print('Nombre de pharmacies reçues: ${pharmacies.length}');

      final filteredPharmacies = _filterOpenPharmacies(pharmacies);
      print('Nombre de pharmacies ouvertes: ${filteredPharmacies.length}');

      setState(() {
        _nearbyPharmacies = filteredPharmacies;
        _isLoading = false;
        if (filteredPharmacies.isEmpty) {
          _errorMessage = 'Aucune pharmacie ouverte trouvée dans votre zone.';
        }
      });

      if (filteredPharmacies.isNotEmpty && _isMapInitialized) {
        _fitMapToPharmacies();
      }

    } catch (e) {
      print('Erreur lors de la récupération des pharmacies: $e');
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
        _nearbyPharmacies = [];
        _errorMessage = 'Erreur lors de la recherche des pharmacies : $e';
      });

      _showError(_errorMessage!);
    }
  }

  Future<void> _fetchGardePharmacies() async {
    if (_currentLocation == null) return;

    setState(() {
      _isLoading = true;
      _isGardeActive = true;
      _errorMessage = null;
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
        _nearbyPharmacies = [];
        _errorMessage =
            'Erreur lors de la récupération des pharmacies de garde : $e';
      });
    }
  }

  List<Map<String, dynamic>> _filterOpenPharmacies(List<dynamic> pharmacies) {
    final now = DateTime.now();
    final currentHour = now.hour;
    final currentMinute = now.minute;
    final currentTimeInMinutes = currentHour * 60 + currentMinute;

    return pharmacies
        .where((pharmacy) {
          if (pharmacy['ouverture'] == null || pharmacy['fermeture'] == null) {
            return false;
          }

          final openTime = _parseTime(pharmacy['ouverture']);
          final closeTime = _parseTime(pharmacy['fermeture']);

          if (openTime == null || closeTime == null) return false;

          if (closeTime < openTime) {
            return currentTimeInMinutes >= openTime ||
                currentTimeInMinutes <= closeTime;
          } else {
            return currentTimeInMinutes >= openTime &&
                currentTimeInMinutes <= closeTime;
          }
        })
        .toList()
        .cast<Map<String, dynamic>>();
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

    final url = Uri.parse('http://router.project-osrm.org/route/v1/driving/'
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

          if (newRoute.length < 2) {
            _showError('Itinéraire invalide : pas assez de points.');
            return;
          }

          for (int i = 0; i < newRoute.length - 1; i++) {
            final distance = Geolocator.distanceBetween(
              newRoute[i].latitude,
              newRoute[i].longitude,
              newRoute[i + 1].latitude,
              newRoute[i + 1].longitude,
            );
            if (distance > 1000) {
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
        _showError(
            'Échec de la récupération de l\'itinéraire : ${response.statusCode}');
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
        padding: const EdgeInsets.all(
            30),
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
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final isTablet = ResponsiveLayout.isTablet(context);
    final padding = MediaQuery.of(context).padding;
    
    return Container(
      color: Colors.white,
      child: Column(
        children: [
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
                              initialZoom: isDesktop ? 13.0 : 15.0,
                              onMapReady: () {
                                _onMapCreated(_mapController);
                              },
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                subdomains: const ['a', 'b', 'c'],
                              ),
                              MarkerLayer(
                                markers: _buildMarkers(context),
                              ),
                              PolylineLayer(
                                polylines: [
                                  if (_route.isNotEmpty)
                                    Polyline(
                                      points: _route,
                                      strokeWidth: isDesktop ? 6.0 : 4.0,
                                      color: Colors.red,
                                    ),
                                ],
                              ),
                            ],
                          ),
                if (_errorMessage != null)
                  Positioned(
                    top: isDesktop ? 120 : (90 + padding.top),
                    left: isDesktop ? 270 : 10,
                    right: 10,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: isDesktop ? 16 : 12,
                        horizontal: isDesktop ? 24 : 16
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isDesktop ? 18 : 16,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                Positioned(
                  top: isDesktop ? 40 : (20 + padding.top),
                  left: isDesktop ? 270 : 20,
                  right: 20,
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildFilterButton(
                          'Pharmacies Ouvertes',
                          _fetchNearbyPharmacies,
                          !_isGardeActive,
                          isDesktop,
                        ),
                      ),
                      SizedBox(width: isDesktop ? 16 : 10),
                      Expanded(
                        child: _buildFilterButton(
                          'Pharmacies de Garde',
                          _fetchGardePharmacies,
                          _isGardeActive,
                          isDesktop,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Marker> _buildMarkers(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final markers = <Marker>[];

    // Marqueur de position actuelle
    if (_currentLocation != null) {
      markers.add(
        Marker(
          width: isDesktop ? 100.0 : 80.0,
          height: isDesktop ? 100.0 : 80.0,
          point: _currentLocation!,
          child: Icon(
            Icons.location_on,
            color: Colors.blue,
            size: isDesktop ? 50.0 : 40.0,
          ),
        ),
      );
    }

    // Marqueurs des pharmacies
    markers.addAll(_nearbyPharmacies.map(
      (pharmacy) => Marker(
        width: isDesktop ? 100.0 : 80.0,
        height: isDesktop ? 100.0 : 80.0,
        point: LatLng(
          double.parse(pharmacy['latitude'].toString()),
          double.parse(pharmacy['longitude'].toString()),
        ),
        child: GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => PharmacyDetailsSheet(
                pharmacy: pharmacy,
                onGetDirections: (destination) async {
                  Navigator.of(context).pop();
                  await _fetchRoute(destination);
                },
              ),
            );
          },
          child: Icon(
            Icons.local_pharmacy,
            color: Colors.green,
            size: isDesktop ? 50.0 : 40.0,
          ),
        ),
      ),
    ));

    return markers;
  }

  Widget _buildFilterButton(String text, VoidCallback onPressed, bool isActive, bool isDesktop) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive
            ? const Color(0xFF6AAB64).withOpacity(0.9)
            : Colors.white.withOpacity(0.8),
        elevation: 0,
        padding: EdgeInsets.symmetric(
          vertical: isDesktop ? 16 : 12,
          horizontal: isDesktop ? 24 : 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isDesktop ? 16 : 30),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.grey.shade700,
          fontWeight: FontWeight.w600,
          fontSize: isDesktop ? 16 : 14,
        ),
      ),
    );
  }
}
