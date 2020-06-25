import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:hitomemo/widgets/note_replica_tile.dart';
import 'package:hitomemo/person_tags_model.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import 'many_to_many.dart';
import 'note.dart';
import 'note_form.dart';
import 'note_list_item.dart';
import 'person.dart';
import 'person_model.dart';
import 'screen_show_person.i18n.dart';
import 'tag.dart';
import 'tag_chip.dart';
import 'widgets/cached_image.dart';
import 'widgets/tutorial.dart';

class ShowPersonRoute extends StatefulWidget {
  const ShowPersonRoute(this.person);

  final Person person;

  static const String routeName = 'show/person';

  @override
  _ShowPersonRouteState createState() => _ShowPersonRouteState(person);

  static void navigateToPersonPage(Person person, BuildContext context) {
    Navigator.push<dynamic>(
      context,
      MaterialPageRoute<dynamic>(
          settings: const RouteSettings(name: routeName),
          builder: (context) => ShowPersonRoute(person)),
    );
  }
}

class _ShowPersonRouteState extends State<ShowPersonRoute> {
  _ShowPersonRouteState(this.person);

  Person person;
  // Because this is State, the ValueNotifier constructor is called once.
  ValueNotifier<List<Note>> notesNotifier = ValueNotifier(null);

  ValueNotifier<Note> newNoteNotifier = ValueNotifier(Note(content: ''));

  ValueNotifier<List<NoteReplica>> replicasNotifier = ValueNotifier(null);

  final ScrollController _scrollController = ScrollController();

  PersonsModel personsModel;

  @override
  void initState() {
    super.initState();
    // This note list initialization should only happen once
    personsModel = Provider.of<PersonsModel>(context, listen: false);
    personsModel.getNotes(person).then((notes) {
      notesNotifier.value = notes;
    });

    final family = personsModel.getFamily(person.familyId);
    final searchEngine = personsModel.searchEngine;
    if (searchEngine == null) {
      return; // for test
    }
    searchEngine.then((se) async {
      final familyReplicasFuture = se.searchNoteByFamily(person.id, family);
      final personTagReplicasFuture = se.searchNoteByPersonTag(person.id);

      final replicas =
          await Future.wait([familyReplicasFuture, personTagReplicasFuture]);

      final familyReplicas = replicas[0];
      final personTagReplicas = replicas[1];
      setState(() {
        final uniqueReplicas = <NoteReplica>{}
          ..addAll(familyReplicas)
          ..addAll(personTagReplicas);
        replicasNotifier.value = uniqueReplicas.toList();
      });
    });
  }

  final double _pictureHeight = 200;
  Widget _personPicture(BuildContext context, Person person) {
    final theme = Theme.of(context);
    if (person.pictureGcsPath == null) {
      return Container();
    }
    return Container(
        height: _pictureHeight,
        color: theme.primaryColor,
        padding: const EdgeInsets.only(bottom: 32),
        child: Center(
            child: GestureDetector(
          child: CircleAvatar(
            radius: 70,
            backgroundImage: CachedImage(person.pictureGcsPath),
          ),
        )));
  }

