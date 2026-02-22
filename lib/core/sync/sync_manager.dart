import 'package:workmanager/workmanager.dart';
import '../database/database.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Background logic goes here
    return Future.value(true);
  });
}

class SyncManager {
  static void init() {
    Workmanager().initialize(callbackDispatcher);
    Workmanager().registerPeriodicTask(
      "offline_sync",
      "syncDataTask",
      frequency: const Duration(minutes: 30),
    );
  }
}