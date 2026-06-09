enum PlayerGender { male, female }

extension PlayerGenderText on PlayerGender {
  String get label => this == PlayerGender.male ? 'Male' : 'Female';
  String get subject => this == PlayerGender.male ? 'He' : 'She';
  String get object => this == PlayerGender.male ? 'him' : 'her';
  String get possessive => this == PlayerGender.male ? 'his' : 'her';
}
