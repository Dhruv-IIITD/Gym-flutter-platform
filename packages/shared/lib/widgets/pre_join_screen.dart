import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../providers/call_providers.dart';
import '../utils/theme.dart';
import '../utils/ui_copy.dart';

class PreJoinScreen extends ConsumerStatefulWidget {
  const PreJoinScreen({
    required this.roomCode,
    required this.userName,
    super.key,
  });

  final String roomCode;
  final String userName;

  @override
  ConsumerState<PreJoinScreen> createState() => _PreJoinScreenState();
}

class _PreJoinScreenState extends ConsumerState<PreJoinScreen> {
  bool _micOn = true;
  bool _cameraOn = true;
  bool _permissionsReady = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pre-join')),
      body: Padding(
        padding: const EdgeInsets.all(WtfSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 10,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: WtfColors.neutral900,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    _cameraOn && _permissionsReady
                        ? Icons.videocam
                        : Icons.videocam_off,
                    size: 56,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: WtfSpacing.lg),
            Text(
              UiCopy.joinPrompt,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: WtfSpacing.md),
            Text(
              widget.userName,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filledTonal(
                  tooltip: _micOn ? 'Mute mic' : 'Unmute mic',
                  onPressed: () => setState(() => _micOn = !_micOn),
                  icon: Icon(_micOn ? Icons.mic : Icons.mic_off),
                ),
                const SizedBox(width: WtfSpacing.md),
                IconButton.filledTonal(
                  tooltip: _cameraOn ? 'Turn camera off' : 'Turn camera on',
                  onPressed: () => setState(() => _cameraOn = !_cameraOn),
                  icon: Icon(_cameraOn ? Icons.videocam : Icons.videocam_off),
                ),
              ],
            ),
            const SizedBox(height: WtfSpacing.md),
            FilledButton.icon(
              onPressed: _join,
              icon: const Icon(Icons.login),
              label: const Text('Join Call'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _requestPermissions() async {
    final camera = await Permission.camera.request();
    final mic = await Permission.microphone.request();
    if (!mounted) {
      return;
    }
    setState(() {
      _permissionsReady = camera.isGranted && mic.isGranted;
    });
  }

  Future<void> _join() async {
    await ref.read(callControllerProvider.notifier).joinWithRoomCode(
          roomCode: widget.roomCode,
          userName: widget.userName,
        );
    if (!mounted) {
      return;
    }
    context.go('/call/${widget.roomCode}');
  }
}
