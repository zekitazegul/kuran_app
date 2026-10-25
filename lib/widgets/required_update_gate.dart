import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/translations.dart';
import '../services/app_language.dart';
import '../services/available_update.dart';
import 'app_distribution.dart';

class RequiredUpdateGate extends StatefulWidget {
  const RequiredUpdateGate({super.key, required this.child});
  final Widget child;
  @override
  State<RequiredUpdateGate> createState() => _RequiredUpdateGateState();
}

class _RequiredUpdateGateState extends State<RequiredUpdateGate> with WidgetsBindingObserver {
  static const channel = MethodChannel('com.zekitazegul.kuranapp/update');
  AvailableUpdate? _available;
  bool _checking = false, _busy = false, _started = false;
  String? _status;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AppLanguage.instance.addListener(_start);
    _start();
  }

  void _start() {
    if (_started || AppLanguage.instance.value == null) return;
    _started = true;
    _check();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _started && !_busy) _check();
  }

  Future<void> _check() async {
    if (_checking) return;
    _checking = true;
    try {
      final data = await channel.invokeMapMethod<String, dynamic>('checkUpdate',
        {'manifestUrl': updateManifestUrl, 'force': true});
      if (mounted && data != null) setState(() => _available = AvailableUpdate.fromMap(data));
    } catch (_) {
      // Keep an already discovered mandatory update on network failure.
    } finally { _checking = false; }
  }

  Future<void> _install() async {
    if (_busy) return;
    setState(() { _busy = true; _status = 'updateDownloading'; });
    try {
      await channel.invokeMethod<String>('update', {
        'manifestUrl': updateManifestUrl,
        'labels': {
          'title': context.t('downloadTitle'),
          'wifi': context.t('downloadWifi'),
          'smallMobile': context.t('downloadSmallMobile'),
          'largeMobile': context.t('downloadLargeMobile'),
          'download': context.t('downloadAccept'),
          'cancel': context.t('downloadCancel'),
          'cancelled': context.t('downloadCancelled'),
          'downloading': context.t('updateDownloading'),
        },
      });
      if (mounted) setState(() => _status = 'requiredUpdate');
    } catch (_) {
      if (mounted) setState(() => _status = 'updateError');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AppLanguage.instance.removeListener(_start);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final update = _available;
    return Stack(children: [widget.child,
      if (update != null) Positioned.fill(child: PopScope(canPop: false,
        child: Material(color: Theme.of(context).colorScheme.surface,
          child: SafeArea(child: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24),
            child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 520),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.system_update, size: 48),
                const SizedBox(height: 16),
                Text(update.version, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                Text(context.t('requiredUpdate')),
                const SizedBox(height: 12),
                Text(update.description(context.language, context.t('requiredUpdate'))),
                const SizedBox(height: 20),
                if (_status != null) Text(context.t(_status!)),
                if (_busy) const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
                FilledButton(onPressed: _busy ? null : _install,
                  child: Text(context.t('downloadAccept'))),
              ])))))))),
    ]);
  }
}
