import 'package:flutter/material.dart';

import 'package:zefyrka/zefyrka.dart';

class ZefyrkaEditor extends StatefulWidget {
  const ZefyrkaEditor({Key? key}) : super(key: key);

  @override
  State<ZefyrkaEditor> createState() => _ZefyrkaEditorState();
}

class _ZefyrkaEditorState extends State<ZefyrkaEditor> {
  ZefyrController _controller = ZefyrController();

  @override
  Widget build(BuildContext context) {
    print(_controller.document.toJson());
    return Scaffold(
      appBar: AppBar(
        title: Text('ZefyrkaEditor'),
      ),
      body: Column(
        children: [
          ZefyrToolbar.basic(controller: _controller),
          Expanded(
            child: ZefyrEditor(
              controller: _controller,
            ),
          ),
        ],
      ),
    );

  }
}