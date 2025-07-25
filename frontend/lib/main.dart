import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'theme/app_theme.dart';
import 'widgets/system_status_card.dart';
import 'widgets/aws_architecture_diagram.dart';
import 'widgets/cicd_architecture_diagram.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AWS Docker Demo',
      theme: AppTheme.lightTheme,
      home: const MyHomePage(title: 'AWS Full Stack Demo'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  String _message = 'Ready to connect';
  bool _isLoading = false;
  final TextEditingController _textController = TextEditingController();
  
  // 시스템 상태
  bool _apiConnected = false;
  bool _dbConnected = false;
  String _apiStatus = 'Checking...';
  String _dbStatus = 'Checking...';
  String _lastApiResponse = '';
  
  // 애니메이션
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  // 주기적 상태 확인
  Timer? _statusTimer;
  
  // API base URL
  String get apiBaseUrl => '/api';

  @override
  void initState() {
    super.initState();
    
    // 애니메이션 초기화
    _fadeController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();
    
    // 초기 상태 확인
    _checkSystemStatus();
    
    // 3초마다 상태 확인
    _statusTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkSystemStatus();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _statusTimer?.cancel();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _checkSystemStatus() async {
    try {
      // API 헬스체크
      final healthResponse = await http
          .get(Uri.parse('$apiBaseUrl/health'))
          .timeout(const Duration(seconds: 2));
      
      setState(() {
        _apiConnected = healthResponse.statusCode == 200;
        _apiStatus = _apiConnected ? 'Connected' : 'Disconnected';
        
        // DB 상태는 헬스체크 응답에서 확인
        if (_apiConnected && healthResponse.body.contains('UP')) {
          _dbConnected = true;
          _dbStatus = 'Connected';
        } else {
          _dbConnected = false;
          _dbStatus = 'Disconnected';
        }
      });
    } catch (e) {
      setState(() {
        _apiConnected = false;
        _dbConnected = false;
        _apiStatus = 'Connection Error';
        _dbStatus = 'N/A';
      });
    }
  }

  Future<void> _fetchMessage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/message'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _message = data['content'] ?? 'No content found';
          _lastApiResponse = 'GET /api/message → 200 OK';
        });
      } else {
        setState(() {
          _message = 'Error: ${response.statusCode}';
          _lastApiResponse = 'GET /api/message → ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Connection failed: ${e.toString()}';
        _lastApiResponse = 'GET /api/message → Failed';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _setMessage() async {
    if (_textController.text.trim().isEmpty) {
      setState(() {
        _message = 'Please enter a message';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/message'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'content': _textController.text.trim()}),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _message = 'Saved: ${data['content']}';
          _lastApiResponse = 'POST /api/message → 200 OK';
          _textController.clear();
        });
      } else {
        setState(() {
          _message = 'Save failed: ${response.statusCode}';
          _lastApiResponse = 'POST /api/message → ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Connection failed: ${e.toString()}';
        _lastApiResponse = 'POST /api/message → Failed';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.gradientBackground,
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  expandedHeight: 120,
                  floating: false,
                  pinned: true,
                  backgroundColor: AppTheme.awsDeepBlue,
                  flexibleSpace: FlexibleSpaceBar(
                    title: AnimatedTextKit(
                      animatedTexts: [
                        TypewriterAnimatedText(
                          'AWS Full Stack Demo',
                          textStyle: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          speed: const Duration(milliseconds: 100),
                        ),
                      ],
                      totalRepeatCount: 1,
                    ),
                    centerTitle: true,
                  ),
                ),
                
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // 시스템 상태 카드들
                      Row(
                        children: [
                          Expanded(
                            child: SystemStatusCard(
                              title: 'API Server',
                              status: _apiStatus,
                              isConnected: _apiConnected,
                              icon: Icons.api,
                              details: 'Spring Boot on EC2',
                              onRefresh: _checkSystemStatus,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SystemStatusCard(
                              title: 'Database',
                              status: _dbStatus,
                              isConnected: _dbConnected,
                              icon: Icons.storage,
                              details: 'MySQL 8.0',
                              onRefresh: _checkSystemStatus,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // AWS 아키텍처 다이어그램
                      Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const AwsArchitectureDiagram(),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // CI/CD 파이프라인 다이어그램
                      Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const CICDArchitectureDiagram(),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // 메시지 관리 섹션
                      Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          decoration: AppTheme.cardGradient,
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.message,
                                    color: AppTheme.awsOrange,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Message Manager',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.awsDeepBlue,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              
                              // 현재 메시지
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppTheme.awsLightGray,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppTheme.awsGray.withOpacity(0.3),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Current Message:',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppTheme.awsGray,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _message,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    if (_lastApiResponse.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        _lastApiResponse,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.awsGray,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // 버튼들
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: _isLoading || !_apiConnected 
                                        ? null 
                                        : _fetchMessage,
                                    icon: _isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Icon(Icons.download),
                                    label: const Text('Get Message'),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 20),
                              const Divider(),
                              const SizedBox(height: 20),
                              
                              // 새 메시지 입력
                              const Text(
                                'Save New Message:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.awsDeepBlue,
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _textController,
                                decoration: InputDecoration(
                                  labelText: 'Enter your message',
                                  hintText: 'Type a message to save...',
                                  prefixIcon: const Icon(
                                    Icons.edit,
                                    color: AppTheme.awsOrange,
                                  ),
                                  suffixIcon: _textController.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear),
                                          onPressed: () {
                                            setState(() {
                                              _textController.clear();
                                            });
                                          },
                                        )
                                      : null,
                                ),
                                maxLines: 2,
                                onChanged: (value) {
                                  setState(() {});
                                },
                              ),
                              const SizedBox(height: 16),
                              Center(
                                child: ElevatedButton.icon(
                                  onPressed: _isLoading || !_apiConnected
                                      ? null
                                      : _setMessage,
                                  icon: const Icon(Icons.save),
                                  label: const Text('Save Message'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.successGreen,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Footer
                      Center(
                        child: Text(
                          'Powered by AWS EC2 • Docker • GitHub Actions',
                          style: TextStyle(
                            color: AppTheme.awsGray,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}