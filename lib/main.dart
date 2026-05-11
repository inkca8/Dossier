import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'services/contacts_repo.dart';
import 'services/logger.dart';

Future<void> main() async {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (details) {
      AppLogger.instance.error(
        'FlutterError: ${details.exceptionAsString()}',
        details.exception,
        details.stack,
      );
      FlutterError.presentError(details);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      AppLogger.instance.error('Uncaught async error: $error', error, stack);
      return true;
    };

    ErrorWidget.builder = (FlutterErrorDetails details) {
      AppLogger.instance.error(
        'ErrorWidget: ${details.exceptionAsString()}',
        details.exception,
        details.stack,
      );
      return Material(
        color: Colors.transparent,
        child: Container(
          color: const Color(0xFFFFE4E4),
          padding: const EdgeInsets.all(12),
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: Text(
              'Widget error:\n${details.exceptionAsString()}',
              style: const TextStyle(
                color: Color(0xFF8B0000),
                fontFamily: 'monospace',
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    };

    AppLogger.instance.info('Booting Dossier…');
    try {
      repo = await ContactsRepo.load();
    } catch (e, s) {
      AppLogger.instance.error('Failed to load contacts repo.', e, s);
      rethrow;
    }
    runApp(const DossierApp());
  }, (error, stack) {
    AppLogger.instance.error('Zone error: $error', error, stack);
  });
}
