part of 'xray_bloc.dart';

class XrayEvent {}

class XrayLoadEvent extends XrayEvent {}

class SendRequestEvent extends XrayEvent {
  final String imagePath;
  final XFile? pickedFile;
  SendRequestEvent({
    required this.imagePath,
    this.pickedFile,
  });
}

class NewChatReceivedEvent extends XrayEvent {
  final Map<String, dynamic> chat;

  NewChatReceivedEvent({required this.chat});
}