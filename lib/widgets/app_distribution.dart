import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/translations.dart';

const updateManifestUrl = 'https://github.com/zekitazegul/kuran_app/releases/latest/download/update.json';

class AppDistribution extends StatefulWidget {
  const AppDistribution({super.key});
  @override
  State<AppDistribution> createState() => _AppDistributionState();
}

class _AppDistributionState extends State<AppDistribution> {
  static const updates = MethodChannel('com.zekitazegul.kuranapp/update');
  static const sharing = MethodChannel('com.zekitazegul.kuranapp/share');
  bool busy = false, preparing = false;
  String status = 'updateIdle';

  @override
  void initState() {
    super.initState();
    updates.setMethodCallHandler((call) async {
      if (mounted && call.method == 'status') setState(() => status = call.arguments as String);
    });
  }
  @override
  void dispose() { updates.setMethodCallHandler(null); super.dispose(); }

  String message() {
    if (status.startsWith('current:')) return context.t('updateCurrent', {'version': status.substring(8)});
    if (status.startsWith('downloading:')) return '${context.t('updateDownloading')} %${status.substring(12)}';
    return context.t(status);
  }
  Future<void> update() async {
    if (busy) return;
    setState(() { busy = true; status = 'updateChecking'; });
    try {
      final result = await updates.invokeMethod<String>('update', {'manifestUrl': updateManifestUrl, 'labels': {
        'title': context.t('downloadTitle'),
        'wifi': context.t('downloadWifi'),
        'smallMobile': context.t('downloadSmallMobile'),
        'largeMobile': context.t('downloadLargeMobile'),
        'download': context.t('downloadAccept'),
        'cancel': context.t('downloadCancel'),
        'cancelled': context.t('downloadCancelled'),
        'downloading': context.t('updateDownloading'),
      }});
      if (mounted) setState(() => status = result ?? 'updateError');
    } catch (_) {
      if (mounted) setState(() => status = 'updateError');
    } finally { if (mounted) setState(() => busy = false); }
  }
  Future<void> share() async {
    if (preparing) return;
    setState(() => preparing = true);
    try { await sharing.invokeMethod<void>('shareApk', {'title': context.t('distributionShare')}); }
    catch (_) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.t('shareError')))); }
    finally { if (mounted) setState(() => preparing = false); }
  }
  Widget spinner() => const SizedBox.square(dimension: 22, child: CircularProgressIndicator());
  @override
  Widget build(BuildContext context) => Column(children: [
    Card(child: ListTile(leading: const Icon(Icons.share_outlined),
      title: Text(context.t(preparing ? 'distributionPreparing' : 'distributionShare')),
      subtitle: Text(context.t('distributionShareHint')),
      trailing: preparing ? spinner() : const Icon(Icons.chevron_right), onTap: preparing ? null : share)),
    Card(child: ListTile(leading: const Icon(Icons.system_update_outlined),
      title: Text(context.t('distributionUpdate')), subtitle: Semantics(liveRegion: true, child: Text(message())),
      trailing: busy ? spinner() : const Icon(Icons.chevron_right), onTap: busy ? null : update)),
    Padding(padding: const EdgeInsets.all(12), child: Text(context.t('distributionPrivacy'), style: Theme.of(context).textTheme.bodySmall)),
  ]);
}
