import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants.dart';
import '../services/appwrite_service.dart';

final clientProvider = Provider<Client>((ref) {
  return Client()
    ..setEndpoint(AppwriteConstants.endpoint)
    ..setProject(AppwriteConstants.projectId)
    ..setSelfSigned(status: true); // Remove this in production
});

final appwriteServiceProvider = Provider<AppwriteService>((ref) {
  final client = ref.watch(clientProvider);
  return AppwriteService(client: client);
});
