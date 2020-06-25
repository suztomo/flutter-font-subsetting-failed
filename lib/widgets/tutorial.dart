import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hitomemo/note_tags_model.dart';
import 'package:hitomemo/person_model.dart';
import 'package:provider/provider.dart';

import '../person.dart';
import '../screen_multiple_persons_dialog.dart';
import 'bottom_up_animation.dart';
import 'tutorial.i18n.dart';

part 'tutorial.freezed.dart';

@freezed
abstract class TutorialState with _$TutorialState {
  const factory TutorialState.off() = Off; // Tutorial is not shown
  const factory TutorialState.on() = On; // No ongoing tutorial
  const factory TutorialState.onAddPeopleTutorial(int peopleCount) =
      AddPeopleTutorial;
  const factory TutorialState.onTagsTutorial(TagsTutorialState state) =
      TagsTutorial;
}

@freezed
abstract class TagsTutorialState with _$TagsTutorialState {
  factory TagsTutorialState(
      {@Default(<String>{}) Set<String> recentTagIds,
      @Default(<String>{}) Set<String> noteUsedTagIds,
      @Default(<String>{}) Set<String> viewedTagIds}) = _TagsTutorialState;
}

TutorialState tutorialState = const TutorialState.off();

void showSnackBarMessage(BuildContext context, String message) {
  Scaffold.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

class Tutorial {
  static void recordAddingRecentlySavedTag(BuildContext context, String tagId) {
    final tutorialNotifier =
        Provider.of<ValueNotifier<TutorialState>>(context, listen: false);
    tutorialNotifier.value.maybeWhen(
        orElse: () {},
        onTagsTutorial: (state) {
          tutorialNotifier.value = TutorialState.onTagsTutorial(
              state.copyWith(recentTagIds: {tagId, ...state.recentTagIds}));

          showSnackBarMessage(context, tagsTutorialCreateNoteSnackBar.i18n);
        });
  }

  static void recordAddingTagToNote(BuildContext context, String tagId) {
    final tutorialNotifier =
        Provider.of<ValueNotifier<TutorialState>>(context, listen: false);
    tutorialNotifier.value.maybeWhen(
        orElse: () {},
        onTagsTutorial: (state) {
          var snackBarShown = false;
          final tagIds = state.recentTagIds;
          if (tagIds.contains(tagId)) {
            tutorialNotifier.value = TutorialState.onTagsTutorial(state
                .copyWith(noteUsedTagIds: {tagId, ...state.noteUsedTagIds}));

            if (!snackBarShown) {
              // This is not shown. Because the scaffold disappears.
              showSnackBarMessage(
                  context, tagsTutorialViewTaggedNoteSnackBar.i18n);
            }
            snackBarShown = true;
          }
        });
  }

  static void recordViewedTaggedNotes(BuildContext context, String tagId) {
    final tutorialNotifier =
        Provider.of<ValueNotifier<TutorialState>>(context, listen: false);
    tutorialNotifier.value.maybeWhen(
        orElse: () {},
        onTagsTutorial: (state) {
          final tagIds = state.noteUsedTagIds;
          if (tagIds.contains(tagId)) {
            if (state.viewedTagIds.isEmpty) {
              showSnackBarMessage(context, tagsTutorialStepCompleted.i18n);
            }

            tutorialNotifier.value = TutorialState.onTagsTutorial(
                state.copyWith(viewedTagIds: {tagId, ...state.viewedTagIds}));
          }
        });
  }
}

class _TutorialPanelOnShowPerson extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<ValueNotifier<TutorialState>>(context);
    final tutorialState = notifier.value;

    return tutorialState.maybeWhen<Widget>(
        onTagsTutorial: (TagsTutorialState state) {
          return GestureDetector(
            child: panelWrapped([const TutorialContent(cancellable: true)]),
            onTap: () {
              final notifier = Provider.of<ValueNotifier<TutorialState>>(
                  context,
                  listen: false);
              notifier.value.maybeWhen(
                  onTagsTutorial: (s) {
                    if (s.noteUsedTagIds.isNotEmpty && s.viewedTagIds.isEmpty) {
                      Scaffold.of(context).hideCurrentSnackBar();
                      showSnackBarMessage(
                          context, tagsTutorialViewTaggedNoteSnackBar.i18n);
                    }
                  },
                  orElse: () {});
            },
          );
        },
        orElse: () => Container());
  }
}

