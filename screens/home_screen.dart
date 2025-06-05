import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/bluetooth_service.dart';
import '../services/notification_service.dart';
import '../widgets/device_card.dart';
import 'device_list.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Запуск проверки показаний для уведомлений
    _startNotificationChecks();
  }
  
  // Запуск периодической проверки показаний для уведомлений
  void _startNotificationChecks() {
    Future.delayed(Duration(seconds: 5), () {
      if (!mounted) return;
      
      final bluetoothService = Provider.of<BluetoothService>(context, listen: false);
      final notificationService = Provider.of<NotificationService>(context, listen: false);
      
      // Проверка всех подключенных устройств
      for (final device in bluetoothService.connectedDevices) {
        final reading = bluetoothService.latestReadings[device.id];
        if (reading != null) {
          notificationService.checkAndNotify(device, reading);
        }
      }
      
      // Повторная проверка через 5 секунд
      _startNotificationChecks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothService = Provider.of<BluetoothService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Монитор кислорода'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: bluetoothService.connectedDevices.isEmpty
          ? _buildEmptyState()
          : _buildDeviceList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DeviceListScreen()),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Добавить устройство',
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bluetooth_disabled,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'Нет подключенных устройств',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Нажмите кнопку "+" чтобы подключить датчик',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDeviceList() {
    final bluetoothService = Provider.of<BluetoothService>(context);
    
    return RefreshIndicator(
      onRefresh: () async {
        // Обновление данных с устройств
        // (в реальном приложении здесь может быть запрос к устройствам для обновления показаний)
      },
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: bluetoothService.connectedDevices.length,
        itemBuilder: (context, index) {
          final device = bluetoothService.connectedDevices[index];
          final reading = bluetoothService.latestReadings[device.id];
          
          return DeviceCard(
            device: device,
            reading: reading,
            onDisconnect: () {
              bluetoothService.disconnectDevice(device.id);
            },
          );
        },
      ),
    );
  }
}
