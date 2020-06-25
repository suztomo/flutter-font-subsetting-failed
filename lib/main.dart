import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: MaterialApp(
          home: TextFormField(
        decoration: InputDecoration(
          icon: const Icon(CommunityMaterialIcons.pound_box),
          labelText: 'hello',
        ),
      )),
    );
  }
}
