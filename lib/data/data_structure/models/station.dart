class Station {
  final String id;
  final String name;
  final String? address;
  final String? county;

  Station({required this.id, required this.name, this.address, this.county});

  factory Station.fromMap(String id, Map<String, dynamic> map) {
    return Station(
      id: id,
      name: map['name'] as String,
      address: map['address'] as String?,
      county: map['county'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'county': county,
    };
  }
}

