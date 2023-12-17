import 'dart:io';
import 'package:ctrlfirl/constants/app_theme.dart';
import 'package:ctrlfirl/constants/colors.dart';
import 'package:ctrlfirl/controllers/auth_controller.dart';
import 'package:ctrlfirl/controllers/chat_controller.dart';
import 'package:ctrlfirl/recognizer/mlkit_text_recognizer.dart';
import 'package:ctrlfirl/screens/chat_screen.dart';
import 'package:ctrlfirl/screens/side_navigation_bar/side_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:ctrlfirl/models/recognition_response.dart';
import 'package:ctrlfirl/recognizer/interface/text_recognizer.dart';
import 'package:ctrlfirl/recognizer/tesseract_text_recognizer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:skeletonizer/skeletonizer.dart';

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
      child: Consumer2<AuthController, ChatController>(
          builder: (context, authController, chatController, child) {
        return Skeletonizer(
          enabled: authController.isLoading,
          child: Scaffold(
            appBar: AppBar(
              leadingWidth: 35,
              leading: IconButton(
                onPressed: () {
                  Navigator.of(context).push(_createRoute());
                },
                icon: const Icon(Icons.menu),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good Morning',
                    style: AppTheme.textTheme.labelMedium,
                  ),
                  Text(
                    authController.userData?.fullName ?? "",
                    style: AppTheme.textTheme.titleMedium,
                  ),
                ],
              ),
            ),
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
                                Provider.of<ChatController>(context,
                                    listen: false);
                            List<String> imagePath = image!.path.split('/');
                            chatController.setAppbarSubtitle(imagePath.last);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  recognizedText:
                                      _response?.recognizedText ?? '',
                                ),
                              ),
                            ).then((value) => {
                                  setState(() {
                                    _response = null;
                                  })
                                });
                          },
                          icon: const Icon(Icons.arrow_forward),
                        ),
                      ],
                    ),
                  )
                : null,
            body: Padding(
              padding: const EdgeInsets.all(15),
              child: _response == null
                  ? buildHomeScreen(chatController)
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Image.file(
                                  File(_response!.imgPath),
                                  height: 300,
                                ),
                                Text(
                                  _response!.recognizedText,
                                  style: AppTheme.textTheme.bodyMedium,
                                ),
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
      }),
    );
  }

  buildHomeScreen(ChatController chatController) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Image.asset(
                'assets/graphics/splash.png',
                color: Colors.white,
                height: 10.h,
              ),
              SizedBox(
                width: 1.w,
              ),
              Text("CTRLFIRL",
                  style:
                      AppTheme.textTheme.displayLarge?.copyWith(fontSize: 45))
            ],
          ),
          SizedBox(
            height: 2.h,
          ),
          Text(
              'Turn any image into a conversation starter.\nLet the pixels speak.',
              textAlign: TextAlign.center,
              style: AppTheme.textTheme.bodyMedium),
          SizedBox(
            height: 5.h,
          ),
          // To switch between MLKit and Tesseract
          Material(
            elevation: 5,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColors.scaffoldColor.withOpacity(0.9)),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text('Configuration ',
                          style: AppTheme.textTheme.titleLarge
                              ?.copyWith(color: AppColors.black)),
                    ],
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Material(
                          elevation: 5,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: AppColors.scaffoldColor.withOpacity(1)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text('Select OCR Engine: ',
                                        style: AppTheme.textTheme.titleLarge
                                            ?.copyWith(color: AppColors.black)),
                                  ],
                                ),
                                SizedBox(
                                  height: 1.h,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          _recognizer = MLKitTextRecognizer();
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _recognizer
                                                is MLKitTextRecognizer
                                            ? AppColors
                                                .green // Highlight the button if MLKit recognizer is active
                                            : null,
                                      ),
                                      child: Text(
                                        'MLKit',
                                        style: AppTheme.textTheme.bodyMedium
                                            ?.copyWith(color: AppColors.white),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 2.w,
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          _recognizer =
                                              TesseractTextRecognizer();
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _recognizer
                                                is TesseractTextRecognizer
                                            ? AppColors
                                                .green // Highlight the button if Tesseract recognizer is active
                                            : null,
                                      ),
                                      child: Text(
                                        'Tesseract',
                                        style: AppTheme.textTheme.bodyMedium
                                            ?.copyWith(color: AppColors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(
                          height: 3.h,
                        ),
                        // To switch between MLKit and Tesseract
                        Material(
                          elevation: 5,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: AppColors.scaffoldColor),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text('Select GPT Model: ',
                                        style: AppTheme.textTheme.titleLarge
                                            ?.copyWith(color: AppColors.black)),
                                  ],
                                ),
                                SizedBox(
                                  height: 1.h,
                                ),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: chatController.llmModels
                                        .map(
                                          (e) => Padding(
                                            padding: const EdgeInsets.only(
                                                right: 8.0),
                                            child: ElevatedButton(
                                              onPressed: () {
                                                setState(() {
                                                  chatController
                                                      .setSelectedModel(e);
                                                });
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: e ==
                                                        chatController
                                                            .selectedModel
                                                    ? AppColors
                                                        .green // Highlight the button if MLKit recognizer is active
                                                    : null,
                                              ),
                                              child: Text(
                                                e,
                                                style: AppTheme
                                                    .textTheme.bodyMedium
                                                    ?.copyWith(
                                                        color: AppColors.white),
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 3.h,
          ),

          ElevatedButton(
              onPressed: () async {
                await pickImage();
                processImage(image!.path);
              },
              child: const Text('CHAT')),
        ],
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

Route _createRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        const SideNavigationBar(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(-1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
