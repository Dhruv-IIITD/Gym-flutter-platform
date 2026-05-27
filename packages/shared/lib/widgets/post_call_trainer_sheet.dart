import 'package:flutter/material.dart';

import '../utils/theme.dart';

class PostCallTrainerSheet extends StatefulWidget {
  const PostCallTrainerSheet({
    required this.onSubmit,
    super.key,
  });

  final void Function(String notes) onSubmit;

  @override
  State<PostCallTrainerSheet> createState() => _PostCallTrainerSheetState();
}

class _PostCallTrainerSheetState extends State<PostCallTrainerSheet> {
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(WtfSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Trainer notes',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: WtfSpacing.md),
          TextField(
            controller: _notesController,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Notes'),
          ),
          const SizedBox(height: WtfSpacing.md),
          FilledButton(
            onPressed: () => widget.onSubmit(_notesController.text),
            child: const Text('Mark as Complete'),
          ),
        ],
      ),
    );
  }
}
