import 'dart:typed_data';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:tweech/resources/firestore_methods.dart';
import 'package:tweech/screens/broadcast_screen.dart';
import 'package:tweech/utils/colors.dart';
import 'package:tweech/utils/utils.dart';
import 'package:tweech/widget/custom_button.dart';
import 'package:tweech/widget/custom_textfield.dart';

class GoLiveScreen extends StatefulWidget {
  const GoLiveScreen({Key? key}) : super(key: key);

  @override
  State<GoLiveScreen> createState() => _GoLiveScreenState();
}

class _GoLiveScreenState extends State<GoLiveScreen> {
  late TextEditingController _titleController;
  Uint8List? _thumbnail;
  bool _goingLive = false;

  @override
  initState() {
    _titleController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        children: [
          const SizedBox(
            height: 15,
          ),
          _thumbnail != null
              ? GestureDetector(
                  onTap: _selectThumbnail,
                  child: Container(
                    // height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10),
                      ),
                      child: Image.memory(
                        _thumbnail!,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                )
              : GestureDetector(
                  onTap: _selectThumbnail,
                  child: DottedBorder(
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(10),
                    dashPattern: const [10, 4],
                    strokeCap: StrokeCap.round,
                    color: btnColor,
                    child: Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                        color: btnColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.folder_open_outlined,
                            color: btnColor,
                            size: 40,
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Text(
                            "Choose video thumbnail",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          const SizedBox(
            height: 40,
          ),
          const Text(
            "Title",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.left,
          ),
          const SizedBox(
            height: 10,
          ),
          CustomTextField(
            controller: _titleController,
            icon: Icons.text_fields_outlined,
            inputType: TextInputType.text,
          ),
          const SizedBox(
            height: 30,
          ),
          if (_goingLive)
            const Center(
              child: CircularProgressIndicator.adaptive(),
            ),
          Visibility(
            visible: !_goingLive,
            child: CustomButton(
              text: 'Go Live',
              press: _startStreaming,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  _selectThumbnail() async {
    Uint8List? _pickedThumbnail = await imagePicker();
    if (_pickedThumbnail != null) {
      _thumbnail = _pickedThumbnail;
      setState(() {});
    }
  }

  void _startStreaming() async {
    toggleKeypad(context);
    _goingLive = true;
    setState(() {});
    String _channelId = await FirestoreMethods()
        .startLiveStream(context, _titleController.text, _thumbnail);
    _goingLive = false;
    setState(() {});
    if (_channelId.isNotEmpty) {
      showSnackBar(context, "Nice, livestream has started ");
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              // BroadCastScreen(isBroadcaster: true, channelId: 'test123'),
              BroadCastScreen(isBroadcaster: true, channelId: _channelId),
        ),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}
