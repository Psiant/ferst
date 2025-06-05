import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_sms/flutter_sms.dart';
import '../models/device.dart';
import '../models/oxygen_reading.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = 
      FlutterLocalNotificationsPlugin();
  
  // Номера телефонов для SMS-уведомлений
  List<String> _emergencyContacts = [];
  
  // Инициализация сервиса уведомлений
  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    
    const IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }
  
  // Добавление номера телефона для SMS-уведомлений
  void addEmergencyContact(String phoneNumber) {
    if (!_emergencyContacts.contains(phoneNumber)) {
      _emergencyContacts.add(phoneNumber);
    }
  }
  
  // Удаление номера телефона
  void removeEmergencyContact(String phoneNumber) {
    _emergencyContacts.remove(phoneNumber);
  }
  
  // Получение списка контактов
  List<String> get emergencyContacts => _emergencyContacts;
  
  // Проверка показаний и отправка уведомлений при необходимости
  Future<void> checkAndNotify(Device device, OxygenReading reading) async {
    // Проверка, включены ли уведомления для этого устройства
    if (!device.notificationsEnabled) {
      return;
    }
    
    String message = '';
    
    // Проверка, вышли ли показания за пределы допустимых значений
    if (reading.value < device.minThreshold) {
      message = 'Низкий уровень кислорода: ${reading.value} мг/л (датчик: ${device.name})';
    } else if (reading.value > device.maxThreshold) {
      message = 'Высокий уровень кислорода: ${reading.value} мг/л (датчик: ${device.name})';
    }
    
    // Если есть сообщение, отправляем уведомления
    if (message.isNotEmpty) {
      // Отправка локального уведомления
      await _showNotification(device.id, device.name, message);
      
      // Отправка SMS, если есть контакты
      if (_emergencyContacts.isNotEmpty) {
        await _sendSms(message);
      }
    }
  }
  
  // Отправка локального уведомления
  Future<void> _showNotification(String id, String title, String body) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'oxygen_monitor_channel',
      'Уведомления о кислороде',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );
    
    IOSNotificationDetails iOSPlatformChannelSpecifics =
        IOSNotificationDetails();
    
    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    
    await _flutterLocalNotificationsPlugin.show(
      id.hashCode,
      title,
      body,
      platformChannelSpecifics,
    );
  }
  
  // Отправка SMS
  Future<void> _sendSms(String message) async {
    try {
      await sendSMS(message: message, recipients: _emergencyContacts);
    } catch (e) {
      print('Ошибка отправки SMS: $e');
    }
  }
}
