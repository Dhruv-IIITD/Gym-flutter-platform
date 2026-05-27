import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/call_service.dart';
import '../utils/logger.dart';

part 'call_providers.g.dart';

class CallState {
  const CallState({
    this.room,
    this.localPeer,
    this.remotePeer,
    this.localVideoTrack,
    this.remoteVideoTrack,
    this.isMicMuted = false,
    this.isCameraOff = false,
    this.isReconnecting = false,
    this.callDuration = Duration.zero,
    this.errorMessage,
  });

  final HMSRoom? room;
  final HMSPeer? localPeer;
  final HMSPeer? remotePeer;
  final HMSVideoTrack? localVideoTrack;
  final HMSVideoTrack? remoteVideoTrack;
  final bool isMicMuted;
  final bool isCameraOff;
  final bool isReconnecting;
  final Duration callDuration;
  final String? errorMessage;

  CallState copyWith({
    HMSRoom? room,
    HMSPeer? localPeer,
    HMSPeer? remotePeer,
    HMSVideoTrack? localVideoTrack,
    HMSVideoTrack? remoteVideoTrack,
    bool? isMicMuted,
    bool? isCameraOff,
    bool? isReconnecting,
    Duration? callDuration,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CallState(
      room: room ?? this.room,
      localPeer: localPeer ?? this.localPeer,
      remotePeer: remotePeer ?? this.remotePeer,
      localVideoTrack: localVideoTrack ?? this.localVideoTrack,
      remoteVideoTrack: remoteVideoTrack ?? this.remoteVideoTrack,
      isMicMuted: isMicMuted ?? this.isMicMuted,
      isCameraOff: isCameraOff ?? this.isCameraOff,
      isReconnecting: isReconnecting ?? this.isReconnecting,
      callDuration: callDuration ?? this.callDuration,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

@riverpod
class CallController extends _$CallController {
  CallService? _service;
  DateTime? _startedAt;

  @override
  CallState build() => const CallState();

  Future<void> init() async {
    _service = CallService(
      onJoinSuccess: (room) {
        _startedAt = DateTime.now();
        state = state.copyWith(room: room, clearError: true);
        WtfLogger.rtc('Joined room ${room.name}');
      },
      onPeerUpdated: (peer, update) {
        if (peer.isLocal) {
          state = state.copyWith(localPeer: peer);
        } else {
          state = state.copyWith(remotePeer: peer);
        }
        WtfLogger.rtc('Peer ${peer.name} ${update.name}');
      },
      onTrackUpdated: (track, update, peer) {
        if (track is HMSVideoTrack) {
          state = peer.isLocal
              ? state.copyWith(
                  localVideoTrack: track,
                  isCameraOff: track.isMute,
                )
              : state.copyWith(remoteVideoTrack: track);
        }
        if (track is HMSAudioTrack && peer.isLocal) {
          state = state.copyWith(isMicMuted: track.isMute);
        }
        WtfLogger.rtc('Track ${track.trackId} ${update.name}');
      },
      onError: (error) {
        state = state.copyWith(errorMessage: error.message);
        WtfLogger.rtc('Error ${error.message}');
      },
      onReconnectingCallback: () {
        state = state.copyWith(isReconnecting: true);
      },
      onReconnectedCallback: () {
        state = state.copyWith(isReconnecting: false);
      },
    );
    await _service!.init();
  }

  Future<void> joinWithRoomCode({
    required String roomCode,
    required String userName,
  }) async {
    await (_service ??= _buildService()).init();
    await _service!.joinWithRoomCode(roomCode: roomCode, userName: userName);
  }

  Future<void> toggleMic() async {
    await _service?.toggleMic();
    state = state.copyWith(isMicMuted: !state.isMicMuted);
  }

  Future<void> toggleCamera() async {
    await _service?.toggleCamera();
    state = state.copyWith(isCameraOff: !state.isCameraOff);
  }

  Future<void> switchCamera() async {
    await _service?.switchCamera();
  }

  Future<Duration> leave() async {
    await _service?.leave();
    final duration = _startedAt == null
        ? Duration.zero
        : DateTime.now().difference(_startedAt!);
    state = const CallState();
    return duration;
  }

  CallService _buildService() {
    return CallService(
      onJoinSuccess: (room) {
        _startedAt = DateTime.now();
        state = state.copyWith(room: room, clearError: true);
      },
      onPeerUpdated: (peer, update) {
        state = peer.isLocal
            ? state.copyWith(localPeer: peer)
            : state.copyWith(remotePeer: peer);
      },
      onTrackUpdated: (track, update, peer) {
        if (track is HMSVideoTrack) {
          state = peer.isLocal
              ? state.copyWith(
                  localVideoTrack: track,
                  isCameraOff: track.isMute,
                )
              : state.copyWith(remoteVideoTrack: track);
        }
      },
      onError: (error) => state = state.copyWith(errorMessage: error.message),
      onReconnectingCallback: () =>
          state = state.copyWith(isReconnecting: true),
      onReconnectedCallback: () =>
          state = state.copyWith(isReconnecting: false),
    );
  }
}
