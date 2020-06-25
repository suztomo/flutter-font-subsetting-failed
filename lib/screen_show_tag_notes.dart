import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'gesture_detector_app_bar.dart';
import 'person_model.dart';
import 'screen_note_tags.i18n.dart';
import 'tag.dart';
import 'widgets/note_replica_tile.dart';
import 'widgets/tutorial.dart';

class ShowTagNotesRoute extends StatefulWidget {
  const ShowTagNotesRoute(this._tag);

  static const String routeName = 'tag/notes';

  final NTag _tag;

  @override
  State<StatefulWidget> createState() {
    return ShowTagNotesState(_tag);
  }
}

class ShowTagNotesState extends State<ShowTagNotesRoute> {
  ShowTagNotesState(NTag tag) : tagNotifier = ValueNotifier(tag);

  final ValueNotifier<NTag> tagNotifier;

  bool editing = false;

  PersonsModel _personsModel;

  Future<List<NoteReplica>> noteReplicaFuture;

  final ScrollController _scrollController = ScrollController();

  final _listViewKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    editing = false;

    _personsModel = Provider.of<PersonsModel>(context, listen: false);
    reloadReplica();

    Future<dynamic>.delayed(const Duration(milliseconds: 500))
        .then((dynamic _) {
          // Ensure the listView has context
          if (_listViewKey.currentContext != null) {
            Tutorial.recordViewedTaggedNotes(
                _listViewKey.currentContext, tagNotifier.value.id);
          }
    });
  }

  void reloadReplica() {
    final tag = tagNotifier.value;
    setState(() {
      noteReplicaFuture = _personsModel.searchEngine
          .then((searchEngine) => searchEngine.searchNoteByTag(tag.id));
    });
  }

  List<Widget> _noteTiles(BuildContext context, List<NoteReplica> notes) {
    final items = notes.map((NoteReplica note) {
      final person = _personsModel.get(note.personId);

      if (person == null) {
        return Container();
      }

      // I hate ListTile's inflexibility on padding/margin
      return NoteReplicaTile(person, note);
    });

    return ListTile.divideTiles(
      context: context,
      tiles: items,
    ).toList();
  }

  void scrollToTop() {
    _scrollController.animateTo(
      _scrollController.position.minScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ValueNotifier<NTag>>.value(
      value: tagNotifier,
      child: Consumer<ValueNotifier<NTag>>(
          builder: (_, ValueNotifier<NTag> notifier, __) => Scaffold(
                resizeToAvoidBottomPadding: false,
                appBar: GestureDetectorAppBar(
                    title: Text(tagNotifier.value.name), onTap: scrollToTop),
                body: WithBottomTutorial.showTaggedNotes(
                    child: FutureBuilder(
                  future: noteReplicaFuture,
                  builder:
                      (context, AsyncSnapshot<List<NoteReplica>> snapshot) {
                    final state = snapshot.connectionState;
                    if (state == ConnectionState.done) {
                      final data = snapshot.data;
                      if (data.isEmpty) {
                        return Container(
                            height: 50,
                            alignment: Alignment.center,
                            child: Text(
                                'No note tagged with "#%s"'
                                    .i18n
                                    .fill([tagNotifier.value.name]),
                                style: Theme.of(context).textTheme.caption));
                      }
                      return ListView(
                          key: _listViewKey,
                          controller: _scrollController,
                          children: [
                            ..._noteTiles(context, data),
                            const SizedBox(
                              height: 200,
                            )
                          ]);
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    return const LinearProgressIndicator();
                  },
                )),
              )),
    );
  }
}
