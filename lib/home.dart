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

  /// Pick image from gallery
  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final croppedFile = await _cropImage(pickedFile.path);
      if (croppedFile != null) {
        _navigateToImageDisplay(croppedFile);
      }
    }
  }

  /// Pick image from camera
  Future<void> _openCamera() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final croppedFile = await _cropImage(pickedFile.path);
      if (croppedFile != null) {
        _navigateToImageDisplay(croppedFile);
      }
    }
  }

  /// Navigate to preview page
  void _navigateToImageDisplay(File croppedFile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageDisplayPage(
          imageFile: croppedFile,
          onSend: (imagePath) async {
            context.read<XrayBloc>().add(
                  SendRequestEvent(
                    imagePath: imagePath,
                    pickedFile: XFile(croppedFile.path),
                  ),
                );
          },
        ),
      ),
    );
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
          ),
        ),
        actions: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return IconButton(
                onPressed: () => _showLogoutDialog(),
                icon: const Icon(Icons.logout),
              );
            },
          ),
        ],
      ),
      body: BlocListener<XrayBloc, XrayState>(
        listener: (context, state) {
          if (state is XrayRequestError) {
            showWarningDialog(context, state.message);
          }
        },
        child: BlocBuilder<XrayBloc, XrayState>(
          builder: (context, state) {
            final chats = state.chats;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            });

            if (state is XrayLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Center(
              child: chats.isEmpty
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
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      shrinkWrap: true,
                      itemCount: chats.length + 1,
                      itemBuilder: (context, index) {
                        if (index == chats.length) {
                          return const SizedBox(height: 80);
                        }
                        final chat = chats[index];
                        return _buildChatBubble(chat);
                      },
                    ),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            heroTag: 'gallery',
            foregroundColor: Colors.black,
            backgroundColor: Colors.white,
            onPressed: _pickImage,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: const Icon(Icons.add, size: 35),
          ),
          const SizedBox(width: 20),
          FloatingActionButton(
            heroTag: 'camera',
            foregroundColor: Colors.black,
            backgroundColor: Colors.white,
            onPressed: _openCamera,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: const Icon(Icons.camera, size: 35),
          ),
        ],
      ),
    );
  }

  /// Build chat bubble UI
  Widget _buildChatBubble(Map<String, dynamic> chat) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
                right: chat['sender'] != 'ai' ? 0 : 50,
              ),
              decoration: BoxDecoration(
                color: chat['sender'] != 'ai'
                    ? Colors.blue[100]
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (chat['image'] != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        '${Constants.server}/static/${chat['image']}',
                        width: 200,
                      ),
                    ),
                  if (chat['text'].isNotEmpty)
                    Padding(
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
          if (chat['sender'] == 'ai') ...[
            ElevatedButton(
              onPressed: () => _showZoneWiseDialog(chat),
              child: Text(
                'Zone Wise\nDetection',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Show logout dialog
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Rounded corners
        ),
        title: const Text(
          'Log Out',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Are you sure you want to log out?'),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthBloc>().add(LogoutEvent());
              Navigator.of(context).pop();
            },
            child: const Text(
              "Logout",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  /// Show zone wise detection dialog
  void _showZoneWiseDialog(Map<String, dynamic> chat) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
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
                onPressed: () => Navigator.pop(context),
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
      ),
    );
  }

  /// Crop image utility
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

  /// Show error warning dialog
  void showWarningDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 8),
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
            child: const Text('Back'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

/// Preview page for selected image
class ImageDisplayPage extends StatelessWidget {
  final File imageFile;
  final Function(String) onSend;

  const ImageDisplayPage({
    super.key,
    required this.imageFile,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Selected X-ray"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: Center(child: Image.file(imageFile)),
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
        child: const Icon(Icons.send),
      ),
    );
  }
}

/// Custom crop ratio
class CropAspectRatioPresetCustom implements CropAspectRatioPresetData {
  @override
  (int, int)? get data => (2, 3);

  @override
  String get name => '2x3 (customized)';
}
