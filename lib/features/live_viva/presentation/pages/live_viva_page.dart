import 'dart:async';
import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/livekit_placeholder_gateway.dart';
import '../../data/livekit_service.dart';
import '../services/permission_preflight_service.dart';

class LiveVivaPage extends StatefulWidget {
  const LiveVivaPage({super.key});

  @override
  State<LiveVivaPage> createState() => _LiveVivaPageState();
}

class _LiveVivaPageState extends State<LiveVivaPage> {
  final _permissions = const PermissionPreflightService();
  final _gateway = LiveKitPlaceholderGateway();
  LiveKitService? _gatewayRealService;

  bool _joining = false;
  bool _isActive = false;
  bool _isMuted = false;
  bool _isCameraOn = true;
  bool _isSpeakerOn = true;
  
  int _callDuration = 0;
  Timer? _timer;
  
  // Developer Sandbox Settings
  final _serverUrlController = TextEditingController();
  final _tokenController = TextEditingController();
  bool _useLiveKitCloud = false;
  String _liveKitStatus = '';

  VideoTrack? _localVideoTrack;
  VideoTrack? _remoteVideoTrack;
  bool _isRealSpeaking = false;

  // High fidelity interview stages simulation
  int _currentSubtitleIndex = 0;
  final List<String> _mockSubtitles = [
    'নমস্কার। সেরা ভাইভা লাইভ মডিউলে আপনাকে স্বাগত।',
    'আপনার বায়োডাটা দেখছি। বিসিএস পুলিশ ক্যাডার প্রথম পছন্দ দেওয়ার কারণ কী?',
    'পুলিশে যোগ দিলে মাঠ পর্যায়ে দুর্নীতি রোধে আপনার প্রথম ৩টি পদক্ষেপ কী হবে?',
    'চমৎকার! বর্তমান সাইবার অপরাধ দমনে বিসিএস পুলিশ ক্যাডার কীভাবে ভূমিকা রাখতে পারে?',
    'ধন্যবাদ। আপনার ভাইভা শেষ হলো। আমরা ফলাফল ড্যাশবোর্ডে পাঠিয়ে দিচ্ছি।'
  ];
  Timer? _subtitleTimer;

  @override
  void initState() {
    super.initState();
    _loadDeveloperSettings();
  }

  Future<void> _loadDeveloperSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Read from compile-time environment variables (passed via --dart-define)
    const envUrl = String.fromEnvironment('LIVEKIT_URL');
    const envToken = String.fromEnvironment('LIVEKIT_TOKEN');

