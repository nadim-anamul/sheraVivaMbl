import 'package:flutter/material.dart';
import '../../../../shared/presentation/widgets/waveform_painter.dart';
import '../../../live_viva/data/livekit_placeholder_gateway.dart';
import '../../../live_viva/presentation/services/permission_preflight_service.dart';

class AIConversationPage extends StatefulWidget {
  const AIConversationPage({super.key});

  @override
  State<AIConversationPage> createState() => _AIConversationPageState();
}

class _AIConversationPageState extends State<AIConversationPage> {
  final _permissions = const PermissionPreflightService();
  final _gateway = LiveKitPlaceholderGateway();
  bool _starting = false;
  bool _isActive = false;
  bool _isMuted = false;
  bool _isSpeakerOn = true;

  // Mock dialogue logs for high fidelity simulation
  final List<Map<String, String>> _mockChat = [
    {
      'role': 'AI',
      'message': 'আসসালামু আলাইকুম। সেরা ভিভা এআই ইন্টারভিউ সেশনে আপনাকে স্বাগতম। আমি আপনার ভাইভা গ্রহণ করব।'
    },
    {
      'role': 'AI',
      'message': 'আপনার প্রথম পছন্দ প্রশাসন ক্যাডার। মাঠ প্রশাসনে একজন সহকারী কমিশনার ও নির্বাহী ম্যাজিস্ট্রেটের প্রধান কার্যাবলি কী কী?'
    },
    {
      'role': 'User',
      'message': 'ধন্যবাদ স্যার। মাঠ প্রশাসনে প্রধান কাজ হলো মোবাইল কোর্ট পরিচালনা করা, আইন-শৃঙ্খলা রক্ষা করা এবং রাজস্ব আদায় তদারকি করা...'
    },
    {
      'role': 'AI',
      'message': 'চমৎকার। নির্বাহী বিভাগ ও বিচার বিভাগ পৃথকীকরণের পর ম্যাজিস্ট্রেসির বর্তমান অবস্থা কী?'
    }
  ];

