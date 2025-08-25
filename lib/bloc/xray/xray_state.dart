part of 'xray_bloc.dart';

class XrayState {
  final List<Map<String, dynamic>> chats;
  XrayState({
    required this.chats,
  });
}

final class XrayInitial extends XrayState {
  XrayInitial({
    required super.chats
  });
}

final class XrayLoading extends XrayState {
  XrayLoading({
    required super.chats
  });
}

final class XrayLoaded extends XrayState {
  XrayLoaded({
    required super.chats
  });
}

final class XrayLoadError extends XrayState {
  XrayLoadError({
    required super.chats
  });
}

final class XrayRequestInitial extends XrayState {
  XrayRequestInitial({
    required super.chats
  });
}

final class XrayRequestSuccess extends XrayState {
  XrayRequestSuccess({
    required super.chats
  });
}

final class XrayRequestError extends XrayState {
  final String message;
  XrayRequestError({
    required super.chats,
    required this.message
  });
}