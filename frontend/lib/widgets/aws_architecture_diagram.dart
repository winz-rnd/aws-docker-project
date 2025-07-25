import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';

class AwsArchitectureDiagram extends StatefulWidget {
  const AwsArchitectureDiagram({Key? key}) : super(key: key);

  @override
  State<AwsArchitectureDiagram> createState() => _AwsArchitectureDiagramState();
}

class _AwsArchitectureDiagramState extends State<AwsArchitectureDiagram>
    with TickerProviderStateMixin {
  late AnimationController _flowController;
  late AnimationController _pulseController;
  late Animation<double> _flowAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // 데이터 흐름 애니메이션
    _flowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _flowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _flowController,
      curve: Curves.linear,
    ));
    
    // 펄스 애니메이션
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _flowController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'AWS Docker Architecture',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.awsDeepBlue,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: CustomPaint(
              painter: DockerArchitecturePainter(
                flowAnimation: _flowAnimation,
                pulseAnimation: _pulseAnimation,
              ),
              child: Container(),
            ),
          ),
          const SizedBox(height: 10),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(Colors.blue[700]!, 'Docker Container'),
        const SizedBox(width: 20),
        _buildLegendItem(AppTheme.awsOrange, 'AWS Service'),
        const SizedBox(width: 20),
        _buildLegendItem(Colors.purple, 'Database'),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.awsGray,
          ),
        ),
      ],
    );
  }
}

class DockerArchitecturePainter extends CustomPainter {
  final Animation<double> flowAnimation;
  final Animation<double> pulseAnimation;

  DockerArchitecturePainter({
    required this.flowAnimation,
    required this.pulseAnimation,
  }) : super(repaint: Listenable.merge([flowAnimation, pulseAnimation]));

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // EC2 Instance Container
    _drawEC2Container(canvas, size);
    
    // Docker Network
    _drawDockerNetwork(canvas, Offset(centerX, centerY - 50));
    
    // Docker Containers
    _drawNginxContainer(canvas, Offset(centerX - 120, centerY));
    _drawFlutterContainer(canvas, Offset(centerX, centerY));
    _drawSpringBootContainer(canvas, Offset(centerX + 120, centerY));
    _drawMySQLContainer(canvas, Offset(centerX, centerY + 100));
    
    // Client
    _drawClient(canvas, Offset(centerX, 40));
    
    // Draw connections with animation
    _drawAnimatedConnections(canvas, size);
    
