import 'package:social/model/message.dart';

class MessageCache {
  final Map<String, List<Message>> _cache = {};
  final Map<String, bool> _hasMoreMessages = {};
  final Map<String, int> _currentPage = {};
  
  void cacheMessages(String chatId, List<Message> messages, bool hasMore) {
    if (!_cache.containsKey(chatId)) {
      _cache[chatId] = [];
      _currentPage[chatId] = 1;
    }
    _cache[chatId]?.addAll(messages);
    _hasMoreMessages[chatId] = hasMore;
  }

  List<Message> getCachedMessages(String chatId) {
    return _cache[chatId] ?? [];
  }

  bool hasMore(String chatId) => _hasMoreMessages[chatId] ?? true;
  
  int getCurrentPage(String chatId) => _currentPage[chatId] ?? 1;
  
  void incrementPage(String chatId) {
    _currentPage[chatId] = (_currentPage[chatId] ?? 1) + 1;
  }

  void clear(String chatId) {
    _cache.remove(chatId);
    _hasMoreMessages.remove(chatId);
    _currentPage[chatId] = 1;
  }
}