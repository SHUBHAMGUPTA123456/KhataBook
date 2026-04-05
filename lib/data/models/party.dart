class Party {
  int? id;
  String name;
  String type; // 'customer' or 'supplier'
  String? phone; // For WhatsApp reminder

  Party({this.id, required this.name, required this.type, this.phone});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'type': type, 'phone': phone};
  }

  Party.fromMap(Map<String, dynamic> map): id = map['id'],
      name = map['name'],
      type = map['type'],
      phone = map['phone'];
}
