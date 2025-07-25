import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';

class CICDArchitectureDiagram extends StatefulWidget {
  const CICDArchitectureDiagram({Key? key}) : super(key: key);

  @override
  State<CICDArchitectureDiagram> createState() => _CICDArchitectureDiagramState();
}

class _CICDArchitectureDiagramState extends State<CICDArchitectureDiagram>
    with TickerProviderStateMixin {
  late AnimationController _flowController;
  late AnimationController _pulseController;
  late Animation<double> _flowAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    // 플로우 애니메이션 컨트롤러 (점이 이동하는 애니메이션)
    _flowController = AnimationController(
      duration: const Duration(seconds: 6),
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
      begin: 0.8,
      end: 1.2,
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
      height: 900,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'CI/CD Pipeline Architecture',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.awsDeepBlue,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: AnimatedBuilder(
              animation: _flowAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: CICDPainter(
                    flowProgress: _flowAnimation.value,
                    pulseAnimation: _pulseAnimation,
                  ),
                  child: Container(),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildLegendItem(Colors.green, 'Developer Push'),
          const SizedBox(height: 8),
          _buildLegendItem(AppTheme.awsOrange, 'GitHub Actions'),
          const SizedBox(height: 8),
          _buildLegendItem(Colors.blue, 'AWS Services'),
          const SizedBox(height: 8),
          _buildLegendItem(Colors.purple, 'Deployment'),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}

class CICDPainter extends CustomPainter {
  final double flowProgress;
  final Animation<double> pulseAnimation;

  CICDPainter({
    required this.flowProgress,
    required this.pulseAnimation,
  }) : super(repaint: pulseAnimation);

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final spacing = size.height / 7;  // 더 넓은 간격
    
    // 위치 계산
    final positions = [
      Offset(centerX, spacing * 0.7),      // Developer
      Offset(centerX, spacing * 1.5),      // GitHub
      Offset(centerX, spacing * 2.3),      // GitHub Actions
      Offset(centerX, spacing * 3.1),      // Docker Build
      Offset(centerX, spacing * 3.9),      // ECR/IAM
      Offset(centerX, spacing * 4.7),      // EC2
      Offset(centerX, spacing * 5.5),      // Docker Containers
    ];

    // 모든 요소 그리기 (순차 애니메이션 없이)
    _drawDeveloper(canvas, positions[0]);
    _drawGitHub(canvas, positions[1]);
    _drawGitHubActions(canvas, positions[2]);
    _drawDockerBuild(canvas, positions[3]);
    _drawECR(canvas, Offset(centerX - 100, positions[4].dy));
    _drawIAM(canvas, Offset(centerX + 100, positions[4].dy));
    _drawEC2(canvas, positions[5]);
    _drawDockerContainers(canvas, positions[6]);
    
    // Draw connections (static lines)
    _drawConnections(canvas, positions);
    
    // Draw moving dots
    _drawMovingDots(canvas, positions);
    
    // Draw labels
    _drawLabels(canvas, positions);
  }

  void _drawDeveloper(Canvas canvas, Offset center) {
    final paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;
    
    // Developer icon (smaller)
    canvas.drawCircle(center.translate(0, -8), 6, paint);
    
    final path = Path()
      ..moveTo(center.dx - 8, center.dy)
      ..lineTo(center.dx - 2, center.dy - 5)
      ..lineTo(center.dx + 2, center.dy - 5)
      ..lineTo(center.dx + 8, center.dy)
      ..lineTo(center.dx + 5, center.dy + 8)
      ..lineTo(center.dx - 5, center.dy + 8)
      ..close();
    
    canvas.drawPath(path, paint);
    
    _drawLabel(canvas, 'Developer', center.translate(0, 30));
  }

  void _drawGitHub(Canvas canvas, Offset center) {
    final paint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, 18, paint);
    
    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, 13, whitePaint);
    
    _drawLabel(canvas, 'GitHub\nRepository', center.translate(0, 35));
  }

  void _drawGitHubActions(Canvas canvas, Offset center) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 60, height: 45),
      const Radius.circular(6),
    );
    
    final paint = Paint()
      ..color = AppTheme.awsOrange.withOpacity(0.9)
      ..style = PaintingStyle.fill;
    
    canvas.drawRRect(rect, paint);
    
    final iconPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawCircle(center.translate(-12, 0), 6, iconPaint);
    canvas.drawCircle(center.translate(0, 0), 6, iconPaint);
    canvas.drawCircle(center.translate(12, 0), 6, iconPaint);
    
    _drawLabel(canvas, 'GitHub\nActions', center.translate(0, 35));
  }

  void _drawDockerBuild(Canvas canvas, Offset center) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 70, height: 45),
      const Radius.circular(6),
    );
    
    final paint = Paint()
      ..color = Colors.blue[700]!
      ..style = PaintingStyle.fill;
    
    canvas.drawRRect(rect, paint);
    
    final whalePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final whaleBody = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 30, height: 18),
      const Radius.circular(8),
    );
    canvas.drawRRect(whaleBody, whalePaint);
    
    _drawLabel(canvas, 'Docker\nBuild', center.translate(0, 35));
  }

  void _drawECR(Canvas canvas, Offset center) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 50, height: 40),
      const Radius.circular(6),
    );
    
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    
    canvas.drawRRect(rect, paint);
    
    final iconPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    final containerRect = Rect.fromCenter(center: center, width: 20, height: 25);
    canvas.drawRect(containerRect, iconPaint);
    
    _drawLabel(canvas, 'ECR', center.translate(0, 30));
  }

  void _drawIAM(Canvas canvas, Offset center) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 45, height: 40),
      const Radius.circular(6),
    );
    
    final paint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.fill;
    
    canvas.drawRRect(rect, paint);
    
    final iconPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final lockBody = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center.translate(0, 3), width: 15, height: 12),
      const Radius.circular(2),
    );
    canvas.drawRRect(lockBody, iconPaint);
    
    _drawLabel(canvas, 'IAM', center.translate(0, 30));
  }

  void _drawEC2(Canvas canvas, Offset center) {
    final scale = pulseAnimation.value;
    
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(scale);
    canvas.translate(-center.dx, -center.dy);
    
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 70, height: 55),
      const Radius.circular(8),
    );
    
    final paint = Paint()
      ..color = Colors.purple
      ..style = PaintingStyle.fill;
    
    canvas.drawRRect(rect, paint);
    
    final serverPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < 3; i++) {
      final serverRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center.translate(0, -15 + i * 15), 
          width: 45, 
          height: 8
        ),
        const Radius.circular(2),
      );
      canvas.drawRRect(serverRect, serverPaint);
    }
    
    canvas.restore();
    
    _drawLabel(canvas, 'EC2 Instance', center.translate(0, 40));
  }

  void _drawDockerContainers(Canvas canvas, Offset center) {
    final containerWidth = 40.0;  // Reduced from 50
    final containerHeight = 30.0;  // Reduced from 35
    final spacing = 15.0;  // Increased spacing
    
    final containers = [
      {'name': 'nginx', 'color': Colors.green},
      {'name': 'Flutter', 'color': Colors.blue},
      {'name': 'Spring', 'color': Colors.orange},
    ];
    
    for (int i = 0; i < containers.length; i++) {
      final offset = center.translate(
        -containerWidth - spacing + i * (containerWidth + spacing),
        0
      );
      
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: offset, width: containerWidth, height: containerHeight),
        const Radius.circular(4),
      );
      
      final paint = Paint()
        ..color = (containers[i]['color'] as Color).withOpacity(0.8)
        ..style = PaintingStyle.fill;
      
      canvas.drawRRect(rect, paint);
      
      _drawLabel(canvas, containers[i]['name'] as String, offset.translate(0, 25), fontSize: 9);
    }
    
    _drawLabel(canvas, 'Docker Containers', center.translate(0, 50));
  }

  void _drawConnections(Canvas canvas, List<Offset> positions) {
    final paint = Paint()
      ..color = AppTheme.awsOrange.withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    // Draw all static connections
    _drawLine(canvas, positions[0], positions[1], paint);
    _drawLine(canvas, positions[1], positions[2], paint);
    _drawLine(canvas, positions[2], positions[3], paint);
    
    // Split connections for ECR/IAM
    _drawLine(canvas, positions[3], Offset(positions[4].dx - 100, positions[4].dy), paint);
    _drawLine(canvas, positions[3], Offset(positions[4].dx + 100, positions[4].dy), paint);
    
    // Merge connections from ECR/IAM to EC2
    _drawLine(canvas, Offset(positions[4].dx - 100, positions[4].dy), positions[5], paint);
    _drawLine(canvas, Offset(positions[4].dx + 100, positions[4].dy), positions[5], paint);
    
    // EC2 to Containers
    _drawLine(canvas, positions[5], positions[6], paint);
  }

  void _drawLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    canvas.drawLine(
      Offset(start.dx, start.dy + 20),
      Offset(end.dx, end.dy - 20),
      paint,
    );
  }

  void _drawMovingDots(Canvas canvas, List<Offset> positions) {
    final dotPaint = Paint()
      ..color = AppTheme.awsOrange
      ..style = PaintingStyle.fill;
    
    // Calculate positions for moving dots based on flowProgress
    final paths = [
      [positions[0], positions[1]],
      [positions[1], positions[2]],
      [positions[2], positions[3]],
      [positions[3], Offset(positions[4].dx - 100, positions[4].dy)],
      [positions[3], Offset(positions[4].dx + 100, positions[4].dy)],
      [Offset(positions[4].dx - 100, positions[4].dy), positions[5]],
      [Offset(positions[4].dx + 100, positions[4].dy), positions[5]],
      [positions[5], positions[6]],
    ];
    
    for (int i = 0; i < paths.length; i++) {
      final progress = (flowProgress + i * 0.1) % 1.0;
      final start = paths[i][0];
      final end = paths[i][1];
      
      final x = start.dx + (end.dx - start.dx) * progress;
      final y = (start.dy + 20) + ((end.dy - 20) - (start.dy + 20)) * progress;
      
      canvas.drawCircle(Offset(x, y), 5, dotPaint);
    }
  }

  // Removed _drawConnection method - no longer needed as we're using dots instead of arrows

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

  void _drawLabels(Canvas canvas, List<Offset> positions) {
    final steps = [
      '1. Code Push',
      '2. Webhook',
      '3. CI/CD Trigger',
      '4. Build Image',
      '5. Push to ECR',
      '6. Deploy',
      '7. Run Services',
    ];
    
    for (int i = 0; i < steps.length && i < positions.length; i++) {
      final pos = Offset(40, positions[i].dy);
      
      // Step circle
      final circlePaint = Paint()
        ..color = AppTheme.awsOrange
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(pos, 15, circlePaint);
      
      // Step number
      final numberPainter = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      
      numberPainter.layout();
      numberPainter.paint(
        canvas,
        pos.translate(-numberPainter.width / 2, -numberPainter.height / 2),
      );
      
      // Step text
      _drawLabel(canvas, steps[i].substring(3), pos.translate(30, 0), fontSize: 14);
    }
  }

  @override
  bool shouldRepaint(CICDPainter oldDelegate) => true;
}