import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart' as tts;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:translator/translator.dart';

class SpeechScreen extends StatefulWidget {
  @override
  _SpeechScreenState createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _isSpeaking = false;
  String _text = 'Or press the button and start speaking';
  //double _confidence = 1.0;
  var chosenVal = "en";
  final _flutterTts = tts.FlutterTts();
  //final TextEditingController _controller = TextEditingController();
  final translator = GoogleTranslator();
  final screens = [
    SpeechScreen(),
    Center(child: Text('home')),
  ];
  @override
  void initState() {
    super.initState();
    initializeTts();
    _speech = stt.SpeechToText();
  }

  void initializeTts() {
    _flutterTts.setStartHandler(() {
      setState(() {
        _isSpeaking = true;
      });
    });
    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
      });
    });
    _flutterTts.setErrorHandler((message) {
      setState(() {
        _isSpeaking = false;
      });
    });
  }

  void speak() async {
    if (_text.isNotEmpty) {
      await _flutterTts.speak(_text);
    }
  }

  void stop() async {
    await _flutterTts.stop();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
            if (val.hasConfidenceRating && val.confidence > 0) {
              //  _confidence = val.confidence;
            }
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showFab = MediaQuery.of(context).viewInsets.bottom == 0.0;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        //   title: Text('Confidence:${(_confidence * 100).toStringAsFixed(1)}%'),
        title: Text('MyTranslator'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: showFab
          ? AvatarGlow(
              animate: _isListening,
              glowColor: Theme.of(context).primaryColor,
              endRadius: 75.0,
              duration: const Duration(milliseconds: 4000),
              repeatPauseDuration: const Duration(milliseconds: 100),
              repeat: true,
              child: FloatingActionButton(
                onPressed: () {
                  _listen();
                  FocusScope.of(context).unfocus();
                },
                child: Icon(_isListening ? Icons.mic : Icons.mic_none),
              ),
            )
          : null,
      body: SingleChildScrollView(
        reverse: true,
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                height: 40,
              ),
              Container(
                child: TextField(
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 60.0),
                      border: OutlineInputBorder(),
                      hintText: 'write your text',
                    ),
                    onChanged: (String? val) {
                      setState(() {
                        _text = val.toString();
                        chosenVal = 'en';
                      });
                    }),
              ),
              SizedBox(
                height: 20,
              ),
              DropdownButton(
                hint: new Text("Select your language"),
                items: <String>['en', 'hi', 'ml', 'hl']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    child: Text(value),
                    value: value,
                  );
                }).toList(),
                onChanged: (String? value) async {
                  var trans = await translator.translate(_text,
                      from: chosenVal, to: value.toString());
                  setState(() {
                    _text = trans.text;
                    chosenVal = value.toString();
                  });
                },
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                _text,
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  _isSpeaking ? stop() : speak();
                },
                child: Icon(_isSpeaking ? Icons.pause : Icons.play_arrow),
              )
            ],
          ),
        ),
      ),
    );
  }
}
