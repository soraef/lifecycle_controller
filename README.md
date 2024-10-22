# Lifecycle Controller

**Lifecycle Controller** is a Flutter library designed to eliminate the boilerplate associated with the **ChangeNotifier** pattern from the **Provider** package. By leveraging **Provider** as the underlying library, LifecycleWidget simplifies state management and lifecycle handling in your applications. It provides a structured and intuitive approach to managing screen lifecycle events, local state, and UI updates, enabling you to build robust, scalable, and maintainable Flutter applications with ease.

## 🌟 Why Lifecycle Controller?

Managing state and lifecycle events in Flutter can involve repetitive boilerplate code, especially when using the **ChangeNotifier** pattern with **Provider**. As your application grows, maintaining a clean separation between UI and business logic becomes crucial. **Lifecycle Controller** addresses these challenges by:

- **Reducing Boilerplate**: Eliminates repetitive code associated with the ChangeNotifier pattern, allowing you to focus on your app's logic.
- **Simplifying State Management**: Provides a clean, provider-based architecture for managing local state without unnecessary overhead.
- **Handling Lifecycle Events**: Offers built-in methods to handle screen lifecycle events like navigation changes and app lifecycle states.
- **Enhancing Maintainability**: Promotes separation of concerns, making your codebase cleaner and easier to maintain.
- **Customizable UI Components**: Allows easy customization of loading and error screens to match your app's design.
- **Efficient Subscription Management**: Simplifies stream subscription handling to prevent memory leaks.
- **Debouncing and Throttling**: Provides methods to debounce and throttle actions to optimize performance.

What sets Lifecycle Controller apart from other state management libraries is that it provides essential features for separating Widgets from business logic, such as loading state management, efficient subscription handling, and convenient functions like debouncing and throttling. These built-in features simplify complex state management and performance optimization, making it easier to implement.

## 📥 Installation

Add **Lifecycle Controller** to your `pubspec.yaml` file:

```yaml
dependencies:
  lifecycle_controller: latest_version
  provider: latest_version
```

Then run:

```bash
flutter pub get
```

## 🛠️ Getting Started

### Step 1: Create a Controller

Create a controller by extending `LifecycleController`. This controller will manage the state and logic for your screen.

```dart
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
```

### Step 2: Setting up the LifecycleScope

Using `LifecycleScope`, you can create a controller. Within this `LifecycleScope`, you are free to use custom-created controllers by utilizing the approach provided by the Provider package.

```dart
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
```
## 📖 Detailed Guide

### State Management with Provider

**Lifecycle Controller** leverages the power of the Provider package for state management. It automatically sets up the necessary Provider infrastructure, allowing you to access your controller's state easily within your screen.

#### Accessing Controller State

Access your controller and its state using `context.read`, `context.watch`, or `context.select`:

```dart
// Read the controller instance (does not listen for changes)
final controller = context.read<CounterController>();

// Watch for all changes in the controller (rebuilds on any change)
final counter = context.watch<CounterController>().counter;

// Select and listen to specific properties (optimal for performance)
final counter = context.select<CounterController, int>(
  (controller) => controller.counter,
);
```

💡 **Tip**: Use `context.select` when you want to listen to specific properties to optimize performance and prevent unnecessary rebuilds.

### Lifecycle Hooks

**Lifecycle Controller** provides several lifecycle hooks that you can override in your controller to respond to various lifecycle events:

```dart
class MyController extends LifecycleController {
  @override
  void onInit() {
    super.onInit();
    // Called when the controller is initialized
  }

  @override
  void onDispose() {
    super.onDispose();
    // Called when the controller is disposed
  }

  @override
  void onDidPush() {
    super.onDidPush();
    // Called when the screen is pushed onto the navigation stack
  }

  @override
  void onDidPop() {
    super.onDidPop();
    // Called when the screen is popped from the navigation stack
  }

  @override
  void onDidPushNext() {
    super.onDidPushNext();
    // Called when a new screen is pushed on top of this one
  }

  @override
  void onDidPopNext() {
    super.onDidPopNext();
    // Called when the screen on top of this one is popped
  }

  @override
  void onResumed() {
    super.onResumed();
    // Called when the app is resumed from the background
  }

  @override
  void onInactive() {
    super.onInactive();
    // Called when the app becomes inactive
  }

  @override
  void onPaused() {
    super.onPaused();
    // Called when the app is paused
  }

  @override
  void onDetached() {
    super.onDetached();
    // Called when the app is detached
  }
}
```

If you want to use methods related to routing, such as `onDidPop`, you must set up a `RouteObserver`.

