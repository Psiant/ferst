class Device {
  final String id;
  final String name;
  final String macAddress;
  bool isConnected;
  
  // Настройки для уведомлений
  double minThreshold;
  double maxThreshold;
  bool notificationsEnabled;
  
  Device({
    required this.id,
    required this.name,
    required this.macAddress,
    this.isConnected = false,
    this.minThreshold = 5.0, // минимальный порог, мг/л
    this.maxThreshold = 12.0, // максимальный порог, мг/л
    this.notificationsEnabled = true,
  });
  
  Device copyWith({
    String? id,
    String? name,
    String? macAddress,
    bool? isConnected,
    double? minThreshold,
    double? maxThreshold,
    bool? notificationsEnabled,
  }) {
    return Device(
      id: id ?? this.id,
      name: name ?? this.name,
      macAddress: macAddress ?? this.macAddress,
      isConnected: isConnected ?? this.isConnected,
      minThreshold: minThreshold ?? this.minThreshold,
      maxThreshold: maxThreshold ?? this.maxThreshold,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'macAddress': macAddress,
      'minThreshold': minThreshold,
      'maxThreshold': maxThreshold,
      'notificationsEnabled': notificationsEnabled,
    };
  }
  
  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'],
      name: json['name'],
      macAddress: json['macAddress'],
      minThreshold: json['minThreshold'],
      maxThreshold: json['maxThreshold'],
      notificationsEnabled: json['notificationsEnabled'],
    );
  }
}
