import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';

class TagSelectionDialog extends StatefulWidget {
  const TagSelectionDialog();

  @override
  State<StatefulWidget> createState() {
    return _TagSelectionState();
  }
}

class _TagSelectionState extends State<TagSelectionDialog> {
  bool addingNewTag = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        icon: const Icon(
            CommunityMaterialIcons.pound_box),
        labelText: 'New Tag',
      ),
    );
  }
}
