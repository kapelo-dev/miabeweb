import '../repositories/pharmacies_repositorie.dart';
import '../services/location_service.dart';
import '../models/pharmacies.dart';
import 'package:geolocator/geolocator.dart';

class PharmacieViewModel {
  final PharmacieRepository repository;
  final LocationService locationService;

  PharmacieViewModel(this.repository, this.locationService);

  Future<List<Pharmacie>> getPharmaciesProches() async {
    Position position = await locationService.getCurrentLocation();
    return await repository.fetchPharmaciesProches(position.latitude, position.longitude);
  }

  Future<List<Pharmacie>> getPharmaciesAvecProduits(List<String> produits) async {
    Position position = await locationService.getCurrentLocation();
    return await repository.fetchPharmaciesAvecProduits(position.latitude, position.longitude, produits);
  }

  Future<List<Pharmacie>> getPharmaciesGardeAvecProduits(List<String> produits) async {
    Position position = await locationService.getCurrentLocation();
    return await repository.fetchPharmaciesGardeAvecProduits(position.latitude, position.longitude, produits);
  }
}
