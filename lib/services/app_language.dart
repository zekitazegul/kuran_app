import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLanguage extends ValueNotifier<Locale?> {
  AppLanguage._() : super(null);
  static final instance = AppLanguage._();
  static const codes = ['tr', 'en', 'nl'];
  static const channel = MethodChannel('com.zekitazegul.kuranapp/reading');

  void restore(String? code) {
    if (codes.contains(code)) value = Locale(code!);
  }

  Future<void> change(String code) async {
    if (!codes.contains(code)) throw ArgumentError.value(code);
    await channel.invokeMethod<void>('setLanguage', {'language': code});
    value = Locale(code);
  }
}
