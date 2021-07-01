import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:highlight_text/highlight_text.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice Recognition',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SpeechScreen(),
    );
  }
}

class SpeechScreen extends StatefulWidget {
  @override
  _SpeechScreenState createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  final Map<String, HighlightedWord> _highlights = {
    'flutter': HighlightedWord(
        onTap: () => print('flutter'),
        textStyle:
            const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
    'voice': HighlightedWord(
        onTap: () => print('flutter'),
        textStyle:
            const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
    'Hello': HighlightedWord(
        onTap: () => print('flutter'),
        textStyle:
            const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
    'Hey': HighlightedWord(
        onTap: () => print('flutter'),
        textStyle:
            const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold))
  };

  stt.SpeechToText speech = stt.SpeechToText();
  bool _isListening = false;
  String _text = 'Press the mic button to start speaking';
  double _confidence = 1.0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
            'Confidence : ${(_confidence * 100.0).toStringAsFixed(1)}'), //to show 1 place after decimal
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: _isListening,
        glowColor: Theme.of(context).primaryColor,
        endRadius: 75.0,
        duration: const Duration(microseconds: 2000),
        repeatPauseDuration: const Duration(microseconds: 100),
        repeat: true,
        child: FloatingActionButton(
          onPressed: _listen,
          child: Icon(_isListening ? Icons.mic : Icons.mic_none),
          backgroundColor: Theme.of(context).primaryColor,
          hoverColor: Color(0xffdc143c),
        ),
      ),
      body: SingleChildScrollView(
        reverse: true,
        padding: EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 150.0),
        child: TextHighlight(text: _text, words: _highlights),
      ),
    );
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await speech.initialize(
          onStatus: (val) => print('onStatus: $val'),
          onError: (val) => print('onError: $val'));
      if (available) {
        setState(() => _isListening = true);
        speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
            if (val.hasConfidenceRating && val.confidence > 0) {
              _confidence = val.confidence;
            }
          }),
        );
      } else {
        setState(() {
          _isListening = false;
          speech.stop();
        });
      }
    }
  }
}
