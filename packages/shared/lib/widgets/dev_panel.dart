import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../utils/logger.dart';
import '../utils/theme.dart';

class DevPanel extends StatelessWidget {
  const DevPanel({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      return const SizedBox.shrink();
    }
    return Positioned(
      right: WtfSpacing.md,
      bottom: WtfSpacing.md,
      child: FloatingActionButton.small(
        heroTag: 'dev-panel',
        tooltip: 'Dev panel',
        onPressed: () => showModalBottomSheet<void>(
          context: context,
          showDragHandle: true,
          builder: (_) => const _DevPanelSheet(),
        ),
        child: const Icon(Icons.more_vert),
      ),
    );
  }
}

class _DevPanelSheet extends StatelessWidget {
  const _DevPanelSheet();

  @override
  Widget build(BuildContext context) {
    final logs = WtfLogger.recentLogs;
    return DefaultTabController(
      length: 3,
      child: SizedBox(
        height: 360,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Env'),
                Tab(text: 'Logs'),
                Tab(text: 'State'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(WtfSpacing.md),
                    child: Text('Firebase + 100ms dev configuration active'),
                  ),
                  ListView.builder(
                    padding: const EdgeInsets.all(WtfSpacing.md),
                    itemCount: logs.length,
                    itemBuilder: (_, index) => Text(logs[index].toString()),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(WtfSpacing.md),
                    child: Text('Riverpod state is scoped per app'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