```dart
Widget build(BuildContext context) {
  ...
  return new MaterialApp(
    ...
    navigatorObservers: <NavigatorObserver>[
      LifecycleController.basePageRouteObserver,
    ],
    ...
  );
}
```


### Asynchronous Operations Handling

Manage asynchronous tasks with ease using the `asyncRun` method. It automatically handles loading states and error management.

```dart
class DataController extends LifecycleController {
  List<String> _items = [];

  List<String> get items => _items;

  void fetchData() {
    asyncRun(() async {
      // Simulate network request
      await Future.delayed(const Duration(seconds: 2));
      _items = ['Item 1', 'Item 2', 'Item 3'];
      notifyListeners(); // Update UI
    });
  }
}
```

In your widget, you can show a loading indicator or error message based on the controller's state.

```dart
@override
Widget build(BuildContext context, DataController controller) {
  if (controller.isLoading) {
    return const Center(child: CircularProgressIndicator());
  } else if (controller.isError) {
    return Center(child: Text('Error: ${controller.errorMessage}'));
  } else {
    return ListView(
      children: controller.items.map((item) => ListTile(title: Text(item))).toList(),
    );
  }
}
```

### Customizing UI Components

#### Custom Loading View

Override the `buildLoading` method in your widget to provide a custom loading UI.

```dart
class MyWidget extends LifecycleWidget<MyController> {
  @override
  Widget buildLoading(BuildContext context, MyController controller) {
    return const Center(
      child: CircularProgressIndicator(color: Colors.red),
    );
  }
}
```

#### Custom Error View

Override the `buildError` method to customize the error UI.

```dart
class MyWidget extends LifecycleWidget<MyController> {
  @override
  Widget buildError(BuildContext context, MyController controller) {
    return Center(
      child: Text(
        'Oops! ${controller.errorMessage}',
        style: TextStyle(color: Colors.red, fontSize: 18),
      ),
    );
  }
}
```

### Subscription Management

Manage stream subscriptions efficiently using built-in methods to prevent memory leaks.

#### Adding Subscriptions

Use the `addSubscription` method to add a subscription that the controller will manage.

```dart
class MyController extends LifecycleController {
  void listenToStream(Stream<int> stream) {
    final subscription = stream.listen((data) {
      // Handle incoming data
    });
    addSubscription(subscription);
  }
}
```

#### Cancelling Subscriptions

All added subscriptions are automatically cancelled when the controller is disposed. You can also manually cancel subscriptions if needed.

```dart
// Cancel a specific subscription
await cancelSubscription(subscription);

// Cancel all subscriptions
await cancelSubscriptionAll();
```

### Debouncing Actions

Use the `debounce` method to prevent a function from being called too frequently.

```dart
class SearchController extends LifecycleController {
  void onSearchChanged(String query) {
    debounce(const Duration(milliseconds: 500), () {
      // Perform search
    }, id: 'search');
  }
}
```

### Throttling Actions

Use the `throttle` method to limit the rate at which a function can be called.

```dart
class ScrollController extends LifecycleController {
  void onScroll(double offset) {
    throttle(const Duration(milliseconds: 200), () {
      // Handle scroll offset
    }, id: 'scroll');
  }
}
```

## 💡 Best Practices

1. **Keep Controllers Focused**: Each controller should manage state for a single screen or feature to maintain clarity and ease of testing.

2. **Use `asyncRun` for Async Tasks**: Utilize `asyncRun` to handle loading and error states automatically, ensuring consistent UX.

3. **Leverage Lifecycle Hooks**: Override lifecycle methods to initialize resources, dispose of them, and respond to navigation events appropriately.

4. **Optimize UI Rebuilds**: Use `context.select` to listen to specific properties, reducing unnecessary widget rebuilds and improving performance.

5. **Handle Errors Gracefully**: Always provide user feedback by handling errors using `showError` and customizing the error UI.

## ❓ FAQ


### **Q: How does Lifecycle Controller compare to other state management libraries like BLoC or GetX?**

**A:** **Lifecycle Controllert** focuses on providing a simple, provider-based approach to state management with a strong emphasis on lifecycle events. It aims to reduce boilerplate and integrate seamlessly with Flutter's navigation and lifecycle.

### **Q: Do I need to manually dispose of the controller?**

**A:** No, the controller is automatically disposed of when the widget is removed from the widget tree.

## 🤝 Contributing

Contributions are welcome! If you have suggestions for improvements, new features, or find any issues, please open an issue or submit a pull request on [GitHub](https://github.com/your-repo/lifecycle_screen).

## 📝 License

This project is licensed under the MIT License.
