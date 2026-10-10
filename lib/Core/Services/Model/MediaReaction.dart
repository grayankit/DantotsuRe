import 'User.dart';

class MediaReaction {
  final String id;
  final String text;
  final int votes;
  final int? createdAt;
  final User? user;

  const MediaReaction({
    required this.id,
    required this.text,
    this.votes = 0,
    this.createdAt,
    this.user,
  });
}
