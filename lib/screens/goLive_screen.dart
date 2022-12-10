import 'dart:typed_data';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
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

  @override
  initState() {
    _titleController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: _selectThumbnail,
        child: _thumbnail != null
            ? SizedBox(
                height: 350,
                child: Image.memory(_thumbnail!),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DottedBorder(
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
                  const Spacer(),
                  CustomButton(
                    text: 'Go Live',
                    press: () {},
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
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

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}
