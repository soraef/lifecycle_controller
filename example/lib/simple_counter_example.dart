import 'package:flutter/material.dart';
import 'package:lifecycle_controller/lifecycle_controller.dart';
import 'package:provider/provider.dart';

class CounterController extends LifecycleController {
  int _counter = 0;

  int get counter => _counter;

  void increment() {
    // Use `asyncRun` to handle loading states and errors automatically
    asyncRun(() async {
      await Future.delayed(const Duration(seconds: 1));
      _counter++;
      notifyListeners(); // Notify listeners to rebuild UI
    });
  }

  @override
  void onInit() {
    super.onInit();
    // Initialization logic here
    print('CounterController initialized');
  }

  @override
  void onDispose() {
    super.onDispose();
    // Cleanup logic here
    print('CounterController disposed');
  }
}

class CounterWidget extends StatelessWidget {
  const CounterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return LifecycleScope(
      builder: (context) {
        final controller = context.read<CounterController>();
        final counter = context.select<CounterController, int>(
          (value) => value.counter,
        );
        return Scaffold(
          appBar: AppBar(title: const Text('Counter Example')),
          body: Center(
            child: Text(
              'Count: $counter',
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: controller.increment,
            child: const Icon(Icons.add),
          ),
        );
      },
      controller: CounterController(),
    );
  }
}
