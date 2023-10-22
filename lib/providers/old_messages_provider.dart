/* 
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OldNotifier extends StateNotifier<bool> {
  OldNotifier() : super(true);

  void newChat() {
    state = false;
  }
  void oldChat() {
    state = true;
  }
  bool getChatType() {
   return state;
  }
}

final oldMessagesProvider =
    StateNotifierProvider<OldNotifier, bool>((ref) => OldNotifier());
 */