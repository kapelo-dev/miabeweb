import 'package:flutter/material.dart';
import 'package:miabe_pharmacie/services/pharmacie_service.dart';
import 'package:geolocator/geolocator.dart';

class PharmacySelector extends StatefulWidget {
  final Function(Map<String, dynamic>) onPharmacySelected;

  const PharmacySelector({
    Key? key,
    required this.onPharmacySelected,
  }) : super(key: key);

  @override
  State<PharmacySelector> createState() => _PharmacySelectorState();
}

class _PharmacySelectorState extends State<PharmacySelector> {
  final PharmacieService _pharmacieService = PharmacieService();
  List<Map<String, dynamic>> _pharmacies = [];
  bool _isLoading = false;
  bool _isGardeMode = false;
  String? _searchQuery;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showError('Les services de localisation sont désactivés');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showError('Permission de localisation refusée');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showError('Les permissions de localisation sont définitivement refusées');
        return;
      }

      _currentPosition = await Geolocator.getCurrentPosition();
      _loadPharmacies();
    } catch (e) {
      _showError('Erreur lors de la récupération de la position');
    }
  }

  Future<void> _loadPharmacies() async {
    if (_currentPosition == null) {
      _showError('Position non disponible');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final pharmacies = _isGardeMode
          ? await _pharmacieService.getPharmaciesGardeProches(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
              rayon: 5.0)
          : await _pharmacieService.getPharmaciesProches(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
              rayon: 5.0);

      setState(() {
        _pharmacies = List<Map<String, dynamic>>.from(pharmacies);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _pharmacies = [];
        _isLoading = false;
      });
      _showError('Erreur lors du chargement des pharmacies');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  List<Map<String, dynamic>> _getFilteredPharmacies() {
    if (_searchQuery == null || _searchQuery!.isEmpty) {
      return _pharmacies;
    }
    return _pharmacies.where((pharmacy) {
      final name = pharmacy['nom'].toString().toLowerCase();
      final location = pharmacy['emplacement'].toString().toLowerCase();
      final query = _searchQuery!.toLowerCase();
      return name.contains(query) || location.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Barre de recherche
          TextField(
            decoration: InputDecoration(
              hintText: 'Rechercher une pharmacie...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
            onChanged: (value) {
              setState(() => _searchQuery = value);
            },
          ),
          const SizedBox(height: 16),

          // Boutons de mode
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() => _isGardeMode = false);
                    _loadPharmacies();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !_isGardeMode
                        ? const Color(0xFF6AAB64)
                        : Colors.grey.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Pharmacies Proches',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() => _isGardeMode = true);
                    _loadPharmacies();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isGardeMode
                        ? const Color(0xFF6AAB64)
                        : Colors.grey.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Pharmacies de Garde',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Liste des pharmacies
          if (_isLoading)
            const CircularProgressIndicator()
          else if (_pharmacies.isEmpty)
            const Text('Aucune pharmacie trouvée')
          else
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.3,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _getFilteredPharmacies().length,
                itemBuilder: (context, index) {
                  final pharmacy = _getFilteredPharmacies()[index];
                  return ListTile(
                    title: Text(pharmacy['nom']),
                    subtitle: Text(pharmacy['emplacement']),
                    trailing: Text(
                      pharmacy['distance'] != null
                          ? '${pharmacy['distance'].toStringAsFixed(1)} km'
                          : '',
                    ),
                    onTap: () {
                      final pharmacyWithId = {
                        ...pharmacy,
                        'id': pharmacy['_id'] ?? pharmacy['id'] ?? '',
                      };
                      widget.onPharmacySelected(pharmacyWithId);
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
} 