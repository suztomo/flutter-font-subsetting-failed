import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hitomemo/name.dart';
import 'package:hitomemo/person_list.dart';
import 'package:hitomemo/home_search_field.dart';
import 'package:hitomemo/search_engine.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'drawer.dart';
import 'gesture_detector_app_bar.dart';
import 'hitomemo.i18n.dart';
import 'hitomemo_timeline_list.dart';
import 'note.dart';
import 'person.dart';
import 'person_model.dart';
import 'screen_add_person.dart';
import 'screen_multiple_persons_dialog.dart';
import 'widgets/bottom_up_animation.dart';
import 'widgets/menu_button.dart';
import 'widgets/tutorial.dart';

part 'hitomemo.freezed.dart';

class HitomemoHomePage extends StatefulWidget {
  static const String routeName = '/home';

  @override
  _HitomemoHomePageState createState() => _HitomemoHomePageState();
}

bool searchFieldIndexingStarted = false;

class _HitomemoHomePageState extends State<HitomemoHomePage> {
  final ScrollController _personListScrollController = ScrollController();
  final ScrollController _noteListScrollController = ScrollController();

  final PageController _pageController = PageController();

  HomeState state = HomeState.people;

  bool showSearch = false;

  final ValueNotifier<SearchCriteria> _searchCriteriaNotifier =
      ValueNotifier<SearchCriteria>(SearchCriteria());

