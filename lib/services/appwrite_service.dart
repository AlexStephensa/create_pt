import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import '../constants.dart';

class AppwriteService {
  final Client client;
  late final Account account;
  late final Databases databases;

  AppwriteService({required this.client}) {
    account = Account(client);
    databases = Databases(client);
  }

  // Auth Methods
  Future<User> getCurrentUser() async {
    return await account.get();
  }

  Future<Session> login(String email, String password) async {
    return await account.createEmailPasswordSession(
      email: email,
      password: password,
    );
  }

  Future<User> register(String name, String email, String password) async {
    final user = await account.create(
      userId: ID.unique(),
      email: email,
      password: password,
      name: name,
    );
    await login(email, password);
    return user;
  }

  Future<void> logout() async {
    await account.deleteSession(sessionId: 'current');
  }

  // Database Methods
  Future<Document> createDocument({
    required String collectionId,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    return await databases.createDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: collectionId,
      documentId: documentId,
      data: data,
    );
  }

  Future<Document> getDocument({
    required String collectionId,
    required String documentId,
  }) async {
    return await databases.getDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: collectionId,
      documentId: documentId,
    );
  }

  Future<DocumentList> listDocuments({
    required String collectionId,
    List<String>? queries,
  }) async {
    return await databases.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: collectionId,
      queries: queries,
    );
  }

  Future<Document> updateDocument({
    required String collectionId,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    return await databases.updateDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: collectionId,
      documentId: documentId,
      data: data,
    );
  }

  Future<void> deleteDocument({
    required String collectionId,
    required String documentId,
  }) async {
    await databases.deleteDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: collectionId,
      documentId: documentId,
    );
  }
}
