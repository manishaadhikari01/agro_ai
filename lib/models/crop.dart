class Crop {
  final String id;
  final String name;
  final String type;
  final String? description;
  final String? plantingSeason;
  final String? harvestTime;

  Crop({
    required this.id,
    required this.name,
    required this.type,
    this.description,
    this.plantingSeason,
    this.harvestTime,
  });

  factory Crop.fromJson(Map<String, dynamic> json) {
    return Crop(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      description: json['description'],
      plantingSeason: json['plantingSeason'],
      harvestTime: json['harvestTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'description': description,
      'plantingSeason': plantingSeason,
      'harvestTime': harvestTime,
    };
  }
}
