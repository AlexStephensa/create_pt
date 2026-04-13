class Round {
  final String id;
  final String teamId;
  final String scoredBy;
  final String roundType;
  final DateTime createdAt;

  Round({
    required this.id,
    required this.teamId,
    required this.scoredBy,
    required this.roundType,
    required this.createdAt,
  });

  factory Round.fromMap(Map<String, dynamic> map) {
    return Round(
      id: map['\$id'] ?? '',
      teamId: map['team_id'] ?? '',
      scoredBy: map['scored_by'] ?? '',
      roundType: map['round_type'] ?? '',
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'team_id': teamId,
      'scored_by': scoredBy,
      'round_type': roundType,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
