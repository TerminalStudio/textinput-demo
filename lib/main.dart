import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TextInput demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: App(title: 'TextInput demo'),
    );
  }
}

class App extends StatefulWidget {
  App({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  AppState createState() => AppState();
}

class AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('TextInputConnection ${_inputConnection?.serialize()}'),
              SizedBox(height: 15),
              Text('TextEditingValue ${_textEditingValue?.serialize()}'),
              SizedBox(height: 15),
              ElevatedButton(
                child: Text('attach'),
                onPressed: _inputConnection != null ? null : () => _attach(),
              ),
              SizedBox(height: 15),
              ElevatedButton(
                child: Text('show'),
                onPressed: _inputConnection == null ? null : () => _show(),
              ),
              SizedBox(height: 15),
              ElevatedButton(
                child: Text('close'),
                onPressed: _inputConnection == null ? null : () => _close(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  late final TestTextInputClient _inputClient = TestTextInputClient(this);

  TextInputConnection? _inputConnection;

  TextInputConfiguration get _textInputConfiguration {
    return TextInputConfiguration(
      inputType: TextInputType.text,
    );
  }

  void _attach() {
    setState(() {
      _inputConnection = TextInput.attach(
        _inputClient,
        _textInputConfiguration,
      );
    });
  }

  void _close() {
    setState(() {
      _inputConnection?.close();
      _inputConnection = null;
      _textEditingValue = null;
    });
  }

  void _show() {
    setState(() {
      _inputConnection?.show();
    });
  }

  TextEditingValue? _textEditingValue;

  void onTextEditingValue(TextEditingValue textEditingValue) {
    setState(() {
      _textEditingValue = textEditingValue;
    });
  }

  void onClose() {
    setState(() {
      _textEditingValue = null;
    });
  }
}

class TestTextInputClient extends TextInputClient {
  TestTextInputClient(this.state);

  final AppState state;

  TextEditingValue? get currentTextEditingValue {
    print('currentTextEditingValue');
    return null;
  }

  AutofillScope? get currentAutofillScope {
    print('currentAutofillScope');
    return null;
  }

  void updateEditingValue(TextEditingValue value) {
    state.onTextEditingValue(value);
    print('updateEditingValue $value');
  }

  void performAction(TextInputAction action) {
    print('performAction $action');
  }

  void performPrivateCommand(String action, Map<String, dynamic> data) {
    print('performPrivateCommand $action $data');
  }

  void updateFloatingCursor(RawFloatingCursorPoint point) {
    print('updateFloatingCursor $point');
  }

  void showAutocorrectionPromptRect(int start, int end) {
    print('showAutocorrectionPromptRect $start $end');
  }

  void connectionClosed() {
    state.onClose();
    print('connectionClosed');
  }
}

extension TextInputConnectionX on TextInputConnection {
  String serialize() {
    final buffer = StringBuffer();
    buffer.writeln('{');
    buffer.writeln('  attached: $attached');
    buffer.write('}');
    return buffer.toString();
  }
}

extension TextEditingValueX on TextEditingValue {
  String serialize() {
    final buffer = StringBuffer();
    buffer.writeln('{');
    buffer.writeln('  text: ${this.text}');
    buffer.writeln('  selection: ${this.selection}');
    buffer.writeln('  composing: ${this.composing}');
    buffer.write('}');
    return buffer.toString();
  }
}
