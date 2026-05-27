class Validators {
  static String? validateScheduleTime(DateTime scheduledFor) {
    if (scheduledFor.isBefore(DateTime.now())) {
      return 'Cannot schedule a call in the past';
    }
    return null;
  }

  static String? validateNote(String? note) {
    if (note != null && note.length > 140) {
      return 'Note must be 140 characters or less';
    }
    return null;
  }

  static String? validateName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  static String? validateEmail(String? email) {
    final value = email?.trim() ?? '';
    if (value.isEmpty) {
      return 'Email is required';
    }
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  static bool hasConflict(DateTime slot, List<DateTime> approvedSlots) {
    return approvedSlots.any(
      (approved) =>
          approved.year == slot.year &&
          approved.month == slot.month &&
          approved.day == slot.day &&
          approved.hour == slot.hour &&
          approved.minute == slot.minute,
    );
  }
}
