import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../services/logger.dart';

class SafeNetworkImage extends StatefulWidget {
  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Duration timeout;
  final String? debugLabel;
  final bool showUrlInError;

  const SafeNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.timeout = const Duration(seconds: 90),
    this.debugLabel,
    this.showUrlInError = false,
  });

  @override
  State<SafeNetworkImage> createState() => _SafeNetworkImageState();
}

class _SafeNetworkImageState extends State<SafeNetworkImage> {
  Uint8List? _bytes;
  Object? _error;
  bool _loading = false;
  DateTime? _started;
  Timer? _ticker;
  int _seconds = 0;
  int _attempt = 0;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void didUpdateWidget(covariant SafeNetworkImage old) {
    super.didUpdateWidget(old);
    if (old.url != widget.url) _fetch();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String get _label => widget.debugLabel ?? 'image';

  Future<void> _fetch() async {
    _ticker?.cancel();
    _attempt += 1;
    final attempt = _attempt;
    final started = DateTime.now();
    setState(() {
      _bytes = null;
      _error = null;
      _loading = true;
      _started = started;
      _seconds = 0;
    });
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _seconds = DateTime.now().difference(started).inSeconds;
      });
    });

    AppLogger.instance.info('$_label: GET ${widget.url}');
    try {
      final res = await http.get(Uri.parse(widget.url)).timeout(widget.timeout);
      if (!mounted || attempt != _attempt) return;
      final ms = DateTime.now().difference(started).inMilliseconds;
      if (res.statusCode != 200) {
        throw _ImageHttpException(
          'HTTP ${res.statusCode} ${res.reasonPhrase ?? ""}'.trim(),
          status: res.statusCode,
        );
      }
      if (res.bodyBytes.isEmpty) {
        throw const _ImageHttpException('Empty response body');
      }
      AppLogger.instance.info(
        '$_label: 200 OK in ${ms}ms (${res.bodyBytes.length} bytes)',
      );
      _ticker?.cancel();
      setState(() {
        _bytes = res.bodyBytes;
        _loading = false;
      });
    } on TimeoutException catch (e, s) {
      AppLogger.instance.error('$_label: timed out after ${widget.timeout.inSeconds}s', e, s);
      if (!mounted || attempt != _attempt) return;
      _ticker?.cancel();
      setState(() {
        _error = 'Timed out after ${widget.timeout.inSeconds}s';
        _loading = false;
      });
    } catch (e, s) {
      AppLogger.instance.error('$_label: $e', e, s);
      if (!mounted || attempt != _attempt) return;
      _ticker?.cancel();
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget child;
    if (_bytes != null) {
      child = Image.memory(
        _bytes!,
        fit: widget.fit,
        gaplessPlayback: true,
        errorBuilder: (context, error, stack) {
          AppLogger.instance.error('$_label: decode failed: $error', error, stack);
          return _ErrorPlaceholder(
            message: 'Could not decode image: $error',
            onRetry: _fetch,
          );
        },
      );
    } else if (_error != null) {
      child = _ErrorPlaceholder(
        message: _error.toString(),
        url: widget.showUrlInError ? widget.url : null,
        onRetry: _fetch,
      );
    } else {
      child = _LoadingPlaceholder(seconds: _seconds, loading: _loading);
    }
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: child,
    );
  }
}

class _ImageHttpException implements Exception {
  final String message;
  final int? status;
  const _ImageHttpException(this.message, {this.status});
  @override
  String toString() => message;
}

class _LoadingPlaceholder extends StatelessWidget {
  final int seconds;
  final bool loading;
  const _LoadingPlaceholder({required this.seconds, required this.loading});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      color: scheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          if (seconds > 0) ...[
            const SizedBox(height: 8),
            Text(
              'Generating… ${seconds}s',
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
            ),
            if (seconds > 10)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  'first request can take 20–40s',
                  style: TextStyle(
                    fontSize: 10,
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _ErrorPlaceholder extends StatelessWidget {
  final String message;
  final String? url;
  final VoidCallback onRetry;
  const _ErrorPlaceholder({
    required this.message,
    required this.onRetry,
    this.url,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      color: scheme.errorContainer,
      padding: const EdgeInsets.all(8),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.broken_image_outlined, color: scheme.onErrorContainer),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, color: scheme.onErrorContainer),
          ),
          if (url != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: TextButton.icon(
                icon: const Icon(Icons.copy, size: 14),
                label: const Text('Copy URL', style: TextStyle(fontSize: 11)),
                onPressed: () => Clipboard.setData(ClipboardData(text: url!)),
              ),
            ),
          TextButton.icon(
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry'),
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
