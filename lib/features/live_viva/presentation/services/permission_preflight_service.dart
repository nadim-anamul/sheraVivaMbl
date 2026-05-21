class PermissionPreflightService {
  const PermissionPreflightService();

  Future<bool> ensureCameraAndMicrophoneGranted() async {
    // TODO(nadim): Integrate permission_handler for runtime requests.
    return true;
  }
}
