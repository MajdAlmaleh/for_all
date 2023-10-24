import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReplayNotifier extends StateNotifier<String?> {
  ReplayNotifier() : super(null);
  void setReplay(String relplay) {
    state = relplay;
  }

  void cancleReplay() {
    state = null;
  }

  String? getReplay() {
    return state;
  }
}

final replyMessageProvider =
    StateNotifierProvider<ReplayNotifier, String?>((ref) => ReplayNotifier());
