import 'package:flutter_riverpod/flutter_riverpod.dart';
// Note the extra '../' to go from the providers folder up to core
import '../database/database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError();
});