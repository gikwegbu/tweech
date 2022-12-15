import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tweech/config/constants.dart';
import 'package:tweech/providers/user_provider.dart';
import 'package:tweech/resources/firestore_methods.dart';
import 'package:tweech/widget/custom_textfield.dart';
import 'package:tweech/widget/loadingIndicator.dart';

class ChatComponent extends StatefulWidget {
  const ChatComponent({Key? key, required this.channelId}) : super(key: key);
  final String channelId;

  @override
  State<ChatComponent> createState() => _ChatComponentState();
}

class _ChatComponentState extends State<ChatComponent> {
  final TextEditingController _chatController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    print("George this is the chat channel ID:::${widget.channelId}");
    final userProvider = Provider.of<UserProvider>(context, listen: true);
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          Expanded(
            child: StreamBuilder<dynamic>(
              stream: FirebaseFirestore.instance
                  .collection(liveStreamCollection)
                  .doc(widget.channelId)
                  .collection(liveStreamCommentsCollection)
                  .orderBy(liveStreamCommentOrderingFactor, descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingIndicator();
                }

                return ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) => ListTile(
                    title: Text(
                      snapshot.data.docs[index]['username'],
                      style: TextStyle(
                        color:
                            snapshot.data.docs[index]['uid'] == userProvider.user.uid
                                ? Colors.blue
                                : Colors.black,
                      ),
                    ),
                    subtitle: Text(snapshot.data.docs[index]['message']),
                  ),
                );
              },
            ),
          ),
          CustomTextField(
            controller: _chatController,
            icon: Icons.send,
            inputType: TextInputType.text,
            iconPress: () {
              if (_chatController.text.isNotEmpty) {
                FirestoreMethods()
                    .chatting(context, _chatController.text, widget.channelId);
                _chatController.clear();
                setState(
                  () {},
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }
}
