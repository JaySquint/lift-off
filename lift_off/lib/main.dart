import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

final notificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  tz_data.initializeTimeZones();
  final localTimeZone = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(localTimeZone.identifier));

  await notificationsPlugin.initialize(
    settings: const InitializationSettings(
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
      macOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    ),
  );

  runApp(const LiftOffApp());
}

class LiftOffApp extends StatelessWidget {
  const LiftOffApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lift Off',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const WorkoutHomePage(),
    );
  }
}

class WorkoutHomePage extends StatefulWidget {
  const WorkoutHomePage({super.key});

  @override
  State<WorkoutHomePage> createState() => _WorkoutHomePageState();
}

class _WorkoutHomePageState extends State<WorkoutHomePage> {
  final List<DateTime> _workouts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    final preferences = await SharedPreferences.getInstance();
    final savedValues = preferences.getStringList('workoutDateTimes');

    final values = savedValues ??
        [
          if (preferences.getString('workoutDateTime') case final String value)
            value,
        ];

    final workouts = values
        .map(DateTime.tryParse)
        .whereType<DateTime>()
        .toList()
      ..sort((a, b) => a.compareTo(b));

    if (savedValues == null) {
      await preferences.setStringList(
        'workoutDateTimes',
        workouts.map((workout) => workout.toIso8601String()).toList(),
      );
    }

    if (!mounted) return;
    setState(() {
      _workouts
        ..clear()
        ..addAll(workouts);
      _isLoading = false;
    });
  }

  Future<DateTime?> _chooseWorkoutDateTime(DateTime initialDateTime) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDate = DateTime(now.year + 1);
    final initialDate = initialDateTime.isBefore(today)
        ? today
        : initialDateTime.isAfter(lastDate)
            ? lastDate
            : initialDateTime;

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: today,
      lastDate: lastDate,
    );

    if (date == null || !mounted) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDateTime),
    );

    if (time == null || !mounted) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _saveWorkouts(List<DateTime> workouts) async {
    final sortedWorkouts = [...workouts]..sort((a, b) => a.compareTo(b));

    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      'workoutDateTimes',
      sortedWorkouts.map((workout) => workout.toIso8601String()).toList(),
    );

    if (!mounted) return;
    setState(() {
      _workouts
        ..clear()
        ..addAll(sortedWorkouts);
    });
  }

  int _notificationIdFor(DateTime workout) =>
      workout.millisecondsSinceEpoch.remainder(2147483647);

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<bool> _requestNotificationPermission() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final granted = await notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return granted ?? false;
    }

    if (defaultTargetPlatform == TargetPlatform.macOS) {
      final granted = await notificationsPlugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return granted ?? false;
    }

    return false;
  }

  Future<void> _scheduleReminder(DateTime workout) async {
    final reminderTime = workout.subtract(const Duration(minutes: 30));

    if (!reminderTime.isAfter(DateTime.now())) {
      _showMessage(
        'Workout saved, but it is less than 30 minutes away, so no reminder was scheduled.',
      );
      return;
    }

    if (!await _requestNotificationPermission()) {
      _showMessage(
        'Workout saved, but notifications are not allowed. Enable them in Settings to receive reminders.',
      );
      return;
    }

    await notificationsPlugin.zonedSchedule(
      id: _notificationIdFor(workout),
      title: 'Workout in 30 minutes',
      body: 'Time to get ready for your workout.',
      scheduledDate: tz.TZDateTime.from(reminderTime, tz.local),
      notificationDetails: const NotificationDetails(
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );

    debugPrint('Scheduled reminder for $reminderTime');
    final pending = await notificationsPlugin.pendingNotificationRequests();
    debugPrint('Pending notifications: ${pending.length}');
    for (final request in pending) {
      debugPrint('Reminder id=${request.id}, title=${request.title}');
    }
  }

  Future<void> _scheduleWorkout() async {
    final workout = await _chooseWorkoutDateTime(DateTime.now());
    if (workout == null) return;

    if (!workout.isAfter(DateTime.now())) {
      _showMessage('Choose a workout time in the future.');
      return;
    }

    if (_workouts.contains(workout)) {
      _showMessage('A workout is already scheduled for that time.');
      return;
    }

    await _saveWorkouts([..._workouts, workout]);
    await _scheduleReminder(workout);
  }

  Future<void> _editWorkout(int index) async {
    final originalWorkout = _workouts[index];
    final workout = await _chooseWorkoutDateTime(originalWorkout);
    if (workout == null) return;

    if (!workout.isAfter(DateTime.now())) {
      _showMessage('Choose a workout time in the future.');
      return;
    }

    if (_workouts.asMap().entries.any(
      (entry) => entry.key != index && entry.value == workout,
    )) {
      _showMessage('A workout is already scheduled for that time.');
      return;
    }

    await notificationsPlugin.cancel(
      id: _notificationIdFor(originalWorkout),
    );

    final updatedWorkouts = [..._workouts];
    updatedWorkouts[index] = workout;
    await _saveWorkouts(updatedWorkouts);
    await _scheduleReminder(workout);
  }

  Future<void> _deleteWorkout(int index) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete workout?'),
        content: const Text('This scheduled workout will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    await notificationsPlugin.cancel(
      id: _notificationIdFor(_workouts[index]),
    );

    final updatedWorkouts = [..._workouts]..removeAt(index);
    await _saveWorkouts(updatedWorkouts);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lift Off')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Your workouts',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _workouts.isEmpty
                          ? const Center(
                              child: Text('No workouts scheduled yet.'),
                            )
                          : ListView.builder(
                              itemCount: _workouts.length,
                              itemBuilder: (context, index) {
                                final workout = _workouts[index];
                                final date = MaterialLocalizations.of(context)
                                    .formatFullDate(workout);
                                final time = MaterialLocalizations.of(context)
                                    .formatTimeOfDay(
                                  TimeOfDay.fromDateTime(workout),
                                );

                                return Card(
                                  child: ListTile(
                                    leading: const Icon(Icons.fitness_center),
                                    title: Text(date),
                                    subtitle: Text(time),
                                    trailing: PopupMenuButton<String>(
                                      tooltip: 'Workout actions',
                                      onSelected: (action) {
                                        if (action == 'edit') {
                                          _editWorkout(index);
                                        } else if (action == 'delete') {
                                          _deleteWorkout(index);
                                        }
                                      },
                                      itemBuilder: (context) => const [
                                        PopupMenuItem(
                                          value: 'edit',
                                          child: Text('Reschedule'),
                                        ),
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _isLoading ? null : _scheduleWorkout,
                  icon: const Icon(Icons.calendar_month),
                  label: const Text('Schedule a workout'),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Goal: 4 workouts this week',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}