// Calculate trending by activity within past 2 days
const daysTrending = 2;

const double profilePicWidth = 400;
const double profilePicHeight = 400;

const double groupPicWidth = 400;
const double groupPicHeight = 400;

enum Tag {
  Relationships,
  Parties,
  Memes,
  Classes,
  Advice,
  College,
  Confession
}

extension TagExtension on Tag {
  String get string {
    switch (this) {
      case Tag.Relationships:
        return 'Relationships';
      case Tag.Parties:
        return 'Parties';
      case Tag.Memes:
        return 'Memes';
      case Tag.Classes:
        return 'Classes';
      case Tag.Advice:
        return 'Advice';
      case Tag.College:
        return 'College';
      default:
        return 'Confession';
    }
  }
}