class _TutorialPanelOnSnowTaggedNotes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<ValueNotifier<TutorialState>>(context);
    final tutorialState = notifier.value;

    return tutorialState.maybeWhen<Widget>(
        onTagsTutorial: (TagsTutorialState state) {
          return Padding(
              padding: const EdgeInsets.only(top: 64),
              child: panelWrapped([
                const TutorialContent(),
              ]));
        },
        orElse: () => Container());
  }
}

Widget panelWrapped(List<Widget> widgets) {
  final decoration = BoxDecoration(
    color: Colors.white,
    borderRadius: const BorderRadius.all(Radius.circular(10)),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.5),
        spreadRadius: 2,
        blurRadius: 3,
        offset: const Offset(0, 3), // changes position of shadow
      ),
    ],
  );

  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
    child: Container(
      width: 400,
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: decoration,
      child: Column(
//        shrinkWrap: true,
        mainAxisSize: MainAxisSize.min,
        // They should be ListTile to align style
        children: widgets,
      ),
    ),
  );
}

class WithBottomTutorial extends StatelessWidget {
  const WithBottomTutorial._(this.child, this.bottomTutorial,
      {this.topPadding = 180});

  factory WithBottomTutorial.home({@required Widget child}) {
    return WithBottomTutorial._(child, _TutorialPanelHome());
  }

  factory WithBottomTutorial.noteTagsPage({@required Widget child}) {
    return WithBottomTutorial._(
      child,
      _TutorialPanelOnShowTags(),
    );
  }

  factory WithBottomTutorial.showPerson({@required Widget child}) {
    return WithBottomTutorial._(child, _TutorialPanelOnShowPerson(),
        topPadding: 350);
  }

  factory WithBottomTutorial.showTaggedNotes({@required Widget child}) {
    return WithBottomTutorial._(child, _TutorialPanelOnSnowTaggedNotes());
  }
  final Widget child;
  final Widget bottomTutorial;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold.of(context);
    final bottomMargin = scaffold.hasFloatingActionButton ? 73.0 : 0.0;
    return Stack(children: <Widget>[
      child,
      Positioned(
          top: topPadding,
          bottom: bottomMargin,
          left: 0,
          right: 0,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Expanded(
                // Keep tutorial bottom
                child: Container()),
            Align(alignment: Alignment.centerLeft, child: bottomTutorial),
          ]))
    ]);
  }
}

int homePanelTapCount = 0;

class _TutorialPanelHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final notifier =
        Provider.of<ValueNotifier<TutorialState>>(context, listen: true);
    final state = notifier.value;

    if (state is TagsTutorial) {
      return panelWrapped([
        GestureDetector(
          child: const TutorialContent(cancellable: true),
          onTap: () {
            state.maybeWhen(
                onTagsTutorial: (s) {
                  if (s.recentTagIds.isEmpty) {
                    homePanelTapCount++;
                    final scaffold = Scaffold.of(context);
                    if (homePanelTapCount > 1) {
                      scaffold.openDrawer();
                    } else {
                      scaffold.hideCurrentSnackBar();
                      showSnackBarMessage(
                          context, tagsTutorialStartSnackBar.i18n);
                    }
                  }
                },
                orElse: () {});
          },
        )
      ]);
    }

    if (state is Off) {
      return Container();
    }
    return panelWrapped([const TutorialContent(cancellable: true)]);
  }
}

class _TutorialPanelOnShowTags extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<ValueNotifier<TutorialState>>(context);
    final tutorialState = notifier.value;

    return tutorialState.maybeWhen<Widget>(
        onTagsTutorial: (TagsTutorialState state) {
          return panelWrapped([
            GestureDetector(
              child: TutorialContent(
                  cancellable: state.recentTagIds.isEmpty),
              onTap: () {
                final notifier = Provider.of<ValueNotifier<TutorialState>>(
                    context,
                    listen: false);
                notifier.value.maybeWhen(
                    onTagsTutorial: (s) {
                      if (s.recentTagIds.isEmpty) {
                        Scaffold.of(context).hideCurrentSnackBar();
                        showSnackBarMessage(
                            context, tagsTutorialStep1CreateTag.i18n);
                      } else if (s.noteUsedTagIds.isEmpty) {
                        Scaffold.of(context).hideCurrentSnackBar();
                        showSnackBarMessage(
                            context, tagsTutorialGotoHomeSnackBar.i18n);
                      }
                    },
                    orElse: () {});
              },
            )
          ]);
        },
        orElse: () => Container());
  }
}

