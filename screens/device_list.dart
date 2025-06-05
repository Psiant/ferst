import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/bluetooth_service.dart';
import '../models/device.dart';

class DeviceListScreen extends StatefulWidget {
  const DeviceListScreen({Key? key}) : super(key: key);

  @override
  _DeviceListScreenState createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    // Начинаем сканирование устройств при открытии экрана
    _startScan();
  }
  
  void _startScan() {
    setState(() {
      _isScanning = true;
    });
    
    final bluetoothService = Provider.of<BluetoothService>(context, listen: false);
    bluetoothService.startScan().then((_) {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothService = Provider.of<BluetoothService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Доступные устройства'),
        actions: [
          if (_isScanning)
            Container(
              margin: EdgeInsets.all(16),
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          else
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _startScan,
              tooltip: 'Обновить список',
            ),
        ],
      ),
      body: bluetoothService.discoveredDevices.isEmpty
          ? _buildEmptyState()
          : _buildDeviceList(bluetoothService),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bluetooth_searching,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'Устройства не найдены',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Убедитесь, что датчики включены и находятся рядом',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _startScan,
            child: Text('Повторить поиск'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDeviceList(BluetoothService bluetoothService) {
    return ListView.builder(
      itemCount: bluetoothService.discoveredDevices.length,
      itemBuilder: (context, index) {
        final device = bluetoothService.discoveredDevices[index];
        return _buildDeviceItem(device);
      },
    );
  }
  
  Widget _buildDeviceItem(Device device) {
    final bluetoothService = Provider.of<BluetoothService>(context, listen: false);
    
    return ListTile(
      title: Text(device.name),
      subtitle: Text(device.macAddress),
      trailing: device.isConnected
          ? Icon(Icons.bluetooth_connected, color: Colors.green)
          : ElevatedButton(
              onPressed: () async {
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                
                // Показываем индикатор загрузки
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('Подключение к ${device.name}...'),
                    duration: Duration(seconds: 2),
                  ),
                );
                
                // Пытаемся подключиться к устройству
                final success = await bluetoothService.connectToDevice(device);
                
                if (success) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Устройство ${device.name} подключено'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  
                  // Возвращаемся на главный экран
                  Navigator.pop(context);
                } else {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Не удалось подключиться к ${device.name}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text('Подключить'),
            ),
    );
  }
}