    setState(() {
      final savedUrl = prefs.getString('livekit_server_url') ?? '';
      _serverUrlController.text = savedUrl.isNotEmpty ? savedUrl : envUrl;

      final savedToken = prefs.getString('livekit_token') ?? '';
      _tokenController.text = savedToken.isNotEmpty ? savedToken : envToken;

      _useLiveKitCloud = prefs.getBool('livekit_use_cloud') ?? 
          (_serverUrlController.text.isNotEmpty && _tokenController.text.isNotEmpty);
    });
  }

  Future<void> _saveDeveloperSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('livekit_server_url', _serverUrlController.text.trim());
    await prefs.setString('livekit_token', _tokenController.text.trim());
    await prefs.setBool('livekit_use_cloud', _useLiveKitCloud);
  }

  void _showDeveloperSettingsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 32,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.settings_suggest_rounded, color: Color(0xFF0F766E), size: 24),
                          SizedBox(width: 8),
                          Text(
                            'লাইভকিট ক্লাউড সেটিংস (Sandbox)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text(
                      'লাইভকিট ক্লাউড সক্রিয় করুন',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                    ),
                    subtitle: const Text(
                      'নিষ্ক্রিয় থাকলে ডেমো সিমুলেশন মোড চালু থাকবে।',
                      style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                    activeColor: const Color(0xFF0F766E),
                    value: _useLiveKitCloud,
                    onChanged: (val) {
                      setModalState(() {
                        _useLiveKitCloud = val;
                      });
                      setState(() {
                        _useLiveKitCloud = val;
                      });
                      _saveDeveloperSettings();
                    },
                  ),
                  if (_useLiveKitCloud) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: _serverUrlController,
                      decoration: InputDecoration(
                        labelText: 'LiveKit Server URL',
                        hintText: 'wss://your-project.livekit.cloud',
                        labelStyle: const TextStyle(fontSize: 13),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.link_rounded),
                      ),
                      onChanged: (val) {
                        _saveDeveloperSettings();
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _tokenController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Access Token',
                        hintText: 'Paste generated LiveKit token here...',
                        labelStyle: const TextStyle(fontSize: 13),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.key_rounded),
                      ),
                      onChanged: (val) {
                        _saveDeveloperSettings();
                      },
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF0F766E),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.save_rounded),
                    label: const Text('সংরক্ষণ করুন ও বন্ধ করুন', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () {
                      _saveDeveloperSettings();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('সেটিংস সফলভাবে সংরক্ষিত হয়েছে'),
                          backgroundColor: Color(0xFF0F766E),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _joinSession() async {
    setState(() {
      _joining = true;
      _liveKitStatus = '';
    });
    
    final granted = await _permissions.ensureCameraAndMicrophoneGranted();
    if (!granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.white),
                SizedBox(width: 8),
                Expanded(child: Text('লাইভ ভাইভা সেশনের জন্য ক্যামেরা ও মাইক্রোফোন অনুমতি প্রয়োজন')),
              ],
            ),
            backgroundColor: Color(0xFFDC2626),
          ),
        );
      }
      setState(() => _joining = false);
      return;
    }

    if (_useLiveKitCloud && _serverUrlController.text.isNotEmpty && _tokenController.text.isNotEmpty) {
      final realService = LiveKitService();
      
      realService.onStatusChanged = (status) {
        if (mounted) {
          setState(() {
            _liveKitStatus = status;
          });
        }
      };

      realService.onTracksChanged = (local, remote) {
        if (mounted) {
          setState(() {
            _localVideoTrack = local;
            _remoteVideoTrack = remote;
          });
        }
      };

      realService.onInterviewerSpeakingChanged = (isSpeaking) {
        if (mounted) {
          setState(() {
            _isRealSpeaking = isSpeaking;
          });
        }
      };

      try {
        await realService.joinRealRoom(
          serverUrl: _serverUrlController.text.trim(),
          token: _tokenController.text.trim(),
        );

        if (mounted) {
          setState(() {
            _isActive = true;
            _joining = false;
            _callDuration = 0;
            _gatewayRealService = realService;
          });
          _startTimers();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('লাইভকিট কানেকশন ব্যর্থ হয়েছে: $e'),
              backgroundColor: const Color(0xFFDC2626),
            ),
          );
          setState(() => _joining = false);
        }
        return;
      }
    } else {
      _gatewayRealService = null;
      await _gateway.joinRoom(roomName: 'mock-viva-room', token: 'mock-token');

      if (mounted) {
        setState(() {
          _isActive = true;
          _joining = false;
          _callDuration = 0;
          _currentSubtitleIndex = 0;
        });
        _startTimers();
      }
    }
  }

  void _startTimers() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _callDuration++;
        });
      }
    });

    if (_gatewayRealService == null) {
      _subtitleTimer?.cancel();
      _subtitleTimer = Timer.periodic(const Duration(seconds: 12), (timer) {
        if (mounted) {
          setState(() {
            if (_currentSubtitleIndex < _mockSubtitles.length - 1) {
              _currentSubtitleIndex++;
            } else {
              _subtitleTimer?.cancel();
            }
          });
        }
      });
    }
  }

  void _leaveSession() {
    _timer?.cancel();
    _subtitleTimer?.cancel();
    
    if (_gatewayRealService != null) {
      _gatewayRealService!.leaveRoom();
    } else {
      _gateway.leaveRoom();
    }
    
    setState(() {
      _isActive = false;
      _localVideoTrack = null;
      _remoteVideoTrack = null;
      _liveKitStatus = '';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('লাইভ ভাইভা সেশনটি সফলভাবে সম্পন্ন হয়েছে'),
        backgroundColor: Color(0xFF0F766E),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _subtitleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isActive ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: _isActive
          ? null // Full screen experience during call
          : AppBar(
              backgroundColor: const Color(0xFFF8FAFC),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFF1E293B), size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: const Text(
                'Live Video Viva',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                  fontSize: 18,
                ),
              ),
              actions: [
                if (!_isActive)
                  IconButton(
                    icon: const Icon(Icons.settings_suggest_rounded, color: Color(0xFF0F766E), size: 22),
                    tooltip: 'Developer Settings',
                    onPressed: _showDeveloperSettingsModal,
                  ),
                const SizedBox(width: 8),
              ],
              shape: const Border(
                bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1),
              ),
            ),
      body: _isActive ? _buildActiveCallScreen() : _buildPreflightScreen(),
    );
  }

  // State 1: Active Video Call Screen
  Widget _buildActiveCallScreen() {
    final timeStr = _formatDuration(_callDuration);
    final isInterviewerSpeaking = _callDuration % 10 < 6; // Mock speaking pattern

    return SafeArea(
      child: Stack(
        children: [
          // 1. Interviewer View (Takes full screen as primary focus)
          Positioned.fill(
            child: _remoteVideoTrack != null
                ? VideoTrackRenderer(
                    _remoteVideoTrack!,
                    fit: VideoViewFit.cover,
                  )
                : _buildInterviewerView(
                    _gatewayRealService != null ? _isRealSpeaking : isInterviewerSpeaking,
                  ),
          ),

          // 2. Gradient overlays for better UI visibility
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Container(
                  height: 160,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Top Status Row (Time, Board Name, Connection Quality)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Call details card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981), // Emerald green
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'লাইভ বোর্ড #১ • $timeStr',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Live indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'LIVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 4. Picture-in-Picture Local User Video Card
          Positioned(
            right: 16,
            bottom: 120,
            width: 110,
            height: 160,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white30, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  children: [
                    if (_isCameraOn)
                      _localVideoTrack != null
                          ? VideoTrackRenderer(
                              _localVideoTrack!,
                              fit: VideoViewFit.cover,
                              mirrorMode: VideoViewMirrorMode.mirror,
                            )
                          : Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFF334155), Color(0xFF0F172A)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.person_rounded, color: Colors.white70, size: 40),
                                    const SizedBox(height: 8),
                                    // Pulse microphone level indicator
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: List.generate(3, (index) {
                                        final isActive = !_isMuted && (_callDuration % 3 == index);
                                        return AnimatedContainer(
                                          duration: const Duration(milliseconds: 250),
                                          width: 3,
                                          height: isActive ? 12.0 : 4.0,
                                          margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                          decoration: BoxDecoration(
                                            color: isActive ? const Color(0xFF2DD4BF) : Colors.white24,
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                              ),
                            )
                    else
                      Container(
                        color: Colors.black54,
                        child: const Center(
                          child: Icon(Icons.videocam_off_rounded, color: Colors.white38, size: 24),
                        ),
                      ),
                    
                    // User Label
                    Positioned(
                      bottom: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'আপনি',
                          style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 5. Real-time Dialogue Subtitles Card
          Positioned(
            left: 16,
            right: 16,
            bottom: 120,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 150), // leave room for PiP
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: (_gatewayRealService != null ? _isRealSpeaking : isInterviewerSpeaking)
                                ? const Color(0xFF2DD4BF)
                                : Colors.white30,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _gatewayRealService != null
                              ? (_isRealSpeaking ? 'পরীক্ষক (কথা বলছেন)' : 'পরীক্ষক (নীরব)')
                              : (isInterviewerSpeaking ? 'বোর্ড চেয়ারম্যান (কথা বলছেন)' : 'বোর্ড চেয়ারম্যান (নীরব)'),
                          style: TextStyle(
                            color: (_gatewayRealService != null ? _isRealSpeaking : isInterviewerSpeaking)
                                ? const Color(0xFF2DD4BF)
                                : Colors.white30,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _gatewayRealService != null
                          ? (_isRealSpeaking 
                              ? '📢 পরীক্ষক কথা বলছেন... দয়া করে মনোযোগ দিয়ে শুনুন ও উত্তর দিন।' 
                              : '💤 লাইভকিট কানেকশন সক্রিয়। পরীক্ষকের কথা শোনার জন্য অপেক্ষা করুন...')
                          : _mockSubtitles[_currentSubtitleIndex],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12.5,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 6. Immersive Toolbar Controls Overlay
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B).withOpacity(0.85),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Mute Button
                  _buildCallControl(
                    icon: _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                    isActive: !_isMuted,
                    activeColor: const Color(0xFF334155),
                    inactiveColor: const Color(0xFFDC2626),
                    label: _isMuted ? 'আনমিউট' : 'মিউট',
                    onPressed: () {
                      final muteState = !_isMuted;
                      setState(() => _isMuted = muteState);
                      if (_gatewayRealService != null) {
                        _gatewayRealService!.toggleMicrophone(!muteState);
                      } else {
                        _gateway.toggleMicrophone(!muteState);
                      }
                    },
                  ),

                  // Camera Toggle
                  _buildCallControl(
                    icon: _isCameraOn ? Icons.videocam_rounded : Icons.videocam_off_rounded,
                    isActive: _isCameraOn,
                    activeColor: const Color(0xFF334155),
                    inactiveColor: const Color(0xFF64748B),
                    label: _isCameraOn ? 'ক্যাম অফ' : 'ক্যাম অন',
                    onPressed: () {
                      final camState = !_isCameraOn;
                      setState(() => _isCameraOn = camState);
                      if (_gatewayRealService != null) {
                        _gatewayRealService!.toggleCamera(camState);
                      } else {
                        _gateway.toggleCamera(camState);
                      }
                    },
                  ),

                  // Audio Route Toggle
                  _buildCallControl(
                    icon: _isSpeakerOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                    isActive: _isSpeakerOn,
                    activeColor: const Color(0xFF334155),
                    inactiveColor: const Color(0xFF64748B),
                    label: _isSpeakerOn ? 'স্পিকার' : 'ইয়ারপিস',
                    onPressed: () => setState(() => _isSpeakerOn = !_isSpeakerOn),
                  ),

                  const SizedBox(width: 8),
                  
                  // Crimson Hang Up Button
                  Container(
                    height: 52,
                    width: 52,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDC2626),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.call_end_rounded, color: Colors.white, size: 26),
                      onPressed: _leaveSession,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Interviewer avatar view representing feed
  Widget _buildInterviewerView(bool isSpeaking) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Avatar Card
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSpeaking ? const Color(0xFF0D9488) : Colors.white24,
                  width: isSpeaking ? 4.0 : 1.5,
                ),
                boxShadow: isSpeaking
                    ? [
                        BoxShadow(
                          color: const Color(0xFF0D9488).withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 4,
                        )
                      ]
                    : [],
              ),
              child: CircleAvatar(
                radius: 72,
                backgroundColor: const Color(0xFF1E293B),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF0F766E), Color(0xFF2DD4BF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.account_circle_outlined,
                      size: 96,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Name Info
            const Text(
              'ড. মাহবুবুর রহমান',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'সদস্য (সাবেক), পিএসসি ও বোর্ড চেয়ারম্যান',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 13,
              ),
            ),
            
            const SizedBox(height: 12),
            // Speaking text indicator
            AnimatedOpacity(
              opacity: isSpeaking ? 1.0 : 0.4,
              duration: const Duration(milliseconds: 300),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isSpeaking ? const Color(0xFF0D9488).withOpacity(0.15) : Colors.white10,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSpeaking) ...[
                      const Icon(Icons.record_voice_over_rounded, color: Color(0xFF2DD4BF), size: 14),
                      const SizedBox(width: 6),
                      const Text(
                        'কথা বলছেন...',
                        style: TextStyle(color: Color(0xFF2DD4BF), fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ] else ...[
                      const Icon(Icons.hourglass_empty_rounded, color: Colors.white60, size: 14),
                      const SizedBox(width: 6),
                      const Text(
                        'আপনার কথা শুনছেন',
                        style: TextStyle(color: Colors.white60, fontSize: 11),
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Preflight Screen: Setup and check connection, camera and mic
  Widget _buildPreflightScreen() {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Video / Camera Preflight Card
              Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F766E), Color(0xFF134E4A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F766E).withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    )
                  ],
                  border: Border.all(color: const Color(0xFF0D9488).withOpacity(0.3), width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      // Backdrop grid pattern
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _GridPatternPainter(),
                        ),
                      ),
                      
                      // Preflight Scanner Circle
                      Center(
                        child: _buildCameraPreflightBadge(),
                      ),

                      // Floating controls
                      Positioned(
                        bottom: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black38,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.videocam_rounded, color: Colors.white, size: 14),
                              SizedBox(width: 6),
                              Text(
                                'ক্যামেরা প্রিভিউ প্রস্তুত',
                                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Title and Description
              const Text(
                'লাইভ মক ভাইভা বোর্ড',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'সরাসরি প্রফেশনাল ভাইভা পরীক্ষকের সাথে যুক্ত হওয়ার পূর্বে আপনার নেটওয়ার্ক, স্পিকার এবং মাইক্রোফোন পরীক্ষা করুন।',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),

              // Diagnostics checklist
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'প্রি-ফ্লাইট ডায়াগনস্টিকস',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _PreflightCheckRow(
                      icon: Icons.wifi_rounded,
                      title: 'ইন্টারনেট কানেকশন',
                      status: 'চমৎকার (৫২ Mbps)',
                      isOk: true,
                    ),
                    const Divider(height: 20),
                    _PreflightCheckRow(
                      icon: Icons.videocam_outlined,
                      title: 'ক্যামেরা ডিভাইস',
                      status: 'ডিফল্ট ফ্রন্ট ক্যামেরা সক্রিয়',
                      isOk: true,
                    ),
                    const Divider(height: 20),
                    _PreflightCheckRow(
                      icon: Icons.mic_none_rounded,
                      title: 'মাইক্রোফোন লেভেল',
                      status: 'ইনপুট সনাক্ত করা হয়েছে',
                      isOk: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Join Room Button
              FilledButton.icon(
                onPressed: _joining ? null : _joinSession,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0F766E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                icon: _joining
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.video_call_rounded, size: 22),
                label: const Text(
                  'মক ভাইভা রুমে যুক্ত হোন',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.2),
                ),
              ),
              _buildStatusBanner(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBanner() {
    if (_liveKitStatus.isEmpty) return const SizedBox.shrink();

    final isError = _liveKitStatus.contains('ব্যর্থ') || 
                    _liveKitStatus.contains('Exception') || 
                    _liveKitStatus.contains('invalid');

    if (isError) {
      return Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2), // Soft red background
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFCA5A5)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _liveKitStatus,
                style: const TextStyle(
                  color: Color(0xFF991B1B), // Dark red text
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4), // Soft green background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF15803D)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _liveKitStatus,
              style: const TextStyle(
                color: Color(0xFF166534), // Dark green text
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreflightBadge() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 64,
          width: 64,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white30, width: 2),
          ),
          child: const Center(
            child: Icon(
              Icons.face_retouching_natural_rounded,
              color: Color(0xFF2DD4BF),
              size: 32,
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'ভিডিও সিগন্যাল ওকে',
          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5),
        ),
      ],
    );
  }

  Widget _buildCallControl({
    required IconData icon,
    required bool isActive,
    required Color activeColor,
    required Color inactiveColor,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: isActive ? activeColor : inactiveColor,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.white, size: 22),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 9),
        ),
      ],
    );
  }
}

class _PreflightCheckRow extends StatelessWidget {
  const _PreflightCheckRow({
    required this.icon,
    required this.title,
    required this.status,
    required this.isOk,
  });

  final IconData icon;
  final String title;
  final String status;
  final bool isOk;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF0F766E), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                status,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        if (isOk)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Color(0xFFECFDF5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded, color: Color(0xFF10B981), size: 14),
          ),
      ],
    );
  }
}

class _GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1.0;

    const step = 20.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
