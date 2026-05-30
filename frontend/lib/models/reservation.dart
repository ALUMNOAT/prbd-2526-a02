import 'package:prbd_2526_a02/models/security.dart';

class Reservation {
  static String? validateDemande(String? demande) {
    // 1. Si demande est null ou vide (trim permet d'ignorer les espaces)
    if (demande == null || demande.trim().isEmpty) {
      return null; // Tout va bien, c'est optionnel
    }

    // 2. Si le texte existe mais est trop court
    if (demande.trim().length < 10) {
      return 'Si vous précisez une demande, elle doit contenir au moins 10 caractères';
    }

    // 3. Sinon, c'est valide
    return null;
  }
}