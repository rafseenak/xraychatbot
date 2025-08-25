import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:xraychatboat/bloc/auth/auth_bloc.dart';
import 'package:xraychatboat/bloc/xray/xray_bloc.dart';
import 'package:xraychatboat/services/constants.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ImagePicker _picker = ImagePicker();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<XrayBloc>().add(XrayLoadEvent());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final croppedFile = await _cropImage(pickedFile.path);
      if(croppedFile != null){
        Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageDisplayPage(
            imageFile: File(croppedFile.path),
            onSend: (imagePath) async {
              context.read<XrayBloc>().add(SendRequestEvent(
                  imagePath: imagePath, pickedFile: XFile(croppedFile.path)));
            },
          ),
        ),
      );
      }
    }
  }

  Future<void> _openCamera() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final croppedFile = await _cropImage(pickedFile.path);
      if(croppedFile != null){
        Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageDisplayPage(
            imageFile: File(croppedFile.path),
            onSend: (imagePath) async {
              context.read<XrayBloc>().add(SendRequestEvent(
                  imagePath: imagePath, pickedFile: XFile(croppedFile.path)));
            },
          ),
        ),
      );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(
          'XRAYCAD',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        )),
        actions: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Log Out'),
                          content: Text('Do you want to logout?'),
                          actions: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  child: Text(
                                    "Cancel",
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 224, 23, 23)
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: Text(
                                    "OK",
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 67, 196, 235)
                                    ),
                                  ),
                                  onPressed: () {
                                    context.read<AuthBloc>().add(LogoutEvent());
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            )
                          ],
                        );
                      },
                    );
                  },
                  icon: Icon(Icons.logout));
            },
          )
        ],
      ),
      body: BlocListener<XrayBloc, XrayState>(
        listener: (context, state1) {
          if (state1 is XrayRequestError) {
            final errorMessage = state1.message;
            showWarningDialog(context, errorMessage);
          }
        },
        child: BlocBuilder<XrayBloc, XrayState>(
          builder: (context, state) {
            final chats = state.chats;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            });
            if(state is XrayLoading){
              return Center(child: CircularProgressIndicator());
            }

            return Center(
              child: (chats.isEmpty)
                  ? Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Text(
                        'AI Engine for Computer Aided Diagnosis of Chest X-ray',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ))
                  : ListView.builder(
                      controller: _scrollController,
                      shrinkWrap: true,
                      itemCount: chats.length + 1,
                      itemBuilder: (context, index) {
                        if (index == chats.length) {
                          return const SizedBox(height: 80);
                        }
                        final chat = chats[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: chat['sender'] != 'ai'
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.all(5.0),
                                  margin: EdgeInsets.only(
                                      left: chat['sender'] != 'ai' ? 50 : 0,
                                      right: chat['sender'] != 'ai' ? 0 : 50),
                                  decoration: BoxDecoration(
                                    color: chat['sender'] != 'ai'
                                        ? Colors.blue[100]
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      (chat['image'] != null)
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.network(
                                              '${Constants.server}/static/${chat['image']}',
                                              width: 200))
                                      : SizedBox(),
                                      chat['text'].isEmpty
                                      ? SizedBox()
                                      : Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: Text(
                                            chat['text'],
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        
                                    ],
                                  ),
                                ),
                              ),
                              if(chat['sender'] == 'ai')...[
                                ElevatedButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return Dialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  "Zone Wise Detection",
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(10),
                                                  child: Image.network(
                                                    '${Constants.server}/static/${chat['zone']}',
                                                    width: 300,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                const SizedBox(height: 15),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text(
                                                    "Close",
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Text(
                                    'Zone Wise\nDetection',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                    textAlign: TextAlign.end,
                                  ),
                                )

                                // ElevatedButton(
                                //   onPressed: (){
                                //     Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ZoneWiseResultPage()));
                                //   },
                                //   child: Text(
                                //     'Zone Wise\nDetection',
                                //     style: GoogleFonts.poppins(
                                //       fontSize: 10,
                                //       fontWeight: FontWeight.bold,
                                //       color: Colors.blue,
                                //     ),
                                //     textAlign: TextAlign.end,
                                //   )
                                // )
                              ]
                            ],
                          ),
                        );
                      },
                    ),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FloatingActionButton(
            heroTag: 'gallary',
            foregroundColor: Colors.black,
            backgroundColor: Colors.white,
            onPressed: _pickImage,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: Icon(Icons.add, size: 35),
          ),
          SizedBox(width: 20),
          FloatingActionButton(
            heroTag: 'camera',
            foregroundColor: Colors.black,
            backgroundColor: Colors.white,
            onPressed: _openCamera,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: Icon(Icons.camera, size: 35),
          ),
        ],
      ),
    );
  }

  Future<File?> _cropImage(String path) async {
    final cropped = await ImageCropper().cropImage(
      sourcePath: path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Colors.grey,
          toolbarWidgetColor: Colors.white,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPresetCustom(),
          ],
        ),
        IOSUiSettings(
          title: 'Cropper',
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPresetCustom(),
          ],
        ),
        WebUiSettings(context: context),
      ],
    );
    return cropped != null ? File(cropped.path) : null;
  }

  void showWarningDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                overflow: TextOverflow.clip,
                softWrap: true,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Back'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class ImageDisplayPage extends StatelessWidget {
  final File imageFile;
  final Function(String) onSend;

  const ImageDisplayPage(
      {super.key, required this.imageFile, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Selected X-ray"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Image.file(imageFile),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          onSend(imageFile.path);
          Navigator.pop(context);
        },
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: Icon(Icons.send),
      ),
    );
  }
}

class CropAspectRatioPresetCustom implements CropAspectRatioPresetData {
  @override
  (int, int)? get data => (2, 3);

  @override
  String get name => '2x3 (customized)';
}