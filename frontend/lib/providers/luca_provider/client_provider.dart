import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/user.dart';

final client_provider = FutureProvider.family<User?, int>((ref, clientId) async {
  return User.getUserById(clientId);
});