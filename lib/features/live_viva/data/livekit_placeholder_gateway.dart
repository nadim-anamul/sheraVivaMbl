import '../domain/livekit_gateway.dart';

class LiveKitPlaceholderGateway implements LiveKitGateway {
  @override
  Future<void> joinRoom({required String roomName, required String token}) async {
    // TODO(nadim): Replace with livekit_client Room.connect when SDK is wired.
  }

  @override
  Future<void> leaveRoom() async {
    // TODO(nadim): Replace with room.disconnect().
  }

  @override
  Future<void> toggleCamera(bool enabled) async {
    // TODO(nadim): Replace with local video track publish/unpublish.
  }

  @override
  Future<void> toggleMicrophone(bool enabled) async {
    // TODO(nadim): Replace with local audio track publish/unpublish.
  }
}
