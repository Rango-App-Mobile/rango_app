import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rango_app/app/app.dart';
import 'package:rango_app/data/auth_repository.dart';
import 'package:rango_app/data/delivery_link_repository.dart';
import 'package:rango_app/data/fake_auth_repository.dart';
import 'package:rango_app/data/fake_delivery_link_repository.dart';
import 'package:rango_app/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final firebaseOptions = DefaultFirebaseOptions.currentPlatform;
  if (firebaseOptions != null) {
    await Firebase.initializeApp(options: firebaseOptions);
  }
  runApp(
    ProviderScope(
      // Without the Firebase key in env.json the app still runs, on fakes.
      overrides: [
        if (firebaseOptions == null) ...[
          authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
          deliveryLinkRepositoryProvider.overrideWithValue(
            FakeDeliveryLinkRepository(),
          ),
        ],
      ],
      child: const RangoApp(),
    ),
  );
}
