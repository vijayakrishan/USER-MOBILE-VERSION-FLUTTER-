class UserProfile {
  final String? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? dateOfBirth;
  final String? gender;
  final String? address;
  final String? emergencyContactName;
  final String? emergencyContactNumber;
  final String? relationship;
  final String? medicalInformation;
  final String? designation;

  UserProfile({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.emergencyContactName,
    this.emergencyContactNumber,
    this.relationship,
    this.medicalInformation,
    this.designation,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'] ?? json['fullName'],
      email: json['email'],
      phone: json['phone'],
      dateOfBirth: json['date_of_birth'] ?? json['dateOfBirth'],
      gender: json['gender'],
      address: json['address'],
      emergencyContactName: json['emergency_contact_name'] ?? json['emergencyContactName'],
      emergencyContactNumber: json['emergency_contact_number'] ?? json['emergencyContactNumber'],
      relationship: json['relationship'],
      medicalInformation: json['medical_information'] ?? json['medicalInformation'],
      designation: json['designation'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'fullName': name,
      'email': email,
      'phone': phone,
      'date_of_birth': dateOfBirth,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'address': address,
      'emergency_contact_name': emergencyContactName,
      'emergencyContactName': emergencyContactName,
      'emergency_contact_number': emergencyContactNumber,
      'emergencyContactNumber': emergencyContactNumber,
      'relationship': relationship,
      'medical_information': medicalInformation,
      'medicalInformation': medicalInformation,
      'designation': designation,
    };
    if (id != null) {
      data['id'] = id;
    }
    return data;
  }
}