  Future<void> _startConversation() async {
    setState(() => _starting = true);
    final granted = await _permissions.ensureCameraAndMicrophoneGranted();
    if (!granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.white),
                SizedBox(width: 8),
                Expanded(child: Text('এআই কনভারসেশনের জন্য মাইক ও ক্যামেরা অনুমতি প্রয়োজন')),
              ],
            ),
            backgroundColor: Color(0xFFDC2626),
          ),
        );
      }
      setState(() => _starting = false);
      return;
    }

    await _gateway.joinRoom(roomName: 'ai-viva-room', token: 'mock-token');

    if (mounted) {
      setState(() {
        _isActive = true;
        _starting = false;
      });
    }
  }

  void _endConversation() {
    _gateway.leaveRoom();
    setState(() {
      _isActive = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ভাইভা সেশনটি সফলভাবে সংরক্ষণ করা হয়েছে'),
        backgroundColor: Color(0xFF0F766E),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI Mock Interview',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: _isActive 
            ? [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'REC 04:15',
                            style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ]
            : null,
      ),
      body: _isActive ? _buildActiveSession() : _buildSetupScreen(),
    );
  }

  // State 1: Active Interactive Mock Session Screen
  Widget _buildActiveSession() {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: Column(
        children: <Widget>[
          // Interviewer Profile banner
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                // Glowing Robot Interviewer Avatar
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F766E), Color(0xFF2DD4BF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F766E).withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.smart_toy_outlined,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'বিসিএস এআই ভাইভা বোর্ড',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'টপিক: প্রশাসন ক্যাডার (মাঠ প্রশাসন)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Dialogue scroll area
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(18),
              itemCount: _mockChat.length,
              itemBuilder: (context, index) {
                final chat = _mockChat[index];
                final isAI = chat['role'] == 'AI';
                
                return Align(
                  alignment: isAI ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: isAI ? Colors.white : const Color(0xFF0F766E),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: isAI ? const Radius.circular(0) : const Radius.circular(16),
                        bottomRight: isAI ? const Radius.circular(16) : const Radius.circular(0),
                      ),
                      border: isAI ? Border.all(color: const Color(0xFFE2E8F0)) : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.015),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Text(
                      chat['message']!,
                      style: TextStyle(
                        fontSize: 14,
                        color: isAI ? const Color(0xFF334155) : Colors.white,
                        height: 1.45,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Speech Waveform Display
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                // Animated Waveform
                WaveformVisualizer(
                  isActive: !_isMuted,
                  color: const Color(0xFF0F766E),
                ),
                const SizedBox(height: 12),
                
                Text(
                  _isMuted ? 'আপনার মাইক্রোফোন বন্ধ রয়েছে' : 'এআই ইন্টারভিউয়ার আপনার কথা শুনছে...',
                  style: TextStyle(
                    fontSize: 12,
                    color: _isMuted ? Colors.red : const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Action Toolbar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Mute control
                    IconButton(
                      icon: Icon(_isMuted ? Icons.mic_off_rounded : Icons.mic_rounded),
                      onPressed: () => setState(() => _isMuted = !_isMuted),
                      style: IconButton.styleFrom(
                        backgroundColor: _isMuted ? Colors.red.withOpacity(0.1) : const Color(0xFFF1F5F9),
                        foregroundColor: _isMuted ? Colors.red : const Color(0xFF475569),
                        padding: const EdgeInsets.all(14),
                      ),
                    ),
                    
                    // Main Crimson Hangup
                    ElevatedButton.icon(
                      onPressed: _endConversation,
                      icon: const Icon(Icons.call_end_rounded, color: Colors.white),
                      label: const Text(
                        'ভাইভা শেষ করুন',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626), // crimson
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    
                    // Speaker control
                    IconButton(
                      icon: Icon(_isSpeakerOn ? Icons.volume_up_rounded : Icons.volume_off_rounded),
                      onPressed: () => setState(() => _isSpeakerOn = !_isSpeakerOn),
                      style: IconButton.styleFrom(
                        backgroundColor: _isSpeakerOn ? const Color(0xFF0F766E).withOpacity(0.1) : const Color(0xFFF1F5F9),
                        foregroundColor: _isSpeakerOn ? const Color(0xFF0F766E) : const Color(0xFF475569),
                        padding: const EdgeInsets.all(14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // State 2: Welcome / Configuration screen
  Widget _buildSetupScreen() {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Big Robot Icon
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F766E).withOpacity(0.08),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF0F766E).withOpacity(0.15), width: 3),
                  ),
                  padding: const EdgeInsets.all(28),
                  child: const Icon(
                    Icons.psychology_outlined,
                    size: 80,
                    color: Color(0xFF0F766E),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              const Text(
                'এআই কথোপকথন মডিউল',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 10),
              
              const Text(
                'বাস্তব ভাইভা বোর্ডের আদলে কৃত্রিম বুদ্ধিমত্তার মাধ্যমে আপনার ক্যাডার সম্পর্কিত বিষয়ের উপর ভাইভা দিতে পারবেন। ভয়েস ও টেক্সট অর্কেস্ট্রেশন স্বয়ংক্রিয়ভাবে পরিচালিত হবে।',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 36),

              // Features grid list
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: const [
                    _InstructionRow(icon: Icons.check_circle_outline, text: 'রিয়েল-টাইম ভয়েস ও পজ অ্যানালাইসিস'),
                    Divider(height: 20),
                    _InstructionRow(icon: Icons.check_circle_outline, text: 'ক্যাডার পছন্দভিত্তিক স্বয়ংক্রিয় প্রশ্ন সাজেশান'),
                    Divider(height: 20),
                    _InstructionRow(icon: Icons.check_circle_outline, text: 'সেশন শেষে বিস্তারিত স্কোর ও সংশোধন রিপোর্ট'),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              
              // Start Button
              FilledButton.icon(
                onPressed: _starting ? null : _startConversation,
                icon: _starting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.record_voice_over_outlined),
                label: const Text(
                  'AI ভাইভা শুরু করুন',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InstructionRow extends StatelessWidget {
  const _InstructionRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF0F766E), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF334155),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
