import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/translations.dart';
import '../services/available_update.dart';

const updateManifestUrl =
    'https://github.com/zekitazegul/kuran_app/releases/latest/download/update.json';

class AppDistribution extends StatefulWidget {
  const AppDistribution({super.key});
  @override
  State<AppDistribution> createState() => _AppDistributionState();
}

class _AppDistributionState extends State<AppDistribution> {
  static const updates = MethodChannel('com.zekitazegul.kuranapp/update');
  static const sharing = MethodChannel('com.zekitazegul.kuranapp/share');
  bool busy = false, preparing = false, checking = false;
  AvailableUpdate? available;
  bool revealed = false;
  String? checkError;
  String installedVersion = '';
  bool installing = false;
  String status = 'updateIdle';

  @override
  void initState() {
    super.initState();
    check();
    updates.setMethodCallHandler((call) async {
      if (mounted && call.method == 'status') {
        setState(() => status = call.arguments as String);
      }
    });
  }

  @override
  void dispose() {
    updates.setMethodCallHandler(null);
    super.dispose();
  }

  Future<void> check({bool force = false}) async {
    if (checking) return;
    setState(() {
      checking = true;
      if (force) {
        revealed = true;
        checkError = null;
        installing = false;
      }
    });
    try {
      final data = await updates.invokeMapMethod<String, dynamic>(
        'checkUpdate',
        {'manifestUrl': updateManifestUrl, 'force': force},
      );
      if (mounted) {
        setState(() {
          available = AvailableUpdate.fromMap(data);
          installedVersion = data?['installedVersionName'] as String? ?? '';
        });
      }
    } catch (_) {
      if (mounted && force) setState(() => checkError = 'updateCheckError');
    } finally {
      if (mounted) setState(() => checking = false);
    }
  }

  String message() {
    if (status.startsWith('current:')) {
      return context.t('updateCurrent', {'version': status.substring(8)});
    }
    if (status.startsWith('downloading:')) {
      return '${context.t('updateDownloading')} %${status.substring(12)}';
    }
    return context.t(status);
  }

  Future<void> update() async {
    if (busy) return;
    setState(() {
      busy = true;
      installing = true;
      status = 'updateChecking';
    });
    try {
      final result = await updates.invokeMethod<String>('update', {
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
      if (mounted) setState(() => status = result ?? 'updateError');
    } catch (_) {
      if (mounted) setState(() => status = 'updateError');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> share() async {
    if (preparing) return;
    setState(() => preparing = true);
    try {
      await sharing.invokeMethod<void>('shareInstaller', {
        'title': context.t('distributionShare'),
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(context.t('shareError'))));
      }
    } finally {
      if (mounted) setState(() => preparing = false);
    }
  }

  Widget spinner() =>
      const SizedBox.square(dimension: 22, child: CircularProgressIndicator());
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Card(
        child: Padding(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListTile(
                leading: const Icon(Icons.system_update_outlined),
                title: Row(
                  children: [
                    Expanded(child: Text(context.t('distributionCheck'))),
                    if (available != null)
                      Badge(label: Text(context.t('updateNewBadge'))),
                  ],
                ),
                trailing: checking && revealed
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.expand_more),
                onTap: checking || busy ? null : () => check(force: true),
              ),
              if (revealed && !checking)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 12),
                      if (checkError != null)
                        Semantics(
                          liveRegion: true,
                          child: Text(context.t(checkError!)),
                        )
                      else if (available == null)
                        Semantics(
                          liveRegion: true,
                          child: Text(
                            context.t('updateCurrent', {
                              'version': installedVersion,
                            }),
                          ),
                        )
                      else ...[
                        Text(
                          context.t('updateAvailableVersion', {
                            'version': available!.version,
                          }),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          available!.description(
                            context.language,
                            context.t('updateNotesFallback'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        FilledButton.icon(
                          onPressed: busy ? null : update,
                          icon: const Icon(Icons.download_outlined),
                          label: Text(context.t('distributionUpdate')),
                        ),
                      ],
                      if (installing)
                        Semantics(liveRegion: true, child: Text(message())),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      Card(
        child: ExpansionTile(
          leading: const Icon(Icons.share_outlined),
          title: Text(context.t('distributionShare')),
          children: [
            ListTile(
              title: Text(
                context.t(
                  preparing ? 'distributionPreparing' : 'distributionInstaller',
                ),
              ),
              subtitle: Text(context.t('distributionShareHint')),
              trailing: preparing ? spinner() : const Icon(Icons.chevron_right),
              onTap: preparing ? null : share,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                context.t('distributionPrivacy'),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
