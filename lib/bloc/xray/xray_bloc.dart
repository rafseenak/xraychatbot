
import 'package:bloc/bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xraychatboat/models/xray_response.dart';
import 'package:xraychatboat/services/api_service.dart';
import 'package:xraychatboat/services/socket_service.dart';
part 'xray_event.dart';
part 'xray_state.dart';

class XrayBloc extends Bloc<XrayEvent, XrayState> {
  final SocketService socketService = SocketService();
  final ApiService apiService = ApiService();
  XrayBloc() : super(XrayInitial(chats: [])) {
    socketService.connect(onNewChat: (chat) {
      add(NewChatReceivedEvent(chat: chat));
    }); 
    on<SendRequestEvent>(_onSendRequestEvent);
    on<XrayLoadEvent>(_onXrayLoadEvent);
    on<NewChatReceivedEvent>(_onNewChatReceivedEvent);
  }

  Future<void> _onSendRequestEvent(SendRequestEvent event, Emitter<XrayState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    String? userName = prefs.getString('userName');
    try {
      final currentChats = List<Map<String, dynamic>>.from(state.chats);
      emit(XrayLoading(chats: currentChats));

      XrayResponse response = await apiService.sendRequest(userName!, event.imagePath);
      print(response.toJson());
      if (response.status == 'error') {
        final currentChats = List<Map<String, dynamic>>.from(state.chats);
        emit(XrayRequestError(chats: currentChats, message: response.message));
      } else {
        final currentChats = List<Map<String, dynamic>>.from(state.chats);

        // Send the original uploaded image as a chat message
        for (var fileData in response.files) {
          await socketService.sendChat({
            "text": '',
            "image": 'images/RAWImage/${fileData.fileName}',
            "sender": userName,
            "receiver": "ai"
          });
          await Future.delayed(Duration(milliseconds: 200)); 
          // Flatten diseases for chat messages
          for (var disease in fileData.diseases) {
            await socketService.sendChat({
              "text": '${disease.name}: ${disease.predProb.toStringAsFixed(2)}%',
              "image": disease.camFile,
              "sender": "ai",
              "receiver": userName,
              "zone": disease.annotatedPath
            });
          }
        }

        emit(XrayRequestSuccess(chats: currentChats));
      }
    } catch (e) {
      final currentChats = List<Map<String, dynamic>>.from(state.chats);
      emit(XrayRequestError(chats: currentChats, message: e.toString()));
    }
  }


  Future<void> _onXrayLoadEvent(XrayLoadEvent event, Emitter<XrayState> emit) async {
    emit(XrayLoading(chats: []));
    final prefs = await SharedPreferences.getInstance();
    String? userName = prefs.getString('userName');
    List<Map<String, dynamic>> chats = await apiService.fetchChats(userName!);
    emit(XrayInitial(chats: chats));
  }

  Future<void> _onNewChatReceivedEvent(NewChatReceivedEvent event, Emitter<XrayState> emit) async {
    final currentChats = List<Map<String, dynamic>>.from(state.chats);
    currentChats.add(event.chat);
    emit(XrayInitial(chats: currentChats));
  }
}
