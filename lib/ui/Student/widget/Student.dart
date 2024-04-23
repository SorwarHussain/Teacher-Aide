// student.dart
class Student {
  final String name;
  final int roll;
  final String? email; // Make email optional
  final String? phone; // Make phone optional
  Student(this.name, this.roll,{this.email,this.phone});

  // Convert student object to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'roll': roll,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
    };
  }
}
