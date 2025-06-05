import 'package:flutter/material.dart';
import 'dart:math' as math;

class OxygenGauge extends StatelessWidget {
  final double value;
  final double minThreshold;
  final double maxThreshold;
  final double min;
  final double max;
  
  const OxygenGauge({
    Key? key,
    required this.value,
    required this.minThreshold,
    required this.maxThreshold,
    this.min = 0.0,
    this.max = 20.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      child: CustomPaint(
        size: Size.infinite,
        painter: _GaugePainter(
          value: value,
          minThreshold: minThreshold,
          maxThreshold: maxThreshold,
          min: min,
          max: max,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: _getColorForValue(value),
                ),
              ),
              Text(
                'мг/л',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Color _getColorForValue(double value) {
    if (value < minThreshold) {
      return Colors.red;
    } else if (value > maxThreshold) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
}

class _GaugePainter extends CustomPainter {
  final double value;
  final double minThreshold;
  final double maxThreshold;
  final double min;
  final double max;
  
  _GaugePainter({
    required this.value,
    required this.minThreshold,
    required this.maxThreshold,
    required this.min,
    required this.max,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = math.min(size.width / 2, size.height) * 0.8;
    
    final startAngle = math.pi * 0.8;
    final endAngle = math.pi * 0.2;
    
    // Рисуем фоновую дугу
    final backgroundPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      endAngle - startAngle,
      false,
      backgroundPaint,
    );
    
    // Рисуем цветные сегменты (красный, зеленый, оранжевый)
    // Красный (низкий уровень)
    final redPaint = Paint()
      ..color = Colors.red[400]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;
    
    final redStartAngle = startAngle;
    final redEndAngle = startAngle + (endAngle - startAngle) * ((minThreshold - min) / (max - min));
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      redStartAngle,
      redEndAngle - redStartAngle,
      false,
      redPaint,
    );
    
    // Зеленый (нормальный уровень)
    final greenPaint = Paint()
      ..color = Colors.green[400]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;
    
    final greenStartAngle = redEndAngle;
    final greenEndAngle = startAngle + (endAngle - startAngle) * ((maxThreshold - min) / (max - min));
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      greenStartAngle,
      greenEndAngle - greenStartAngle,
      false,
      greenPaint,
    );
    
    // Оранжевый (высокий уровень)
    final orangePaint = Paint()
      ..color = Colors.orange[400]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;
    
    final orangeStartAngle = greenEndAngle;
    final orangeEndAngle = endAngle;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      orangeStartAngle,
      orangeEndAngle - orangeStartAngle,
      false,
      orangePaint,
    );
    
    // Рисуем стрелку
    final valueAngle = startAngle + (endAngle - startAngle) * ((value - min) / (max - min));
    
    final pointerPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    
    final pointerLength = radius * 0.7;
    final pointerWidth = 2.0;
    
    final pointerPath = Path();
    pointerPath.moveTo(
      center.dx + math.cos(valueAngle) * (radius - 15),
      center.dy + math.sin(valueAngle) * (radius - 15),
    );
    pointerPath.lineTo(
      center.dx + math.cos(valueAngle - math.pi/2) * pointerWidth,
      center.dy + math.sin(valueAngle - math.pi/2) * pointerWidth,
    );
    pointerPath.lineTo(
      center.dx + math.cos(valueAngle) * pointerLength,
      center.dy + math.sin(valueAngle) * pointerLength,
    );
    pointerPath.lineTo(
      center.dx + math.cos(valueAngle + math.pi/2) * pointerWidth,
      center.dy + math.sin(valueAngle + math.pi/2) * pointerWidth,
    );
    pointerPath.close();
    
    canvas.drawPath(pointerPath, pointerPaint);
    
    // Рисуем центральную точку
    final centerPaint = Paint()
      ..color = Colors.grey[800]!
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, 5, centerPaint);
    
    // Добавляем метки значений
    final textStyle = TextStyle(
      color: Colors.grey[600],
      fontSize: 12,
    );
    
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    
    // Рисуем метки min, max и промежуточные значения
    final valueSteps = [min, (min + max) / 2, max];
    
    for (var i = 0; i < valueSteps.length; i++) {
      final stepValue = valueSteps[i];
      final stepAngle = startAngle + (endAngle - startAngle) * ((stepValue - min) / (max - min));
      
      final textPosition = Offset(
        center.dx + math.cos(stepAngle) * (radius + 15),
        center.dy + math.sin(stepAngle) * (radius + 15),
      );
      
      textPainter.text = TextSpan(
        text: stepValue.toStringAsFixed(1),
        style: textStyle,
      );
      
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          textPosition.dx - textPainter.width / 2,
          textPosition.dy - textPainter.height / 2,
        ),
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.value != value ||
           oldDelegate.minThreshold != minThreshold ||
           oldDelegate.maxThreshold != maxThreshold;
  }
}
