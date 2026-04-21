import 'dart:convert';

String _asString(dynamic value) {
  if (value == null) return '';
  if (value is String) return value;
  if (value is Map) {
    final id = value[r'$id'] ?? value['id'];
    if (id != null) return id.toString();
  }
  return value.toString();
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.round();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

class RoundScore {
  final String id;
  final String roundId;
  final String userId;
  final String displayName;
  final List<String> shots;
  final int totalShots;
  final int hits;
  final int misses;

  RoundScore({
    required this.id,
    required this.roundId,
    required this.userId,
    required this.displayName,
    required this.shots,
    required this.totalShots,
    required this.hits,
    required this.misses,
  });

  factory RoundScore.fromMap(Map<String, dynamic> map) {
    List<String> parsedShots = [];
    if (map['shots'] != null) {
      if (map['shots'] is String) {
        final decoded = json.decode(map['shots']);
        if (decoded is List) {
          parsedShots = decoded.map((e) => e.toString()).toList();
        }
      } else if (map['shots'] is List) {
        parsedShots = (map['shots'] as List).map((e) => e.toString()).toList();
      }
    }

    return RoundScore(
      id: _asString(map['\$id']),
      roundId: _asString(map['round_id']),
      userId: _asString(map['user_id']),
      displayName: _asString(map['display_name']),
      shots: parsedShots,
      totalShots: _asInt(map['total_shots']),
      hits: _asInt(map['hits']),
      misses: _asInt(map['misses']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'round_id': roundId,
      'user_id': userId,
      'display_name': displayName,
      'shots': json.encode(shots),
      'total_shots': totalShots,
      'hits': hits,
      'misses': misses,
    };
  }

  @override
  String toString() {
    return 'RoundScore(id: $id, roundId: $roundId, userId: $userId, displayName: $displayName, shots: $shots, totalShots: $totalShots, hits: $hits, misses: $misses)';
  }
}
