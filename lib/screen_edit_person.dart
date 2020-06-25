import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hitomemo/login_user_model.dart';
import 'package:hitomemo/screen_edit_person_family_section.dart';
import 'package:hitomemo/tag.dart';
import 'package:image/image.dart' as _image;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

import 'person.dart';
import 'person_model.dart';
import 'person_tags_model.dart';
import 'screen_edit_person.i18n.dart';
import 'tag_chip.dart';
import 'widgets/cached_image.dart';
import 'widgets/person_editable_avatar.dart';
import 'widgets/photo_access_dialog.dart';

class EditPersonRoute extends StatefulWidget {
  // Passing value to screen (route)
  // https://flutter.dev/docs/cookbook/navigation/passing-data#4-navigate-and-pass-data-to-the-detail-screen
  const EditPersonRoute(this._person);

  final Person _person;

  bool get isFirstRecord => _person.id == '0';

  @override
  State<StatefulWidget> createState() {
    return PersonInfoFormState(_person);
  }
}

class PersonInfoFormState extends State<EditPersonRoute> {
  PersonInfoFormState(this._originalPerson);
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneticNameController = TextEditingController();

  // The original data that we can use to compare the temporary value of _person
  // so that we can warn the user about discarding changes.
  final Person _originalPerson;
  Family _originalFamily;
  Person _person;
  Set<PTag> _originalTags;
  Set<PTag> _tags;
  PersonsModel _personsModel;
  TagsModel _tagsModel;
  bool uploadingPhoto;
  bool _saveEnabled = true;
  ValueNotifier<Person> _personNotifier;
  ValueNotifier<Family> _familyNotifier;

  @override
  void initState() {
    super.initState();
    _personsModel = Provider.of<PersonsModel>(context, listen: false);
    _tagsModel = Provider.of<TagsModel>(context, listen: false);
    _nameController.text = _originalPerson.name;
    _phoneticNameController.text = _originalPerson.phoneticName ?? '';
    _person = _originalPerson.copyWith();
    _nameController.addListener(() {
      _personNotifier.value = _person.copyWith(name: _nameController.text);
    });
    _phoneticNameController.addListener(() {
      final txt = _phoneticNameController.text;
      if (txt.isEmpty) {
        _personNotifier.value = _person.copyWith(phoneticName: null);
      } else {
        _personNotifier.value = _person.copyWith(phoneticName: txt);
      }
    });

    _tags = _originalTags = _tagsModel.getTags(_person.id).toSet();

    uploadingPhoto = false;

    _personNotifier = ValueNotifier(_person)
      ..addListener(() {
        setState(() {
          _person = _personNotifier.value;
        });
      });
    _originalFamily = _personsModel.getFamily(_person.familyId);
    _familyNotifier = ValueNotifier(_originalFamily)
      ..addListener(() {
        setState(() {});
      });
  }

