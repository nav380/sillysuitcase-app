import '../services/notification_service.dart';

class TimeScheduler {
  static Future scheduleDailyNotifications() async {
    // Morning notification 9 AM
    await NotificationService.scheduleDaily(
      100,
      9,
      "Good Morning",
      "You missed this place 👀",
    );

    // Evening notification 7 PM
    await NotificationService.scheduleDaily(
      101,
      19,
      "Party Time 🎉",
      "Top place to party like a pro 🍻",
    );
  }
}