  @override
  Widget build(BuildContext context) {
    // This may be called and the tree may be rebuilt with old _person value.
    // DON'T create your object from variables that can change over the time.
    // In such situation, your object would never be updated when the value
    // changes.
    // https://pub.dev/packages/provider
    Widget settingsButton() => IconButton(
          icon: const Icon(Icons.account_circle),
        );

    final theme = Theme.of(context);

    Widget builder(BuildContext context) =>
        Consumer<ValueNotifier<List<Note>>>(builder:
            (BuildContext _context, ValueNotifier<List<Note>> notifier, _) {
          final family = personsModel.getFamily(person.familyId);
          final groupChips = _groupChips();
          final familyChips = _familyChips(family);
          final chips = [...groupChips, ...familyChips];
          final chipSection =
              chips.isEmpty ? Container() : Wrap(children: chips);
          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                // https://api.flutter.dev/flutter/material/SliverAppBar-class.html
                floating: false,
                pinned: true,
                snap: false,
                expandedHeight:
                    person.pictureGcsPath != null ? (25 + _pictureHeight) : 25,
                // FlexibleSpaceBar cannot include  variable-height
                // widgets, such as Chips in Wrap.
                // https://github.com/flutter/flutter/issues/18345
                flexibleSpace: FlexibleSpaceBar(
                  // When modifying this padding, be sure you check
                  // various cases such as
                  // - person without picture or tag
                  // - person with tag
                  // - person with picture and tag
                  titlePadding: const EdgeInsets.only(bottom: 12),
                  title: FittedBox(child: Text(person.name)),
                  background: SafeArea(
                    child: Column(
                      children: <Widget>[
                        _personPicture(context, person),
                      ],
                    ),
                  ),
                ),
                actions: [settingsButton()],
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  Container(
                      color: theme.primaryColor,
                      alignment: Alignment.center,
                      child: chipSection),
                  SafeArea(top: false, bottom: false, child: NoteForm(person)),
                ]),
              ),
              ...noteList(context),
              const SliverToBoxAdapter(
                child: SizedBox(height: 200),
              )
            ],
          );
        });

    return Scaffold(
      body: WithBottomTutorial.showPerson(
          child: MultiProvider(
        providers: [
          // NoteListItem references this provider
          ChangeNotifierProvider<ValueNotifier<List<Note>>>.value(
              value: notesNotifier),
          ChangeNotifierProvider<ValueNotifier<Note>>.value(
              value: newNoteNotifier)
        ],
        child: Builder(builder: builder),
      )),
    );
  }

  Widget onDateWidget(OnDate item) {
    if (item is Note) {
      return NoteListItem(person, item);
    }
    if (item is NoteReplica) {
      final p = personsModel.get(item.personId);
      if (p != null) {
        return NoteReplicaTile(p, item);
      }
      // this personId has been deleted
    }
    return Container();
  }

  List<Widget> noteList(BuildContext context) {
    final items = <OnDate>[];
    final _notes = notesNotifier.value;
    if (_notes == null) {
      return [
        SliverList(
            delegate: SliverChildListDelegate(
                [Center(child: Text('Loading notes...'.i18n))]))
      ];
    }
    final notes = List<Note>.from(_notes)..removeWhere((n) => n.deleted);
    items.addAll(notes);

    final replicas = replicasNotifier.value;

    if (replicas != null) {
      items.addAll(replicas);
    }

    if (items.isEmpty) {
      final message = person.id == '0'
          ? aDiaryIsNoteAboutYourself.i18n // for user-as-person
          : '''Examples:
- Achievement they shared with you
- An anniversary you celebrated together
- Gifts you received
'''
              .i18n;
      return [
        SliverList(
            delegate: SliverChildListDelegate([
          const SizedBox(height: 16),
          Center(
            child: Text(
              message,
            ),
          ),
        ]))
      ];
    }

    final sortedNotes = <OnDate>[...items]..sort(OnDate.order);
    var i = 0;

    final groupedNotes = _groupByYear(sortedNotes);
    final yearGroups = groupedNotes.map((t) {
      final year = t.item1;
      final items = t.item2;
      final noteItems = items
          .map((item) => Container(
              color: (i++ % 2) == 0 ? const Color(0x05111111) : Colors.white,
              child: SafeArea(
                  top: false, bottom: false, child: onDateWidget(item))))
          .toList();
      return SliverStickyHeader(
          header: Container(
            height: 50,
            padding: const EdgeInsets.fromLTRB(12, 8, 0, 8),
            alignment: Alignment.bottomLeft,
            child: SafeArea(top: false, bottom: false, child: Text(year)),
          ),
          sliver: SliverList(
              delegate: SliverChildListDelegate(
                  ListTile.divideTiles(context: context, tiles: noteItems)
                      .toList())));
    });

    return yearGroups.toList();
  }

  List<Tuple2<String, List<OnDate>>> _groupByYear(List<OnDate> notes) {
    final ret = <Tuple2<String, List<OnDate>>>[];

    var currentYear = _yearFormatter.format(notes.first.date);
    var items = <OnDate>[];
    for (final note in notes) {
      final y = _yearFormatter.format(note.date);
      if (y != currentYear) {
        ret.add(Tuple2(currentYear, items));
        items = [];
        currentYear = y;
      }
      items.add(note);
    }
    if (items.isNotEmpty) {
      ret.add(Tuple2(currentYear, items));
    }

    return ret;
  }

  static final DateFormat _yearFormatter =
      DateFormat.y(I18n.locale.languageCode);

  List<Widget> _groupChips() {
    final tagsModel = Provider.of<TagsModel>(context, listen: false);

    final selectedTags = tagsModel.getTags(person.id);
    final groupChips = tagsModel.tags.where(selectedTags.contains).map((tag) {
      return Container(
          padding: const EdgeInsets.only(right: 2),
          child: GroupChip(
            tag,
          ));
    }).toList();
    return groupChips;
  }

  List<Widget> _familyChips(Family family) {
    if (family == null) {
      return [];
    }

    if (family.id == person.id) {
      // family head
      return family.memberIds
          .map(personsModel.get)
          .map((p) => PersonTagChip(
                p, // head does not show 'Family: ' prefix
                onSelected: (_) {
                  ShowPersonRoute.navigateToPersonPage(p, context);
                },
              ))
          .toList(growable: false);
    } else {
      final familyHead = personsModel.get(family.id);
      return [
        PersonTagChip(
          familyHead,
          title: 'Family:%s'.i18n.fill([familyHead.name]),
          onSelected: (_) {
            ShowPersonRoute.navigateToPersonPage(familyHead, context);
          },
        )
      ];
    }
  }
}
