import 'dart:convert';
import 'package:intl/intl.dart';
import '../core/services/api_client.dart';

class Luca_Reservation {
  final int id;
  final int client;
  final int restaurant;
  final DateTime datetime;
  final int numberOfGuests;
  final String status;
  final String? specialRequests;

  Luca_Reservation({
    required this.id,
    required this.client,
    required this.restaurant,
    required this.datetime,
    required this.numberOfGuests,
    required this.status,
    this.specialRequests,
  });

  factory Luca_Reservation.fromJson(Map<String, dynamic> json) {
    if (json['client'] == null) {
      print("ALERTE : Clé 'client' manquante ou nulle dans : $json");
    }
    return Luca_Reservation(
      id: (json['id'] as num?)?.toInt() ?? 0,
      client: (json['client'] as num?)?.toInt() ?? 0,
      restaurant: (json['restaurant'] as num?)?.toInt() ?? 0,
      datetime: (json['datetime'] != null)
          ? DateTime.tryParse(json['datetime'].toString()) ?? DateTime.now()
          : DateTime.now(),
      numberOfGuests: (json['number_of_guests'] as num?)?.toInt() ?? 1,
      status: json['status']?.toString() ?? 'pending',
      specialRequests: json['special_requests']?.toString(),
    );
  }

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

  /// Function returns a list
  static Future<List<dynamic>> getClientReservations(String userID) async {
    final response = await ApiClient.get(
      'getclientreservations?userid=$userID',
      anonymous: false,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to gather reservations');
    }
  }

  /// Function returns void
  static Future<void> annuler_reservation({
    required int id
  }) async {
    final response = await ApiClient.post(
      'clientannulerreservation',
      body: json.encode({
        '_id': id,
      }),
      anonymous: false,
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to cancel reservation\n\n${response.body}');
    }
  }

  /// Function returns a list
  static Future<List<dynamic>> getAllClientRestaurantsReservations(String userID) async {
    final response = await ApiClient.get(
      'getclientallrestaurantreservationsandservices?userid=$userID',
      anonymous: false,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to gather restaurant/reservations');
    }
  }

  static Future<void> addReservation({
    required int clientId,
    required int restaurantId,
    required DateTime datetime,
    required int nbConvives,
    String? specialRequests,
  }) async {
    final body = {
      'p_client': clientId,
      'p_restaurant': restaurantId,
      'p_datetime': DateFormat('yyyy-MM-dd HH:mm:ss').format(datetime),
      'p_guests': nbConvives,
      'p_special_requests': (specialRequests == null || specialRequests.trim().isEmpty)
          ? null
          : specialRequests,
    };

    print("DEBUG: Envoi de la requête add_reservation avec body: $body");

    final response = await ApiClient.post(
      'add_reservation',
      body: json.encode(body),
      anonymous: false,
    );

    print("DEBUG: Réponse serveur: ${response.statusCode} - ${response.body}");

    if (response.statusCode != 200 && response.statusCode != 204) {
      // AFFICHE LE BODY POUR VOIR L'ERREUR SQL (ex: contrainte violée)
      throw Exception('Erreur ${response.statusCode}: ${response.body}');
    }
  }

  static Future<void> editReservation({
    required int id,
    required DateTime datetime,
    required int nbConvives,
    String? specialRequests
  }) async {
    final response = await ApiClient.post(
      'edit_reservation', // Correspond au nom de la fonction SQL créée
      body: json.encode({
        'p_id': id,
        'p_datetime': DateFormat('yyyy-MM-dd HH:mm:ss').format(datetime),
        'p_guests': nbConvives,
        'p_special_requests': (specialRequests == null || specialRequests.trim().isEmpty)
            ? null
            : specialRequests,
      }),
      anonymous: false,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to update reservation: ${response.body}');
    }
  }
}