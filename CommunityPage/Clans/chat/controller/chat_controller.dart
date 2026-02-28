// class ChatController extends ChangeNotifier {
//   final ChatStore store;

//   ChatController(this.store);

//   List<ChatMessage> messages(String chatId) {
//     return store.get(chatId);
//   }

//   void hydrate(String chatId, List<ChatMessage> msgs) {
//     store.set(chatId, msgs);
//     notifyListeners();
//   }

//   void onIncoming(ChatMessage msg) {
//     if (store.contains(msg.chatId, msg.id)) return;
//     store.insert(msg);
//     notifyListeners();
//   }
// }
