// File generated for GlowBayBD Firebase Configuration
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for GlowBay BD
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDpy5dpJBY1MBc23OgxMMb97jUuIpXOtws',
    appId: '1:524435743928:android:d7e847a77f42a2f5bc004d',
    messagingSenderId: '524435743928',
    projectId: 'glowbay-bd',
    storageBucket: 'glowbay-bd.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDpy5dpJBY1MBc23OgxMMb97jUuIpXOtws',
    appId: '1:524435743928:ios:d7e847a77f42a2f5bc004d',
    messagingSenderId: '524435743928',
    projectId: 'glowbay-bd',
    storageBucket: 'glowbay-bd.firebasestorage.app',
    iosBundleId: 'com.glowbaybd.glowbayApp',
  );
}
