class RecipientModel {
  final String name;
  final String email;
  final String status; // 'pending', 'sent', 'failed'

  RecipientModel({
    required this.name,
    required this.email,
    this.status = 'pending',
  });

  factory RecipientModel.fromJson(Map<String, dynamic> json) {
    return RecipientModel(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      status: json['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'status': status,
    };
  }
}
