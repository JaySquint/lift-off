import 'package:flutter/material.dart';

void main() {
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

class WorkoutHomePage extends StatelessWidget {
  const WorkoutHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lift Off')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Your next workout',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('No workout scheduled yet.'),
                ),
              ),
              const SizedBox(height: 16),
              const FilledButton(
                onPressed: null,
                child: Text('Schedule a workout'),
              ),
              const SizedBox(height: 24),
              const Text('Goal: 4 workouts this week'),
            ],
          ),
        ),
      ),
    );
  }
}