  Future<void> _deleteTapped() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Delete this entry?'.i18n),
          actions: <Widget>[
            RaisedButton(
              key: const Key('confirm-delete'),
              child: Text('Delete'.i18n),
              textColor: Theme.of(dialogContext).colorScheme.onError,
              color: Theme.of(dialogContext).colorScheme.error,
              onPressed: () async {
                Navigator.of(dialogContext).pop(true);
              },
            ),
            FlatButton(
              child: Text('Cancel'.i18n),
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
            ),
          ],
        );
      },
    );

    if (confirmed) {
      await _personsModel.delete(_person);
      Navigator.of(context).pop(EditPersonResult.deleted(_person));
    }
  }

  Future<void> _saveTapped() async {
    setState(() {
      _saveEnabled = false;
    });

    var person = _person.copyWith(name: _nameController.text);
    if (_phoneticNameController.text.isNotEmpty) {
      person = _person.copyWith(phoneticName: _phoneticNameController.text);
    }

    if (_originalTags != _tags) {
      await _tagsModel.updatePersonTags(person, _tags);
    }

    final latestFamily = _familyNotifier.value;
    if (latestFamily != null) {
      if (_originalFamily == null || latestFamily.id == _originalFamily.id) {
        // Membership change
        await _personsModel.updateFamily(latestFamily);
      }
      person = person.copyWith(familyId: latestFamily.id);
    }

    // The update below could have done with tagsModel.updatePersonTags together
    // but updatePersonTags needs atomicity.
    person = await _personsModel.update(person);

    Navigator.of(context).pop(EditPersonResult.updated(person));
  }

  Future<File> _pickImage(BuildContext context) async {
    try {
      final imageFile =
          await ImagePicker.pickImage(source: ImageSource.gallery);
      return imageFile;
    } on PlatformException catch (err) {
      // User did not give permission
      if (err.code == 'photo_access_denied') {
        await dialogPhotoAccess(context);
        return null;
      }
      return null;
    } on Exception catch (_) {
      // User did not give permission
      return null;
    }
  }

  /// Returns path of Google Cloud Storage image
  Future<String> _uploadImage(BuildContext context, File file) async {
    final loginUserModel = Provider.of<LoginUserModel>(context, listen: false);
    final personPath = '${loginUserModel.user.uid}/${_person.id}';
    // final extension = file.path.split('.').last;
    final secondsSinceEpoch = DateTime.now().millisecondsSinceEpoch / 1000;
//    final path = '$personPath.jpg';
    final path = '$personPath/$secondsSinceEpoch.jpg';
    final firebaseStorage = FirebaseStorage();
    final storageReference = firebaseStorage.ref().child(path);
    final uploadTask = storageReference.putFile(file);
    Scaffold.of(context)
        .showSnackBar(SnackBar(content: Text('Uploading picture'.i18n)));

    setState(() {
      uploadingPhoto = true;
    });
    final streamSubscription = uploadTask.events.listen((event) {
      // https://pub.dev/packages/firebase_storage
      print('EVENT ${event.type}');
    });

    final taskSnapshot = await uploadTask.onComplete;
    await streamSubscription.cancel();
    setState(() {
      uploadingPhoto = false;
    });
    if (taskSnapshot.error != null) {
      Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('Picture failed: Error: %s'
              .i18n
              .fill(['${taskSnapshot.error}']))));
      return null;
    } else {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text('Picture uploaded'.i18n)));
      final bucketName = await storageReference.getBucket();
      return 'gs://$bucketName/${storageReference.path}';
    }
  }

  Future<void> _onPhotoIconPressed(BuildContext context) async {
    final theme = Theme.of(context);
    final imageFile = await _pickImage(context);
    if (imageFile == null) {
      return;
    }

    final croppedFile = await ImageCropper.cropImage(
        sourcePath: imageFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper'.i18n,
            toolbarColor: theme.primaryColor,
            toolbarWidgetColor: theme.primaryColor,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: const IOSUiSettings(
          minimumAspectRatio: 1,
          hidesNavigationBar: false,
          rotateButtonsHidden: true,
          rotateClockwiseButtonHidden: true,
        ));
    if (croppedFile == null) {
      return;
    }

    final decodedImage = _image.decodeImage(croppedFile.readAsBytesSync());
    // Resize the image to a 120x? thumbnail (maintaining the aspect ratio).
    // Use 8x8 grid
    // https://developer.apple.com/design/human-interface-guidelines/ios/icons-and-images/image-size-and-resolution/
    final resizedImage = _image.copyResize(decodedImage, width: 512);
    final jpegData = _image.encodeJpg(resizedImage);
    final tempDir = await getTemporaryDirectory();
    final tempPath = tempDir.path;
    final bn = path.basename(imageFile.path);
    final file = File('$tempPath/resized_$bn')..writeAsBytesSync(jpegData);

    // https://firebasestorage.googleapis.com/v0/b/suztomo-hitomemo.appspot.com/o/t1gVCkBrgMU9LjFRnrtu1FFjlir1%2FYagiCfrKMGTwcxq3l21V.jpg?alt=media&token=3b17cf0d-e6ba-4543-890a-2f5a4e363547
    final gcsPath = await _uploadImage(context, file);
    await file.delete();

    setState(() {
      _person = _person.copyWith(pictureGcsPath: gcsPath);
    });
  }

  Future<void> _iconSelection(BuildContext context) async {
    final pictureGcsUrl = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const AvatarIconSelection(),
    );
    if (pictureGcsUrl != null) {
      setState(() {
        _person = _person.copyWith(pictureGcsPath: pictureGcsUrl);
      });
    }
  }

  Future<void> _onPersonFaceIconPressed(BuildContext context) async {
    final source = await showModalBottomSheet<AvatarSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const AvatarSourceSelection(),
    );

    switch (source) {
      case AvatarSource.photoLibrary:
        return _onPhotoIconPressed(context);
      case AvatarSource.icon:
        return _iconSelection(context);
      default:
        // E.g., tapping outside the sheet
        return;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneticNameController.dispose();
    super.dispose();
  }

  Widget _photo(BuildContext context) {
    final theme = Theme.of(context);

    final photoStack = <Widget>[
      GestureDetector(
        child: Center(
            child: _person.pictureGcsPath == null
                ? const Icon(Icons.person, size: 90)
                : CircleAvatar(
                    radius: 90,
                    backgroundImage: CachedImage(_person.pictureGcsPath),
                  )),
        onTap: () => _onPersonFaceIconPressed(context),
      ),
      Align(
        alignment: Alignment.bottomRight,
        child: IconButton(
          icon: Icon(Icons.add_photo_alternate),
          iconSize: 30,
          onPressed: () => _onPersonFaceIconPressed(context),
        ),
      )
    ];
    if (uploadingPhoto) {
      photoStack.add(const Center(
          child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      )));
    }

    return Container(
      height: 200,
      color: theme.primaryColor,
      child: Stack(
        children: photoStack,
      ),
    );
  }

  bool hasNoChange() =>
      _originalPerson == _person &&
      _originalTags == _tags &&
      _originalFamily == _familyNotifier.value;

  Widget _form() {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: _nameController,
            validator: (value) {
              if (value.length < 2) {
                return 'Invalid name'.i18n;
              }
              return null;
            },
            decoration: InputDecoration(
              icon: const Icon(Icons.person),
              labelText: widget.isFirstRecord ? 'Your Name'.i18n : 'Name'.i18n,
            ),
          ),
          TextFormField(
            key: const Key('form_phonetic_name'),
            controller: _phoneticNameController,
            decoration: InputDecoration(
              icon: const Icon(Icons.person),
              labelText: 'Phonetic Name'.i18n,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> tagChoiceChipList(ValueNotifier<Set<PTag>> tagNotifier) {
    final tags = tagNotifier.value;
    return _tagsModel.tags.map((tag) {
      return Container(
        padding: const EdgeInsets.all(2),
        child: GroupChip(
          tag,
          selected: tags.contains(tag),
          onSelected: (selected) async {
            final updatedTags = {...tags}; // copy
            if (selected) {
              updatedTags.add(tag);
            } else {
              updatedTags.remove(tag);
            }
            tagNotifier.value = updatedTags;
          },
        ),
      );
    }).toList();
  }

  Widget choiceChipPanel(ValueNotifier<Set<PTag>> tagsNotifier) {
    return ChangeNotifierProvider<ValueNotifier<Set<PTag>>>.value(
      value: tagsNotifier,
      child: Consumer<ValueNotifier<Set<PTag>>>(
          builder: (_, notifier, __) => Wrap(
                children: tagChoiceChipList(notifier),
              )),
    );
  }

  Future<void> _groupAddTapped() async {
    final notifier = ValueNotifier(_tags);
    await showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Select Groups'.i18n),
            content: choiceChipPanel(notifier),
            actions: [
              MaterialButton(
                  elevation: 5,
                  child: Text('Close'.i18n),
                  onPressed: () => Navigator.of(context).pop())
            ],
          );
        });
    setState(() {
      _tags = notifier.value;
    });
  }

  Wrap _selectedTags(BuildContext context, TagsModel tagsModel) {
    final theme = Theme.of(context);
    final tagChips =
        tagsModel.tags.where((tag) => _tags.contains(tag)).map((tag) {
      return Container(
          padding: const EdgeInsets.all(2),
          child: ChoiceChip(
            label: Text(tag.name, style: theme.textTheme.bodyText2),
            selected: true,
            onSelected: (selected) {
              _groupAddTapped();
            },
          ));
    }).toList();

    if (tagChips.isEmpty) {
      tagChips.add(Container(
          padding: const EdgeInsets.all(2),
          child: ChoiceChip(
            label: Text('No Group'.i18n),
            onSelected: (selected) {
              _groupAddTapped();
            },
            selected: false,
          )));
    }

    return Wrap(children: tagChips);
  }

  Container _groupSection() {
    return Container(
      child: Consumer<TagsModel>(
        builder: (BuildContext context, TagsModel tagsModel, Widget child) =>
            Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _selectedTags(context, tagsModel),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PersonsModel>(
        builder: (context, personsModel, child) => Scaffold(
            appBar: AppBar(
                leading:
                    hasNoChange() ? null : Container(), // Hide go-back button
                title: widget.isFirstRecord
                    ? Text('Your Entry'.i18n)
                    : FittedBox(
                        child: Text('Edit %s'.i18n.fill([_person.name]))),
                actions: [
                  IconButton(
                      icon: const Icon(Icons.check_circle),
                      key: const Key('form_submit'),
                      iconSize: 30,
                      onPressed:
                          _saveEnabled && !hasNoChange() ? _saveTapped : null)
                ]),
            body: Builder(
              builder: (context) => ScrollConfiguration(
                behavior: NonOverScrollBehavior(),
                child: ListView(
                  children: [
                    _photo(context),
                    Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(children: [
                          _groupSection(),
                          FamilySection(_personNotifier, _familyNotifier),
                          widget.isFirstRecord
                              ? Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                      'This entry is about yourself.'.i18n,
                                      style:
                                          Theme.of(context).textTheme.caption))
                              : Container(),
                          SafeArea(child: _form()),
                          const SizedBox(
                            height: 40,
                          ),
                          widget.isFirstRecord
                              ? Container()
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    SafeArea(
                                      child: IconButton(
                                        key: const Key('delete'),
                                        icon: const Icon(Icons.delete),
                                        color: Theme.of(context).errorColor,
                                        onPressed: _deleteTapped,
                                      ),
                                    ),
                                  ],
                                ),
                        ]))
                  ],
                ),
              ),
            )));
  }
}

class NonOverScrollBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const ClampingScrollPhysics();
}
