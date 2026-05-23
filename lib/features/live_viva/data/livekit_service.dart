import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:livekit_client/livekit_client.dart';
import '../domain/livekit_gateway.dart';

class LiveKitService implements LiveKitGateway {
  Room? _room;
  EventsListener<RoomEvent>? _roomListener;

  // Track status and callbacks
  Function(String status)? onStatusChanged;
  Function(VideoTrack? local, VideoTrack? remote)? onTracksChanged;
  Function(bool isSpeaking)? onInterviewerSpeakingChanged;

  LocalVideoTrack? _localVideoTrack;
  RemoteVideoTrack? _remoteVideoTrack;

  Room? get room => _room;
  LocalVideoTrack? get localVideoTrack => _localVideoTrack;
  RemoteVideoTrack? get remoteVideoTrack => _remoteVideoTrack;

  @override
  Future<void> joinRoom({required String roomName, required String token}) async {
    // Note: roomName is typically handled in token generation,
    // but the websocket URL is passed to connection.
    throw UnimplementedError('Please use joinRealRoom with serverUrl and token');
  }

  /// Establishes connection to the LiveKit Cloud SFU server.
  Future<void> joinRealRoom({required String serverUrl, required String token}) async {
    try {
      onStatusChanged?.call('কানেক্ট করা হচ্ছে...');
      
      // 1. Create a new Room instance
      final room = Room();
      _room = room;

      // 2. Setup Events Listener
      _roomListener = room.createListener();
      _setupRoomListeners(_roomListener!);

      // 3. Connect to the server
      await room.connect(
        serverUrl,
        token,
        roomOptions: const RoomOptions(
          adaptiveStream: true,
          dynacast: true,
        ),
      );

      onStatusChanged?.call('রুমে যুক্ত হয়েছেন, ভিডিও চালু হচ্ছে...');

      // 4. Turn on camera and mic (publish local tracks)
      await room.localParticipant?.setCameraEnabled(true);
      await room.localParticipant?.setMicrophoneEnabled(true);

      // Find if we already have local video track published
      final videoTrackPubs = room.localParticipant?.videoTrackPublications;
      if (videoTrackPubs != null && videoTrackPubs.isNotEmpty) {
        final track = videoTrackPubs.first.track;
        if (track is LocalVideoTrack) {
          _localVideoTrack = track;
        }
      }

      _notifyTracks();
      onStatusChanged?.call('কানেকশন সফল');
    } catch (e) {
      debugPrint('Error connecting to LiveKit Cloud: $e');
      onStatusChanged?.call('কানেকশন ব্যর্থ হয়েছে: $e');
      await leaveRoom();
      rethrow;
    }
  }

  void _setupRoomListeners(EventsListener<RoomEvent> listener) {
    // A remote video or audio track is published/subscribed
    listener.on<TrackSubscribedEvent>((event) {
      debugPrint('Track subscribed: ${event.track.sid} for participant ${event.participant.identity}');
      if (event.track is RemoteVideoTrack) {
        _remoteVideoTrack = event.track as RemoteVideoTrack;
        _notifyTracks();
      }
    });

    listener.on<TrackUnsubscribedEvent>((event) {
      debugPrint('Track unsubscribed: ${event.track.sid}');
      if (event.track is RemoteVideoTrack) {
        if (_remoteVideoTrack?.sid == event.track.sid) {
          _remoteVideoTrack = null;
          _notifyTracks();
        }
      }
    });

    // Local tracks are successfully published to SFU
    listener.on<LocalTrackPublishedEvent>((event) {
      debugPrint('Local track published: ${event.publication.sid}');
      if (event.publication.track is LocalVideoTrack) {
        _localVideoTrack = event.publication.track as LocalVideoTrack;
        _notifyTracks();
      }
    });

    // Detect when someone starts/stops speaking
    listener.on<ActiveSpeakersChangedEvent>((event) {
      if (_room == null) return;
      
      // Check if any remote participant is currently speaking
      final speakers = event.speakers;
      bool isRemoteSpeaking = false;
      for (final speaker in speakers) {
        // If the speaker is not local, then the interviewer/remote is speaking
        if (speaker.identity != _room?.localParticipant?.identity) {
          isRemoteSpeaking = true;
          break;
        }
      }
      onInterviewerSpeakingChanged?.call(isRemoteSpeaking);
    });

    // Disconnected from room
    listener.on<RoomDisconnectedEvent>((event) {
      debugPrint('Room disconnected: ${event.reason}');
      onStatusChanged?.call('কানেকশন বিচ্ছিন্ন');
      _cleanupTracks();
    });
  }

  void _notifyTracks() {
    onTracksChanged?.call(_localVideoTrack, _remoteVideoTrack);
  }

  void _cleanupTracks() {
    _localVideoTrack = null;
    _remoteVideoTrack = null;
    _notifyTracks();
  }

  @override
  Future<void> leaveRoom() async {
    try {
      _cleanupTracks();
      
      // Stop and publish disable local camera and mic
      if (_room?.localParticipant != null) {
        await _room?.localParticipant?.setCameraEnabled(false);
        await _room?.localParticipant?.setMicrophoneEnabled(false);
      }

      await _roomListener?.dispose();
      _roomListener = null;

      await _room?.disconnect();
      await _room?.dispose();
      _room = null;
    } catch (e) {
      debugPrint('Error leaving LiveKit room: $e');
    }
  }

  @override
  Future<void> toggleCamera(bool enabled) async {
    try {
      await _room?.localParticipant?.setCameraEnabled(enabled);
      if (!enabled) {
        _localVideoTrack = null;
      } else {
        final videoPubs = _room?.localParticipant?.videoTrackPublications;
        if (videoPubs != null && videoPubs.isNotEmpty) {
          final track = videoPubs.first.track;
          if (track is LocalVideoTrack) {
            _localVideoTrack = track;
          }
        }
      }
      _notifyTracks();
    } catch (e) {
      debugPrint('Error toggling camera: $e');
    }
  }

  @override
  Future<void> toggleMicrophone(bool enabled) async {
    try {
      await _room?.localParticipant?.setMicrophoneEnabled(enabled);
    } catch (e) {
      debugPrint('Error toggling microphone: $e');
    }
  }
}
