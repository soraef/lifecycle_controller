import 'package:flutter/material.dart';
import 'package:lifecycle_controller/lifecycle_controller.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AutoSavePage extends LifecycleWidget<AutoSavePageController> {
  const AutoSavePage({super.key});

  @override
  Widget build(BuildContext context, AutoSavePageController controller) {
    return const _AutoSavePage();
  }

  @override
  AutoSavePageController createController() {
    return AutoSavePageController();
  }

  @override
  void onEvent(
    BuildContext context,
    AutoSavePageController controller,
    Object event,
  ) {
    if (event is AutoSavePageEventSaveText) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Successfully saved: ${event.text}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

class _AutoSavePage extends StatefulWidget {
  const _AutoSavePage({super.key});

  @override
  State<_AutoSavePage> createState() => _AutoSavePageState();
}

class _AutoSavePageState extends State<_AutoSavePage> {
  _AutoSavePageState();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final textController =
        context.select<AutoSavePageController, TextEditingController?>(
      (controller) => controller.textController,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Auto Save Page'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: textController,
            onChanged: (text) {
              context.read<AutoSavePageController>().saveText(text);
            },
            decoration: const InputDecoration(
              hintText: 'Enter text to save',
              label: Text('Text'),
            ),
          ),
        ),
      ),
    );
  }
}

class AutoSavePageController extends LifecycleController {
  final String saveKey = 'auto_save_page_text';

  TextEditingController? textController;

  AutoSavePageController();

  @override
  void onInit() async {
    super.onInit();
    await asyncRun(() async {
      // wait for 1 second
      await Future.delayed(const Duration(seconds: 1));
      textController = TextEditingController(text: (await _fetchText()) ?? '');
      notifyListeners();
    });
  }

  void saveText(String text) async {
    debounce(
      id: 'saveText',
      duration: const Duration(seconds: 1),
      action: () async {
        await _saveText(text);
      },
    );
  }

  @override
  void onInactive() {
    super.onInactive();
    _saveText(textController?.text ?? '');
  }

  @override
  void onDidPop() {
    super.onDidPop();
    _saveText(textController?.text ?? '');
  }

  Future<String?> _fetchText() async {
    return (await SharedPreferences.getInstance()).getString(saveKey);
  }

  Future<void> _saveText(String text) async {
    await (await SharedPreferences.getInstance()).setString(saveKey, text);
    emit(AutoSavePageEventSaveText(text));
  }
}

abstract interface class AutoSavePageEvent {}

class AutoSavePageEventSaveText implements AutoSavePageEvent {
  final String text;

  AutoSavePageEventSaveText(this.text);
}
