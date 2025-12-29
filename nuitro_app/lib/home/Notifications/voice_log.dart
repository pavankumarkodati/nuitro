import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:nuitro/providers/scan_workflow_provider.dart';

import 'record_stop_button.dart';

class VoiceLogController {
  _VoiceLogState? _state;

  void submit() => _state?._submit();

  String get text => _state?._textController.text ?? '';

  bool get isListening => _state?._isListening ?? false;

  void _attach(_VoiceLogState state) {
    _state = state;
  }

  void _detach(_VoiceLogState state) {
    if (_state == state) {
      _state = null;
    }
  }
}

class VoiceLog extends StatefulWidget {
  final ValueChanged<String>? onTextChanged;
  final ValueChanged<String>? onSubmit;
  final VoiceLogController? controller;

  const VoiceLog({Key? key, this.onTextChanged, this.onSubmit, this.controller})
      : super(key: key);

  @override
  State<VoiceLog> createState() => _VoiceLogState();
}

class _VoiceLogState extends State<VoiceLog> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _spokenText = "";
  bool _speechReady = false;
  bool _initializing = false;
  late TextEditingController _textController;
  bool _controllerInitialized = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _textController = TextEditingController();
    _initializeSpeechEngine();
    widget.controller?._attach(this);
  }

  @override
  void dispose() {
    widget.controller?._detach(this);
    _textController.dispose();
    _speech.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant VoiceLog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detach(this);
      widget.controller?._attach(this);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controllerInitialized) {
      return;
    }
    final workflow = context.read<ScanWorkflowProvider>();
    final transcript = workflow.voiceTranscript;
    if (transcript.isNotEmpty) {
      _textController.text = transcript;
      _spokenText = transcript;
      _textController.selection = TextSelection.fromPosition(
        TextPosition(offset: _textController.text.length),
      );
    }
    _controllerInitialized = true;
  }

  Future<void> _initializeSpeechEngine() async {
    if (_initializing) return;
    _initializing = true;
    try {
      _speechReady = await _speech.initialize(
        onStatus: (status) {
          if (status == 'notListening' && mounted) {
            setState(() => _isListening = false);
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _isListening = false;
              _spokenText = '';
            });
          }
        },
      );

      if (!_speechReady && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Speech recognition unavailable or permission denied.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Speech recognizer not available on this device.')),
        );
        setState(() {
          _speechReady = false;
        });
      }
    } finally {
      _initializing = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _toggleListening() async {
    if (!_speechReady) {
      await _initializeSpeechEngine();
      if (!_speechReady) return;
    }

    if (_isListening) {
      await _speech.stop();
      if (!mounted) return;
      setState(() => _isListening = false);
    } else {
      _textController.clear();
      setState(() {
        _spokenText = '';
        _isListening = true;
      });
      widget.onTextChanged?.call('');
      context.read<ScanWorkflowProvider>().clearVoiceTranscript();

      final started = await _speech.listen(onResult: (result) {
        if (!mounted) return;
        setState(() {
          _spokenText = result.recognizedWords;
          _textController.text = _spokenText;
          _textController.selection = TextSelection.fromPosition(
              TextPosition(offset: _textController.text.length));
        });
        widget.onTextChanged?.call(_spokenText);
        context.read<ScanWorkflowProvider>().setVoiceTranscript(_spokenText);
      });

      if (!started && mounted) {
        setState(() => _isListening = false);
      }
    }
  }

  void _submit() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    context.read<ScanWorkflowProvider>().setVoiceTranscript(text);
    widget.onSubmit?.call(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Voice Log",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                        decoration: const BoxDecoration(
                            color: Color.fromRGBO(35, 34, 32, 1),
                            shape: BoxShape.circle),
                        child: const Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(Icons.close, color: Colors.white))),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Image.asset(
              "assets/images/Cat.png",
              height: 250,
            ),
            const Text(
              "Log with voice Prompt",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            if (!_isListening && _spokenText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _spokenText,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: _textController,
                    onChanged: (text) {
                      setState(() {
                        _spokenText = text;
                      });
                      widget.onTextChanged?.call(_spokenText);
                      context.read<ScanWorkflowProvider>().setVoiceTranscript(text);
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      hintText: _isListening ? 'Listening...' : 'Speak or type here',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        icon: _isListening
                            ? Frame61()
                            : SvgPicture.asset(
                                'assets/images/Voice Wave - Dark.svg',
                                height: 24,
                                width: 24,
                              ),
                        onPressed: _toggleListening,
                      ),
                    ),
                  ),
                  // const SizedBox(height: 20),
                  // if (!_isListening && _spokenText.isNotEmpty)
                  //   ElevatedButton(
                  //     onPressed: _submit,
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: const Color.fromRGBO(220, 250, 157, 1),
                  //       minimumSize: const Size(double.infinity, 50),
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(12),
                  //       ),
                  //     ),
                  //     child: const Text(
                  //       'Submit',
                  //       style: TextStyle(
                  //         fontWeight: FontWeight.w500,
                  //         fontSize: 15,
                  //         color: Colors.black,
                  //       ),
                  //     ),
                  //   ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


