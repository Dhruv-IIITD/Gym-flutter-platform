import '../models/call_request.dart';
import '../repositories/schedule_repository.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';

class ScheduleService {
  ScheduleService({ScheduleRepository? repository}) : _repository = repository;

  final ScheduleRepository? _repository;

  List<DateTime> generateTimeSlots(DateTime date) {
    final slots = <DateTime>[];
    var cursor = DateTime(date.year, date.month, date.day, 6);
    final end = DateTime(date.year, date.month, date.day, 22);
    while (!cursor.isAfter(end)) {
      slots.add(cursor);
      cursor = cursor.add(AppConstants.slotDuration);
    }
    return slots;
  }

  List<DateTime> getAvailableDates() {
    final now = DateTime.now();
    return List.generate(
      AppConstants.scheduleAheadDays,
      (index) => DateTime(now.year, now.month, now.day + index),
    );
  }

  Future<bool> checkConflict(String trainerId, DateTime slot) async {
    final approvedSlots =
        await (_repository ?? ScheduleRepository()).getApprovedSlots(trainerId);
    return Validators.hasConflict(slot, approvedSlots);
  }

  bool canJoin(CallRequest request) {
    if (request.status != CallRequestStatus.approved) {
      return false;
    }
    final now = DateTime.now();
    final opensAt = request.scheduledAt.subtract(
      const Duration(minutes: AppConstants.joinWindowMinutes),
    );
    final closesAt = request.scheduledAt.add(const Duration(hours: 1));
    return now.isAfter(opensAt) && now.isBefore(closesAt);
  }
}
