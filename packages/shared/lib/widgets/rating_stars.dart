import 'package:flutter/material.dart';

import '../utils/theme.dart';

class RatingStars extends StatelessWidget {
  const RatingStars({
    this.rating,
    this.onChanged,
    this.size = 24,
    super.key,
  });

  final int? rating;
  final ValueChanged<int>? onChanged;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final value = index + 1;
        final selected = (rating ?? 0) >= value;
        return IconButton(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: BoxConstraints.tight(Size(size + 8, size + 8)),
          tooltip: '$value stars',
          onPressed: onChanged == null ? null : () => onChanged!(value),
          icon: Icon(
            selected ? Icons.star : Icons.star_border,
            color: selected ? WtfColors.warning : WtfColors.neutral600,
            size: size,
          ),
        );
      }),
    );
  }
}
