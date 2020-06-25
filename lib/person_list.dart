import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hitomemo/person.dart';
import 'package:provider/provider.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'hitomemo.dart';
import 'person_list.i18n.dart';
import 'person_list_item.dart';
import 'person_model.dart';
import 'search_engine.dart';

part 'person_list.freezed.dart';

class PersonList extends StatefulWidget {
  const PersonList(this._scrollController);

  final ScrollController _scrollController;

  @override
  _PersonListState createState() => _PersonListState();
}

class _PersonListState extends State<PersonList>
    with AutomaticKeepAliveClientMixin {
  PersonListSearchCriteria _criteria;

  PersonsModel _personsModel;

  SearchEngine _searchEngine;

  @override
  void initState() {
    super.initState();

    final searchNotifier =
        Provider.of<ValueNotifier<SearchCriteria>>(context, listen: false);

    _personsModel = Provider.of<PersonsModel>(context, listen: false);

    _personsModel.searchEngine.then((engine) {
      _searchEngine = engine;
    });

    searchNotifier.addListener(() async {
      final queryText = searchNotifier.value.text;
      if (queryText.isEmpty) {
        setState(() {
          _criteria = null;
        });
        return;
      }

      var newCriteria = PersonListSearchCriteria();

      final nameMatchingPersons = _personsModel.searchByText(queryText);
      final personIdsFromName = nameMatchingPersons.map((p) => p.id).toSet();
      newCriteria = newCriteria.copyWith(personIdsHigh: personIdsFromName);

      if (_searchEngine != null) {
        final results = await _searchEngine.searchByNote(queryText);
        final foundBySearchEngine = results
            .map((r) => r.personId)
            .where((personId) => !newCriteria.personIdsHigh.contains(personId))
            .toSet();
        newCriteria = newCriteria.copyWith(personIdsLow: foundBySearchEngine);
      }

      _criteria = newCriteria;
      if (mounted) {
        setState(() {});
      }
    });
  }

  static List<Widget> _getPersonListItems(
      List<Person> persons, PersonListSearchCriteria criteria) {
    // visibleIds is null when nothing is typed in the field
    var i = 0;
    if (criteria == null) {
      return persons
          .map((person) => Visibility(
              visible: true,
              child: Container(
                  color:
                      (i++ % 2) == 0 ? const Color(0x05111111) : Colors.white,
                  child: PersonListItem(person))))
          .toList();
    }

    final ret = <Widget>[];
    for (final person in persons) {
      if (criteria.personIdsHigh.contains(person.id)) {
        ret.add(Container(
            color: (i++ % 2) == 0 ? const Color(0x05111111) : Colors.white,
            child: PersonListItem(person)));
      }
    }
    for (final person in persons) {
      if (criteria.personIdsLow.contains(person.id)) {
        ret.add(Container(
            color: (i++ % 2) == 0 ? const Color(0x05111111) : Colors.white,
            child: PersonListItem(person)));
      }
    }
    return ret;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // Null if persons is not initialized
    final persons = _personsModel.persons;
    if (persons == null) {
      return Center(child: Text('Loading...'.i18n));
    }
    // Listen true to rebuild this widget pointed by context

    final sections = <Widget>[const SizedBox(height: 8)];
    final recentPersons = _personsModel.recentPersons;
    if (recentPersons != null && _criteria == null) {
      // No search text
      final recentItems = _getPersonListItems(recentPersons, null);
      final recentSection = StickyHeader(
          header: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            alignment: Alignment.centerLeft,
            child: SafeArea(child: Text('Recent'.i18n)),
          ),
          content: Container(
              child: Column(
            children: ListTile.divideTiles(context: context, tiles: recentItems)
                .toList(),
          )));
      sections.add(recentSection);
    }
    final allItems = _getPersonListItems(persons, _criteria);
    final allPersonsSection = StickyHeader(
        header: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          alignment: Alignment.centerLeft,
          child: SafeArea(child: Text('All (a-z)'.i18n)),
        ),
        content: Container(
            child: Column(
          children:
              ListTile.divideTiles(context: context, tiles: allItems).toList(),
        )));
    sections..add(allPersonsSection)..add(const SizedBox(height: 200));

    return ListView(
      children: sections,
      controller: widget._scrollController,
    );
  }

  @override
  bool get wantKeepAlive => true;
}

@freezed
abstract class PersonListSearchCriteria with _$PersonListSearchCriteria {
  factory PersonListSearchCriteria({
    @Default(<String>{}) Set<String> personIdsHigh,
    @Default(<String>{}) Set<String> personIdsLow,
  }) = _PersonListSearchCriteria;
}
