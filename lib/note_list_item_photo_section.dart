import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hitomemo/widgets/cached_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class NotePhotoSection extends StatelessWidget {
  const NotePhotoSection(this.photoUrls);

  final List<String> photoUrls;

  List<Widget> thumbnails(BuildContext context, double height) {
    final theme = Theme.of(context);
    return photoUrls
        .map((url) => Container(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                  onTap: () => open(context, url),
                  child: Hero(
                    tag: url,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      child: SizedBox(
                          height: height,
                          child: Image(
                              image: CachedImage(url),
                              errorBuilder: (context, _, __) => Container(
                                  height: height,
                                  width: height,
                                  alignment: Alignment.center,
                                  color: theme.disabledColor,
                                  child: Icon(Icons.broken_image)))),
                    ),
                  )),
            ))
        .toList(growable: false);
  }

  List<PhotoViewGalleryPageOptions> galleryOptions() {
    return photoUrls
        .map((url) => PhotoViewGalleryPageOptions(
              imageProvider: CachedImage(url),
              heroAttributes: PhotoViewHeroAttributes(tag: url),
            ))
        .toList(growable: false);
  }

  void open(BuildContext context, final String url) {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => GalleryPhotoViewWrapper(
          galleryItems: photoUrls,
          backgroundDecoration: const BoxDecoration(
            color: Colors.black,
          ),
          initialIndex: photoUrls.indexOf(url),
          scrollDirection: Axis.horizontal,
        ),
      ),
    );
  }

  double thumbnailHeight(double screenHeight) {
    if (screenHeight <= 320) {
      return 100;
    }
    if (screenHeight > 1024) {
      return 150;
    }

    return 100 + 50 / (1024 - 320) * screenHeight;
  }

  @override
  Widget build(BuildContext context) {
    if (photoUrls.isEmpty) {
      return Container();
    }

    final screenHeight = MediaQuery.of(context).size.height;
    final photoHeight = thumbnailHeight(screenHeight);

    return SizedBox(
      height: photoHeight,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: thumbnails(context, photoHeight),
      ),
    );
  }
}

class GalleryPhotoViewWrapper extends StatefulWidget {
  GalleryPhotoViewWrapper({
    this.loadingBuilder,
    this.backgroundDecoration,
    this.minScale,
    this.maxScale,
    this.initialIndex,
    @required this.galleryItems,
    this.scrollDirection = Axis.horizontal,
  }) : pageController = PageController(initialPage: initialIndex);

  final LoadingBuilder loadingBuilder;
  final Decoration backgroundDecoration;
  final dynamic minScale;
  final dynamic maxScale;
  final int initialIndex;
  final PageController pageController;
  final List<String> galleryItems;
  final Axis scrollDirection;

  @override
  State<StatefulWidget> createState() {
    return _GalleryPhotoViewWrapperState();
  }
}

class _GalleryPhotoViewWrapperState extends State<GalleryPhotoViewWrapper> {
  int currentIndex;

  @override
  void initState() {
    currentIndex = widget.initialIndex;
    super.initState();
  }

  void onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: widget.backgroundDecoration,
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: Stack(
          children: <Widget>[
            Container(
              child: PhotoViewGallery.builder(
                scrollPhysics: const BouncingScrollPhysics(),
                builder: _buildItem,
                itemCount: widget.galleryItems.length,
                loadingBuilder: widget.loadingBuilder,
                backgroundDecoration: widget.backgroundDecoration,
                pageController: widget.pageController,
                onPageChanged: onPageChanged,
                scrollDirection: widget.scrollDirection,
              ),
            ),
            Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(20),
              child: Text(
                '${currentIndex + 1} / ${widget.galleryItems.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  decoration: null,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.close),
              color: Colors.white,
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        ),
      ),
    );
  }

  PhotoViewGalleryPageOptions _buildItem(BuildContext context, int index) {
    final photoUrl = widget.galleryItems[index];
    return PhotoViewGalleryPageOptions(
      imageProvider: CachedImage(photoUrl),
      initialScale: PhotoViewComputedScale.contained,
      minScale: PhotoViewComputedScale.contained * (0.5 + index / 10),
      maxScale: PhotoViewComputedScale.covered * 1.1,
      heroAttributes: PhotoViewHeroAttributes(tag: photoUrl),
    );
  }
}
