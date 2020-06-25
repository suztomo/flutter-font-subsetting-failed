import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hitomemo/timeline.dart';
import 'package:pedantic/pedantic.dart';
import 'package:provider/provider.dart';

import 'hitomemo.dart';
import 'hitomemo.i18n.dart';
import 'person_model.dart';
import 'tag.dart';
import 'widgets/note_replica_tile.dart';

class TimelineList extends StatefulWidget {
  const TimelineList(this.scrollController);

  final ScrollController scrollController;

  @override
  State<StatefulWidget> createState() {
    return TimelineListState();
  }
}

class TimelineListState extends State<TimelineList>
    with AutomaticKeepAliveClientMixin {
  TimelineListState();

  PersonsModel _personsModel;

  Timeline timeline;

  @override
  void initState() {
    super.initState();

    _personsModel = Provider.of<PersonsModel>(context, listen: false)
      ..addListener(() => timeline?.reload());

    final searchNotifier =
        Provider.of<ValueNotifier<SearchCriteria>>(context, listen: false);

    searchNotifier.addListener(() {
      final criteria = searchNotifier.value;
      unawaited(timeline.query(criteria));
    });

    unawaited(_personsModel.searchEngine.then((value) {
      setState(() {
        timeline = Timeline(_personsModel, value, searchNotifier.value);
        unawaited(timeline.fetchNext());
      });
    }));

    widget.scrollController.addListener(() {
      final reachedMax = widget.scrollController.position.pixels ==
          widget.scrollController.position.maxScrollExtent;
      if (reachedMax) {
        timeline.fetchNext();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return timeline == null
        ? const Center(child: LinearProgressIndicator())
        : ChangeNotifierProvider<Timeline>.value(
            value: timeline, child: _TimelineList(widget.scrollController));
  }

  @override
  bool get wantKeepAlive => true;
}

class _TimelineList extends StatelessWidget {
  const _TimelineList(this.controller);
  final ScrollController controller;

  Widget _noteTileAt(
      BuildContext context, PersonsModel personsModel, NoteReplica note) {
    final person = personsModel.get(note.personId);

    if (person == null) {
      // This person has been deleted
      return Container();
    }

    // I hate ListTile's inflexibility on padding/margin
    return NoteReplicaTile(person, note);
  }

  @override
  Widget build(BuildContext context) {
    // When there's a change in notes, update the list.
    final personsModel = Provider.of<PersonsModel>(context, listen: false);

    // Somehow this build method is called twice where one time is enough.
    // print('Building _TimelineList');
    return Consumer<Timeline>(builder: (context, timeline, _) {
      if (timeline.length == 0) {
        return Column(children: [
          const SizedBox(height: 16),
          Text(
            'No note yet'.i18n,
            style: Theme.of(context).textTheme.caption,
          )
        ]);
      }
      return ListView.builder(
        controller: controller,
        itemBuilder: (context, index) {
          if (index >= timeline.length) {
            return const CupertinoActivityIndicator();
          }
          return _noteTileAt(context, personsModel, timeline.get(index));
        },
        itemCount: timeline.length + (timeline.hasMoreData ? 1 : 0),
      );
    });
  }
}
