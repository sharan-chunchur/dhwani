import 'package:animate_do/animate_do.dart';
import 'package:dhwani/utils/pallets.dart';
import 'package:dhwani/widgets/feature_box.dart';
import 'package:flutter/material.dart';
import '../services/open_ai_service.dart';

import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:flutter_tts/flutter_tts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  final aiAssistant = OpenAIService();
  String _currentlySpokenContent = '';
  String _lastWords = '';
  String? generatedContent;
  String? generatedImageUrl;
  int start = 200;
  int delay = 300;

  @override
  void initState() {
    super.initState();
    initSpeechToText();
    initTextToSpeech();
  }

  Future<void> initSpeechToText() async {
    await _speechToText.initialize();
    setState(() {});
  }

  /// Each time to start a speech recognition session
  Future<void> _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    print('_startListening : $_lastWords');
    setState(() { _lastWords; });
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  Future<void> _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
      setState(() async {
        // _lastWords = result.recognizedWords;
        print('_onSpeechResult : $_lastWords');
        if ( result.finalResult) {
          _lastWords = result.recognizedWords;
          // Do something with the final transcription result
          var res = await aiAssistant.isArtPromtAPI(_lastWords);
          if (res['isDallE']) {
            setState(() {
              generatedImageUrl = res['content'];
            });
          } else {
            setState(() {
              generatedContent = res['content'];
              generatedImageUrl = null;
            });
          }
          print('Final transcription result: $_lastWords');
        }
      });
  }

  void initTextToSpeech() async {
    await _flutterTts.setSharedInstance(true);
  }

  Future<void> systemSpeak(String content) async {
    if (content == _currentlySpokenContent) {
      // If the content to be spoken is the same as the currently spoken content, do nothing
      return;
    }

    await _flutterTts.speak(content);
    _currentlySpokenContent = content;
  }

  @override
  void dispose() {
    _speechToText.stop();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget resultWidget = FadeInRight(
      child: const Text(
        'Good Morning, How can I help you?',
        style: TextStyle(
            color: Pallete.mainFontColor,
            fontSize: 25,
            fontFamily: 'Cera Pro'),
      ),
    );

    if (generatedContent != null) {
      resultWidget = Text(
        generatedContent!,
        style: const TextStyle(
            color: Pallete.mainFontColor,
            fontSize: 18,
            fontFamily: 'Cera Pro'),
      );
      systemSpeak(generatedContent!);
    }

    if (generatedImageUrl != null) {
      resultWidget = Padding(
        padding: const EdgeInsets.all(8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.network(
            generatedImageUrl!,
            fit: BoxFit.fill,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.menu),
        ),
        title: BounceInDown(
          child: const Text(
            'DHWANI',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Virtual Assistant Picture
            Stack(
              children: [
                Center(
                  child: Container(
                    height: 100,
                    width: 100,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: const BoxDecoration(
                        color: Pallete.assistantCircleColor,
                        shape: BoxShape.circle),
                  ),
                ),
                ZoomIn(
                  child: Container(
                    height: 103,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: AssetImage(
                                'assets/images/virtualAssistant.png'))),
                  ),
                )
              ],
            ),
            Container(
              child: Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    margin: const EdgeInsets.fromLTRB(40, 16, 40, 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Pallete.borderColor),
                      borderRadius: BorderRadius.circular(20)
                          .copyWith(topLeft: const Radius.circular(0)),
                    ),
                    child: resultWidget,
                  ),
                  // features list
                  Visibility(
                    visible: (generatedContent != null || generatedImageUrl != null) ? false : true,
                    child: Column(
                      children:  [
                        SlideInLeft(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            alignment: Alignment.centerLeft,
                            child: const Text(
                              'Here are a few commands',
                              style: TextStyle(
                                  fontFamily: 'Cera Pro',
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        SlideInUp(
                          delay: Duration(milliseconds: start),
                          child: const FeatureBox(
                              title: 'Chat GPT',
                              color: Pallete.firstSuggestionBoxColor,
                              subtitle:
                                  'A smarter way to stay organized and informed with Chat GPT'),
                        ),
                        SlideInUp(
                          delay: Duration(milliseconds: start + delay),
                          child: const FeatureBox(
                              title: 'Dall-E',
                              color: Pallete.secondSuggestionBoxColor,
                              subtitle:
                                  'Get Inspired and stay creative with your personal assistant powered by Dall-E'),
                        ),
                        SlideInUp(
                          delay: Duration(milliseconds: start + 2*delay),
                          child: const FeatureBox(
                              title: 'Smart Voice Assistant',
                              color: Pallete.thirdSuggestionBoxColor,
                              subtitle:
                                  'Get the best of both worlds with a voice assistant powered by Dall_e and ChatGPT'),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ZoomIn(
        delay: Duration(milliseconds: start + 3*delay),
        child: FloatingActionButton(
          backgroundColor: Pallete.firstSuggestionBoxColor,
          onPressed: () async {
            if(await _speechToText.hasPermission &&
                _speechToText.isNotListening) {
              await _startListening();
            } else if (_speechToText.isListening) {
              await _stopListening();
            } else {
              initSpeechToText();
            }
          },
          child: Icon(_speechToText.isListening ? Icons.stop : Icons.mic),
        ),
      ),
    );
  }
}
