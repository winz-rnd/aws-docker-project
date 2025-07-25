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
    
    // 데이터 플로우 애니메이션
    _flowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _flowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _flowController,
      curve: Curves.easeInOut,
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
      height: 800,
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
            child: CustomPaint(
              painter: CICDPainter(
                flowAnimation: _flowAnimation,
                pulseAnimation: _pulseAnimation,
              ),
              child: Container(),
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
  final Animation<double> flowAnimation;
  final Animation<double> pulseAnimation;

  CICDPainter({
    required this.flowAnimation,
    required this.pulseAnimation,
  }) : super(repaint: Listenable.merge([flowAnimation, pulseAnimation]));

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final rowHeight = size.height / 8;

    // Vertical layout - top to bottom
    // 1. Developer
    _drawDeveloper(canvas, Offset(centerX, rowHeight * 0.8));
    
    // 2. GitHub Repository
    _drawGitHub(canvas, Offset(centerX, rowHeight * 1.8));
    
    // 3. GitHub Actions
    _drawGitHubActions(canvas, Offset(centerX, rowHeight * 2.8));
    
    // 4. Docker Build
    _drawDockerBuild(canvas, Offset(centerX, rowHeight * 3.8));
    
    // 5. AWS Services (ECR and IAM side by side)
    _drawECR(canvas, Offset(centerX - 80, rowHeight * 4.8));
    _drawIAM(canvas, Offset(centerX + 80, rowHeight * 4.8));
    
    // 6. EC2 Instance
    _drawEC2(canvas, Offset(centerX, rowHeight * 5.8));
    
    // 7. Docker Containers
    _drawDockerContainers(canvas, Offset(centerX, rowHeight * 6.8));
    
    // Draw connections with flow animation
    _drawAnimatedConnections(canvas, size);
    
    // Draw labels
    _drawLabels(canvas, size);
  }

  void _drawDeveloper(Canvas canvas, Offset center) {
    final paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;
    
    // Developer icon (simplified person)
    canvas.drawCircle(center.translate(0, -15), 10, paint);
    
    final path = Path()
      ..moveTo(center.dx - 15, center.dy)
      ..lineTo(center.dx - 5, center.dy - 10)
      ..lineTo(center.dx + 5, center.dy - 10)
      ..lineTo(center.dx + 15, center.dy)
      ..lineTo(center.dx + 10, center.dy + 15)
      ..lineTo(center.dx - 10, center.dy + 15)
      ..close();
    
    canvas.drawPath(path, paint);
    
    _drawLabel(canvas, 'Developer', center.translate(0, 35));
  }

  void _drawGitHub(Canvas canvas, Offset center) {
    final paint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;
    
    // GitHub logo (simplified)
    canvas.drawCircle(center, 25, paint);
    
    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    // Octocat shape (simplified)
    canvas.drawCircle(center, 18, whitePaint);
    
    _drawLabel(canvas, 'GitHub\nRepository', center.translate(0, 40));
  }

  void _drawGitHubActions(Canvas canvas, Offset center) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 80, height: 60),
      const Radius.circular(8),
    );
    
    final paint = Paint()
      ..color = AppTheme.awsOrange.withOpacity(0.9)
      ..style = PaintingStyle.fill;
    
    canvas.drawRRect(rect, paint);
    
    // Actions icon
    final iconPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawCircle(center.translate(-15, 0), 8, iconPaint);
    canvas.drawCircle(center.translate(0, 0), 8, iconPaint);
    canvas.drawCircle(center.translate(15, 0), 8, iconPaint);
    
    _drawLabel(canvas, 'GitHub\nActions', center.translate(0, 45));
  }

  void _drawDockerBuild(Canvas canvas, Offset center) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 100, height: 60),
      const Radius.circular(8),
    );
    
    final paint = Paint()
      ..color = Colors.blue[700]!
      ..style = PaintingStyle.fill;
    
    canvas.drawRRect(rect, paint);
    
    // Docker whale icon (simplified)
    final whalePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    // Whale body
    final whaleBody = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 40, height: 25),
      const Radius.circular(10),
    );
    canvas.drawRRect(whaleBody, whalePaint);
    
    // Containers on whale
    for (int i = 0; i < 3; i++) {
      final containerRect = Rect.fromLTWH(
        center.dx - 15 + i * 10,
        center.dy - 12,
        8,
        8,
      );
      canvas.drawRect(containerRect, Paint()..color = Colors.blue[700]!);
    }
    
    _drawLabel(canvas, 'Docker\nBuild', center.translate(0, 45));
  }

  void _drawECR(Canvas canvas, Offset center) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 70, height: 50),
      const Radius.circular(8),
    );
    
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    
    canvas.drawRRect(rect, paint);
    
    // Container icon
    final iconPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    final containerRect = Rect.fromCenter(center: center, width: 25, height: 30);
    canvas.drawRect(containerRect, iconPaint);
    
    _drawLabel(canvas, 'ECR', center.translate(0, 35));
  }

  void _drawIAM(Canvas canvas, Offset center) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 60, height: 50),
      const Radius.circular(8),
    );
    
    final paint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.fill;
    
    canvas.drawRRect(rect, paint);
    
    // Lock icon
    final iconPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final lockBody = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center.translate(0, 5), width: 20, height: 15),
      const Radius.circular(2),
    );
    canvas.drawRRect(lockBody, iconPaint);
    
    // Lock shackle
    final shacklePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    final shacklePath = Path()
      ..moveTo(center.dx - 7, center.dy - 2)
      ..lineTo(center.dx - 7, center.dy - 8)
      ..quadraticBezierTo(center.dx, center.dy - 15, center.dx + 7, center.dy - 8)
      ..lineTo(center.dx + 7, center.dy - 2);
    
    canvas.drawPath(shacklePath, shacklePaint);
    
    _drawLabel(canvas, 'IAM', center.translate(0, 35));
  }

  void _drawEC2(Canvas canvas, Offset center) {
    // Pulsing effect for EC2
    final scale = pulseAnimation.value;
    
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(scale);
    canvas.translate(-center.dx, -center.dy);
    
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 100, height: 80),
      const Radius.circular(12),
    );
    
    final paint = Paint()
      ..color = Colors.purple
      ..style = PaintingStyle.fill;
    
    canvas.drawRRect(rect, paint);
    
    // Server icon
    final serverPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < 3; i++) {
      final serverRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center.translate(0, -20 + i * 20), 
          width: 60, 
          height: 12
        ),
        const Radius.circular(2),
      );
      canvas.drawRRect(serverRect, serverPaint);
      
      // LED indicators
      final ledPaint = Paint()
        ..color = i == 0 ? Colors.green : Colors.orange
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        center.translate(-20, -20 + i * 20), 
        3, 
        ledPaint
      );
    }
    
    canvas.restore();
    
    _drawLabel(canvas, 'EC2 Instance', center.translate(0, 55));
  }

  void _drawDockerContainers(Canvas canvas, Offset center) {
    final containerWidth = 80.0;
    final containerHeight = 60.0;
    final spacing = 10.0;
    
    final containers = [
      {'name': 'nginx', 'color': Colors.green},
      {'name': 'Flutter', 'color': Colors.blue},
      {'name': 'Spring', 'color': Colors.orange},
    ];
    
    for (int i = 0; i < containers.length; i++) {
      final offset = center.translate(
        -containerWidth - spacing + i * (containerWidth / 2 + spacing / 2),
        0
      );
      
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: offset, width: containerWidth / 2, height: containerHeight / 2),
        const Radius.circular(4),
      );
      
      final paint = Paint()
        ..color = (containers[i]['color'] as Color).withOpacity(0.8)
        ..style = PaintingStyle.fill;
      
      canvas.drawRRect(rect, paint);
      
      // Docker logo
      final dockerPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      
      final logoSize = 15.0;
      final logoRect = Rect.fromCenter(center: offset, width: logoSize, height: logoSize * 0.8);
      canvas.drawRect(logoRect, dockerPaint);
      
      _drawLabel(canvas, containers[i]['name'] as String, offset.translate(0, 25), fontSize: 10);
    }
    
    _drawLabel(canvas, 'Docker Containers', center.translate(0, 50));
  }

  void _drawAnimatedConnections(Canvas canvas, Size size) {
    final dashPaint = Paint()
      ..color = AppTheme.awsOrange.withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    final animatedPaint = Paint()
      ..color = AppTheme.awsOrange
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    
    final centerX = size.width / 2;
    final rowHeight = size.height / 8;
    
    // Vertical connection paths
    final connections = [
      // Developer to GitHub
      [Offset(centerX, rowHeight * 1.1), Offset(centerX, rowHeight * 1.5)],
      // GitHub to Actions
      [Offset(centerX, rowHeight * 2.1), Offset(centerX, rowHeight * 2.5)],
      // Actions to Docker Build
      [Offset(centerX, rowHeight * 3.1), Offset(centerX, rowHeight * 3.5)],
      // Docker Build to ECR/IAM (split)
      [Offset(centerX, rowHeight * 4.1), Offset(centerX - 80, rowHeight * 4.5)],
      [Offset(centerX, rowHeight * 4.1), Offset(centerX + 80, rowHeight * 4.5)],
      // ECR/IAM to EC2 (merge)
      [Offset(centerX - 80, rowHeight * 5.1), Offset(centerX, rowHeight * 5.5)],
      [Offset(centerX + 80, rowHeight * 5.1), Offset(centerX, rowHeight * 5.5)],
      // EC2 to Containers
      [Offset(centerX, rowHeight * 6.1), Offset(centerX, rowHeight * 6.5)],
    ];
    
    for (final connection in connections) {
      final path = Path()
        ..moveTo(connection[0].dx, connection[0].dy)
        ..lineTo(connection[1].dx, connection[1].dy);
      
      // Draw dashed background
      _drawDashedPath(canvas, path, dashPaint);
      
      // Draw animated flow
      final progress = flowAnimation.value;
      final metrics = path.computeMetrics().first;
      final extractPath = metrics.extractPath(0, metrics.length * progress);
      
      canvas.drawPath(extractPath, animatedPaint);
      
      // Draw arrow at the end of animated path
      if (progress > 0.1) {
        final tangent = metrics.getTangentForOffset(metrics.length * progress);
        if (tangent != null) {
          _drawArrow(canvas, tangent.position, tangent.angle, animatedPaint);
        }
      }
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final dashWidth = 5.0;
    final dashSpace = 5.0;
    final metrics = path.computeMetrics();
    
    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final extractPath = metric.extractPath(distance, distance + dashWidth);
        canvas.drawPath(extractPath, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  void _drawArrow(Canvas canvas, Offset position, double angle, Paint paint) {
    final arrowSize = 10.0;
    final arrowPath = Path()
      ..moveTo(0, -arrowSize / 2)
      ..lineTo(arrowSize, 0)
      ..lineTo(0, arrowSize / 2);
    
    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(angle);
    canvas.drawPath(arrowPath, paint);
    canvas.restore();
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
    final centerX = size.width / 2;
    final rowHeight = size.height / 8;
    
    // Step labels for vertical layout
    final steps = [
      {'pos': Offset(40, rowHeight * 0.8), 'text': '1. Code Push'},
      {'pos': Offset(40, rowHeight * 2.8), 'text': '2. Trigger CI/CD'},
      {'pos': Offset(40, rowHeight * 3.8), 'text': '3. Build Image'},
      {'pos': Offset(40, rowHeight * 4.8), 'text': '4. Push to ECR'},
      {'pos': Offset(40, rowHeight * 5.8), 'text': '5. Deploy to EC2'},
      {'pos': Offset(40, rowHeight * 6.8), 'text': '6. Run Containers'},
    ];
    
    final stepPaint = Paint()
      ..color = AppTheme.awsDeepBlue
      ..style = PaintingStyle.fill;
    
    for (final step in steps) {
      final pos = step['pos'] as Offset;
      final text = step['text'] as String;
      
      // Step number background
      final circlePaint = Paint()
        ..color = AppTheme.awsOrange
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(pos, 15, circlePaint);
      
      // Step number
      final numberPainter = TextPainter(
        text: TextSpan(
          text: text.substring(0, 1),
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
      _drawLabel(canvas, text.substring(3), pos.translate(30, 0), fontSize: 14);
    }
  }

  @override
  bool shouldRepaint(CICDPainter oldDelegate) => true;
}