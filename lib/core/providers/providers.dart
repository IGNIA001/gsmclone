import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../database/database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError();
});

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);