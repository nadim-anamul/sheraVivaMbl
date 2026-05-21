abstract class LiveKitGateway {
  Future<void> joinRoom({
    required String roomName,
    required String token,
  });

  Future<void> leaveRoom();
  Future<void> toggleMicrophone(bool enabled);
  Future<void> toggleCamera(bool enabled);
}
