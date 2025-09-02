class Session {
  final String id;
  final DateTime startedAt;
  final DateTime endedAt;
  
  Session({
    required this.id,
    required this.startedAt,
    required this.endedAt,
  });
  
  Duration get duration => endedAt.difference(startedAt);
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'started_at': startedAt.millisecondsSinceEpoch,
      'ended_at': endedAt.millisecondsSinceEpoch,
    };
  }
  
  factory Session.fromMap(Map<String, dynamic> map) {
    return Session(
      id: map['id'],
      startedAt: DateTime.fromMillisecondsSinceEpoch(map['started_at']),
      endedAt: DateTime.fromMillisecondsSinceEpoch(map['ended_at']),
    );
  }
}

class Reflection {
  final String id;
  final String sessionId;
  final String mirror;
  final String koan;
  final String microPractice;
  final String? userJournal;
  final DateTime createdAt;
  
  Reflection({
    required this.id,
    required this.sessionId,
    required this.mirror,
    required this.koan,
    required this.microPractice,
    this.userJournal,
    required this.createdAt,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'session_id': sessionId,
      'mirror': mirror,
      'koan': koan,
      'micro_practice': microPractice,
      'user_journal': userJournal,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }
  
  factory Reflection.fromMap(Map<String, dynamic> map) {
    return Reflection(
      id: map['id'],
      sessionId: map['session_id'],
      mirror: map['mirror'],
      koan: map['koan'],
      microPractice: map['micro_practice'],
      userJournal: map['user_journal'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    );
  }
}