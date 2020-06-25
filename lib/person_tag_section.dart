import 'package:flutter/material.dart';
import 'package:hitomemo/person_model.dart';
import 'package:provider/provider.dart';

import 'screen_show_person.dart';
import 'tag_chip.dart';

class PersonTagSection extends StatelessWidget {
  const PersonTagSection(this.personIds);
  final List<String> personIds;

  @override
  Widget build(BuildContext context) {
    final personsModel = Provider.of<PersonsModel>(context, listen: false);

    final chips = personIds.map(personsModel.get).where((p) => p != null).map(
        (p) => PersonTagChip(p,
            onSelected: (_) => ShowPersonRoute.navigateToPersonPage(
                personsModel.get(p.id), context)));

    return Wrap(
      children: chips.toList(),
    );
  }
}
