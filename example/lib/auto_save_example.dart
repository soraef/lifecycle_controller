import 'package:flutter/material.dart';
import 'package:lifecycle_controller/lifecycle_controller.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AutoSavePage extends StatelessWidget {
  const AutoSavePage({super.key});

  @override
  Widget build(BuildContext context) {
    return LifecycleScope(
      controller: AutoSavePageController(),
      builder: (context) {
        final textController =
            context.select<AutoSavePageController, TextEditingController?>(
          (controller) => controller.textController,
        );
        return Scaffold(
          appBar: AppBar(
            title: const Text('Auto Save Memo'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: textController,
              minLines: 1,
              maxLines: 30,
              onChanged: (text) {
                context.read<AutoSavePageController>().saveText(text);
              },
              decoration: const InputDecoration.collapsed(
                hintText: 'Enter text',
              ),
            ),
          ),
        );
      },
      onEvent: (context, controller, event) {
        if (event is AutoSavePageEventSaveText) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Successfully saved',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
    );
  }
}

class AutoSavePageController extends LifecycleController {
  final String saveKey = 'auto_save_page_text';
  final loadingKey = LifecycleKey.unique();

  TextEditingController? textController;

  AutoSavePageController();

  @override
  void onInit() async {
    super.onInit();
    await lock(
      id: loadingKey,
      action: () async {
        await Future.delayed(const Duration(seconds: 1));
        textController = TextEditingController(
          text: (await _fetchText()) ?? '',
        );
        notifyListeners();
      },
    );
  }

  @override
  void onDispose() {
    super.onDispose();
    textController?.dispose();
  }

  void saveText(String text) async {
    debounce(
      id: LifecycleKey.unique(),
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
