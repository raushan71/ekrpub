import 'package:flutter_riverpod/flutter_riverpod.dart';

final typingIndicatorProvider = StateNotifierProvider.family<TypingIndicatorNotifier, Map<int, bool>, int>((ref, shopId) {
  return TypingIndicatorNotifier();
});

class TypingIndicatorNotifier extends StateNotifier<Map<int, bool>> {
  TypingIndicatorNotifier() : super({});

  void setTyping(int shopId, bool isTyping) {
    state = {...state, shopId: isTyping};
  }

  bool isTyping(int shopId) {
    return state[shopId] ?? false;
  }
}

