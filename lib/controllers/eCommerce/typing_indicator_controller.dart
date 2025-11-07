import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider to track typing status for all shops
final typingIndicatorStateProvider = StateNotifierProvider<TypingIndicatorNotifier, Map<int, bool>>((ref) {
  return TypingIndicatorNotifier();
});

// Provider to get typing status for a specific shop
final typingIndicatorProvider = Provider.family<bool, int>((ref, shopId) {
  final typingState = ref.watch(typingIndicatorStateProvider);
  return typingState[shopId] ?? false;
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

