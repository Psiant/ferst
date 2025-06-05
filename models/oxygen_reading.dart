class OxygenReading {
  final String deviceId;
  final double value; // значение в мг/л
  final double temperature; // температура в °C
  final DateTime timestamp;
  
  OxygenReading({
    required this.deviceId,
    required this.value,
    required this.temperature,
    required this.timestamp,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'value': value,
      'temperature': temperature,
      'timestamp': timestamp.toIso8601String(),
    };
  }
  
  factory OxygenReading.fromJson(Map<String, dynamic> json) {
    return OxygenReading(
      deviceId: json['deviceId'],
      value: json['value'],
      temperature: json['temperature'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
