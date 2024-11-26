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
}
