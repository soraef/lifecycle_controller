import 'package:flutter/material.dart';
import 'package:lifecycle_controller/lifecycle_controller.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      navigatorObservers: [
        LifecycleController.basePageRouteObserver,
      ],
      home: const MyHomePage(),
    );
  }
}

class MyRouterDelegate extends RouterDelegate with ChangeNotifier {
  @override
  Widget build(BuildContext context) {
    return const MyHomePage();
  }

  @override
  Future<void> setNewRoutePath(configuration) async {}

  @override
  Future<bool> popRoute() {
    // TODO: implement popRoute
    throw UnimplementedError();
  }
}

class MyHomePage extends LifecycleWidget<CounterController> {
  const MyHomePage({super.key});

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
}

class CounterController extends LifecycleController {
  int _counter = 0;
  int get counter => _counter;

  @override
  void onInit() {
    super.onInit();
    reset();
  }

  Future<void> increment() async {
    await asyncRun(
      () async {
        await Future.delayed(const Duration(milliseconds: 300));
        if (_counter == 5) {
          showError('Counter limit reached!');
          return;
        }
        _counter++;
        notifyListeners();
      },
    );
  }

  Future<void> reset() async {
    await asyncRun(
      () async {
        await Future.delayed(const Duration(seconds: 1));
        _counter = 0;
        clearError();
        notifyListeners();
      },
    );
  }

  @override
  void onDidPop() {
    super.onDidPush();
    print('onDidPop');
    reset();
  }

  @override
  void onInactive() {
    super.onInactive();
    print('onInactive');
    reset();
  }
}
