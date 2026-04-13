class Team {
  final String id;
  final String name;
  final String description;
  final String teamCode;
  final String createdBy;

  Team({
    required this.id,
    required this.name,
    required this.description,
    required this.teamCode,
    required this.createdBy,
  });

  factory Team.fromMap(Map<String, dynamic> map) {
    return Team(
      id: map['\$id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      teamCode: map['team_code'] ?? '',
      createdBy: map['created_by'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'team_code': teamCode,
      'created_by': createdBy,
    };
  }
}
