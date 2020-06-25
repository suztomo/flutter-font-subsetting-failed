import 'package:firebase_image/firebase_image.dart';

class CachedImage extends FirebaseImage {
  CachedImage(this.url)
      : super(url,
            // No need to check the metadata because our usage does not update
            // an existing image
            cacheRefreshStrategy: CacheRefreshStrategy.NEVER);
  String url;
}
