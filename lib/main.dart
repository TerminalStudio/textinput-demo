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
                onPressed:
                    _inputConnection?.attached == true ? null : () => _attach(),
              ),
              SizedBox(height: 15),
              ElevatedButton(
                child: Text('show'),
                onPressed:
                    _inputConnection?.attached != true ? null : () => _show(),
              ),
              SizedBox(height: 15),
              ElevatedButton(
                child: Text('close'),
                onPressed: _inputConnection == null ? null : () => _close(),
              ),
              SizedBox(height: 15),
              NumberField(
                name: 'editableWidth',
                initValue: editableWidth,
                onChanged: (_) {
                  setState(() {});
                },
                onValue: (value) {
                  editableWidth = value;
                  _updateEditableSizeAndTransform();
                },
              ),
              NumberField(
                name: 'editableHeight',
                initValue: editableHeight,
                onChanged: (_) {
                  setState(() {});
                },
                onValue: (value) {
                  editableHeight = value;
                  _updateEditableSizeAndTransform();
                },
              ),
              NumberField(
                name: 'editableOffsetX',
                initValue: editableOffsetX,
                onChanged: (_) {
                  setState(() {});
                },
                onValue: (value) {
                  editableOffsetX = value;
                  _updateEditableSizeAndTransform();
                },
              ),
              NumberField(
                name: 'editableOffsetY',
                initValue: editableOffsetY,
                onChanged: (_) {
                  setState(() {});
                },
                onValue: (value) {
                  editableOffsetY = value;
                  _updateEditableSizeAndTransform();
                },
              ),
              SizedBox(height: 15),
              Text('lastKeyEvent ${lastKeyEvent?.serialize()}'),
              SizedBox(height: 15),
              FocusDetect(onKeyPress: (event) {
                lastKeyEvent = event;
              }),
              Text('Click the rect above to toggle focus.'),
            ],
          ),
        ),
      ),
    );
  }

  RawKeyEvent? lastKeyEvent;

  late final TestTextInputClient _inputClient = TestTextInputClient(this);

  TextInputConnection? _inputConnection;

  var editableWidth = 10.0;
  var editableHeight = 10.0;
  var editableOffsetX = 10.0;
  var editableOffsetY = 10.0;

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
      _inputConnection?.setEditingState(TextEditingValue.empty);
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

  void _updateEditableSizeAndTransform() {
    setState(() {
      _inputConnection?.setEditableSizeAndTransform(
        Size(editableWidth, editableHeight),
        Matrix4.translationValues(editableOffsetX, editableOffsetY, 0.0),
      );
    });
  }
}

class TestTextInputClient extends TextInputClient {
  TestTextInputClient(this.state);

  final AppState state;

  TextEditingValue? _currentTextEditingValue;

  TextEditingValue? get currentTextEditingValue {
    print('currentTextEditingValue');
    return _currentTextEditingValue;
  }

  AutofillScope? get currentAutofillScope {
    print('currentAutofillScope');
    return null;
  }

  void updateEditingValue(TextEditingValue value) {
    state.onTextEditingValue(value);
    _currentTextEditingValue = value;
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

extension RawKeyEventX on RawKeyEvent {
  String serialize() {
    final buffer = StringBuffer();
    buffer.writeln('{');
    buffer.writeln('  logicalKey: ${this.logicalKey}');
    buffer.writeln('  character: ${this.character}');
    buffer.write('}');
    return buffer.toString();
  }
}

class NumberField extends StatelessWidget {
  NumberField({
    required this.name,
    required this.onValue,
    required this.onChanged,
    required this.initValue,
  });

  final String name;
  final double initValue;
  final void Function(String) onChanged;
  final void Function(double) onValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: 270,
      ),
      child: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: name),
        onChanged: (content) {
          onChanged(content);
          final value = double.tryParse(content);
          if (value != null) {
            onValue(value);
          }
        },
      ),
    );
  }

  TextEditingController get _controller {
    return TextEditingController.fromValue(
      TextEditingValue(text: initValue.toString()),
    );
  }
}

class FocusDetect extends StatelessWidget {
  FocusDetect({
    required this.onKeyPress,
  });

  final void Function(RawKeyEvent) onKeyPress;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKey: _handleKeyPress,
      child: Builder(
        builder: (BuildContext context) {
          final FocusNode focusNode = Focus.of(context);
          final bool hasFocus = focusNode.hasFocus;
          return GestureDetector(
            onTap: () {
              if (hasFocus) {
                focusNode.unfocus();
              } else {
                focusNode.requestFocus();
              }
            },
            child: Container(
              width: 200,
              height: 100,
              alignment: Alignment.center,
              color: hasFocus ? Colors.red : Colors.grey,
              child: Text(hasFocus ? "hasFocus" : '!hasFocus'),
            ),
          );
        },
      ),
    );
  }

  KeyEventResult _handleKeyPress(FocusNode node, RawKeyEvent event) {
    onKeyPress(event);
    print('_handleKeyPress $event');
    return KeyEventResult.ignored;
  }
}
