import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/notification_service.dart';
import '../services/bluetooth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _phoneController = TextEditingController();
  
  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notificationService = Provider.of<NotificationService>(context);
    final bluetoothService = Provider.of<BluetoothService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Настройки'),
      ),
      body: ListView(
        children: [
          // Секция настроек уведомлений
          _buildSectionHeader('Уведомления'),
          
          // Экстренные контакты для SMS
          _buildEmergencyContacts(notificationService),
          
          // Добавление нового контакта
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'Номер телефона',
                      hintText: '+7XXXXXXXXXX',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    final phone = _phoneController.text.trim();
                    if (phone.isNotEmpty) {
                      notificationService.addEmergencyContact(phone);
                      _phoneController.clear();
                      setState(() {});
                    }
                  },
                  child: Text('Добавить'),
                ),
              ],
            ),
          ),
          
          Divider(),
          
          // Секция настроек устройств
          _buildSectionHeader('Настройки устройств'),
          
          // Список подключенных устройств с настройками
          _buildDeviceSettings(bluetoothService),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue[800],
        ),
      ),
    );
  }
  
  Widget _buildEmergencyContacts(NotificationService service) {
    final contacts = service.emergencyContacts;
    
    if (contacts.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          'Нет добавленных контактов для SMS-уведомлений',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.grey[600],
          ),
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 16, bottom: 8),
          child: Text('Контакты для SMS-уведомлений:'),
        ),
        ...contacts.map((contact) => ListTile(
          title: Text(contact),
          trailing: IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              service.removeEmergencyContact(contact);
              setState(() {});
            },
          ),
        )).toList(),
      ],
    );
  }
  
  Widget _buildDeviceSettings(BluetoothService bluetoothService) {
    final devices = bluetoothService.connectedDevices;
    
    if (devices.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          'Нет подключенных устройств',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.grey[600],
          ),
        ),
      );
    }
    
    return Column(
      children: devices.map((device) {
        return ExpansionTile(
          title: Text(device.name),
          subtitle: Text('ID: ${device.id}'),
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Включение/отключение уведомлений
                  SwitchListTile(
                    title: Text('Уведомления'),
                    value: device.notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        final index = bluetoothService.connectedDevices.indexWhere(
                          (d) => d.id == device.id
                        );
                        if (index != -1) {
                          bluetoothService.connectedDevices[index] = 
                              device.copyWith(notificationsEnabled: value);
                        }
                      });
                    },
                  ),
                  
                  // Минимальный порог
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Минимальный порог: ${device.minThreshold.toStringAsFixed(1)} мг/л',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Slider(
                    min: 0.0,
                    max: 10.0,
                    divisions: 20,
                    value: device.minThreshold,
                    label: device.minThreshold.toStringAsFixed(1),
                    onChanged: (value) {
                      setState(() {
                        final index = bluetoothService.connectedDevices.indexWhere(
                          (d) => d.id == device.id
                        );
                        if (index != -1) {
                          bluetoothService.connectedDevices[index] = 
                              device.copyWith(minThreshold: value);
                        }
                      });
                    },
                  ),
                  
                  // Максимальный порог
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Максимальный порог: ${device.maxThreshold.toStringAsFixed(1)} мг/л',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Slider(
                    min: 10.0,
                    max: 20.0,
                    divisions: 20,
                    value: device.maxThreshold,
                    label: device.maxThreshold.toStringAsFixed(1),
                    onChanged: (value) {
                      setState(() {
                        final index = bluetoothService.connectedDevices.indexWhere(
                          (d) => d.id == device.id
                        );
                        if (index != -1) {
                          bluetoothService.connectedDevices[index] = 
                              device.copyWith(maxThreshold: value);
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
