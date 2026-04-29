import 'dart:convert';

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
        try {
          parsedShots = List<String>.from(json.decode(map['shots']));
        } catch (_) {}
      } else if (map['shots'] is List) {
        parsedShots = List<String>.from(map['shots']);
      }
    }

    int parseNum(dynamic val) {
      if (val == null) return 0;
      if (val is num) return val.toInt();
      return (num.tryParse(val.toString()) ?? 0).toInt();
    }

    return RoundScore(
      id: map['\$id'] ?? '',
      roundId: map['round_id'] ?? '',
      userId: map['user_id'] ?? '',
      displayName: map['display_name'] ?? '',
      shots: parsedShots,
      totalShots: parseNum(map['total_shots']),
      hits: parseNum(map['hits']),
      misses: parseNum(map['misses']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'round_id': roundId,
      'user_id': userId,
      'display_name': displayName,
      'shots': shots,
      'total_shots': totalShots,
      'hits': hits,
      'misses': misses,
    };
  }
}
