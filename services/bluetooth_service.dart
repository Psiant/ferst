import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/device.dart';
import '../models/oxygen_reading.dart';

class BluetoothService with ChangeNotifier {
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  
  // Список найденных устройств
  final List<Device> _discoveredDevices = [];
  // Список подключенных устройств
  final List<Device> _connectedDevices = [];
  // Последние показания для каждого устройства
  final Map<String, OxygenReading> _latestReadings = {};
  
  // Потоки для показаний от устройств
  final Map<String, StreamSubscription<List<int>>> _deviceStreams = {};
  
  // Геттеры
  List<Device> get discoveredDevices => _discoveredDevices;
  List<Device> get connectedDevices => _connectedDevices;
  Map<String, OxygenReading> get latestReadings => _latestReadings;
  
  // Конструктор
  BluetoothService() {
    // Инициализация Bluetooth
    initBluetooth();
  }
  
  // Инициализация Bluetooth
  Future<void> initBluetooth() async {
    // Проверка, включен ли Bluetooth
    if (await flutterBlue.isOn) {
      startScan();
    } else {
      // Здесь можно добавить запрос на включение Bluetooth
      print('Bluetooth выключен. Пожалуйста, включите Bluetooth.');
    }
  }
  
  // Начать сканирование устройств
  Future<void> startScan() async {
    // Очистка списка найденных устройств
    _discoveredDevices.clear();
    notifyListeners();
    
    // Начать сканирование
    flutterBlue.startScan(timeout: Duration(seconds: 10));
    
    // Слушать результаты сканирования
    flutterBlue.scanResults.listen((results) {
      for (ScanResult result in results) {
        if (result.device.name.isNotEmpty) {
          // Проверка, если устройство уже в списке
          bool deviceExists = _discoveredDevices.any(
            (device) => device.id == result.device.id.toString()
          );
          
          if (!deviceExists) {
            // Добавляем новое устройство в список
            _discoveredDevices.add(Device(
              id: result.device.id.toString(),
              name: result.device.name,
              macAddress: result.device.id.id,
            ));
            notifyListeners();
          }
        }
      }
    });
  }
  
  // Подключиться к устройству
  Future<bool> connectToDevice(Device device) async {
    try {
      // Поиск устройства BluetoothDevice по ID
      BluetoothDevice bluetoothDevice = BluetoothDevice.fromId(device.id);
      
      // Подключение к устройству
      await bluetoothDevice.connect();
      
      // Добавление устройства в список подключенных
      final connectedDevice = device.copyWith(isConnected: true);
      _connectedDevices.add(connectedDevice);
      
      // Обновление списка найденных устройств
      final index = _discoveredDevices.indexWhere((d) => d.id == device.id);
      if (index != -1) {
        _discoveredDevices[index] = connectedDevice;
      }
      
      // Получение сервисов устройства
      List<BluetoothService> services = await bluetoothDevice.discoverServices();
      
      // Поиск сервиса для чтения данных кислорода
      // Здесь нужно знать UUID сервиса и характеристики от производителя
      for (BluetoothService service in services) {
        // Пример UUID - нужно заменить на реальный
        if (service.uuid.toString() == '0000180d-0000-1000-8000-00805f9b34fb') {
          for (BluetoothCharacteristic characteristic in service.characteristics) {
            if (characteristic.properties.notify) {
              // Подписка на уведомления
              await characteristic.setNotifyValue(true);
              _deviceStreams[device.id] = characteristic.value.listen((data) {
                // Обработка данных от датчика
                _processOxygenData(device.id, data);
              });
            }
          }
        }
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      print('Ошибка подключения: $e');
      return false;
    }
  }
  
  // Отключение от устройства
  Future<void> disconnectDevice(String deviceId) async {
    try {
      // Поиск устройства в списке подключенных
      final index = _connectedDevices.indexWhere((d) => d.id == deviceId);
      if (index != -1) {
        // Отмена подписки на данные
        _deviceStreams[deviceId]?.cancel();
        _deviceStreams.remove(deviceId);
        
        // Отключение от устройства
        BluetoothDevice bluetoothDevice = BluetoothDevice.fromId(deviceId);
        await bluetoothDevice.disconnect();
        
        // Удаление из списка подключенных
        _connectedDevices.removeAt(index);
        
        // Обновление списка найденных устройств
        final discoveredIndex = _discoveredDevices.indexWhere((d) => d.id == deviceId);
        if (discoveredIndex != -1) {
          _discoveredDevices[discoveredIndex] = _discoveredDevices[discoveredIndex].copyWith(isConnected: false);
        }
        
        notifyListeners();
      }
    } catch (e) {
      print('Ошибка отключения: $e');
    }
  }
  
  // Обработка данных от датчика
  void _processOxygenData(String deviceId, List<int> data) {
    // Здесь нужно преобразовать полученные байты в значения кислорода и температуры
    // Формат данных зависит от производителя датчика
    // Это пример, реальная реализация будет зависеть от протокола устройства
    
    // Пример обработки: предполагаем, что первые 4 байта - значение кислорода (float),
    // следующие 4 байта - температура (float)
    if (data.length >= 8) {
      // Преобразование байтов в float (пример, может отличаться)
      double oxygenValue = _bytesToFloat(data.sublist(0, 4));
      double temperature = _bytesToFloat(data.sublist(4, 8));
      
      // Создание объекта показаний
      final reading = OxygenReading(
        deviceId: deviceId,
        value: oxygenValue,
        temperature: temperature,
        timestamp: DateTime.now(),
      );
      
      // Сохранение последнего показания
      _latestReadings[deviceId] = reading;
      
      // Уведомление слушателей об изменении данных
      notifyListeners();
    }
  }
  
  // Преобразование байтов в float (пример, нужно адаптировать под протокол устройства)
  double _bytesToFloat(List<int> bytes) {
    // Этот метод должен быть реализован в соответствии с форматом данных устройства
    // Пример простой реализации
    int bits = (bytes[3] << 24) | (bytes[2] << 16) | (bytes[1] << 8) | bytes[0];
    int sign = ((bits >>> 31) == 0) ? 1 : -1;
    int exponent = ((bits >>> 23) & 0xff) - 127;
    int mantissa = (bits & 0x7fffff) | 0x800000;
    double value = sign * mantissa * pow(2, exponent - 23);
    return value;
  }
  
  // Освобождение ресурсов при уничтожении сервиса
  @override
  void dispose() {
    // Отменяем все подписки
    for (var subscription in _deviceStreams.values) {
      subscription.cancel();
    }
    _deviceStreams.clear();
    
    super.dispose();
  }
}
