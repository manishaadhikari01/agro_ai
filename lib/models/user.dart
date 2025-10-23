class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? state;
  final String? crops;
  final String? farmerType;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.state,
    this.crops,
    this.farmerType,
  });

  // Factory constructor to create User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      state: json['state'],
      crops: json['crops'],
      farmerType: json['farmerType'],
    );
  }

  // Method to convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'state': state,
      'crops': crops,
      'farmerType': farmerType,
    };
  }

  // Copy with method for updating user data
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? state,
    String? crops,
    String? farmerType,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      state: state,
      crops: crops,
      farmerType: farmerType,
    );
  }
}
