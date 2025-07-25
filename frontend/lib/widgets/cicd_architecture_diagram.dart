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
  late AnimationController _sequenceController;
  late AnimationController _pulseController;
  late Animation<double> _sequenceAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    // 순차적 애니메이션 컨트롤러 (8초 사이클: 6초 진행 + 2초 대기)
    _sequenceController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    
    _sequenceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sequenceController,
      curve: const Interval(0.0, 0.75, curve: Curves.easeInOut), // 75%만 애니메이션, 25% 대기
    ));
    
    // 애니메이션 반복
    _sequenceController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 100), () {
          _sequenceController.reset();
          _sequenceController.forward();
        });
      }
    });
    
    _sequenceController.forward();
    
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
    _sequenceController.dispose();
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
              animation: _sequenceAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: CICDPainter(
                    sequenceProgress: _sequenceAnimation.value,
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
  final double sequenceProgress;
  final Animation<double> pulseAnimation;

  CICDPainter({
    required this.sequenceProgress,
    required this.pulseAnimation,
  }) : super(repaint: pulseAnimation);

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final spacing = size.height / 7;  // 더 넓은 간격
    
    // 각 단계의 타이밍 (0.0 ~ 1.0)
    const stageCount = 7;
    const stageDuration = 1.0 / stageCount;
    
    // 각 단계별 진행도 계산
    double getStageOpacity(int stage) {
      final stageStart = stage * stageDuration;
      final stageEnd = stageStart + stageDuration;
      
      if (sequenceProgress < stageStart) return 0.0;
      if (sequenceProgress > stageEnd) return 1.0;
      
      return (sequenceProgress - stageStart) / stageDuration;
    }

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

    // 1. Developer
    _drawWithOpacity(canvas, () {
      _drawDeveloper(canvas, positions[0]);
    }, getStageOpacity(0));
    
    // 2. GitHub Repository
    _drawWithOpacity(canvas, () {
      _drawGitHub(canvas, positions[1]);
    }, getStageOpacity(1));
    
    // 3. GitHub Actions
    _drawWithOpacity(canvas, () {
      _drawGitHubActions(canvas, positions[2]);
    }, getStageOpacity(2));
    
    // 4. Docker Build
    _drawWithOpacity(canvas, () {
      _drawDockerBuild(canvas, positions[3]);
    }, getStageOpacity(3));
    
    // 5. AWS Services (ECR and IAM)
    _drawWithOpacity(canvas, () {
      _drawECR(canvas, Offset(centerX - 100, positions[4].dy));
      _drawIAM(canvas, Offset(centerX + 100, positions[4].dy));
    }, getStageOpacity(4));
    
    // 6. EC2 Instance
    _drawWithOpacity(canvas, () {
      _drawEC2(canvas, positions[5]);
    }, getStageOpacity(5));
    
    // 7. Docker Containers
    _drawWithOpacity(canvas, () {
      _drawDockerContainers(canvas, positions[6]);
    }, getStageOpacity(6));
    
    // Draw connections
    _drawSequentialConnections(canvas, positions, getStageOpacity);
    
    // Draw labels
    _drawLabels(canvas, positions);
  }

  void _drawWithOpacity(Canvas canvas, VoidCallback draw, double opacity) {
    if (opacity <= 0) return;
    
    final paint = Paint()
      ..color = Colors.white.withOpacity(opacity);
    
    canvas.saveLayer(null, paint);
    draw();
    canvas.restore();
  }

  void _drawDeveloper(Canvas canvas, Offset center) {
    final paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;
    
    // Developer icon
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
    
    canvas.drawCircle(center, 25, paint);
    
    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
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
    
    final whalePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final whaleBody = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 40, height: 25),
      const Radius.circular(10),
    );
    canvas.drawRRect(whaleBody, whalePaint);
    
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
    
    final iconPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final lockBody = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center.translate(0, 5), width: 20, height: 15),
      const Radius.circular(2),
    );
    canvas.drawRRect(lockBody, iconPaint);
    
    _drawLabel(canvas, 'IAM', center.translate(0, 35));
  }

  void _drawEC2(Canvas canvas, Offset center) {
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
    }
    
    canvas.restore();
    
    _drawLabel(canvas, 'EC2 Instance', center.translate(0, 55));
  }

  void _drawDockerContainers(Canvas canvas, Offset center) {
    final containerWidth = 80.0;
    final containerHeight = 60.0;
    final spacing = 15.0;
    
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
      
      _drawLabel(canvas, containers[i]['name'] as String, offset.translate(0, 25), fontSize: 10);
    }
    
    _drawLabel(canvas, 'Docker Containers', center.translate(0, 50));
  }

  void _drawSequentialConnections(Canvas canvas, List<Offset> positions, Function getStageOpacity) {
    // 연결선 정의
    final connections = [
      {'from': 0, 'to': 1, 'stage': 1},  // Developer to GitHub
      {'from': 1, 'to': 2, 'stage': 2},  // GitHub to Actions
      {'from': 2, 'to': 3, 'stage': 3},  // Actions to Docker
      {'from': 3, 'to': 4, 'stage': 4},  // Docker to ECR/IAM
      {'from': 4, 'to': 5, 'stage': 5},  // ECR/IAM to EC2
      {'from': 5, 'to': 6, 'stage': 6},  // EC2 to Containers
    ];
    
    for (final conn in connections) {
      final from = conn['from'] as int;
      final to = conn['to'] as int;
      final stage = conn['stage'] as int;
      final opacity = getStageOpacity(stage);
      
      if (opacity > 0) {
        // Special handling for split connections
        if (from == 3 && to == 4) {
          // Docker to ECR/IAM (split)
          _drawConnection(canvas, positions[from], Offset(positions[to].dx - 100, positions[to].dy), opacity);
          _drawConnection(canvas, positions[from], Offset(positions[to].dx + 100, positions[to].dy), opacity);
        } else if (from == 4 && to == 5) {
          // ECR/IAM to EC2 (merge)
          _drawConnection(canvas, Offset(positions[from].dx - 100, positions[from].dy), positions[to], opacity);
          _drawConnection(canvas, Offset(positions[from].dx + 100, positions[from].dy), positions[to], opacity);
        } else {
          _drawConnection(canvas, positions[from], positions[to], opacity);
        }
      }
    }
  }

  void _drawConnection(Canvas canvas, Offset start, Offset end, double opacity) {
    final path = Path()
      ..moveTo(start.dx, start.dy + 30)
      ..lineTo(end.dx, end.dy - 30);
    
    final paint = Paint()
      ..color = AppTheme.awsOrange.withOpacity(opacity)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    
    canvas.drawPath(path, paint);
    
    // Arrow
    if (opacity > 0.5) {
      final angle = math.atan2(end.dy - start.dy, end.dx - start.dx) + math.pi / 2;
      canvas.save();
      canvas.translate(end.dx, end.dy - 30);
      canvas.rotate(angle);
      
      final arrowPath = Path()
        ..moveTo(0, 0)
        ..lineTo(-5, -10)
        ..lineTo(5, -10)
        ..close();
      
      canvas.drawPath(arrowPath, Paint()
        ..color = AppTheme.awsOrange.withOpacity(opacity)
        ..style = PaintingStyle.fill);
      
      canvas.restore();
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