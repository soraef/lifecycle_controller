import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Demo Home Page'),
      ),
      body: const CounterWidget(),
    );
  }
}

class CounterWidget extends StatefulWidget {
  const CounterWidget({super.key});

  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  late final CounterController controller;

  @override
  void initState() {
    super.initState();
    controller = CounterController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.onInit();
    });
  }

  @override
  void dispose() {
    controller.onDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: controller,
      child: const _CounterWidget(),
    );
  }
}

class _CounterWidget extends StatelessWidget {
  const _CounterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('You have pushed the button this many times:'),
        Consumer<CounterController>(
          builder: (context, controller, child) {
            return Text(
              '${controller.counter}',
              style: Theme.of(context).textTheme.displayLarge,
            );
          },
        ),
        ElevatedButton(
          onPressed: () {
            context.read<CounterController>().incremenrt();
          },
          child: const Text('Increment'),
        ),
        ElevatedButton(
          onPressed: () {
            context.read<CounterController>().reset();
          },
          child: const Text('Reset'),
        ),
      ],
    );
  }
}

class CounterController with ChangeNotifier {
  int counter = 0;

  void onInit() {
    reset();
  }

  void onDispose() {}

  void incremenrt() {
    counter += 1;
    notifyListeners();
  }

  void reset() {
    counter = 0;
    notifyListeners();
  }
}
