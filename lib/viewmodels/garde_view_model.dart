import '../services/location_service.dart';
import '../repositories/gardes_repositorie.dart';
import '../models/gardes.dart';
import 'package:geolocator/geolocator.dart';

class GardeViewModel {
  final GardeRepository repository;
  final LocationService locationService;

  GardeViewModel(this.repository, this.locationService);

  Future<List<Garde>> getGardes() async {
    // Obtenez la position actuelle
    Position position = await locationService.getCurrentLocation();
    double latitude = position.latitude;
    double longitude = position.longitude;

    // Utilisez les coordonnées pour appeler l'API
    return await repository.fetchGardes(latitude, longitude);
  }
}
