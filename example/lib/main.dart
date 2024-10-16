import 'package:example/auto_save_page.dart';
import 'package:flutter/material.dart';
import 'package:lifecycle_controller/lifecycle_controller.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldState> drawerKey = GlobalKey<ScaffoldState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final List<Widget> _pages = [
    const CounterPage(),
    const AutoSavePage(),
  ];

  @override
  void initState() {
    super.initState();
  }

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
      navigatorKey: navigatorKey,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Playground'),
        ),
        drawer: Drawer(
          key: drawerKey,
          child: ListView.separated(
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('${_pages[index].runtimeType}'),
                onTap: () {
                  navigatorKey.currentState!.pop();
                  navigatorKey.currentState!.push(
                    MaterialPageRoute(
                      builder: (context) {
                        return _pages[index];
                      },
                    ),
                  );
                },
              );
            },
            separatorBuilder: (context, index) {
              return const Divider();
            },
            itemCount: _pages.length,
          ),
        ),
      ),
    );
  }
}

class CounterPage extends LifecycleWidget<CounterController> {
  const CounterPage({super.key});

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
          notifyListeners();
          return 'Counter limit reached!';
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
      },
    );
  }

  @override
  void onDidPop() {
    super.onDidPush();
    reset();
  }

  @override
  void onInactive() {
    super.onInactive();
    reset();
  }
}
