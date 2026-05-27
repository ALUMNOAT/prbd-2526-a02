import 'package:prbd_2526_a02/models/security.dart';

class Reservation {
  static String? validateDemande(String? demande) {
    if (demande!.trim().length < 10) {
      return 'Les demandes spéciales doivent contenir au moins 10 caractères';
    }
    return null;
  }
}