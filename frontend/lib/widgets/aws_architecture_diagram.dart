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
      height: 400,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'AWS Architecture Flow',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.awsDeepBlue,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // 연결선
                    CustomPaint(
                      size: Size(constraints.maxWidth, constraints.maxHeight),
                      painter: ConnectionPainter(
                        flowAnimation: _flowAnimation,
                      ),
                    ),
                    // 컴포넌트들
                    Positioned(
                      left: 20,
                      top: constraints.maxHeight / 2 - 40,
                      child: _buildComponent(
                        'Flutter\nWeb',
                        Icons.web,
                        AppTheme.awsLightBlue,
                        'Frontend running on your browser',
                      ),
                    ),
                    Positioned(
                      left: constraints.maxWidth * 0.3 - 40,
                      top: constraints.maxHeight / 2 - 40,
                      child: _buildComponent(
                        'nginx',
                        Icons.router,
                        AppTheme.awsOrange,
                        'Reverse proxy server',
                      ),
                    ),
                    Positioned(
                      right: constraints.maxWidth * 0.3 - 40,
                      top: constraints.maxHeight / 2 - 40,
                      child: _buildComponent(
                        'Spring\nBoot',
                        Icons.api,
                        AppTheme.successGreen,
                        'REST API Server',
                      ),
                    ),
                    Positioned(
                      right: 20,
                      top: constraints.maxHeight / 2 - 40,
                      child: _buildComponent(
                        'MySQL',
                        Icons.storage,
                        AppTheme.awsDeepBlue,
                        'Database',
                      ),
                    ),
                    // EC2 컨테이너
                    Positioned(
                      bottom: 20,
                      left: constraints.maxWidth / 2 - 60,
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.awsOrange,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.awsOrange.withOpacity(0.3),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Text(
                                'AWS EC2',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComponent(
    String label,
    IconData icon,
    Color color,
    String tooltip,
  ) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(tooltip),
              duration: const Duration(seconds: 2),
              backgroundColor: color,
            ),
          );
        },
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ConnectionPainter extends CustomPainter {
  final Animation<double> flowAnimation;

  ConnectionPainter({required this.flowAnimation}) : super(repaint: flowAnimation);

  @override
  void paint(Canvas canvas, Size size) {

    final dashPaint = Paint()
      ..color = AppTheme.awsOrange.withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // 연결선 경로
    final path = Path();
    final y = size.height / 2;
    
    // Flutter -> nginx
    path.moveTo(100, y);
    path.lineTo(size.width * 0.3, y);
    
    // nginx -> Spring Boot
    path.moveTo(size.width * 0.3 + 40, y);
    path.lineTo(size.width * 0.7 - 40, y);
    
    // Spring Boot -> MySQL
    path.moveTo(size.width * 0.7 + 40, y);
    path.lineTo(size.width - 100, y);

    // 점선 그리기
    _drawDashedPath(canvas, path, dashPaint);
    
    // 애니메이션 점 그리기
    final dotPaint = Paint()
      ..color = AppTheme.awsOrange
      ..style = PaintingStyle.fill;

    // 각 연결선에 움직이는 점 그리기
    final progress = flowAnimation.value;
    
    // Flutter -> nginx
    final x1 = 100 + (size.width * 0.3 - 100) * progress;
    canvas.drawCircle(Offset(x1, y), 5, dotPaint);
    
    // nginx -> Spring Boot
    final x2 = (size.width * 0.3 + 40) + 
               (size.width * 0.7 - 40 - size.width * 0.3 - 40) * progress;
    canvas.drawCircle(Offset(x2, y), 5, dotPaint);
    
    // Spring Boot -> MySQL
    final x3 = (size.width * 0.7 + 40) + 
               (size.width - 100 - size.width * 0.7 - 40) * progress;
    canvas.drawCircle(Offset(x3, y), 5, dotPaint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final dashWidth = 10.0;
    final dashSpace = 5.0;
    final pathMetrics = path.computeMetrics();
    
    for (final metric in pathMetrics) {
      double distance = 0.0;
      
      while (distance < metric.length) {
        final start = distance;
        final end = math.min(distance + dashWidth, metric.length);
        
        final extractPath = metric.extractPath(start, end);
        canvas.drawPath(extractPath, paint);
        
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}