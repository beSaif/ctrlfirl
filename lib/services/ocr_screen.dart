import 'dart:io';
import 'package:ctrlfirl/controllers/chat_controller.dart';
import 'package:ctrlfirl/services/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:ctrlfirl/models/recognition_response.dart';
import 'package:ctrlfirl/recognizer/interface/text_recognizer.dart';
import 'package:ctrlfirl/recognizer/tesseract_text_recognizer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class OCRScreen extends StatefulWidget {
  const OCRScreen({super.key});

  @override
  State<OCRScreen> createState() => _OCRScreenState();
}

class _OCRScreenState extends State<OCRScreen> {
  late ImagePicker _picker;
  RecognitionResponse? _response;
  late ITextRecognizer _recognizer;

  XFile? image;
  @override
  void initState() {
    super.initState();
    _picker = ImagePicker();

    /// Can be [MLKitTextRecognizer] or [TesseractTextRecognizer]
    // _recognizer = MLKitTextRecognizer();
    _recognizer = TesseractTextRecognizer();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        bottomNavigationBar: _response != null
            ? BottomAppBar(
                height: 65,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        ChatController chatController =
                            Provider.of<ChatController>(context, listen: false);
                        List<String> imagePath = image!.path.split('/');
                        chatController.setAppbarSubtitle(imagePath.last);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChatScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.arrow_forward),
                    ),
                  ],
                ),
              )
            : null,
        body: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _response == null
                  ? Center(
                      child: ElevatedButton(
                          onPressed: () async {
                            await pickImage();
                            processImage(image!.path);
                          },
                          child: const Text('Upload Image')),
                    )
                  : Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Image.file(
                              File(_response!.imgPath),
                              height: 300,
                            ),
                            Text(_response!.recognizedText),
                            const SizedBox(
                              height: 15,
                            ),
                          ],
                        ),
                      ),
                    )
            ],
          ),
        ),
      ),
    );
  }

  pickImage() async {
    // Pick an image.
    final XFile? imageLocal =
        await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      image = imageLocal;
    });
  }

  void processImage(String imgPath) async {
    final recognizedText = await _recognizer.processImage(imgPath);
    setState(() {
      _response = RecognitionResponse(
        imgPath: imgPath,
        recognizedText: recognizedText,
      );
    });
    debugPrint(recognizedText);
  }
}
