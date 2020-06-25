import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: TextFormField(
      decoration: InputDecoration(
        // This fails: Target release_ios_bundle_flutter_assets failed:
        // FontSubset error: Font subsetting failed with exit code 255.
        icon: const Icon(CommunityMaterialIcons.pound_box),

        // This works
        // icon: const Icon(Icons.add),
        labelText: 'hello',
      ),
    ));
  }
}
