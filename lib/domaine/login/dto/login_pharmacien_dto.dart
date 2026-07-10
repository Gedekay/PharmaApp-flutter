class LoginPharmacienDto {
  final String name;
  final String phoneNumber;

  LoginPharmacienDto({required this.name, required this.phoneNumber});

  Map<String, dynamic> toJson() {
    return {"name": name, "phone_number": phoneNumber};
  }
}
