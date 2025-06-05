import 'package:flutter/material.dart';
import '../models/device.dart';
import '../models/oxygen_reading.dart';
import 'oxygen_gauge.dart';

class DeviceCard extends StatelessWidget {
  final Device device;
  final OxygenReading? reading;
  final VoidCallback onDisconnect;
  
  const DeviceCard({
    Key? key,
    required this.device,
    this.reading,
    required this.onDisconnect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок с названием устройства и кнопкой отключения
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    device.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: onDisconnect,
                  tooltip: 'Отключить',
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            // Индикатор уровня кислорода
            if (reading != null) ...[
              OxygenGauge(
                value: reading!.value,
                minThreshold: device.minThreshold,
                maxThreshold: device.maxThreshold,
              ),
              
              SizedBox(height: 16),
              
              // Дополнительная информация
              _buildInfoRow('Уровень кислорода', '${reading!.value.toStringAsFixed(2)} мг/л'),
              _buildInfoRow('Температура', '${reading!.temperature.toStringAsFixed(1)} °C'),
              _buildInfoRow('Время измерения', _formatDateTime(reading!.timestamp)),
              
              // Индикатор статуса
              SizedBox(height: 8),
              _buildStatusIndicator(reading!.value),
            ] else ...[
              // Если нет данных
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Нет данных с устройства',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusIndicator(double value) {
    Color color;
    String status;
    
    if (value < device.minThreshold) {
      color = Colors.red;
      status = 'Низкий уровень кислорода';
    } else if (value > device.maxThreshold) {
      color = Colors.orange;
      status = 'Высокий уровень кислорода';
    } else {
      color = Colors.green;
      status = 'Нормальный уровень кислорода';
    }
    
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: color,
          ),
          SizedBox(width: 8),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
