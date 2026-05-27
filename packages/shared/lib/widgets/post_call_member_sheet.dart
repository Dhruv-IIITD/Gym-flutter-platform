import 'package:flutter/material.dart';

import '../utils/theme.dart';
import 'rating_stars.dart';

class PostCallMemberSheet extends StatefulWidget {
  const PostCallMemberSheet({
    required this.onSubmit,
    super.key,
  });

  final void Function(int? rating, String note) onSubmit;

  @override
  State<PostCallMemberSheet> createState() => _PostCallMemberSheetState();
}

class _PostCallMemberSheetState extends State<PostCallMemberSheet> {
  final _noteController = TextEditingController();
  int? _rating;

  @override
  void dispose() {
    _noteController.dispose();
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
          Text('Rate session',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: WtfSpacing.sm),
          RatingStars(
              rating: _rating, onChanged: (v) => setState(() => _rating = v)),
          const SizedBox(height: WtfSpacing.md),
          TextField(
            controller: _noteController,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Notes'),
          ),
          const SizedBox(height: WtfSpacing.md),
          FilledButton(
            onPressed: () => widget.onSubmit(_rating, _noteController.text),
            child: const Text('Submit'),
          ),
          TextButton(
            onPressed: () => widget.onSubmit(null, ''),
            child: const Text('Skip'),
          ),
        ],
      ),
    );
  }
}
