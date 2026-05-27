import 'package:hmssdk_flutter/hmssdk_flutter.dart';

class CallService implements HMSUpdateListener {
  CallService({
    required this.onJoinSuccess,
    required this.onPeerUpdated,
    required this.onTrackUpdated,
    required this.onError,
    required this.onReconnectingCallback,
    required this.onReconnectedCallback,
  });

  late HMSSDK _hmsSDK;
  final void Function(HMSRoom) onJoinSuccess;
  final void Function(HMSPeer, HMSPeerUpdate) onPeerUpdated;
  final void Function(HMSTrack, HMSTrackUpdate, HMSPeer) onTrackUpdated;
  final void Function(HMSException) onError;
  final void Function() onReconnectingCallback;
  final void Function() onReconnectedCallback;

  Future<void> init() async {
    _hmsSDK = HMSSDK();
    await _hmsSDK.build();
    _hmsSDK.addUpdateListener(listener: this);
  }

  Future<void> joinWithRoomCode({
    required String roomCode,
    required String userName,
  }) async {
    final authToken = await _hmsSDK.getAuthTokenByRoomCode(roomCode: roomCode);
    if (authToken is String) {
      final config = HMSConfig(authToken: authToken, userName: userName);
      await _hmsSDK.join(config: config);
    } else if (authToken is HMSException) {
      onError(authToken);
    }
  }

  Future<void> toggleMic() async {
    await _hmsSDK.toggleMicMuteState();
  }

  Future<void> toggleCamera() async {
    await _hmsSDK.toggleCameraMuteState();
  }

  Future<void> switchCamera() async {
    await _hmsSDK.switchCamera();
  }

  Future<void> leave() async {
    _hmsSDK.removeUpdateListener(listener: this);
    await _hmsSDK.leave();
  }

  @override
  void onJoin({required HMSRoom room}) => onJoinSuccess(room);

  @override
  void onPeerUpdate({required HMSPeer peer, required HMSPeerUpdate update}) {
    onPeerUpdated(peer, update);
  }

  @override
  void onTrackUpdate({
    required HMSTrack track,
    required HMSTrackUpdate trackUpdate,
    required HMSPeer peer,
  }) {
    onTrackUpdated(track, trackUpdate, peer);
  }

  @override
  void onHMSError({required HMSException error}) => onError(error);

  @override
  void onReconnecting() => onReconnectingCallback();

  @override
  void onReconnected() => onReconnectedCallback();

  @override
  void onMessage({required HMSMessage message}) {}

  @override
  void onRoomUpdate({required HMSRoom room, required HMSRoomUpdate update}) {}

  @override
  void onUpdateSpeakers({required List<HMSSpeaker> updateSpeakers}) {}

  @override
  void onRoleChangeRequest({required HMSRoleChangeRequest roleChangeRequest}) {}

  @override
  void onChangeTrackStateRequest({
    required HMSTrackChangeRequest hmsTrackChangeRequest,
  }) {}

  @override
  void onRemovedFromRoom({
    required HMSPeerRemovedFromPeer hmsPeerRemovedFromPeer,
  }) {}

  @override
  void onAudioDeviceChanged({
    HMSAudioDevice? currentAudioDevice,
    List<HMSAudioDevice>? availableAudioDevice,
  }) {}

  @override
  void onSessionStoreAvailable({HMSSessionStore? hmsSessionStore}) {}

  @override
  void onPeerListUpdate({
    required List<HMSPeer> addedPeers,
    required List<HMSPeer> removedPeers,
  }) {}
}
