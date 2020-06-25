import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'tag_chip.dart';

class TagSelectionDialog extends StatefulWidget {
  const TagSelectionDialog(this.scaffoldContext);
  final BuildContext scaffoldContext;

  @override
  State<StatefulWidget> createState() {
    return _TagSelectionState();
  }
}

class _TagSelectionState extends State<TagSelectionDialog> {
  bool addingNewTag = false;

  TextEditingController _textEditingController;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  List<Widget> tagChoiceChipList(ValueNotifier<Set<String>> tagNotifier) {
    final tags = tagNotifier.value;
    return [].map((tag) {
      return Container(
        padding: const EdgeInsets.all(2),
        child: NoteTagChip(
          selectable: true,
          selected: tags.contains(tag.id),
          onSelected: (selected) async {
            final updatedTags = {...tags}; // copy
            if (selected) {
              updatedTags.add(tag.id);
            } else {
              updatedTags.remove(tag.id);
            }
            tagNotifier.value = updatedTags;
          },
        ),
      );
    }).toList();
  }

  Future<void> onCreatePressed() async {
    if (!_formKey.currentState.validate()) {
      return;
    }

    final scaffold = Scaffold.of(widget.scaffoldContext)
      ..showSnackBar(SnackBar(content: Text('Saving the tag')));

    final tagName = _textEditingController.text;

    _textEditingController.clear();
    setState(() {
      addingNewTag = false;
    });

  }

  String validateNewTagName(String newTagName) {
    final tagNames = [].map((t) => t.name).toSet();
    if (newTagName.length <= 1) {
      return 'Tag name too short';
    }
    if (tagNames.contains(newTagName)) {
      // If _tag is null, it's a new tag
      return 'Duplicate tag name';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(8, 24, 8, 8),
      title: Stack(
        children: [
          Text(
            'Select Tags',
            style: const TextStyle(fontSize: 22),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: InkWell(
//              visualDensity: VisualDensity.compact,
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Icon(
                  addingNewTag ? Icons.remove_circle : Icons.add_circle,
                  color: theme.primaryColor,
                ),
              ),
              onTap: () {
                setState(() {
                  addingNewTag = !addingNewTag;
                });
              },
            ),
          )
        ],
      ),
      content: SingleChildScrollView(
        child: Consumer<ValueNotifier<Set<String>>>(
            builder: (_, notifier, __) => Column(
                  children: [
                    addingNewTag
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Form(
                              key: _formKey,
                              child: Row(children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _textEditingController,
                                    validator: validateNewTagName,
                                    decoration: InputDecoration(
                                      icon: const Icon(
                                          CommunityMaterialIcons.pound_box),
                                      labelText: 'New Tag',
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 60,
                                  child: RaisedButton(
                                    visualDensity: VisualDensity.compact,
                                    child: Text('Create'),
                                    onPressed: onCreatePressed,
                                  ),
                                )
                              ]),
                            ),
                          )
                        : Container(),
                    Wrap(
                      children: tagChoiceChipList(notifier),
                    ),
                  ],
                )),
      ),
      actions: [
        MaterialButton(
            elevation: 5,
            child: Text('Close'),
            onPressed: () => Navigator.of(context).pop())
      ],
    );
  }
}