const int desiredNumber = 3;

const double iconColumnWidth = 30;

class AddMorePeoplePanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Want to know if anything changes.
    final personsModel = Provider.of<PersonsModel>(context, listen: true);
    final currentPeopleCount = personsModel.persons.length;
    final addedPeopleCount = currentPeopleCount - 1;
    final achieved = addedPeopleCount >= desiredNumber;

    final notifier =
        Provider.of<ValueNotifier<TutorialState>>(context, listen: false);

    Future<void> showAddPeopleRoute() async {
      await Navigator.of(context).push<List<Person>>(
          createBottomUpAnimationRoute<List<Person>>(
              (context, animation, secondaryAnimation) =>
                  AddMultiplePersonsRoute()));
    }

    return Row(
      children: <Widget>[
        Expanded(
          child: ListTile(
            onTap: achieved
                ? () => notifier.value = const TutorialState.on()
                : showAddPeopleRoute,
            title: addedPeopleCount >= desiredNumber
                ? Text(enoughPeopleAdded.i18n.fill([addedPeopleCount]))
                : Text('Let\'s add 3 people to take notes.'.i18n),
            subtitle: currentPeopleCount > 1
                ? Column(
                    children: <Widget>[
                      Text(youCanAddMore.i18n),
                      achieved
                          ? Text(
                              'Next: Tutorial'.i18n,
                              style: theme.textTheme.bodyText1.copyWith(
                                  decoration: TextDecoration.underline),
                            )
                          : Container(),
                    ],
                  )
                : Container(),
          ),
        ),
        Column(
          children: <Widget>[
            achieved
                ? IconButton(
                    icon: Icon(Icons.check_circle, color: Colors.lightGreen),
                    onPressed: () {
                      notifier.value = const TutorialState.on();
                    },
                  )
                : InkWell(
                    onTap: showAddPeopleRoute,
                    child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          //borderRadius: new BorderRadius.circular(30.0),
                          color: theme.primaryColor,
                        ),
                        child: Icon(Icons.group_add,
                            color: theme.colorScheme.onPrimary)),
                  ),
            const SizedBox(height: 8),
            Text('$addedPeopleCount / $desiredNumber',
                style: theme.textTheme.caption)
          ],
        ),
        const SizedBox(width: 16)
      ],
    );
  }
}

class CheckBoxLine extends StatelessWidget {
  const CheckBoxLine(this.text, {@required this.checked});

  final String text;
  final bool checked;

  @override
  Widget build(BuildContext context) {
    const checkBoxIconSize = 20.0;
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(
          checked ? Icons.check_box : Icons.check_box_outline_blank,
          size: checkBoxIconSize,
          color: checked ? Colors.lightGreen : theme.disabledColor,
        ),
        Expanded(child: Text(text))
      ],
    );
  }
}

class TutorialContent extends StatelessWidget {
  const TutorialContent({this.cancellable = false});
  final bool cancellable;

