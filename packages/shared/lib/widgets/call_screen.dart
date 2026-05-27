import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';

import '../providers/call_providers.dart';
import '../utils/theme.dart';

class CallScreen extends ConsumerWidget {
  const CallScreen({
    required this.roomCode,
    super.key,
  });

  final String roomCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(callControllerProvider);
    return Scaffold(
      backgroundColor: WtfColors.neutral900,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(WtfSpacing.md),
                  child: _DurationPill(duration: state.callDuration),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide =
                          constraints.maxWidth > constraints.maxHeight;
                      final children = [
                        _VideoTile(
                          peer: state.localPeer,
                          track: state.localVideoTrack,
                          label: state.localPeer?.name ?? 'You',
                          isMuted: state.isMicMuted,
                          isCameraOff: state.isCameraOff,
                        ),
                        _VideoTile(
                          peer: state.remotePeer,
                          track: state.remoteVideoTrack,
                          label: state.remotePeer?.name ?? 'Waiting',
                          isMuted: false,
                          isCameraOff: state.remoteVideoTrack?.isMute ?? true,
                        ),
                      ];
                      return isWide
                          ? Row(children: children)
                          : Column(children: children);
                    },
                  ),
                ),
                _Controls(roomCode: roomCode),
              ],
            ),
            if (state.isReconnecting)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: WtfSpacing.md),
                      Text(
                        'Reconnecting...',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _VideoTile extends StatelessWidget {
  const _VideoTile({
    required this.peer,
    required this.track,
    required this.label,
    required this.isMuted,
    required this.isCameraOff,
  });

  final HMSPeer? peer;
  final HMSVideoTrack? track;
  final String label;
  final bool isMuted;
  final bool isCameraOff;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(6),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFF1F2937),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (track != null && !isCameraOff)
              HMSVideoView(track: track!, key: ValueKey(track!.trackId))
            else
              Center(
                child: CircleAvatar(
                  radius: 40,
                  child: Text(
                    _initials(label),
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      peer?.name ?? label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (isMuted)
                    const Icon(Icons.mic_off, size: 18, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.take(2).map((part) => part[0].toUpperCase()).join();
  }
}

class _Controls extends ConsumerWidget {
  const _Controls({required this.roomCode});

  final String roomCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(callControllerProvider);
    final controller = ref.read(callControllerProvider.notifier);
    return Padding(
      padding: const EdgeInsets.all(WtfSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton.filledTonal(
            tooltip: state.isMicMuted ? 'Unmute' : 'Mute',
            onPressed: controller.toggleMic,
            icon: Icon(state.isMicMuted ? Icons.mic_off : Icons.mic),
          ),
          IconButton.filledTonal(
            tooltip: state.isCameraOff ? 'Camera on' : 'Camera off',
            onPressed: controller.toggleCamera,
            icon: Icon(
              state.isCameraOff ? Icons.videocam_off : Icons.videocam,
            ),
          ),
          IconButton.filledTonal(
            tooltip: 'Flip camera',
            onPressed: controller.switchCamera,
            icon: const Icon(Icons.cameraswitch),
          ),
          IconButton.filled(
            tooltip: 'End call',
            style: IconButton.styleFrom(backgroundColor: WtfColors.error),
            onPressed: () async {
              await controller.leave();
              if (context.mounted) {
                context.go('/sessions');
              }
            },
            icon: const Icon(Icons.call_end),
          ),
        ],
      ),
    );
  }
}

class _DurationPill extends StatelessWidget {
  const _DurationPill({required this.duration});

  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Text(
          '$minutes:$seconds',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
