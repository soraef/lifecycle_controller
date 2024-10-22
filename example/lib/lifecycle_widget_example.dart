import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:lifecycle_controller/lifecycle_controller.dart';
import 'package:provider/provider.dart';

class CounterPageWithLifecycleWidget
    extends LifecycleWidget<CounterController> {
  const CounterPageWithLifecycleWidget({super.key});

  @override
  Widget build(BuildContext context, CounterController controller) {
    final counter = context.select<CounterController, int>(
      (value) => value.counter,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Demo Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.increment,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  CounterController createController() {
    return CounterController();
  }

  @override
  Widget buildError(BuildContext context, CounterController controller) {
    final errorMessage = context.select<CounterController, String?>(
      (value) => value.errorMessage,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Demo Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              errorMessage ?? 'Error',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.reset,
        tooltip: 'Reset',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  @override
  Widget buildLoading(BuildContext context, CounterController controller) {
    return Container(
      color: Colors.white.withOpacity(0.5),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
