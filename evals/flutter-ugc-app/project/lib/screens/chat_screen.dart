import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String roomId;
  final String roomName;

  const ChatScreen({super.key, required this.roomId, required this.roomName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _user = FirebaseAuth.instance.currentUser!;

  CollectionReference get _messages =>
      FirebaseFirestore.instance.collection('rooms').doc(widget.roomId).collection('messages');

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    await _messages.add({
      'text': text,
      'senderId': _user.uid,
      'senderName': _user.displayName ?? 'Anonymous',
      'sentAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _sendGift(String recipientId) async {
    final users = FirebaseFirestore.instance.collection('users');
    await FirebaseFirestore.instance.runTransaction((tx) async {
      final me = await tx.get(users.doc(_user.uid));
      final coins = (me['coins'] as int);
      if (coins < 50) return;
      tx.update(users.doc(_user.uid), {'coins': coins - 50});
      tx.update(users.doc(recipientId), {'coins': FieldValue.increment(50)});
    });
    await _messages.add({
      'text': '🎁 sent a gift!',
      'senderId': _user.uid,
      'senderName': _user.displayName ?? 'Anonymous',
      'sentAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.roomName)),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _messages.orderBy('sentAt', descending: true).limit(200).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final m = docs[i].data() as Map<String, dynamic>;
                    final mine = m['senderId'] == _user.uid;
                    final sentAt = (m['sentAt'] as Timestamp?)?.toDate();
                    return ListTile(
                      title: Text(m['senderName'] ?? ''),
                      subtitle: Text(m['text'] ?? ''),
                      trailing: sentAt == null ? null : Text(DateFormat.Hm().format(sentAt)),
                      onLongPress: mine ? null : () => _sendGift(m['senderId']),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextField(controller: _controller, decoration: const InputDecoration(hintText: 'Say something...')),
                  ),
                ),
                IconButton(icon: const Icon(Icons.send), onPressed: _send),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
