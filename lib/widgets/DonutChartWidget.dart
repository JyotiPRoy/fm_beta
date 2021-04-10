import 'dart:math';

import 'package:flutter/cupertino.dart';

class ChartData {
  final String segmentName;
  final double value;
  final Color color;

  ChartData({this.segmentName, this.value, this.color});
}

class DonutChartWidget extends CustomPainter {
  final List<ChartData> data;
  final double strokeWidth;

  DonutChartWidget({
    this.data,
    this.strokeWidth
  });

  double get _total {
    double total = 0;
    this.data.forEach((entity) => total += entity.value);
    return total;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Offset center = Offset(size.width/2, size.height/2);
    double radius = min(size.width/2, size.height/2);

    var paint = Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = strokeWidth/2
                ..strokeCap = StrokeCap.round
                ..strokeJoin = StrokeJoin.round;

    double startRadian = -pi/2;
    for(ChartData currentData in this.data){
      final sweepRadian = (currentData.value / _total) * 2 * pi;
      paint.color = currentData.color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startRadian,
        sweepRadian,
        false,
        paint
      );
      startRadian += sweepRadian;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

}