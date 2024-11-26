import 'package:example/auto_save_example.dart';
import 'package:example/lifecycle_widget_example.dart';
import 'package:flutter/material.dart';
import 'package:lifecycle_controller/lifecycle_controller.dart';
import 'package:provider/provider.dart';
import 'package:example/simple_counter_example.dart' as simple;

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
    const CounterPageWithLifecycleWidget(),
    const simple.CounterWidget(),
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

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LifecycleScope(
      controller: CounterController(),
      builder: (context) {
        final controller = context.read<CounterController>();
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
      },
    );
  }
}

class CounterController extends LifecycleController {
  int _counter = 0;
  int get counter => _counter;

  final loadingKey = LifecycleKey.unique();

  @override
  void onInit() {
    super.onInit();
    reset();
  }

  Future<void> increment() async {
    await lock(
      id: loadingKey,
      action: () async {
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
    await lock(
      id: 'reset',
      action: () async {
        await Future.delayed(const Duration(seconds: 1));
        _counter = 0;
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
