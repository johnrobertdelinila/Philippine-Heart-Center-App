class MedicalRecord {
  final String gender;
  final int age;
  final double weight;
  final double height;
  final String bloodType;

  MedicalRecord({
    required this.gender,
    required this.age,
    required this.weight,
    required this.height,
    required this.bloodType,
  });

  Map<String, dynamic> toMap() {
    return {
      'gender': gender,
      'age': age,
      'weight': weight,
      'height': height,
      'bloodType': bloodType,
    };
  }

  factory MedicalRecord.fromMap(Map<String, dynamic> map) {
    return MedicalRecord(
      gender: map['gender'] ?? '',
      age: map['age']?.toInt() ?? 0,
      weight: map['weight']?.toDouble() ?? 0.0,
      height: map['height']?.toDouble() ?? 0.0,
      bloodType: map['bloodType'] ?? '',
    );
  }
} 