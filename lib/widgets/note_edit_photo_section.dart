import 'dart:async';
import 'dart:ui';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hitomemo/note.dart';

import 'cached_image.dart';

import 'note_edit_photo_section.i18n.dart';

const double imageCarouselHeight = 150;

class NoteEditPhotoSection extends StatelessWidget {
  const NoteEditPhotoSection(this.noteNotifier, this.scrollController);

  final ValueNotifier<Note> noteNotifier;

  final ScrollController scrollController;

  Future<void> _onImageDelete(String url, BuildContext context) async {
    final scaffold = Scaffold.of(context)
      ..showSnackBar(SnackBar(content: Text('Deleting image'.i18n)));

    final uri = Uri.parse(url);
    final firebaseStorage = FirebaseStorage();
    final storageReference = firebaseStorage.ref().child(uri.path);

    await storageReference.delete();
    // deletion success

    final note = noteNotifier.value;
    noteNotifier.value =
        note.copyWith(pictureUrls: [...note.pictureUrls]..remove(url));

    scaffold
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('Deleted'.i18n)));
  }

  List<Widget> images(List<String> pictureUrls, BuildContext context) {
    final ret = <Widget>[];
    for (final url in pictureUrls) {
      ret.add(Padding(
          padding: const EdgeInsets.only(right: 8),
          child: DeletableImage(
              CachedImage(url), () => _onImageDelete(url, context),
              // Without a key, the blur effect on the leftmost picture remains
              // even after the picture is deleted.
              key: ValueKey(url)
          )
      )
      );
    }

    return ret;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Note>(
        valueListenable: noteNotifier,
        builder: (context, note, child) {
          final pictureUrls = note.pictureUrls;
          final items = <Widget>[...images(pictureUrls, context)];

          if (pictureUrls.isEmpty) {
            return Container();
          }
          return SizedBox(
              height: imageCarouselHeight,
              child: ListView(
                controller: scrollController,
                scrollDirection: Axis.horizontal,
                children: items,
              ));
        });
  }
}

class DeletableImage extends StatefulWidget {
  const DeletableImage(this.imageProvider, this.onDelete, {Key key}):
  super(key: key);
  final CachedImage imageProvider;
  final VoidCallback onDelete;

  @override
  _DeletableImageState createState() => _DeletableImageState();
}

class _DeletableImageState extends State<DeletableImage> {
  bool deleteButtonOn = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        child: Stack(
          children: [
            Image(
              image: widget.imageProvider,
              fit: BoxFit.cover,
              errorBuilder: (context, error, _) => Container(
                  height: imageCarouselHeight,
                  width: imageCarouselHeight,
                  alignment: Alignment.center,
                  color: theme.disabledColor,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.broken_image),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text('$error',
                            style: theme.textTheme.caption.copyWith(
                                fontSize: 10,
                                color: theme.colorScheme.onPrimary)),
                      )
                    ],
                  )),
            ),
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    deleteButtonOn = !deleteButtonOn;
                  });
                },
                child: ClipRect(
                  child: deleteButtonOn
                      ? BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Container(
                            color: Colors.black.withOpacity(0),
                          ),
                        )
                      : Container(color: Colors.transparent),
                ),
              ),
            ),
            deleteButtonOn
                ? IconButton(
                    icon: const Icon(Icons.cancel),
                    onPressed: () {
                      widget.onDelete();
                    },
                  )
                : Container()
          ],
        ));
  }
}
