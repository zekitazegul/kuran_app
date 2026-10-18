import '../widgets/screen_title.dart';
import '../widgets/personal_page_scope.dart';
import 'package:flutter/material.dart';
import '../l10n/translations.dart';
import '../widgets/support_card.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: PersonalPageScope.of(context) != null ? null : AppBar(automaticallyImplyLeading: PersonalPageScope.of(context) == null, title: PersonalPageScope.of(context) == null ? ScreenTitle(context, context.t('Destek')) : null, actions: const <Widget>[]),
    body: ListView(padding: const EdgeInsets.all(24), children: const [
      SupportCard(),
    ]),
  );
}
