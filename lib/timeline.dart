import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:hitomemo/hitomemo.dart';
import 'package:hitomemo/person.dart';
import 'package:hitomemo/search_engine.dart';
import 'package:hitomemo/tag.dart';

import 'person_model.dart';

const int _initialFetchCount = 10;

/// Global timeline that contains all notes. This notified when any of the note
/// has changes.
class Timeline extends ChangeNotifier {
  Timeline(this.personsModel, this.searchEngine, this.criteria);

  final SearchEngine searchEngine;

  final PersonsModel personsModel;

  SearchCriteria criteria;

  final List<NoteReplica> _replicas = [];

  final Set<String> _fetchedNoteIds = {};

  DateTime _lastCursor;

  bool hasMoreData = true;

  int _fetchCount = _initialFetchCount;

  NoteReplica get(int index) {
    return _replicas[index];
  }

  int get length => _replicas.length;

  Future<void> fetchNext() async {
    final persons = criteria.text.isEmpty
        ? <Person>[]
        : personsModel.searchByText(criteria.text);

    final notes = await searchEngine.searchNotes(
        startCursor: _lastCursor,
        count: _fetchCount,
        text: criteria.text,
        orPersonIds: persons.map((p) => p.id).toSet());

    var dataAdded = false;
    for (final note in notes) {
      if (_fetchedNoteIds.add(note.id)) {
        _replicas.add(note);
        dataAdded = true;
      }
      _lastCursor = note.date;
    }
    if (notes.length == _fetchCount && !dataAdded) {
      // Many data on the same date
      _fetchCount = _fetchCount + 10;
      hasMoreData = true;
    } else if (notes.length < _fetchCount) {
      // no more data
      hasMoreData = false;
    } else {
      hasMoreData = dataAdded;
    }

    notifyListeners();
  }

  Future<void> query(SearchCriteria criteria) async {
    _replicas.clear();
    _fetchedNoteIds.clear();
    this.criteria = criteria;
    _lastCursor = null;
    return fetchNext();
  }

  // When the underlying data changes
  Future<void> reload() async {
    _fetchCount = max(_fetchCount, _replicas.length);
    _replicas.clear();
    _fetchedNoteIds.clear();
    _lastCursor = null;
    await fetchNext();
    _fetchCount = _initialFetchCount;
  }
}
