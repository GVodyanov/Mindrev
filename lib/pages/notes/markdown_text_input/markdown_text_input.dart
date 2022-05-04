/*
TAKEN FROM: https://github.com/playmoweb/markdown-editable-textinput
ADAPTED TO MINDREV
 */

import 'package:flutter/material.dart';
import 'package:mindrev/extra/theme.dart';
import 'package:mindrev/widgets/widgets.dart';
import 'format_markdown.dart';
import 'package:expandable/expandable.dart';

/// Widget with markdown buttons
class MarkdownTextInput extends StatefulWidget {
  /// Callback called when text changed
  final Function onTextChanged;

  /// Initial value you want to display
  final String initialValue;

  /// Validator for the TextFormField
  final String? Function(String? value)? validators;

  /// Change the text direction of the input (RTL / LTR)
  final TextDirection? textDirection;

  /// The maximum of lines that can be display in the input
  final int? maxLines;

  /// List of action the component can handle
  final List<MarkdownType> actions;

  /// Optional controller to manage the input
  final TextEditingController? controller;

  //theme
  final MindrevTheme theme;

  //scroll controller for hiding appBar
  final ScrollController scrollController;

  /// Constructor for [MarkdownTextInput]
  const MarkdownTextInput(
    this.onTextChanged,
    this.initialValue, {
    Key? key,
    this.validators,
    this.textDirection = TextDirection.ltr,
    this.maxLines = 10,
    this.actions = const [
      MarkdownType.bold,
      MarkdownType.italic,
      MarkdownType.title,
      MarkdownType.link,
      MarkdownType.list
    ],
    this.controller,
    required this.theme,
    required this.scrollController,
  }) : super(key: key);

  @override
  _MarkdownTextInputState createState() =>
      // ignore: no_logic_in_create_state
      _MarkdownTextInputState(controller ?? TextEditingController());
}

class _MarkdownTextInputState extends State<MarkdownTextInput> {
  final TextEditingController _controller;
  TextSelection textSelection = const TextSelection(baseOffset: 0, extentOffset: 0);

  _MarkdownTextInputState(this._controller);

  void onTap(MarkdownType type, {int titleSize = 1}) {
    final basePosition = textSelection.baseOffset;
    var noTextSelected = (textSelection.baseOffset - textSelection.extentOffset) == 0;

    final result = FormatMarkdown.convertToMarkdown(
      type,
      _controller.text,
      textSelection.baseOffset,
      textSelection.extentOffset,
      titleSize: titleSize,
    );

    _controller.value = _controller.value.copyWith(
      text: result.data,
      selection: TextSelection.collapsed(offset: basePosition + result.cursorIndex),
    );

    if (noTextSelected) {
      _controller.selection = TextSelection.collapsed(
        offset: _controller.selection.end - result.replaceCursorIndex,
      );
    }
  }

  @override
  void initState() {
    _controller.text = widget.initialValue;
    _controller.addListener(() {
      if (_controller.selection.baseOffset != -1) textSelection = _controller.selection;
      widget.onTextChanged(_controller.text);
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Stack(
        fit: StackFit.expand,
        alignment: AlignmentDirectional.topStart,
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Positioned(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 50),
              child: SingleChildScrollView(
                controller: widget.scrollController,
                child: Material(
                  elevation: 3,
                  color: theme.primary,
                  child: TextFormField(
                    autofocus: true,
                    textInputAction: TextInputAction.newline,
                    maxLines: widget.maxLines,
                    controller: _controller,
                    textCapitalization: TextCapitalization.sentences,
                    validator: (value) => widget.validators!(value),
                    cursorColor: theme.accent,
                    style: defaultPrimaryTextStyle(),
                    textDirection: widget.textDirection,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(8),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 44,
              child: Material(
                color: theme.secondary,
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                elevation: 4,
                child: Center(
                  child: ListView(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    children: widget.actions.map((type) {
                      return type == MarkdownType.title
                          ? ExpandableNotifier(
                              child: Expandable(
                                key: const Key('H#_button'),
                                collapsed: ExpandableButton(
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Text(
                                        'H#',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: theme.secondaryText),
                                      ),
                                    ),
                                  ),
                                ),
                                expanded: Container(
                                  color: Colors.white10,
                                  child: Row(
                                    children: [
                                      for (int i = 1; i <= 6; i++)
                                        InkWell(
                                          key: Key('H${i}_button'),
                                          onTap: () => onTap(MarkdownType.title, titleSize: i),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Text(
                                              'H$i',
                                              style: TextStyle(
                                                fontSize: (18 - i).toDouble(),
                                                fontWeight: FontWeight.w700,
                                                color: theme.secondaryText,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ExpandableButton(
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Icon(
                                            Icons.close,
                                            color: theme.secondaryText,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : InkWell(
                              key: Key(type.key),
                              onTap: () => onTap(type),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Icon(
                                  type.icon,
                                  color: theme.secondaryText,
                                ),
                              ),
                            );
                    }).toList(),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
