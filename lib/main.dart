import 'package:flutter/material.dart';
import 'screens/surah_screen.dart';

void main() {
runApp(const KuranApp());
}

class KuranApp extends StatelessWidget {
const KuranApp({super.key});

@override
Widget build(BuildContext context) {
return MaterialApp(
debugShowCheckedModeBanner: false,
title: 'Kuran App',
theme: ThemeData(
useMaterial3: true,
colorScheme: ColorScheme.fromSeed(
seedColor: Colors.green,
),
fontFamily: 'Arial',
),
home: const HomeScreen(),
);
}
}

class HomeScreen extends StatelessWidget {
const HomeScreen({super.key});

void _openYasin(BuildContext context) {
Navigator.push(
context,
MaterialPageRoute(
builder: (context) => const SurahScreen(
surahName: 'Yasin Suresi',
pageCount: 6,
),
),
);
}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text(
'Kuran App',
style: TextStyle(
fontWeight: FontWeight.bold,
),
),
centerTitle: true,
),
body: SafeArea(
child: Center(
child: SingleChildScrollView(
padding: const EdgeInsets.all(24),
child: ConstrainedBox(
constraints: const BoxConstraints(
maxWidth: 600,
),
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
const Icon(
Icons.menu_book,
size: 90,
),
const SizedBox(height: 24),
const Text(
'Kuran-ı Kerim',
textAlign: TextAlign.center,
style: TextStyle(
fontSize: 30,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 12),
const Text(
'Sureleri okumak için başlayın',
textAlign: TextAlign.center,
style: TextStyle(
fontSize: 18,
),
),
const SizedBox(height: 40),
Card(
elevation: 3,
child: Padding(
padding: const EdgeInsets.all(24),
child: Column(
children: [
const Icon(
Icons.auto_stories,
size: 50,
),
const SizedBox(height: 16),
const Text(
'Yasin Suresi',
style: TextStyle(
fontSize: 25,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 8),
const Text(
'83 Ayet • 6 Sayfa',
style: TextStyle(
fontSize: 16,
),
),
const SizedBox(height: 22),
SizedBox(
width: double.infinity,
child: FilledButton.icon(
onPressed: () => _openYasin(context),
icon: const Icon(
Icons.menu_book,
),
label: const Text(
'Yasin Suresini Oku',
),
),
),
],
),
),
),
],
),
),
),
),
),
);
}
}