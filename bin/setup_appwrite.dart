import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:dart_appwrite/enums.dart';

// Please set your API key here or pass it as an environment variable
// Example: dart run bin/setup_appwrite.dart YOUR_API_KEY
void main(List<String> args) async {
  final apiKey =
      'standard_e57aa65177f330a4b6e38d2ff31558c200c890321020c7a17d6bd2de4988639b207911cf47c08d47d48edc8d275912d6b3093351971da80145549778a1c2b0c0fedbcfa88c23f8a8aede1de56b928b575f6794e03f676a7c00e02449264cc7ec359bbc6d35987817e5a9e69a96451a4ca3f5645802d69a6b4039a8db24cfcebd';
  final endpoint = 'https://sfo.cloud.appwrite.io/v1'; // From constants.dart
  final projectId = '69a5e1210026a1ac2d68'; // From constants.dart
  final databaseId = '69def663002af03d967e'; // From constants.dart

  final client = Client()
      .setEndpoint(endpoint)
      .setProject(projectId)
      .setSelfSigned(status: true)
      .setKey(apiKey);

  final databases = Databases(client);

  print('Starting Appwrite setup...');

  // 1. Teams Collection
  print('Creating Teams collection...');
  try {
    await databases.createCollection(
      databaseId: databaseId,
      collectionId: 'teams',
      name: 'Teams',
    );
    print(' - Collection created (or already exists)');
  } on AppwriteException catch (e) {
    if (e.code == 409) {
      print(' - Collection already exists');
    } else {
      print(' - Error creating collection: ${e.message}');
    }
  } catch (e) {
    print(' - Collection created but encountered SDK parsing error: $e');
  }

  try {
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: 'teams',
      key: 'name',
      size: 255,
      xrequired: true,
    );
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: 'teams',
      key: 'description',
      size: 500,
      xrequired: false,
    );
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: 'teams',
      key: 'team_code',
      size: 6,
      xrequired: true,
    );
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: 'teams',
      key: 'created_by',
      size: 36,
      xrequired: true,
    );
    print(
      ' - Attributes created for teams. Warning: Appwrite processes these asynchronously.',
    );
  } catch (e) {
    print(' - Error creating attributes for teams: $e');
  }

  // 2. Team Members Collection
  print('Creating Team Members collection...');
  try {
    await databases.createCollection(
      databaseId: databaseId,
      collectionId: 'team_members',
      name: 'Team Members',
    );
  } on AppwriteException catch (e) {
    if (e.code == 409) print(' - Collection already exists');
  } catch (e) {
    print(' - Collection created but encountered SDK parsing error: $e');
  }

  try {
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: 'team_members',
      key: 'team_id',
      size: 36,
      xrequired: true,
    );
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: 'team_members',
      key: 'user_id',
      size: 36,
      xrequired: true,
    );
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: 'team_members',
      key: 'display_name',
      size: 255,
      xrequired: false,
    );
    print(' - Attributes created for team_members.');
  } catch (e) {
    print(' - Error creating attributes for team_members: $e');
  }

  // 3. Rounds Collection
  print('Creating Rounds collection...');
  try {
    await databases.createCollection(
      databaseId: databaseId,
      collectionId: 'rounds',
      name: 'Rounds',
    );
  } on AppwriteException catch (e) {
    if (e.code == 409) print(' - Collection already exists');
  } catch (e) {
    print(' - Collection created but encountered SDK parsing error: $e');
  }

  try {
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: 'rounds',
      key: 'team_id',
      size: 36,
      xrequired: true,
    );
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: 'rounds',
      key: 'scored_by',
      size: 36,
      xrequired: true,
    );
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: 'rounds',
      key: 'round_type',
      size: 50,
      xrequired: true,
    );
    await databases.createDatetimeAttribute(
      databaseId: databaseId,
      collectionId: 'rounds',
      key: 'created_at',
      xrequired: true,
    );
    print(' - Attributes created for rounds.');
  } catch (e) {
    print(' - Error creating attributes for rounds: $e');
  }

  // 4. Round Scores Collection
  print('Creating Round Scores collection...');
  try {
    await databases.createCollection(
      databaseId: databaseId,
      collectionId: 'round_scores',
      name: 'Round Scores',
    );
  } on AppwriteException catch (e) {
    if (e.code == 409) print(' - Collection already exists');
  } catch (e) {
    print(' - Collection created but encountered SDK parsing error: $e');
  }

  try {
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: 'round_scores',
      key: 'round_id',
      size: 36,
      xrequired: true,
    );
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: 'round_scores',
      key: 'user_id',
      size: 36,
      xrequired: true,
    );
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: 'round_scores',
      key: 'display_name',
      size: 255,
      xrequired: false,
    );
    await databases.createIntegerAttribute(
      databaseId: databaseId,
      collectionId: 'round_scores',
      key: 'total_shots',
      xrequired: true,
    );
    await databases.createIntegerAttribute(
      databaseId: databaseId,
      collectionId: 'round_scores',
      key: 'hits',
      xrequired: true,
    );
    await databases.createIntegerAttribute(
      databaseId: databaseId,
      collectionId: 'round_scores',
      key: 'misses',
      xrequired: true,
    );
    // Shots is an array of strings
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: 'round_scores',
      key: 'shots',
      size: 20,
      xrequired: true,
      array: true,
    );
    print(' - Attributes created for round_scores.');
  } catch (e) {
    print(' - Error creating attributes for round_scores: $e');
  }

  // Sleep before adding indexes since attributes take a moment to be available
  print(
    'Waiting for Appwrite to process attributes before creating indexes...',
  );
  await Future.delayed(Duration(seconds: 5));

  try {
    print('Creating index on teams.team_code...');
    await databases.createIndex(
      databaseId: databaseId,
      collectionId: 'teams',
      key: 'team_code_idx',
      type: IndexType.unique,
      attributes: <String>['team_code'],
    );
    print(' - Index created.');
  } catch (e) {
    print(' - Error creating index: $e');
  }

  print(
    '\\nSetup finished! Check your Appwrite console to verify all schemas.',
  );
}