  void _scrollToTop(ScrollController scrollController) {
    scrollController.animateTo(
      scrollController.position.minScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void initState() {
    super.initState();

    // Hide Keyboard upon scrolling
    _personListScrollController.addListener(() {
      FocusManager.instance.primaryFocus.unfocus();
    });
    _noteListScrollController.addListener(() {
      FocusManager.instance.primaryFocus.unfocus();
    });

    final personsModel = Provider.of<PersonsModel>(context, listen: false);

    // To wait until scaffoldKey is mounted
    SchedulerBinding.instance.addPostFrameCallback((_) {
      // This is null when running in test
      personsModel.searchEngine?.then((engine) {
        final persons = personsModel.persons;
        if (persons.isNotEmpty) {
          if (searchFieldIndexingStarted) {
            return;
          }
          searchFieldIndexingStarted = true;
          indexNotes(personsModel, engine, persons);
        } else {
          personsModel.addListener(() {
            if (searchFieldIndexingStarted) {
              return;
            }
            final persons = personsModel.persons;
            if (persons == null || persons.isEmpty) {
              return;
            }
            searchFieldIndexingStarted = true;
            indexNotes(personsModel, engine, persons);
          });
        }
      });
    });
  }

  GlobalKey scaffoldKey = GlobalKey();

  Future<void> indexNotes(PersonsModel personsModel, SearchEngine searchEngine,
      List<Person> persons) async {
    final scaffold = Scaffold.of(scaffoldKey.currentContext);
    var indexPersonCount = 0;

    final lastIndexTimes = await searchEngine.lastUpdateTimesByPerson();

    for (final person in persons) {
      final lastIndexed = lastIndexTimes[person.id];
      final personNoteUpdated = person.updated.toDate();
      if (lastIndexed == null ||
          personNoteUpdated.difference(lastIndexed).inSeconds > 10) {
        if (indexPersonCount == 0) {
          scaffold
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text('Indexing notes'.i18n)));
        }
        indexPersonCount++;

        final notes = await personsModel.getNotes(person);
        for (final note in notes) {
          final noteUpdated = note.updated.toDate();
          if (lastIndexed == null ||
              noteUpdated.difference(lastIndexed).inSeconds > 10) {
            await searchEngine.indexNote(person, note);
          }
        }
        await searchEngine.updatePersonTimestamp(person);
      }
    }
    if (indexPersonCount > 0) {
      scaffold
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
            content: Text('Indexed %s records'.i18n.fill([indexPersonCount]))));
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _noteListScrollController.dispose();
    _personListScrollController.dispose();
    super.dispose();
  }

  Widget fab(BuildContext context, int peopleCount) {
    if (peopleCount == 1) {
      final tutorialStateNotifier =
          Provider.of<ValueNotifier<TutorialState>>(context, listen: true);
      final tutorialState = tutorialStateNotifier.value;
      if (tutorialState is AddPeopleTutorial) {
        // When showing "Add 3 people", then no need to show FAB
        return null;
      }
    }
    final theme = Theme.of(context);
    if (state == HomeState.people) {
      return InkWell(
        splashColor: theme.primaryColor,
        onLongPress: () async {
          await Navigator.of(context).push<List<Person>>(
              createBottomUpAnimationRoute<List<Person>>(
                  (context, animation, secondaryAnimation) =>
                      AddMultiplePersonsRoute()));
        },
        child: FloatingActionButton(
          child: const Icon(Icons.person_add),
          backgroundColor: theme.accentColor,
          onPressed: () async {
            final addedPerson = await Navigator.of(context).push(
                createBottomUpAnimationRoute<Person>(
                    (context, animation, secondaryAnimation) =>
                        AddPersonRoute()));
            if (addedPerson != null) {
              _scrollToTop(_personListScrollController);
            }
          },
        ),
      );
    } else {
      return FloatingActionButton(
        child: const Icon(Icons.note_add),
        backgroundColor: theme.accentColor,
        onPressed: () async {
        },
      );
    }
  }

  void _switchTo(HomeState state) {
    final pageIndex = state == HomeState.people ? 0 : 1;
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        pageIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
    setState(() {
      this.state = state;
    });
  }

  @override
  Widget build(BuildContext context) {
    // When PersonsModel.notifyListeners, this method should be called.
    final personsModel = Provider.of<PersonsModel>(context, listen: true);
    final theme = Theme.of(context);

    final peopleCount = personsModel.persons?.length ?? 0;

    Widget leadingButton() {
      if (peopleCount == 1) {
        return Container();
      }
      if (peopleCount > 1) {
        return const NotifyingMenuButton(HitomemoHomePage.routeName);
      }
      return null;
    }

    final mq = MediaQuery.of(context);
    final size = mq.size;
    final screenWidth = size.bottomRight(Offset.zero).dx;
    final halfWidth = screenWidth / 2;

    return MultiProvider(
        providers: [
          ChangeNotifierProvider<ValueNotifier<SearchCriteria>>.value(
              value: _searchCriteriaNotifier),
        ],
        child: Scaffold(
          drawer: peopleCount != 1 ? MenuDrawer() : null,
          appBar: GestureDetectorAppBar(
            title: Stack(
              key: scaffoldKey,
              children: [
                const Center(
                  child: Text(appNameEn),
                ),
                Visibility(
                  visible: showSearch,
                  child: Container(
//                      duration: const Duration(milliseconds: 100),
                      height: showSearch ? 40 : 0,
//                    width: showSearch ? 200 : 0,
                      child: HomeSearchField(),
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(4)))),
                ),
              ],
            ), // Alphabet for both English and Japanese
            onTap: () {
              if (state == HomeState.people) {
                _scrollToTop(_personListScrollController);
              } else {
                _scrollToTop(_noteListScrollController);
              }
              FocusManager.instance.primaryFocus.unfocus();
            },
            leading: leadingButton(),

            actions: [
              IconButton(
                icon: Icon(showSearch ? Icons.cancel : Icons.search),
                onPressed: () {
                  setState(() {
                    showSearch = !showSearch;
                    if (showSearch && searchFieldFocusNode.canRequestFocus) {
                      searchFieldFocusNode.requestFocus();
                    }
                    if (!showSearch) {
                      searchFieldFocusNode.unfocus();
                      _searchCriteriaNotifier.value =
                          _searchCriteriaNotifier.value.copyWith(text: '');
                    }
                  });
                },
              )
            ],
          ),
          body: WithBottomTutorial.home(
              child: Column(children: <Widget>[
            SizedBox(
              height: 40,
              child: Row(
                children: [
                  Expanded(
                      child: FlatButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Icon(
                          Icons.person,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text('People'.i18n),
                      ],
                    ),
                    textColor:
                        state == HomeState.people ? null : theme.disabledColor,
                    onPressed: () => _switchTo(HomeState.people),
                  )),
                  Expanded(
                      child: FlatButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Icon(
                          Icons.note,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text('Notes'.i18n),
                      ],
                    ),
                    textColor:
                        state == HomeState.notes ? null : theme.disabledColor,
                    onPressed: () => _switchTo(HomeState.notes),
                  ))
                ],
                mainAxisAlignment: MainAxisAlignment.spaceAround,
              ),
            ),
            SizedBox(
                height: 2,
                child: Stack(
                  children: <Widget>[
                    AnimatedPositioned(
                        duration: const Duration(milliseconds: 200),
                        left: state == HomeState.people ? 0 : halfWidth,
                        top: 0,
                        child: Container(
                          height: 2,
                          width: halfWidth,
                          color: theme.primaryColor,
                        ))
                  ],
                )),
            Expanded(
              child: PageView(
                  controller: _pageController,
                  children: [
                    PersonList(_personListScrollController),
                    TimelineList(_noteListScrollController)
                  ],
                  onPageChanged: (index) {
                    setState(() {
                      state = index == 0 ? HomeState.people : HomeState.notes;
                    });
                  }),
            )
          ])),
          floatingActionButton: fab(context, peopleCount),
        ));
  }
}

@freezed
abstract class SearchCriteria with _$SearchCriteria {
  factory SearchCriteria({
    @Default('') String text,
  }) = _SearchCriteria;
}

class LoadingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(appNameEn), // for both English and Japanese
        ),
        body: const Center(child: LinearProgressIndicator()));
  }
}

enum HomeState { people, notes }

GlobalKey searchFieldKey = GlobalKey();
FocusNode searchFieldFocusNode = FocusNode();