    // Labels
    _drawLabels(canvas, size);
  }

  void _drawEC2Container(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(20, 80, size.width - 40, size.height - 120),
      const Radius.circular(16),
    );
    
    final paint = Paint()
      ..color = AppTheme.awsOrange.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    
    final borderPaint = Paint()
      ..color = AppTheme.awsOrange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawRRect(rect, paint);
    canvas.drawRRect(rect, borderPaint);
    
    // EC2 Label
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'AWS EC2 Instance',
        style: TextStyle(
          color: AppTheme.awsOrange,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    textPainter.paint(canvas, const Offset(30, 90));
  }

  void _drawDockerNetwork(Canvas canvas, Offset center) {
    final networkPaint = Paint()
      ..color = Colors.blue.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    
    final networkBorderPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    
    // Draw network circle
    canvas.drawCircle(center, 100, networkPaint);
    
    // Draw dashed border
    final path = Path();
    const double dashWidth = 5;
    const double dashSpace = 5;
    final double radius = 100;
    double angle = 0;
    
    while (angle < 2 * math.pi) {
      final x1 = center.dx + radius * math.cos(angle);
      final y1 = center.dy + radius * math.sin(angle);
      angle += dashWidth / radius;
      final x2 = center.dx + radius * math.cos(angle);
      final y2 = center.dy + radius * math.sin(angle);
      
      path.moveTo(x1, y1);
      path.lineTo(x2, y2);
      
      angle += dashSpace / radius;
    }
    
    canvas.drawPath(path, networkBorderPaint);
    
    // Network label
    _drawLabel(canvas, 'Docker Network', center.translate(0, -120), fontSize: 12);
  }

  void _drawClient(Canvas canvas, Offset center) {
    // Client icon
    final paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;
    
    // Monitor
    final monitorRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 40, height: 30),
      const Radius.circular(4),
    );
    canvas.drawRRect(monitorRect, paint);
    
    // Screen
    final screenPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final screenRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 34, height: 24),
      const Radius.circular(2),
    );
    canvas.drawRRect(screenRect, screenPaint);
    
    // Stand
    canvas.drawRect(
      Rect.fromCenter(center: center.translate(0, 18), width: 15, height: 5),
      paint,
    );
    
    _drawLabel(canvas, 'Client Browser', center.translate(0, 30));
  }

  void _drawNginxContainer(Canvas canvas, Offset center) {
    _drawDockerContainer(
      canvas,
      center,
      'nginx',
      Colors.green,
      Icons.dns,
      pulseAnimation.value,
    );
  }

  void _drawFlutterContainer(Canvas canvas, Offset center) {
    _drawDockerContainer(
      canvas,
      center,
      'Flutter\nWeb',
      Colors.blue,
      Icons.web,
      pulseAnimation.value,
    );
  }

  void _drawSpringBootContainer(Canvas canvas, Offset center) {
    _drawDockerContainer(
      canvas,
      center,
      'Spring\nBoot',
      Colors.orange,
      Icons.api,
      pulseAnimation.value,
    );
  }

  void _drawMySQLContainer(Canvas canvas, Offset center) {
    _drawDockerContainer(
      canvas,
      center,
      'MySQL',
      Colors.purple,
      Icons.storage,
      1.0, // No pulse for database
    );
  }

  void _drawDockerContainer(
    Canvas canvas,
    Offset center,
    String label,
    Color color,
    IconData icon,
    double scale,
  ) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(scale);
    canvas.translate(-center.dx, -center.dy);
    
    // Container background
    final containerRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 80, height: 60),
      const Radius.circular(8),
    );
    
    final containerPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    
    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawRRect(containerRect, containerPaint);
    canvas.drawRRect(containerRect, borderPaint);
    
    // Docker logo
    final dockerPaint = Paint()
      ..color = Colors.blue[700]!
      ..style = PaintingStyle.fill;
    
    final dockerRect = Rect.fromCenter(
      center: center.translate(25, -20),
      width: 20,
      height: 15,
    );
    canvas.drawRect(dockerRect, dockerPaint);
    
    // Whale fin
    final finPath = Path()
      ..moveTo(center.dx + 15, center.dy - 20)
      ..quadraticBezierTo(
        center.dx + 10, center.dy - 25,
        center.dx + 15, center.dy - 30,
      );
    canvas.drawPath(finPath, Paint()
      ..color = Colors.blue[700]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2);
    
    canvas.restore();
    
    // Icon
    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontFamily: icon.fontFamily,
          fontSize: 24,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    iconPainter.layout();
    iconPainter.paint(
      canvas,
      center.translate(-iconPainter.width / 2, -iconPainter.height / 2),
    );
    
    // Label
    _drawLabel(canvas, label, center.translate(0, 40), fontSize: 10);
  }

  void _drawAnimatedConnections(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    final connections = [
      // Client to nginx
      AnimatedConnection(
        start: Offset(centerX, 70),
        end: Offset(centerX - 120, centerY - 30),
        color: Colors.green,
      ),
      // nginx to Flutter
      AnimatedConnection(
        start: Offset(centerX - 80, centerY),
        end: Offset(centerX - 40, centerY),
        color: Colors.blue,
      ),
      // Flutter to Spring Boot
      AnimatedConnection(
        start: Offset(centerX + 40, centerY),
        end: Offset(centerX + 80, centerY),
        color: Colors.orange,
      ),
      // Spring Boot to MySQL
      AnimatedConnection(
        start: Offset(centerX + 120, centerY + 30),
        end: Offset(centerX + 40, centerY + 100),
        color: Colors.purple,
      ),
    ];
    
    for (final connection in connections) {
      _drawAnimatedArrow(
        canvas,
        connection.start,
        connection.end,
        connection.color,
        flowAnimation.value,
      );
    }
  }

  void _drawAnimatedArrow(
    Canvas canvas,
    Offset start,
    Offset end,
    Color color,
    double progress,
  ) {
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(end.dx, end.dy);
    
    // Background line
    final bgPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    canvas.drawPath(path, bgPaint);
    
    // Animated line
    final animPaint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    
    final metrics = path.computeMetrics().first;
    final extractPath = metrics.extractPath(0, metrics.length * progress);
    
    canvas.drawPath(extractPath, animPaint);
    
    // Arrow head
    if (progress > 0.1) {
      final tangent = metrics.getTangentForOffset(metrics.length * progress);
      if (tangent != null) {
        canvas.save();
        canvas.translate(tangent.position.dx, tangent.position.dy);
        canvas.rotate(tangent.angle);
        
        final arrowPath = Path()
          ..moveTo(-8, -4)
          ..lineTo(0, 0)
          ..lineTo(-8, 4);
        
        canvas.drawPath(arrowPath, animPaint);
        canvas.restore();
      }
    }
  }

  void _drawLabel(Canvas canvas, String text, Offset position, {double fontSize = 12}) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: AppTheme.awsDeepBlue,
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    
    textPainter.layout();
    textPainter.paint(
      canvas,
      position.translate(-textPainter.width / 2, 0),
    );
  }

  void _drawLabels(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    
    // Port labels
    _drawLabel(
      canvas,
      ':3000',
      Offset(size.width / 2 - 120, centerY - 50),
      fontSize: 10,
    );
    
    _drawLabel(
      canvas,
      ':8080',
      Offset(size.width / 2 + 120, centerY - 50),
      fontSize: 10,
    );
    
    _drawLabel(
      canvas,
      ':3306',
      Offset(size.width / 2 + 60, centerY + 100),
      fontSize: 10,
    );
    
    // Description
    final descPainter = TextPainter(
      text: const TextSpan(
        text: 'All services run in Docker containers with isolated networks',
        style: TextStyle(
          color: AppTheme.awsGray,
          fontSize: 12,
          fontStyle: FontStyle.italic,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    
    descPainter.layout();
    descPainter.paint(
      canvas,
      Offset((size.width - descPainter.width) / 2, size.height - 20),
    );
  }

  @override
  bool shouldRepaint(DockerArchitecturePainter oldDelegate) => true;
}

class AnimatedConnection {
  final Offset start;
  final Offset end;
  final Color color;

  AnimatedConnection({
    required this.start,
    required this.end,
    required this.color,
  });
}