import 'package:hive/hive.dart';

part 'poll.g.dart';

@HiveType(typeId: 24)
class Poll extends HiveObject {
  @HiveField(0)
  final String question;

  @HiveField(1)
  final List<String> options;

  @HiveField(2)
  final bool multiple;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final String id;

  Poll({
    required this.question,
    required this.options,
    required this.multiple,
    DateTime? createdAt,
    String? id,
  }) : this.createdAt = createdAt ?? DateTime.now(),
       this.id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'multiple': multiple,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Poll.fromMap(Map<String, dynamic> map) {
    return Poll(
      id: map['id'],
      question: map['question'],
      options: List<String>.from(map['options']),
      multiple: map['multiple'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Poll copyWith({
    String? question,
    List<String>? options,
    bool? multiple,
    DateTime? createdAt,
    String? id,
  }) {
    return Poll(
      question: question ?? this.question,
      options: options ?? this.options,
      multiple: multiple ?? this.multiple,
      createdAt: createdAt ?? this.createdAt,
      id: id ?? this.id,
    );
  }
}


class PollService {
  static const String boxName = 'polls';
  
  Future<Box<Poll>> _getBox() async {
    if (!Hive.isBoxOpen(boxName)) {
      return await Hive.openBox<Poll>(boxName);
    }
    return Hive.box<Poll>(boxName);
  }

  Future<void> addPoll(Poll poll) async {
    final box = await _getBox();
    await box.put(poll.id, poll);
  }

  Future<List<Poll>> getAllPolls() async {
    final box = await _getBox();
    return box.values.toList();
  }

  Future<void> deletePoll(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }

  Future<Poll?> getPoll(String id) async {
    final box = await _getBox();
    return box.get(id);
  }
}
