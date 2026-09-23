class AddressModel {
  final String street;
  final String upazila;
  final String district;
  final String division;

  AddressModel({
    required this.street,
    required this.upazila,
    required this.district,
    required this.division,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      street: json['street'] ?? '',
      upazila: json['upazila'] ?? '',
      district: json['district'] ?? 'Dhaka',
      division: json['division'] ?? 'Dhaka',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'upazila': upazila,
      'district': district,
      'division': division,
    };
  }
}
