import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hitomemo/person.dart';
import 'package:hitomemo/tag_chip.dart';
import 'package:hitomemo/person_tags_model.dart';
import 'package:provider/provider.dart';
import 'screen_show_person.dart';
import 'widgets/person_circle_avatar.dart';

class PersonListItem extends StatelessWidget {
  const PersonListItem(this._person);

  final Person _person;

  List<Widget> tagChips(BuildContext context) {
    final tagsModel = Provider.of<TagsModel>(context, listen: false);

    final tags = tagsModel.getTags(_person.id);

    if (tags.isEmpty) {
      return [
        const SizedBox(
          height: 50,
        )
      ];
    }

    return tags.map((t) => Container(child: GroupChip(t))).toList();
  }

  @override
  Widget build(BuildContext context) {
    const r = 28.0;
    final tags = tagChips(context);
    return Container(
      child: ListTile(
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[PersonCircleAvatar(_person, radius: r)],
        ),
        title: Container(
          child: Text(_person.name),
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
        ),
        subtitle: SizedBox(
          height: 50,
          child: ListView(
            children: tags,
            scrollDirection: Axis.horizontal,
          ),
        ),
        onTap: () async {
          // delete?
          await Navigator.push<dynamic>(
            context,
            MaterialPageRoute<dynamic>(
                settings: const RouteSettings(name: ShowPersonRoute.routeName),
                builder: (context) => ShowPersonRoute(_person)),
          );

          FocusManager.instance.primaryFocus.unfocus();
        },

        // Maybe no need for tailing?
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description,
            )
          ],
        ),
      ),
    );
  }
}
