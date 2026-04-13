class TeamMember {
  final String id;
  final String teamId;
  final String userId;
  final String displayName;

  TeamMember({
    required this.id,
    required this.teamId,
    required this.userId,
    required this.displayName,
  });

  factory TeamMember.fromMap(Map<String, dynamic> map) {
    return TeamMember(
      id: map['\$id'] ?? '',
      teamId: map['team_id'] ?? '',
      userId: map['user_id'] ?? '',
      displayName: map['display_name'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'team_id': teamId,
      'user_id': userId,
      'display_name': displayName,
    };
  }
}