  @override
  Widget build(BuildContext context) {
    final notifier =
        Provider.of<ValueNotifier<TutorialState>>(context, listen: true);

    final tagsRepository =
        Provider.of<NoteTagRepository>(context, listen: false);

    final state = notifier.value;

    final theme = Theme.of(context);

    void showTutorialEndSnackBar() {
      final scaffold = Scaffold.of(context);

      scaffold
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
            content: const Text(''),
            action: SnackBarAction(
              label: 'End tutorial'.i18n,
              onPressed: () {
                notifier.value = const TutorialState.off();
                scaffold
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(
                      content:
                          Text('See "Help" page to resume tutorials'.i18n)));
              },
            )));
    }

    Widget tagsTutorial(TagsTutorialState state) {
      var c = state.recentTagIds.isNotEmpty ? 1 : 0;
      c += state.noteUsedTagIds.isNotEmpty ? 1 : 0;
      c += state.viewedTagIds.isNotEmpty ? 1 : 0;
      final achieved = c >= 3;

      final recentTagNames = state.recentTagIds
          .map(tagsRepository.get)
          .where((t) => t != null)
          .map((t) => '"${t.name}"')
          .toList(growable: false)
          .join(',');

      return Stack(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Tutorial'.i18n,
                        style: theme.textTheme.caption,
                      ),
                      Text(tagsTutorialTitle.i18n),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      recentTagNames.isEmpty
                          ? CheckBoxLine(tagsTutorialStep1CreateTag.i18n,
                              checked: false)
                          : CheckBoxLine(
                              tagsTutorialStep1CreateTagDone.i18n
                                  .fill([recentTagNames]),
                              checked: true),
                      CheckBoxLine(tagsTutorialStep2AddTagToNote.i18n,
                          checked: state.noteUsedTagIds.isNotEmpty),
                      CheckBoxLine(tagsTutorialStep3ViewTaggedNotes.i18n,
                          checked: state.viewedTagIds.isNotEmpty),
                      achieved
                          ? Text(tagsTutorialStepCompleted.i18n,
                              style: theme.textTheme.bodyText1)
                          : Container(),
                    ],
                  ),
                ),
              ),
              achieved
                  ? Container()
                  : Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          achieved
                              ? Icon(Icons.check_circle,
                                  color: Colors.lightGreen)
                              : Container(),
                          cancellable
                              ? GestureDetector(
                                  child: const Icon(Icons.cancel),
                                  onTap: () {
                                    notifier.value = const TutorialState.on();
                                    showTutorialEndSnackBar();
                                  },
                                )
                              : Container(),
                        ],
                      ),
                    ),
            ],
          ),
          achieved
              ? Positioned(
                  top: 0,
                  right: 5,
                  child: GestureDetector(
                      onTap: () {
                        notifier.value = const TutorialState.off();
                      },
                      child: const Icon(Icons.cancel)))
              : Container()
        ],
      );
    }

    return state.when(
        off: () => AvailableTutorialList(), // in help page
        on: () => AvailableTutorialList(),
        onAddPeopleTutorial: (_) => AddMorePeoplePanel(),
        onTagsTutorial: tagsTutorial);
  }
}

class AvailableTutorialList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final notifier =
        Provider.of<ValueNotifier<TutorialState>>(context, listen: false);
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: ListTile(
                title: Text(tagsTutorialTitle.i18n),
                subtitle:
                    Text('You\'ll learn how to organize notes by tags'.i18n),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.play_circle_filled),
              onPressed: () {
                notifier.value =
                    TutorialState.onTagsTutorial(TagsTutorialState());

                showSnackBarMessage(context, tagsTutorialStartSnackBar.i18n);
              },
            ),
            const SizedBox(width: 16)
          ],
        ),
      ],
    );
  }
}

const String tutorialKeyNoteInputTextField = 'tutorialNoteInputTextField';
const String tutorialKeyNoteAdditionalButton = 'tutorialKeyAdditionalButton';
const String tutorialKeyNoteNoTagButton = 'tutorialKeyNoTagButton';
const String tutorialKeyTagAddButton = 'tutorialKeyTagAddButton';

class WithTutorialDot extends StatelessWidget {
  const WithTutorialDot(this.name, {this.child});
  final String name;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tutorialNotifier =
        Provider.of<ValueNotifier<TutorialState>>(context, listen: true);

    final state = tutorialNotifier.value;

    var showDot = false;

    void onTagsTutorial(TagsTutorialState state) {
      if (tutorialKeyTagAddButton == name) {
        if (state.recentTagIds.isEmpty) {
          showDot = true;
        }
      }

      if ([
        tutorialKeyNoteInputTextField,
        tutorialKeyNoteNoTagButton,
        tutorialKeyNoteAdditionalButton
      ].contains(name)) {
        if (state.recentTagIds.isNotEmpty && state.noteUsedTagIds.isEmpty) {
          showDot = true;
        }
      }
      if (state.recentTagIds.contains(name)) {
        showDot = true;
      }
    }

    state.maybeWhen(onTagsTutorial: onTagsTutorial, orElse: () {});

    if (!showDot) {
      return child;
    }

    return Stack(
      children: [
        child,
        Positioned(
          // draw a red marble
          top: 5,
          left: 5,
          child: Icon(Icons.brightness_1, size: 12, color: Colors.orange),
        )
      ],
    );
  }
}
